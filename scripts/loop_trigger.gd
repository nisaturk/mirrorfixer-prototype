extends Node2D

@onready var loop_start = $LoopStart
@onready var loop_end = $LoopEnd
@onready var player = $Player

func _physics_process(_delta):
	if not player:
		return

	if player.global_position.x > loop_end.global_position.x:
		# calculating the offset bc we want smooth movement
		var offset = player.global_position.x - loop_end.global_position.x
		player.global_position.x = loop_start.global_position.x + offset

	elif player.global_position.x < loop_start.global_position.x:
		var offset = loop_start.global_position.x - player.global_position.x
		player.global_position.x = loop_end.global_position.x - offset
