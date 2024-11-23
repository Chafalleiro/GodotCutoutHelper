@tool
## Class for controlling the Bottom panel of cutout sprites
## @experimental
## See Main Help [CutOutMain][br]

extends Control

class_name CutoutBottomPanelControl

## Signal to notyfy that some button has been pressed.[br] 
## Argument carries the name of the node.
signal a_button_pressed(a_value)
signal list_selected(a_value)
signal texture_changed(key, ndx, dat, op)
signal refresh(arr)

var cnt_img = 0
var cur_img = 0
var op = "add"

##Clear list
func clear_list(wich):
	wich.clear()

##Clear sprites.
func clear_img_nodes():
	for child in %TexturesContainer.get_children():
		child.queue_free()

##Populate itemlist
func populate_list(list_name, list_items):
	var index := 0
	var selected_index := 0
	for list_item in list_items:
		list_name.add_item(list_item)
		selected_index = index
		index += 1

##Add sprites from dictionary [BodyPartNodeRes].
func parseKeys(arr: Array):
	for ndx in arr.size():
		createButton(ndx, arr[ndx])

## Create buttons.
func createButton(ndx, values: Array):
	var button = TextureButton.new()
	var atlas_texture = AtlasTexture.new()
	var str = values[0]
	atlas_texture.atlas = load(values[0])
	atlas_texture.region = values[1]
	button.set_texture_normal(atlas_texture)
	button.set_custom_minimum_size(Vector2(72,72))

	button.set_ignore_texture_size(true)
	button.set_stretch_mode(4)

	button.set_toggle_mode(true)

	button.name = %nodeActionList.get_item_text(%nodeActionList.get_selected_items()[0])
	atlas_texture.resource_name = str(ndx)
	button.tooltip_text = %nodeActionList.get_item_text(%nodeActionList.get_selected_items()[0])

	button.button_down.connect(_button_pressed.bind(atlas_texture,button))
	button.button_up.connect(_button_unpress.bind(atlas_texture,button))
	button.mouse_entered.connect(_button_hover.bind(atlas_texture,button))
	button.mouse_exited.connect(_button_out.bind(atlas_texture,button))

	atlas_texture.changed.connect(_on_resource_changed.bind(atlas_texture))

	if not EditorInterface.get_inspector().property_edited.is_connected(on_inspector_property_edited):
		EditorInterface.get_inspector().property_edited.connect(on_inspector_property_edited)
		EditorInterface.get_inspector().edited_object_changed.connect(on_inspector_edited_object_changed)
		EditorInterface.get_inspector().property_selected.connect(on_inspector_property_selected)
		EditorInterface.get_inspector().resource_selected.connect(on_inspector_resource_selected)

	button.set_modulate(Color(0.7,0.7,0.7,1))
	%TexturesContainer.add_child(button)
	return ndx

func _button_pressed(textu,obj):
	EditorInterface.edit_resource(textu)
	for child in %TexturesContainer.get_children():
		if child == obj:
			obj.set_modulate(Color(1.2,1.2,1.2,1))
		else:
			child.set_modulate(Color(0.7,0.7,0.7,1))
			child.set_pressed(false)

func _button_unpress(textu,obj):
	obj.set_pressed(true)

func _button_hover(textu,obj):
	if not obj.is_pressed():
		obj.set_modulate(Color(0.9,0.9,0.9,1))

func _button_out(textu,obj):
	if not obj.is_pressed():
		obj.set_modulate(Color(0.7,0.7,0.7,1))

func _on_add_image_pressed() -> void:
	setTexture("strVar")

func _on_delete_image_pressed() -> void:
	for child in %TexturesContainer.get_children():
		if child.is_pressed():
#			print(%nodeActionList.get_item_text(%nodeActionList.get_selected_items()[0]))
			child.queue_free()
			refresh.emit(["img","del",child.tooltip_text, child.texture_normal.resource_name])

func _on_node_action_list_item_selected(index: int) -> void:
	refresh.emit(["img","sel",%nodeActionList.get_item_text(index)])

func on_inspector_edited_object_changed() -> void:
	#print("Woks at clicling button")
	pass

func on_inspector_property_selected(prop):
	print("on_inspector_property_selected")
	
func on_inspector_resource_selected():
	print("on_inspector_resource_selected")

func on_inspector_multiple_properties_changed():
	print("on_inspector_multiple_properties_changed")

func on_inspector_property_edited(prop):
	var edited_object = EditorInterface.get_inspector().get_edited_object()
	if edited_object is AtlasTexture:
		refresh.emit(["img","mod",
		%nodeActionList.get_item_text(%nodeActionList.get_selected_items()[0]),
		edited_object.resource_name,
		[edited_object.atlas.resource_path, edited_object.region]
		])

func _on_resource_changed(what):
	var edited_object = EditorInterface.get_inspector().get_edited_object()

	refresh.emit(["img","mod",
	%nodeActionList.get_item_text(%nodeActionList.get_selected_items()[0]),
	what.resource_name,
	[what.atlas.resource_path, what.region]
	])

##Add sprites.
func setTexture(strVar):
	var atlas_texture = AtlasTexture.new()
	EditorInterface.edit_resource(atlas_texture)
	atlas_texture.atlas = load("res://addons/bodypartcontrol/icons/favicon_red.png")
	var arr = [atlas_texture.atlas.resource_path, atlas_texture.region]
	var ndx  = await createButton(%TexturesContainer.get_children().size(), arr)
	texture_changed.emit(%nodeActionList.get_item_text(%nodeActionList.get_selected_items()[0]), ndx, arr, "add")
	refresh.emit(["img","add",%nodeActionList.get_item_text(%nodeActionList.get_selected_items()[0]), ndx, arr])
	return atlas_texture

func _on_h_split_container_draw() -> void:
	refresh.emit(["main","rfrs"])
