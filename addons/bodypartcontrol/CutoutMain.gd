@tool
## @experimental
## This plugin adds the following to the Editor:[br]
## - A custom node wich holds directions of the animation[br]
## and can change the editor cutout parts to ease the animation.[br]
## - A custom Sprite2D node wich holds ans process images for the cutout animation.[br]
## - A GUI for editing a AtlasTextures for each part and direction, similar to the SpriteFrames GUI.[br]
##
## @Demo:             https://github.com/Chafalleiro/cutout-plugin-demo
## @tutorial(Tutorial 2): https://example.com/tutorial_2
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
var node_cntrl: BodyPartNode = null
var cntrl
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
	if root_cntrl.sprites_changed.is_connected(_root_actions_changed):
		root_cntrl.sprites_changed.disconnect(_root_actions_changed)
		##Also check body_root_control scene for signals there
		cntrl.get_node("%ButActions").pressed.disconnect(self._act_button_pressed)
		cntrl.get_node("%RefresButton").pressed.disconnect(self._ref_button_pressed)
		cntrl.a_list_changed.disconnect(self._list_changed)
	cntrl.get_node("%ButActions").pressed.connect(self._act_button_pressed)
	cntrl.a_list_changed.connect(self._list_changed)
	root_cntrl.sprites_changed.connect(self._root_actions_changed)
	cntrl.get_node("%RefresButton").pressed.connect(self._ref_button_pressed)	

	##Fill lists of actions in bottom panel.
	cntrl.clear()
	cntrl.populate_list(cntrl.get_node("%actActionList"),root_cntrl.list_sprites.actAction)
	cntrl.populate_list(cntrl.get_node("%avaActionList"),root_cntrl.list_sprites.avaAction)
	cntrl.addActionList(root_cntrl.list_sprites.actAction)
	
	#Get children of this BodyRootNode to fill the Active array if empty.
	#A temporal array
	
	if root_cntrl.list_sprites.listSprite == null || root_cntrl.list_sprites.listSprite.size() == 0:
		root_cntrl.initArrays()
		cntrl.populate_list(cntrl.get_node("%activeNodeList"),root_cntrl.list_sprites.activeNode)
		cntrl.populate_list(cntrl.get_node("%availNodeList"),root_cntrl.list_sprites.availNode)
		root_cntrl.saveRes()
	else:
		_ref_button_pressed()

##Manipulate the [BodyPartNode] and [CutoutBottomPanelControl].
func BodyNode_control(edited_object):
#Connect [CutoutBottomPanelControl] signals
	node_cntrl = edited_object as BodyPartNode
	if cntrl.list_selected.is_connected(_node_actions_changed):
		cntrl.list_selected.disconnect(_node_actions_changed)
		cntrl.texture_changed.disconnect(_node_text_changed)
	cntrl.list_selected.connect(_node_actions_changed)
	cntrl.texture_changed.connect(_node_text_changed)

	cntrl.clear_list(cntrl.get_node("%nodeActionList"))
	cntrl.clear_img_nodes()
	if node_cntrl.list_sprites:
		cntrl.populate_list(cntrl.get_node("%nodeActionList"),node_cntrl.list_sprites.actionDictionary.keys())

##arr_actions receives the name of the array used in BodyPartRoot ListSprites resource.
func _root_actions_changed(actionsArr):
	cntrl.clear()
	cntrl.addActionList(actionsArr)
	root_cntrl.saveRes()

##selectKey is the list item name selected, it correspond to a key in [member BodyPartNode.list_sprites.actionDictionary]
func _node_actions_changed(selectKey):
	cntrl.clear_img_nodes()
	cntrl.parseKeys(node_cntrl.list_sprites.actionDictionary[selectKey])
	
##Pass array and actions to edit dicionary.
func _node_text_changed(key, ndx, dat, act):
	node_cntrl.AModiDel(key, ndx, dat, act)

##Action pressed, change nodes in Editor.
func _act_button_pressed():
	root_cntrl.setNewSprites(cntrl.get_node("%ActionOptions").get_item_text(cntrl.get_node("%ActionOptions").get_selected_id()),0)

##list_control receives the list used in body_root_control(bottom panel).
func _list_changed(list_control):
	print("_list_changed(list_control):")
	#Some lazy coding using the naming of nodes and resources
	var tmp = list_control.name.trim_suffix("List")
	#avaActionList
	var tmpArr = []
	for item in list_control.get_item_count():
		tmpArr.append(list_control.get_item_text(item))
	root_cntrl.clearArr(root_cntrl.list_sprites.get(tmp))
	root_cntrl.fillArray(tmpArr,root_cntrl.list_sprites.get(tmp))
	root_cntrl.initPaths(root_cntrl.list_sprites.activeNode)
	
	if "Action" in list_control.name:
		cntrl.get_node("%ActionOptions").clear()
		cntrl.addActionList(root_cntrl.list_sprites.actAction)
		root_cntrl.setActionsDict()
	root_cntrl.saveRes()
	return
func _ref_button_pressed():
	root_cntrl.refreshNodes()
	cntrl.clearSome(["%activeNodeList","%availNodeList"])
	cntrl.populate_list(cntrl.get_node("%activeNodeList"),root_cntrl.list_sprites.activeNode)
	cntrl.populate_list(cntrl.get_node("%availNodeList"),root_cntrl.list_sprites.availNode)

func _ref_node_act_pressed():
	print("_ref_node_act_pressed")
	cntrl.clear_list(cntrl.get_node("%nodeActionList"))
	cntrl.clear_img_nodes()
	cntrl.populate_list(cntrl.get_node("%nodeActionList"),node_cntrl.list_sprites.actionDictionary.keys())
