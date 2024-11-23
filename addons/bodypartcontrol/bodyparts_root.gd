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
	printt("My list sprites just changed in root!", what)
	sprites_changed.emit(what)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not list_sprites:
		warnings.append("There is not a List Sprites resource.\n Please create one BodypartSpriteList in the Inspector Panel")
	elif list_sprites.listSprite.size() == 0:
		warnings.append("There is no BodyPartNode detected.\n Please create one BodyPartNode or refresh the list.")
	return warnings

func _on_resource_set():
	if list_sprites == null:
		print("My resource ROOT was SET!")
	else:
		print("My resource ROOT was CLEARED!")
	update_configuration_warnings()

## Called when the node enters the scene tree for the first time.[br]
## It's called when the program is run or compiled. Since Paths are different in editor and run environment, a function is called here to sstore them in separate arrays.
func _ready() -> void:
	if list_sprites:
		list_sprites = await loadRes("res://cutouts/"+ self.name + ".res")
		if list_sprites.runningNodePaths.size() == 0:
			initPaths()
		update_configuration_warnings()
	else:
		printt("list_sprites doesn't exist")
		list_sprites = BodypartSpriteList.new()
		initArrays()
		saveRes()
		update_configuration_warnings()

## Clear the array determined by the function parameter.
func clearArr(resourceArr):
	resourceArr.clear()

## Append destArray elements from passedArray
func fillArray(passedArray,destArray):
	for ele in passedArray:
		destArray.append(ele)

## Save the resorce to file. The file is named after the node using [BodypartSpriteList] resource.
func saveRes():
	print("Saving Root!")
	var path = "res://cutouts/"
	var dir = DirAccess.make_dir_absolute(path)
	if not dir:
		print("Creaint DIR Root!")
		dir = DirAccess.make_dir_absolute(path)
		
	var fileName = "res://cutouts/"+ self.name + ".res"
	var result = ResourceSaver.save(list_sprites, fileName)
	assert(result == OK)
	return

## Load the resorce from file.
func loadRes(file_name):
	print("Loading Root!")
	if ResourceLoader.exists(file_name):
		var res_list_sprites = ResourceLoader.load(file_name)
		if res_list_sprites is BodypartSpriteList: # Check that the data is valid
			return res_list_sprites
	else:
		printt("File ",file_name, "doesn't exist.")
		var ret = "FOE"
		return ret

#NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES#
#NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES#

## Create an array of references of the active [BodyPartNode] paths. See first tab of
## Paths are different in Editor or when running the game.
## When the game is ran we store the paths from.
func initPaths():
	var tArr = getAllNodes("paths")
	var mTmp = []
	for el in tArr:
		if list_sprites.activeNode.has(get_node(el).name):
			mTmp.append(el)
	tArr = mTmp
	if Engine.is_editor_hint():##Running in the Editor
		clearArr(list_sprites.editorNodePaths)
		fillArray(tArr,list_sprites.editorNodePaths)
		return
	if not Engine.is_editor_hint():##Running outside the Editor
		clearArr(list_sprites.runningNodePaths)
		fillArray(tArr,list_sprites.runningNodePaths)
		saveRes()
		return

## Initialize and save the arrays in [BodypartSpriteList] with defaults.
func initArrays():
	var tArr = []
	for child in self.get_children():
		if child is BodyPartNode:
			tArr.append(child.name)
	if list_sprites.activeNode.size() == 0:
		fillArray(tArr,list_sprites.activeNode)
	#Get uppermost parent thet is a Node2D
	tArr = getAllNodes("names")
	if list_sprites.listSprite.size() == 0:
		fillArray(tArr,list_sprites.listSprite)
	var mTmp = []
	for ele in tArr:
		if not list_sprites.activeNode.has(ele):
			mTmp.append(ele)
	tArr = mTmp
	if list_sprites.availNode.size() == 0:
		fillArray(tArr,list_sprites.availNode)
	if list_sprites.editorNodePaths.size() == 0:
		initPaths()
	getSkel()
	update_configuration_warnings()

## Refresh list of nodes used by plugin. BodyPartNode and skeletons are stored.
## Saves the resource.
func refreshNodes():
#Get all the BodypartNode names
	var tArr = getAllNodes("nodes")
	var tArrAll = tArr
#Trim existent node names in avail list
	tArr = trimExNode(tArr, list_sprites.availNode)
#Trim existent node names in active list
	tArr = trimExNode(tArr, list_sprites.activeNode)

	if tArr.size() != 0:
		for el in tArr:
			print("New nodes found!")# Then we add the new nodes.
			list_sprites.listSprite.append(el.name)
			setActionsDict()
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
	getSkel()
	initPaths()
	saveRes()
	update_configuration_warnings()
	return

