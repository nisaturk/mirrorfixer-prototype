extends CharacterBody2D
# makin' ma friend into an alcoholic
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	_schedule_next_drink()

func _schedule_next_drink():
	var wait_time = randf_range(5.0, 15.0)
	await get_tree().create_timer(wait_time).timeout
	_play_drink_animation()

func _play_drink_animation():
	if animated_sprite.animation == "idle":
		animated_sprite.play("drink")
		await animated_sprite.animation_finished
		animated_sprite.play("idle")
	
	_schedule_next_drink()
