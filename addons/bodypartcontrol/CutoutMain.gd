@tool
## @experimental
## This plugin adds the following to the Editor:[br]
## - A custom node wich holds directions of the animation[br]
## and can change the editor cutout parts to ease the animation.[br]
## - A custom Sprite2D node wich holds ans process images for the cutout animation.[br]
## - A GUI for editing a AtlasTextures for each part and direction, similar to the SpriteFrames GUI.[br]
##[br]
## Demo:             https://github.com/Chafalleiro/cutout-plugin-demo
## @tutorial(Demo in Github): https://github.com/Chafalleiro/cutout-plugin-demo
## @tutorial(Video tutorial of Demo): https://www.youtube.com/watch?v=-J1b2HQX02E
## [br]
## It has the current classes.[br]
## Classes with usable nodes.[br]
## [BodyPartRoot][br]
## [BodyPartNode][br]
## [br]
## The following classes are listed as nodes but have no utility out of the plugin scripts.[br]
## They are declared only to be accesible by the help system and as resources.[br]
## [br]
## Resource classes.[br]
## [BodyPartNodeRes][br]
## [BodypartSpriteList][br]
## [br]
## Editor plugin classes.[br]
## [CutOutMain][br]
## [CutoutBottomPanelControl][br]
## [CutoutRootControl][br]
## [br]
## You first have to add a [BodyPartRoot] node to store the necesarry data.[br]
## After that add [BodyPartNode]s to store and use the sprites that holds the cutout parts.[br]
## In the Editor you can change the sprites using the Selection in the "Select Action" tab of the bottom panel used by [BodyPartRoot] ([CutoutRootControl]).[br]
## At runtime you can change the sets of sprites grouped by actions calling the methods in root and nodes.[br]
##
## Use [method BodyPartRoot.setNewSprites] to update all the nodes stored in nodes tab list.[br]
## Use [operator BodypartSpriteList.list_sprites.actAction] stored actions. You can chek them in the bottom panel of the root node.[br]
## [br]
## Usage:
## [codeblock]
## func some_function():
##     $Name_Of_[BodyPartRoot]_setNewSprites(ActionFromACtAction, index)
## [/codeblock]

extends EditorPlugin
class_name CutOutMain


##Text button for BodypartNode bottom panel show button.
var bottom_panel_button: Button
##Control for BodypartNode bottom panel.
var bottom_panel_control: Control
##Text button for BodypartRoot bottom panel show button.
var bottom_panel_root_button: Button
##Control for BodypartRoot bottom panel.
var bottom_panel_root_control: Control

##Vars to manipulate control nodes that hold resorces.
var root_cntrl: BodyPartRoot = null
##Vars to manipulate control nodes that hold resorces.
var node_cntrl: BodyPartNode = null
##Vars to manipulate control nodes that hold resorces.
var cntrl
##Vars to manipulate control nodes that hold resorces.
var btn
## Initialization of the plugin scenes, scripts and nodes goes here.
func _enter_tree():
	##@ I. Register the custom nodes for the plugin. Bodypart stores and processes the sprites, BodyPartRoot stores data about the animated body.
	add_custom_type("BodyPartNode", "Sprite2D", preload("bodyparts.gd"), preload("icon.png"))
	add_custom_type("BodyPartRoot", "Node", preload("bodyparts_root.gd"), preload("icon.png"))
	# II. Register the "Cutout parts" bottom panel.
	bottom_panel_control = preload("res://addons/bodypartcontrol/body_part_control.tscn").instantiate()
	bottom_panel_button = add_control_to_bottom_panel(bottom_panel_control, tr("Cutout textures"))
	# III. Register the Cutout list of parts and list of actions bottom panel.
	bottom_panel_root_control = preload("res://addons/bodypartcontrol/body_root_control.tscn").instantiate()
	bottom_panel_root_button = add_control_to_bottom_panel(bottom_panel_root_control, tr("Cutout lists"))
	
	# IV. Show/Hide panels depending on what's inspected in the Inspector.
	on_inspector_edited_object_changed()
	get_editor_interface().get_inspector().edited_object_changed.connect(
		on_inspector_edited_object_changed,
	)
	#self.set_disable_class_editor(CutOutMain, true)
	#set_disable_class(CutOutMain, true)

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Always remember to remove it from the engine when deactivated.
	remove_custom_type("BodyPartNode")
	remove_custom_type("BodyPartRoot")
	if get_editor_interface().get_inspector().edited_object_changed.is_connected(
		on_inspector_edited_object_changed,
	):
		get_editor_interface().get_inspector().edited_object_changed.disconnect(
			on_inspector_edited_object_changed,
		)
	
	remove_control_from_bottom_panel(bottom_panel_control)
	remove_control_from_bottom_panel(bottom_panel_root_control)
	bottom_panel_control.queue_free()
	bottom_panel_root_control.queue_free()