## Traverse nodes of this scene, return values as arrays of nodes, paths, names or skeleton nodes.
## Keywords are "skel", "names", "paths" and "nodes".
func getAllNodes(sw):
	var tArr = []
	if sw == "skel":
		tArr = getSkel()
	else:
		for el in self.owner.find_children("*","BodyPartNode"):
			match sw:
				"names":
					tArr.append(el.name)
				"paths":
					tArr.append(el.get_path())
				"nodes":
					tArr.append(el)	
	return tArr

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

#NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES#
#NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES##NODES#

#ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS#
#ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS#

##Check if Dictionary has some available (inactive)actions. If yes, erase the inactive from the dictionary.
##Check if Dictionary has all active actions. If not, add the non existing ones with default values.
func setActionsDict():
	for cutOut in list_sprites.editorNodePaths:
		for act in list_sprites.avaAction:
			if get_node(cutOut).list_sprites.actionDictionary.has(act):
				get_node(cutOut).list_sprites.actionDictionary.erase(act)
		if not get_node(cutOut).list_sprites.actionDictionary.has_all(list_sprites.actAction):
			for act in list_sprites.actAction:
				get_node(cutOut).list_sprites.actionDictionary.get_or_add(act, [[get_node(cutOut).texture.atlas.resource_path,get_node(cutOut).texture.region]])
		get_node(cutOut).saveRes()
	return
#ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS#
#ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS##ACTIONS#

## The fuction just changes the stored texture path, the other info stored is kept as is.
## if specified it will change the textures of all action in dictionary.
func setNewText(dir, ndx, tex):
	var arrTmp
	if Engine.is_editor_hint():##Running in the Editor
		arrTmp = list_sprites.editorNodePaths
	else:
		arrTmp = list_sprites.runningNodePaths
	for nod in arrTmp:
		get_node(nod).chng_text(dir, ndx, tex)
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

## Check for skeletons, the skeleton node name will be the key of a dictionary.
## The skeleton key will have a dictionary wich keys are the active actions.
## Each key will have an array, each element of wich is filled with a bone name, position and rotation.
func getSkel():
	var skelArr = []
	var boneArr = []
	for el in self.owner.find_children("*","Skeleton2D"):
		skelArr.append(el)
		boneArr = []
		self.list_sprites.skelDictionary.get_or_add(el.name,{})
		for ndx in el.get_bone_count():
			boneArr.append([el.get_bone(ndx).name,el.get_bone(ndx).position,el.get_bone(ndx).rotation])
		for act in list_sprites.avaAction:
			if self.list_sprites.skelDictionary[el.name].has(act):
				self.list_sprites.skelDictionary[el.name].erase(act)
		for act in list_sprites.actAction:
			self.list_sprites.skelDictionary[el.name].get_or_add(act,boneArr)
			var file = "res://addons/bodypartcontrol/tmpres/" + el.name + "_" + act +".png"
			if not ResourceLoader.exists(file):
				screennie("res://addons/bodypartcontrol/tmpres/", el.name + "_" + act)
	saveRes()
	return skelArr

## Take a screenshot of the editor screen of this scene, crop and save it.
## Origin of the image is at the center of this node, the size of the image is loaded from list_sprites.zone.
func screennie(path, nam):
	list_sprites.zone = Rect2(self.get_viewport_transform().origin[0]-115, self.get_viewport_transform().origin[1]-260, 234, 436)
	var screenshot = self.owner.get_viewport().get_texture().get_image().get_region(list_sprites.zone)
	screenshot.save_png(path+nam+".png")

##Add, modify or delete keys and values.
func AModiDel(dict, key, ndx, dat, op):
	match op:
		"add":
			dict[key].append(dat)
		"del":
			dict[key].remove_at(int(ndx))
		"mod":
			dict[key][int(ndx)] = dat
	saveRes()
	return

## Load a saved skeleton pose, or save one.
## After saving the pose, a screenshot will be made, sometime the import refreses a bit late.
## The resorce file is saved after making the screenshot.
func skelRedraw(arr):
	var tmpArr = self.list_sprites.skelDictionary[arr[0]][arr[1]]
	var skel = self.owner.get_node(arr[0])
	match arr[2]:
		"load":
			var arrNames = []
			for ndx in skel.get_bone_count():
				arrNames.append(skel.get_bone(ndx).name)
			for ndx in self.owner.get_node(arr[0]).get_bone_count():
				if arrNames.has(tmpArr[ndx][0]):
					skel.get_bone(ndx).set_position(tmpArr[ndx][1])
					skel.get_bone(ndx).set_rotation(tmpArr[ndx][2])
				else:
					printt("Non existant bone", tmpArr[ndx][0])
		"save":
			tmpArr.clear()
			for ndx in skel.get_bone_count():
				tmpArr.append([skel.get_bone(ndx).name, skel.get_bone(ndx).position, skel.get_bone(ndx).rotation])
			await screennie("res://addons/bodypartcontrol/tmpres/", arr[0] + "_" + arr[1])
			saveRes()
