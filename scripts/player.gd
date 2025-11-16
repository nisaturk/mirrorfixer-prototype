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

# updated the brain-y logic that will decide (lol) which hint to show
func _update_interaction_focus():
	var best_interactable = null
	
	if not nearby_interactables.is_empty():
		best_interactable = nearby_interactables[0]
		if nearby_interactables.size() > 1:
			for i in range(1, nearby_interactables.size()):
				if nearby_interactables[i].prioritylevel > best_interactable.prioritylevel:
					best_interactable = nearby_interactables[i]
	
	if best_interactable != current_best_interactable:
		if current_best_interactable != null:
			current_best_interactable.hide_hint()
			
		current_best_interactable = best_interactable
		
		if current_best_interactable != null:
			current_best_interactable.show_hint()

func _input(event):
	var is_ui_visible = DialogueUI.visible

	if current_best_interactable != null and event.is_action_pressed("interact") and not is_ui_visible:
		get_viewport().set_input_as_handled()
		emit_signal("interacted", current_best_interactable)
		# hide the hint, dialogue is starting
		current_best_interactable.hide_hint()

func _on_dialogue_ended(_caller_node):
	_update_interaction_focus()
