extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

signal interacted(interactable)

var nearby_interactables: Array[Area2D] = []
var current_best_interactable: Area2D = null
var is_interacting: bool = false

func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
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
	if GlobalState.next_spawn_point != "":
		var current_scene = get_tree().current_scene
		var spawn_node = current_scene.find_child(GlobalState.next_spawn_point, true, false)
		if spawn_node:
			self.global_position = spawn_node.global_position
		else:
			print("couldnt find spawn point '", GlobalState.next_spawn_point, "'")
		GlobalState.next_spawn_point = ""
		
	Events.dialogue_started.connect(_on_dialogue_started)
	Events.dialogue_ended.connect(_on_dialogue_ended)
		
	$InteractionDetector.area_entered.connect(_on_detector_area_entered)
	$InteractionDetector.area_exited.connect(_on_detector_area_exited)

func _on_detector_area_entered(area):
	if area is Interactable:
		if not nearby_interactables.has(area):
			nearby_interactables.append(area)
			print("Interactable found: ", area.name)
			_update_interaction_focus()

func _on_detector_area_exited(area):
	if nearby_interactables.has(area):
		nearby_interactables.erase(area)
		_update_interaction_focus()

func _update_interaction_focus():
	nearby_interactables = nearby_interactables.filter(is_instance_valid)
	
	if nearby_interactables.is_empty():
		if current_best_interactable:
			current_best_interactable.hide_hint()
		current_best_interactable = null
		return

	nearby_interactables.sort_custom(func(a, b): return a.prioritylevel > b.prioritylevel)
	var best_candidate = nearby_interactables[0]
	
	if best_candidate.has_method("can_interact") and not best_candidate.can_interact():
		best_candidate = null

	if best_candidate != current_best_interactable:
		if current_best_interactable:
			current_best_interactable.hide_hint()
		
		current_best_interactable = best_candidate
		
		if current_best_interactable:
			current_best_interactable.show_hint()

func _input(event):
	if is_interacting:
		return 

	if event.is_action_pressed("pause"):
		return

	if event.is_action_pressed("interact"):
		print("Player heard Interact!")
		
		if current_best_interactable != null:
			get_viewport().set_input_as_handled()
			interacted.emit(current_best_interactable)
			
			current_best_interactable.hide_hint()

func _on_dialogue_started():
	is_interacting = true
	animated_sprite.play("idle")

func _on_dialogue_ended(_caller):
	await get_tree().process_frame
	is_interacting = false
	_update_interaction_focus()
