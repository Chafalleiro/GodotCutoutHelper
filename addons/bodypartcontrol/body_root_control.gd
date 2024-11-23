@tool
extends Control
## This control is where the user can select wich nodes will be active when an action is called.
## Also we can name actions to group the sprites.
## Changes will be send to [CutoutMain]
##The var will be passed to CutoutMain.gd, the central script of the plugin.
## See Main Help [CutOutMain][br]
## @experimental
class_name CutoutRootControl
## Buttons, panels and lists emits signals, after precessed a signal is sent to [method CutOutMain.BodyRoot_control]
signal refresh(arr)

var itemsList = []
var selected_action = 0
var selected_file_action = 0
var selected_skeleton = 0

##Clear all lists and menus.
func clear():
	%ActionOptions.clear()
	%ActionOptFiles.clear()
	%availNodeList.clear()
	%activeNodeList.clear()
	%actActionList.clear()
	%avaActionList.clear()

func clearSome(wich):
	for w in wich:
		get_node(w).clear()

func addActionList(arr_actions):
	var index := 0
	var selected_index := 0
	for action in arr_actions:
		%ActionOptions.add_item(action)
		%ActionOptFiles.add_item(action)
		index += 1
	%ActionOptions.select(selected_index)
	%ActionOptions.item_selected.emit(selected_index)

func populate_list(list_name, list_items):
	var index := 0
	var selected_index := 0
	for list_item in list_items:
		list_name.add_item(list_item)
		selected_index = index
		index += 1

func _on_action_options_item_selected(index: int) -> void:
	selected_action = index
	var skel = %SkelPose.get_item_text(%SkelPose.get_selected())
	var act = %ActionOptions.get_item_text(%ActionOptions.get_selected())
	_skeletons_draw(act,skel,%PoseSel)

## 
func _on_add_to_active_nodes_pressed() -> void:
	exItems(%availNodeList, %activeNodeList, %activeNodeList)
	refresh.emit(["node","chng",%availNodeList, %activeNodeList])

func _on_add_to_avail_nodes_pressed() -> void:
	exItems(%activeNodeList, %availNodeList, %activeNodeList)
	refresh.emit(["node","chng",%availNodeList, %activeNodeList])

func _on_move_to_avail_act_pressed() -> void:
	exItems(%actActionList, %avaActionList, %actActionList)
	refresh.emit(["acti","chng",%avaActionList, %actActionList])

func _on_move_to_act_act_pressed() -> void:
	exItems(%avaActionList, %actActionList, %actActionList)
	refresh.emit(["acti","chng",%avaActionList, %actActionList])

func _on_refresh_act_button_pressed() -> void:
	retItems(%avaActionList)

##This function traverses the From list and moves selected items to the To list.
##We loop troght the array in reverse while deleting the last items.
##The return list is later traversed and we store its name and elements in an array passed by
##the spritelist_changed signal to the main script.
func exItems(itemsFrom, itemsTo, returnList):
	var tmp = itemsFrom.get_selected_items().size()
	for item in itemsFrom.get_selected_items():
		tmp -= 1
		itemsTo.add_item(itemsFrom.get_item_text(itemsFrom.get_selected_items()[tmp]))
		itemsFrom.remove_item(itemsFrom.get_selected_items()[tmp])

##Report changes in returnList to the [CutoutMain] script.
func retItems(returnList):
	refresh.emit(["list","chng",returnList])

func _on_add_act_btn_pressed() -> void:
	%AcceptDialog.show()

##Remove selected items and report changes in returnList to the [CutoutMain] script.
func _on_rem_act_btn_pressed() -> void:
	var tmp = %avaActionList.get_selected_items().size()
	for item in %avaActionList.get_selected_items():
		tmp -= 1
		%avaActionList.remove_item(%avaActionList.get_selected_items()[tmp])
#	refresh.emit(["acti","del",%avaActionList])
	refresh.emit(["acti","chng",%avaActionList, %actActionList])

##Add item and report changes in returnList to the [CutoutMain] script.
func _on_accept_dialog_confirmed() -> void:
	%avaActionList.add_item(%InputText.text)
	refresh.emit(["acti","chng",%avaActionList, %actActionList])

func _on_nodes_draw() -> void:
	refresh.emit(["node","refr"])

func _on_file_button_pressed() -> void:
	%FileDialog.show()

func _on_file_dialog_file_selected(path: String) -> void:
	%FileList.text = path

func _on_button_pressed() -> void:
	var emitted = [%ActionOptFiles.get_item_text(%ActionOptFiles.get_selected()), %ActionSprite.value, %FileList.text]
	if %FileList.text == "":
		%AlertFile.dialog_text = "File is empty. Please pick a valid image file."
		%AlertFile.show()
	else:
		var tex = AtlasTexture.new()
		tex.atlas = load(emitted[2])
		if tex.atlas && (tex.atlas is Texture2D):
			refresh.emit(["text","chng",emitted])
		else:
			%AlertFile.dialog_text = "File is not valid. Check if is a valid loaded resource or it's corrupt."
			%AlertFile.show()

func _on_modify_actions_draw() -> void:
	refresh.emit(["acti","refr"])

func _on_select_action_draw() -> void:
	refresh.emit(["seac","refr"])
	_on_skel_pose_item_selected(0)

func _on_textures_draw() -> void:
	refresh.emit(["text","refr"])

func _skeletons_draw(act,skel,place) -> void:
	place.texture = await load("res://addons/bodypartcontrol/tmpres/"+ skel + "_" + act + ".png")

func _on_skel_list_item_selected(index: int) -> void:
	var skel = %SkelList.get_item_text(%SkelList.get_selected())
	var act = %ActionSel.get_item_text(%ActionSel.get_selected())
	_skeletons_draw(act,skel,%SkelShot)

func _on_action_sel_item_selected(index: int) -> void:
	var skel = %SkelList.get_item_text(%SkelList.get_selected())
	var act = %ActionSel.get_item_text(%ActionSel.get_selected())
	_skeletons_draw(act,skel,%SkelShot)

## Save skeleton pose.
func _on_save_skel_pressed() -> void:
	var skel = %SkelList.get_item_text(%SkelList.get_selected())
	var act = %ActionSel.get_item_text(%ActionSel.get_selected())
	refresh.emit(["skel","save",skel,act])

## Load skeleton pose.
func _on_load_skel_pressed() -> void:
	var skel = %SkelList.get_item_text(%SkelList.get_selected())
	var act = %ActionSel.get_item_text(%ActionSel.get_selected())
	refresh.emit(["skel","load",skel,act])

func _on_skeletons_draw() -> void:
	refresh.emit(["skel","refr"])
	_on_action_sel_item_selected(0)

func _on_skel_pose_item_selected(index: int) -> void:
	var skel = %SkelPose.get_item_text(%SkelPose.get_selected())
	var act = %ActionOptions.get_item_text(%ActionOptions.get_selected())
	_skeletons_draw(act,skel,%PoseSel)

##Change pose and sprite set in editor view.
func _on_but_actions_pressed() -> void:
	var skel = %SkelPose.get_item_text(%SkelPose.get_selected())
	var act = %ActionOptions.get_item_text(%ActionOptions.get_selected())
	var val = %TextSet.value
	refresh.emit(["pose","load",[skel,act,val]])
