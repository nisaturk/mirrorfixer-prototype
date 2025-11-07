extends CharacterBody2D

@export var start_pos := Vector2(-300, 0)       # where she starts (offscreen)
@export var target_pos := Vector2(-118, 16)    # where she should stop
@export var speed := 60.0

var active := false
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	position = start_pos
	visible = false
	animated_sprite.play("idle")  # start in idle animation

func appear():
	visible = true
	active = true
	print("Miss Manager is coming!")

func _physics_process(delta):
	if active:
		var distance = position.distance_to(target_pos)
		# Stop if she reached the target
		if distance < 2.0:
			active = false
			position = target_pos # snap precisely
			animated_sprite.play("idle") # switch to idle
			print("Miss Manager arrived.")
			return
		# Move toward target
		var dir = (target_pos - position).normalized()
		position += dir * speed * delta
		# Walk animation
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
		# Flip sprite horizontally based on movement direction
		animated_sprite.flip_h = dir.x < 0

# Called when bell signal triggers
func _on_bell_bell_rung(count: int) -> void:
	if count >= 10 and not active:
		appear() 
