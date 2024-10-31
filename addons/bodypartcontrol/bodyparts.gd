@tool
extends Sprite2D
## Class for controlling BodyPart sprites
## See Main Help [CutOutMain][br]
## @experimental
class_name BodyPartNode
signal sprites_changed(a_value)

##Class for controlling BodyPart sprites
@export var list_sprites: BodyPartNodeRes:
	set(new_resource):
		# Disconnect the signal if the previous resource was not null.
		_on_resource_set()
		if list_sprites != null:
			list_sprites.changed.disconnect(_on_resource_changed)
		list_sprites = new_resource
		list_sprites.changed.connect(_on_resource_changed)
		if Engine.is_editor_hint():
			update_configuration_warnings()

func _on_resource_changed(what):
	if Engine.is_editor_hint():
		print("My Dictionary just changed in a bodyparts node!")
		print(what)
		sprites_changed.emit(what)
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not list_sprites:
		warnings.append("There is not a List Sprites resource.\n Please create one BodyPartNodeRes in the Inspector Panel")
	elif list_sprites.actionDictionary.size() == 0:
		warnings.append("There is not Actions in dictionary.\n Please refresh in the body root bottom panel")
	return warnings
## This will only be called when you create, delete, or paste a resource.
## You will not get an update when tweaking properties of it.
func _on_resource_set():
	print("My resource was set!")
	update_configuration_warnings()

var spritesheet
var arrFiles = []
var files = []
var directories = []

func _ready() -> void:
	var file_name = "user://"+ self.get_parent().name +"_" + self.name + ".res"
	list_sprites = loadRes(file_name)

## Save the resorce to file. The file is named after the node using [BodypartSpriteList] resource.
func saveRes():
	var fileName = "user://"+ self.get_parent().name +"_" + self.name + ".res"
	var result = ResourceSaver.save(list_sprites, fileName)
	assert(result == OK)
	return
## Load the resorce from file.
func loadRes(file_name):
	if ResourceLoader.exists(file_name):
		var res_list_sprites = ResourceLoader.load(file_name)
		if res_list_sprites is BodyPartNodeRes: # Check that the data is valid
			return res_list_sprites


## The fuction just changes the stored texture path, the other info stored is kept as is.
## if specified it will change the textures of all action in dictionary.
func chng_text(dir, ndx, tex):
	if dir == "current":
		if list_sprites.currentAction == "":
			dir = "Side"
		dir = list_sprites.currentAction
	var atlas_texture = AtlasTexture.new()
	var tmp = self.list_sprites.actionDictionary[dir]
	if ndx >= tmp.size():
		AModiDel(dir, ndx, [tex, tmp[tmp.size() - 1][1]], "add")
	else:
		AModiDel(dir, ndx, [tex, tmp[ndx][1]], "mod")
	atlas_texture.atlas = load(tex)
	return

## This function changes the texture of the node based on the first Action stored in [operator list_sprites.actionDictionary]
## dir stores tha Key of the dictionary, ndx stores the index of the stored values to access.
func chng_sprt(dir,ndx):
	if dir == "current":
		if list_sprites.currentAction == "":
			dir = "Side"
		dir = list_sprites.currentAction
	else:
		list_sprites.currentAction = dir
	var atlas_texture = AtlasTexture.new()
	var tmp = self.list_sprites.actionDictionary[dir]

	atlas_texture.atlas = load(tmp[ndx][0])
	atlas_texture.region = tmp[ndx][1]
	#Recursively change sprites in children nodes.
	if self.get_children():
		for child in self.get_children():
			if (child is BodyPartNode) and not child.is_queued_for_deletion():
				child.chng_sprt(dir,ndx)
	self.texture = atlas_texture

##Add, modify or delete keys and values.
func AModiDel(key, ndx, dat, op):
	match op:
		"add":
			self.list_sprites.actionDictionary[key].append(dat)
		"del":
			self.list_sprites.actionDictionary[key].remove_at(int(ndx))
		"mod":
			self.list_sprites.actionDictionary[key][int(ndx)] = dat
	saveRes()
	return
##Check if Dictionary has some available (inactive)actions. If yes, erase the inactive from the dictionary.
##Check if Dictionary has all active actions. If not, add the non existing ones with default values.
func setActionsDict():
	for cutOut in list_sprites.editorNodePaths:
		for act in list_sprites.avaAction:
			if get_node(cutOut).list_sprites.actionDictionary.has(act):
				get_node(cutOut).list_sprites.actionDictionary.erase(act)
		if not get_node(cutOut).list_sprites.actionDictionary.has_all(list_sprites.actAction):
			for act in list_sprites.actAction:
				get_node(cutOut).list_sprites.actionDictionary.get_or_add(act, [["res://addons/bodypartcontrol/icons/vga_64.png",Rect2(1,0,63,60)],["res://addons/bodypartcontrol/icons/favicon_yel.png",Rect2(0,0,0,0)]])
	saveRes()
	return
