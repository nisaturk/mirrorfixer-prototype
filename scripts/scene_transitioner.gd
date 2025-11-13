extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var fade_rect = $FadeRect

func _ready():
	pass

func fade_in():
	animation_player.play("fade_to_black")
	return animation_player.animation_finished

func fade_out():
	animation_player.play("fade_from_black")
	return animation_player.animation_finished
