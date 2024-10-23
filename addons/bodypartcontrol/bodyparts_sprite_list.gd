@tool
extends Resource
##Class resource to hold the data used in the [BodyPartRoot] node for [BodyPartNode].
##Each variable emits a signal with its name as parameter.
## @experimental
## See Main Help [CutOutMain][br]

class_name BodypartSpriteList

##Property to store list of [BodyPartNode]s names detected in the current [BodyPartRoot] scene. Use [@export] if you want to edit manually
@export var listSprite: Array[String]:
	set(new_setting):
		listSprite = new_setting
		# Emit a signal when the property is changed.
		changed.emit("listSprite")

##Property to store list of Actions activated. Use [@export] if you want to edit manually[br]
##They correspond with the [CutoutRootControl] nodes %ActionOptions, %actActionList and %avaActionList
@export var actAction: Array[String] = ["Up","SideUp","Side","SideDown","Down"]:
	set(new_setting):
		actAction = new_setting
		# Emit a signal when the property is changed.
		changed.emit("actAction")

##Property to store list of Actions available. Use [@export] if you want to edit manually[br]
##They correspond with the [CutoutRootControl] nodes %ActionOptions, %actActionList and %avaActionList
@export var avaAction: Array[String] = ["Equip","Unequip"]:
	set(new_setting):
		avaAction = new_setting
		# Emit a signal when the property is changed.
		changed.emit("avaAction")

##Property to store list of [BodyPartNode]s names available. Use [@export] if you want to edit manually
@export var availNode: Array[String]:
	set(new_setting):
		availNode = new_setting
		# Emit a signal when the property is changed.
		changed.emit("availNode")

##Property to store list of [BodyPartNode]s names active. Use [@export] if you want to edit manually
@export var activeNode: Array[String]:
	set(new_setting):
		activeNode = new_setting
		# Emit a signal when the property is changed.
		changed.emit("activeNode")

##Property to store list of the active Editor [BodyPartNode]s node paths. Use [@export] if you want to edit manually
##Editor path and runnig path of a node are different.
@export var editorNodePaths: Array[NodePath]:
	set(new_setting):
		editorNodePaths = new_setting
		# Emit a signal when the property is changed.
		changed.emit("editorNodePaths")

##Property to store list of the active Run mode [BodyPartNode]s node paths. Use [@export] if you want to edit manually
##Editor path and runnig path of a node are different.
@export var runningNodePaths: Array[NodePath]:
	set(new_setting):
		runningNodePaths = new_setting
#		# Emit a signal when the property is changed.
		changed.emit("runningNodePaths")
