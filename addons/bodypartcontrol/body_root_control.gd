@tool
extends Control
## This control is where the user can select wich nodes will be active when an action is called.
## Also we can name actions to group the sprites.
## Changes will be send to [CutoutMain]
##The var will be passed to CutoutMain.gd, the central script of the plugin.
## See Main Help [CutOutMain][br]
## @experimental
class_name CutoutRootControl
signal a_list_changed(a_value)

var itemsList = []
var selected_action = 0

##Clear all lists and menus.
func clear():
	%ActionOptions.clear()
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
## 
func _on_add_to_active_nodes_pressed() -> void:
	exItems(%availNodeList, %activeNodeList, %activeNodeList)
	retItems(%availNodeList)

func _on_add_to_avail_nodes_pressed() -> void:
	exItems(%activeNodeList, %availNodeList, %activeNodeList)
	retItems(%availNodeList)

func _on_move_to_avail_act_pressed() -> void:
	exItems(%actActionList, %avaActionList, %actActionList)
	retItems(%avaActionList)

func _on_move_to_act_act_pressed() -> void:
	exItems(%avaActionList, %actActionList, %actActionList)
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
	retItems(returnList)

##Report changes in returnList to the [CutoutMain] script.
func retItems(returnList):
	a_list_changed.emit(returnList)

func _on_add_act_btn_pressed() -> void:
	%AcceptDialog.show()

##Remove selected items and report changes in returnList to the [CutoutMain] script.
func _on_rem_act_btn_pressed() -> void:
	var tmp = %avaActionList.get_selected_items().size()
	for item in %avaActionList.get_selected_items():
		tmp -= 1
		%avaActionList.remove_item(%avaActionList.get_selected_items()[tmp])
	retItems(%avaActionList)

func _on_accept_actions_pressed() -> void:
	pass # Replace with function body.

func _on_but_actions_pressed() -> void:
	pass # Replace with function body.

##Add item and report changes in returnList to the [CutoutMain] script.
func _on_accept_dialog_confirmed() -> void:
	%avaActionList.add_item(%InputText.text)
	retItems(%avaActionList)


func _on_refresh_act_button_pressed() -> void:
	retItems(%avaActionList)
