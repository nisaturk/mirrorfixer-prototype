extends CharacterBody2D

@export var start_pos := Vector2(-300, 0) # where she starts (offscreen)
@export var target_pos := Vector2(-118, 16) # where she should stop
@export var speed := 60.0
@onready var interactable: Area2D = $Interactable # fixing the invisible talker bug with this

signal appeared

var active := false
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	position = start_pos
	visible = false
	if interactable:
		interactable.monitorable = false

func appear():
	visible = true
	active = true
	if interactable:
		interactable.monitorable = true
	animated_sprite.play("idle")
	emit_signal("appeared")

func _physics_process(delta):
	if active:
		var distance = position.distance_to(target_pos)
		# if she reached the target
		if distance < 2.0:
			active = false
			position = target_pos # snap precisely
			animated_sprite.play("idle") # switch to idle
			print("Miss Manager arrived.")
			return
		# move toward target
		position = position.move_toward(target_pos, speed * delta)
		# play the walking animation
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
		# flip sprite horizontally based on movement direction
		animated_sprite.flip_h = velocity.x < 0

# called when bell signal triggers
func _on_bell_bell_rung(count: int) -> void:
	if count >= 10 and not active:
		appear()
		
func allow_pass():
	$CollisionShape2D.disabled = true
	GlobalState.spoke_to_miss_manager = true
