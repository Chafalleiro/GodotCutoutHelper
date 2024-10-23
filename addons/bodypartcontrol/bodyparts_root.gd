@tool
extends Node2D
## @experimental
##Class to manage sprites information of [BodyPartNode]
## See also [CutOutMain][br]
class_name BodyPartRoot

##The var will be pass to [CutOutMain].gd, the central script of the plugin.
##This signal sends which array was changed in [BodypartSpriteList].
signal sprites_changed(a_value)
signal nodes_changed(a_value,b_value)

##Load the resource [BodypartSpriteList] that stores Actions, node names and node paths.
##A signal is triggered with every change in the arrays.
##It's used in [CutOutMain] to transfer info between the resource and the control panel [CutoutBottomPanelControl].
@export var list_sprites: BodypartSpriteList:
	set(new_resource):
		# Disconnect the signal if the previous resource was not null.
		_on_resource_set()
		if list_sprites != null:
			list_sprites.changed.disconnect(_on_resource_changed)
		list_sprites = new_resource
		list_sprites.changed.connect(_on_resource_changed)
		update_configuration_warnings()

func _on_resource_changed(what):
	print("My list sprites just changed in node!")
	print(list_sprites.get(what))
	sprites_changed.emit(what)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not list_sprites:
		warnings.append("There is not a List Sprites resource.\n Please create one BodypartSpriteList in the Inspector Panel")
	return warnings

func _on_resource_set():
	if list_sprites == null:
		print("My resource ROOT was SET!")
	else:
		print("My resource ROOT was CLEARED!")

## Called when the node enters the scene tree for the first time.[br]
## It's called when the program is run or compiled. Since Paths are different in editor and run environment, a function is called here to sstore them in separate arrays.
func _ready() -> void:
	if (list_sprites.runningNodePaths.size() == 0) || (list_sprites.runningNodePaths.size() != list_sprites.editorNodePaths.size()):
	#if self.list_sprites.runningNodePaths.size() == 0:
		list_sprites = loadRes("user://"+ self.name + ".res")
		initPaths(list_sprites.activeNode)
		saveRes()

## Clear the array determined by the function parameter.
func clearArr(resourceArr):
	resourceArr.clear()

## Append destArray elements from passedArray
func fillArray(passedArray,destArray):
	for ele in passedArray:
		destArray.append(ele)

## Save the resorce to file. The file is named after the node using [BodypartSpriteList] resource.
func saveRes():
	var fileName = "user://"+ self.name + ".res"
	print("SAVED " + fileName)
	var result = ResourceSaver.save(list_sprites, fileName)
	assert(result == OK)
	return
## Load the resorce from file.
func loadRes(file_name):
	if ResourceLoader.exists(file_name):
		var res_list_sprites = ResourceLoader.load(file_name)
		if res_list_sprites is BodypartSpriteList: # Check that the data is valid
			return res_list_sprites

## Create an array of references of the active [BodyPartNode] paths. See first tab of
## Paths are different in Editor or when running the game.
## When the game is ran we store the paths from.
func initPaths(nodes):
	var tArr = getAllNodes("paths")
	var mTmp = []
	for el in tArr:
		if list_sprites.activeNode.has(get_node(el).name):
			mTmp.append(el)
	tArr = mTmp
	if Engine.is_editor_hint():##Running in the Editor
	#list_sprites.SpriteList.append(child.name)
		clearArr(list_sprites.editorNodePaths)
		fillArray(tArr,list_sprites.editorNodePaths)
		return
	if not Engine.is_editor_hint():##Running outside the Editor
		clearArr(list_sprites.runningNodePaths)
		fillArray(tArr,list_sprites.runningNodePaths)
		return

## Initialize and save the arrays in [BodypartSpriteList] with defaults.
func initArrays():
	var tArr = []
	var tmp = self.get_parent()
	var tmpAnt = self.get_parent()
	for child in self.get_children():
		if child is BodyPartNode:
			tArr.append(child.name)

	if list_sprites.listSprite.size() == 0:
		fillArray(tArr,list_sprites.listSprite)
	if list_sprites.activeNode.size() == 0:
		fillArray(tArr,list_sprites.activeNode)

	#Get uppermost parent thet is a Node2D
	tArr = getAllNodes("names")
	var mTmp = []
	for ele in tArr:
		if not list_sprites.activeNode.has(ele):
			mTmp.append(ele)
	tArr = mTmp

