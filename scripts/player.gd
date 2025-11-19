extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

signal interacted(interactable)

var nearby_interactables: Array[Area2D] = []
var current_best_interactable: Area2D = null

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
	ActionManager.register_player(self)
	
	# Logic kept here to ensure player is positioned while screen is black
	if GlobalState.next_spawn_point != "":
		var current_scene = get_tree().current_scene
		# Note: Using find_child is preferred over the deprecated find_node
		var spawn_node = current_scene.find_child(GlobalState.next_spawn_point, true, false)
		if spawn_node:
			self.global_position = spawn_node.global_position
		else:
			print("couldnt find spawn point '", GlobalState.next_spawn_point, "'")
		GlobalState.next_spawn_point = ""
		
	$InteractionDetector.area_entered.connect(_on_detector_area_entered)
	$InteractionDetector.area_exited.connect(_on_detector_area_exited)
	DialogueUI.dialogue_cancelled.connect(_on_dialogue_ended)

func _on_detector_area_entered(area):
	if not nearby_interactables.has(area):
		nearby_interactables.append(area)
	print("Player entered: ", area.name)
	_update_interaction_focus()

func _on_detector_area_exited(area):
	if nearby_interactables.has(area):
		nearby_interactables.erase(area)
	print("Player exited: ", area.name)
	_update_interaction_focus()

func _update_interaction_focus():
	var best_interactable = null
	var valid_interactables = []
	
	for area in nearby_interactables:
		if area.has_method("can_interact"):
			if area.can_interact():
				valid_interactables.append(area)
		else:
			valid_interactables.append(area)
	
	if not valid_interactables.is_empty():
		best_interactable = valid_interactables[0]
		if valid_interactables.size() > 1:
			for i in range(1, valid_interactables.size()):
				if valid_interactables[i].prioritylevel > best_interactable.prioritylevel:
					best_interactable = valid_interactables[i]
	
	if best_interactable != current_best_interactable:
		if current_best_interactable != null:
			current_best_interactable.hide_hint()
			
		current_best_interactable = best_interactable
		
		if current_best_interactable != null:
			current_best_interactable.show_hint()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			PauseMenu._on_continue_button_pressed()
		else:
			PauseMenu.show_menu()
		return

	if get_tree().paused:
		return

	var is_ui_visible = DialogueUI.visible
	if current_best_interactable != null and event.is_action_pressed("interact") and not is_ui_visible:
		get_viewport().set_input_as_handled()
		emit_signal("interacted", current_best_interactable)
		current_best_interactable.hide_hint()

func _on_dialogue_ended(_caller_node):
	_update_interaction_focus()