## Show or hide bottom panels.
func update_bottom_panel(ctrl, btn, obj_btm):
	if (obj_btm is BodyPartNode || obj_btm is BodyPartRoot):
		btn.visible = true
		btn.button_pressed = true
	else:
		if(not obj_btm is AtlasTexture):
			#print("NOT BodyPartNode ")
			self.bottom_panel_control.visible = false
			self.bottom_panel_button.visible = false
			self.bottom_panel_root_control.visible = false
			self.bottom_panel_root_button.visible = false
		return

##When a node is selected this func is called by the plugin.
func on_inspector_edited_object_changed():
	var edited_object := get_editor_interface().get_inspector().get_edited_object()
	root_cntrl = null
	
	if edited_object is BodyPartRoot:
		self.bottom_panel_control.visible = false
		self.bottom_panel_button.visible = false
		BodyRoot_control(edited_object)
	if edited_object == null:
		return  # same
	if edited_object is BodyPartNode:
		self.bottom_panel_root_control.visible = false
		self.bottom_panel_root_button.visible = false
		cntrl = self.bottom_panel_control
		btn = self.bottom_panel_button
		#HSplitContainer/MarginContainer/ActionCaontainer/Button
		BodyNode_control(edited_object)
	update_bottom_panel(cntrl, btn, edited_object)

##Manipulate the [BodyPartNode] and [CutoutBottomPanelControl].
func BodyNode_control(edited_object):
#Connect [CutoutBottomPanelControl] signals
	node_cntrl = edited_object as BodyPartNode
#	if cntrl.list_selected.is_connected(_node_actions_changed):
	if cntrl.refresh.is_connected(_node_changes):
#		cntrl.list_selected.disconnect(_node_actions_changed)
		cntrl.refresh.disconnect(_node_changes)
#		cntrl.texture_changed.disconnect(_node_text_changed)
#	cntrl.list_selected.connect(_node_actions_changed)
	cntrl.refresh.connect(_node_changes)
#	cntrl.texture_changed.connect(_node_text_changed)
	refresh_node_panel()

func _node_changes(anArr):
	match anArr[0]:
		"main":
			match anArr[1]:
				"rfrs":
					refresh_node_panel()
		"img":
			match anArr[1]:
				"sel":
					_node_actions_changed(anArr[2])
				"add":
					_node_tex_changed(anArr[2],anArr[3],anArr[4],anArr[1])
				"del":
					_node_tex_changed(anArr[2],anArr[3],anArr[0],anArr[1])
				"mod":
					_node_tex_changed(anArr[2],anArr[3],anArr[4],anArr[1])

	return
func refresh_node_panel():
	cntrl.clear_list(cntrl.get_node("%nodeActionList"))
	cntrl.clear_img_nodes()
	if node_cntrl.list_sprites:
		cntrl.populate_list(cntrl.get_node("%nodeActionList"),node_cntrl.list_sprites.actionDictionary.keys())
	return

##selectKey is the list item name selected, it correspond to a key in [member BodyPartNode.list_sprites.actionDictionary]
func _node_actions_changed(selectKey):
	cntrl.clear_img_nodes()
	cntrl.parseKeys(node_cntrl.list_sprites.actionDictionary[selectKey])
	
##Pass array and actions to edit dicionary.
func _node_tex_changed(key, ndx, dat, act):
	node_cntrl.AModiDel(key, ndx, dat, act)

## See body_root_control.gd or [CutoutRootControl]
##BodypartsRoot has a script associated and a signal, actions changed
##_root_actions_changed receives the var emited by the signal
##It's easier to make [BodyPartRoot] node the root of the "BodyPart" nodes
## You can also add [BodyPartNode] at other places to be used by the plugin scripts.
##If node is not in active list, we add to available nodes list.
##ATM we only need the names.
func BodyRoot_control(edited_object):
	root_cntrl = edited_object as BodyPartRoot
	cntrl = self.bottom_panel_root_control
	btn = self.bottom_panel_root_button

	##Connect to to signals in resources.
	if cntrl.refresh.is_connected(_root_panel_chg):
		cntrl.refresh.disconnect(_root_panel_chg)
	if root_cntrl.sprites_changed.is_connected(_root_actions_changed):
		root_cntrl.sprites_changed.disconnect(_root_actions_changed)
	#root_cntrl.sprites_changed.connect(_root_actions_changed)
	cntrl.refresh.connect(_root_panel_chg)

