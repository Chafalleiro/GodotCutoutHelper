extends CharacterBody2D
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var speed = 250

@onready var animation_tree = get_node("AnimationTree")
@onready var animation_mode = animation_tree.get("parameters/playback")

var last_direction: Vector2
var dir_ant = ""

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var movement = speed * direction * delta
	# If input is digital, normalize it for diagonal movement
	if direction != Vector2.ZERO:
		if abs(direction.x) == 1 and abs(direction.y) == 1:
			direction = direction.normalized()	# Apply movement
		movement = speed * direction * delta
		last_direction = 0.5 * last_direction + 0.5 * direction

		# Animate player based on direction
		animation_tree.set("parameters/Transition/transition_request", "Walk")
		speed= 250
		animation_mode.travel("Walk")
		animation_tree.set("parameters/Walk/Walk/blend_position", last_direction)
		movement = speed * direction * delta
		animation_tree.set("parameters/Idle/Idle/blend_position", last_direction)
		# Turn RayCast2D toward movement direction
		#if direction != Vector2.ZERO:
	#		$RayCast2D.cast_to = direction.normalized() * 40
		get_animation_direction(last_direction)
		move_and_collide(movement)
	else:
		animation_tree.set("parameters/Idle/Idle/blend_position", last_direction)
		animation_mode.travel("Idle")

func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	var str_dir = ""
	if norm_direction.x <= -0.707:#"_left"
		#only one side is needed since we reverse the x scale to play the animations.
		#we just check if there is horizontal movement to select the adequate spritesheet.
		str_dir = "Side"
	elif norm_direction.x >= 0.707:#"_right"
		str_dir = "Side"
	if norm_direction.y >= 0.707:
		str_dir = "Down"
	elif norm_direction.y <= -0.707:
		str_dir = "Up"
	if dir_ant != str_dir:
		if str_dir != "":
			#Change textures based on the "Action" set in BodyPartRoot and associated with BodyPartNode
			#These are changed in bulk, all the textures loades in "Active nodes" list will change.
			$BodyPartRoot.setNewSprites(str_dir,0) 
			dir_ant = str_dir
	return str_dir

func _on_button_pressed() -> void:
	#Get the texture loaded in the cutout node dictionary
	var sw = $TextureButton.list_sprites.actionDictionary["Side"]
	var mt = sw[0][0]
	#Chek if already loaded, if yes change it.
	if mt == "res://player/img/path11.png":
		$TextureButton.chng_text("Side", 0, "res://player/img/dibujo.png")
	else:
		$TextureButton.chng_text("Side", 0, "res://player/img/path11.png")
	#Show the loaded texture. Notice that the node hasn't any texture loaded yet.
	$TextureButton.chng_sprt("Side", 0)
