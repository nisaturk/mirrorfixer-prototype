extends CharacterBody2D

@export var start_pos := Vector2(-300, 0) # where she starts (offscreen)
@export var target_pos := Vector2(-118, 16) # where she should stop
@export var speed := 60.0

var active := false
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	position = start_pos
	visible = false

func appear():
	visible = true
	active = true
	animated_sprite.play("idle") # start in idle animation
	#print("Miss Manager is coming!")
	
	var game_scene = get_parent()
	if game_scene:
		var bell_node = game_scene.get_node("Bell")
		if bell_node:
			bell_node.deactivate()
		else:
			print("ERROR: Miss Manager could not find Bell node.")

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
		var dir = (target_pos - position).normalized()
		position += dir * speed * delta
		# play the walking animation
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
		# flip sprite horizontally based on movement direction
		animated_sprite.flip_h = dir.x < 0

# called when bell signal triggers
func _on_bell_bell_rung(count: int) -> void:
	if count >= 10 and not active:
		appear()
		
func allow_pass():
	$CollisionShape2D.disabled = true