## Refresh root panel and data.
func _root_panel_chg(anArr):
	match anArr[0]:
		"node":
			match anArr[1]:
				"refr":
					root_cntrl.refreshNodes()
					_refresh(["%activeNodeList","%availNodeList",root_cntrl.list_sprites.activeNode,root_cntrl.list_sprites.availNode])
				"chng":
					_list_changed(anArr)
		"acti":
			match anArr[1]:
				"refr":
					_refresh(["%avaActionList","%actActionList",root_cntrl.list_sprites.avaAction,root_cntrl.list_sprites.actAction])
				"chng":
					_list_changed(anArr)
				"add":
					_list_mod(anArr)
				"del":
					_list_mod(anArr)
		"seac":
			match anArr[1]:
				"refr":
					_ref_skel(["%ActionOptions","%SkelPose"])
		"text":
			match anArr[1]:
				"refr":
					_ref_sel("%ActionOptFiles")
				"chng":
					_text_chng(anArr)
		"skel":
			if anArr[1] == "refr":
				_ref_skel(["%ActionSel","%SkelList"])
			else:
				_mod_skel(anArr)
		"pose":
				root_cntrl.skelRedraw([anArr[2][0],anArr[2][1],anArr[1]])
				root_cntrl.setNewSprites(anArr[2][1],anArr[2][2])
	self.root_cntrl.setActionsDict()
	return

##Change textures in nodes.
func _text_chng(arr):
	root_cntrl.setNewText(arr[2][0],arr[2][1],arr[2][2])

##Change root data from bottom panel.
func _list_changed(list_control):
	#Some lazy coding using the naming of nodes and resources
	var tmp = list_control[2].name.trim_suffix("List")
	#avaActionList
	var tmpArr = []
	for item in list_control[2].get_item_count():
		tmpArr.append(list_control[2].get_item_text(item))
	root_cntrl.clearArr(root_cntrl.list_sprites.get(tmp))
	root_cntrl.fillArray(tmpArr,root_cntrl.list_sprites.get(tmp))

	tmp = list_control[3].name.trim_suffix("List")
	tmpArr = []
	for item in list_control[3].get_item_count():
		tmpArr.append(list_control[3].get_item_text(item))
	self.root_cntrl.clearArr(root_cntrl.list_sprites.get(tmp))
	self.root_cntrl.fillArray(tmpArr,root_cntrl.list_sprites.get(tmp))
	self.root_cntrl.initPaths()

	if "Action" in list_control[2].name:
		self.cntrl.get_node("%ActionOptions").clear()
		self.cntrl.addActionList(root_cntrl.list_sprites.actAction)
	self.root_cntrl.saveRes()
	return

##Modify list in panel.
func _list_mod(list_control):
	var tmpArr = []
	var tmp = list_control[2].name.trim_suffix("List")
	for item in list_control[2].get_item_count():
		tmpArr.append(list_control[2].get_item_text(item))
	cntrl.populate_list(cntrl.get_node("%avaActionList"),root_cntrl.list_sprites.avaAction)

## Refresh actions selection in panel.
func _ref_sel(what):
	cntrl.clearSome([what])
	cntrl.populate_list(cntrl.get_node(what),root_cntrl.list_sprites.actAction)

## Refresh lists in panel.
func _refresh(arr):
	cntrl.clearSome([arr[0],arr[1]])
	cntrl.populate_list(cntrl.get_node(arr[0]),arr[2])
	cntrl.populate_list(cntrl.get_node(arr[1]),arr[3])

## Refresh skeletons in panel. Also refresh screenshots.
func _ref_skel(what):
	root_cntrl.getSkel()
	cntrl.clearSome(what)
	cntrl.populate_list(cntrl.get_node(what[0]),root_cntrl.list_sprites.actAction)
	cntrl.populate_list(cntrl.get_node(what[1]),root_cntrl.list_sprites.skelDictionary.keys())
	get_editor_interface().get_resource_filesystem().scan_sources()

## Mod skeletons in root. Also refresh screenshots.
func _mod_skel(arr):
	get_editor_interface().get_resource_filesystem().scan_sources()
	root_cntrl.skelRedraw([arr[2],arr[3],arr[1]])

##arr_actions receives the name of the array used in BodyPartRoot ListSprites resource.
func _root_actions_changed(actionsArr):
	cntrl.clear()
	cntrl.addActionList(actionsArr)
	root_cntrl.saveRes()