#	tArr = mTmptrimEx(tArr, list_sprites.activeNode)
	if list_sprites.availNode.size() == 0:
		fillArray(tArr,list_sprites.availNode)
	if list_sprites.editorNodePaths.size() == 0:
		initPaths(list_sprites.activeNode)
	saveRes()

##Check if Dictionary has some available (inactive)actions. If yes, erase the inactive from the dictionary.
##Check if Dictionary has all active actions. If not, add the non existing ones with default values.
func setActionsDict():
	for cutOut in list_sprites.editorNodePaths:
		for act in list_sprites.avaAction:
			if get_node(cutOut).list_sprites.actionDictionary.has(act):
				get_node(cutOut).list_sprites.actionDictionary.erase(act)
		if not get_node(cutOut).list_sprites.actionDictionary.has_all(list_sprites.actAction):
			for act in list_sprites.actAction:
				get_node(cutOut).list_sprites.actionDictionary.get_or_add(act, [["res://addons/bodypartcontrol/icons/vga_64.png",Rect2(1,0,63,60)],["res://addons/bodypartcontrol/icons/favicon_yel.png",Rect2(1,0,63,60)]])
	return

## The fuction just changes the stored texture path, the other info stored is kept as is.
## if specified it will change the textures of all action in dictionary.
func setNewText(dir, ndx, tex):
	return
##Select wich kind of nodepath will be used to access the nodes. Than call tha change sprite routine.
func setNewSprites(dir,ndx):
	var arrTmp
	if Engine.is_editor_hint():##Running in the Editor
		arrTmp = list_sprites.editorNodePaths
	else:
		arrTmp = list_sprites.runningNodePaths
	for nod in arrTmp:
		get_node(nod).chng_sprt(dir,ndx)

##Trim elements of arr that already are in com and
##Return the trimmed array.
func trimExNode(arr, com):
	var mTmp: Array[Node]
	for ele in arr:
		if not com.has(ele.name):
			mTmp.append(ele)
	return mTmp

##Trim elements of arr that aren't in com.
##Return the trimmed array.
func trimNotNode(arr, com):
#tArr = trimNotNode(list_sprites.activeNode, tArrAll)	
	var mTmp: Array
	for ele in arr:
		if com.has(ele):
			mTmp.append(ele)
	return mTmp

func refreshNodes():
	var tArr = getAllNodes("nodes")
	#tArr = getAllNodes("nodes")
	var tArrAll = tArr
#Get all the BodypartNode names
#Trim existent node names in avail list
	tArr = trimExNode(tArr, list_sprites.availNode)
#Trim existent node names in active list
	tArr = trimExNode(tArr, list_sprites.activeNode)

	if tArr.size() != 0:
		for el in tArr:
			print("New nodes found!")# Then we add the new nodes.
			if el.get_parent() == self:
				list_sprites.activeNode.append(el.name)
			else:
				list_sprites.availNode.append(el.name)
	else:
		print("NO new nodes found!")
		tArr = getAllNodes("names")
		tArrAll = tArr
		tArr = trimNotNode(list_sprites.activeNode, tArr)
		clearArr(list_sprites.activeNode)
		fillArray(tArr,list_sprites.activeNode)
		tArr = trimNotNode(list_sprites.availNode, tArrAll)
		clearArr(list_sprites.availNode)
		fillArray(tArr,list_sprites.availNode)
	saveRes()
	return

func getAllNodes(sw):
	var tArr = []
	var tmp = self.get_parent()
	var tmpAnt = self.get_parent()
	while tmp is Node2D:
		tmpAnt=tmp
		tmp = tmp.get_parent()
	for el in tmpAnt.find_children("*","BodyPartNode"):
		match sw:
			"names":
				tArr.append(el.name)
			"paths":
				tArr.append(el.get_path())
			"nodes":
				tArr.append(el)
	return tArr
