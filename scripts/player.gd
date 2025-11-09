extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var nearby_interactables: Array = [] # newly added variable for overlapping zones

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction := Input.get_axis("move_left", "move_right")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if is_on_floor():
		if direction == 0: 
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.play("jump")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func _ready():
	$InteractionDetector.area_entered.connect(_on_detector_area_entered)
	$InteractionDetector.area_exited.connect(_on_detector_area_exited)
	
func _on_detector_area_entered(area):
	if not nearby_interactables.has(area):
		nearby_interactables.append(area)
	print("Player entered: ", area.name)

func _on_detector_area_exited(area):
	if nearby_interactables.has(area):
		nearby_interactables.erase(area)
	print("Player exited: ", area.name)

func _input(event):
	var ui = $"/root/Game/GameUI" 
	var is_ui_visible = ui.visible

	# check if the list is NOT empty, if interact is pressed, and if UI is hidden
	if not nearby_interactables.is_empty() and event.is_action_pressed("interact") and not is_ui_visible:
		
		# new logic for priority
		var best_interactable = nearby_interactables[0]
		
		# if there's more than one, loop through and find the one with the highest priority
		if nearby_interactables.size() > 1:
			for i in range(1, nearby_interactables.size()):
				if nearby_interactables[i].prioritylevel > best_interactable.prioritylevel:
					best_interactable = nearby_interactables[i]
		
		# use the "best_interactable" found
		var object_id = best_interactable.dialogue_id
		var caller = best_interactable.get_parent()
		
		if not object_id.is_empty():
			ui.start_dialogue(object_id, caller)
			get_viewport().set_input_as_handled()

## just an idea for a future function
#func allow_pass():
	#print("Miss Manager lets Miss Erable pass.")
	#
	## Disable collision
	#if collision_shape:
		#collision_shape.disabled = true
