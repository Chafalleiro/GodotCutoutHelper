@tool
extends Resource
##Class resource to hold the data used in the root node for [BodyPartNode].
## See Main Help [CutOutMain][br]
## @experimental
class_name BodyPartNodeRes

## Dictionary to hold the resource paths and rtegions of the Atlas sprites.
@export var actionDictionary = {}: # Creates an empty dictionary.
	set(new_setting):
		actionDictionary = new_setting
		# Emit a signal when the property is changed.
		changed.emit("actionDictionary")

@export var currentAction: String: # Creates an empty dictionary.
	set(new_setting):
		currentAction = new_setting
		# Emit a signal when the property is changed.
		changed.emit("currentAction")
