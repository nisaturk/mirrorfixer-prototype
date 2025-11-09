#extends Area2D
#
#signal shard_collected(bool)
#var player_in_range: bool = false
#
#func _ready():
	#pass
	#
#func _input(event):	
	#if not player_in_range:
		#return
#
	#var ui = $"/root/Game/GameUI"
	#if ui and ui.visible:
		#return
#
	#if event.is_action_pressed("interact"):
		#collect_shard()
		#get_viewport().set_input_as_handled() # consume input so it wont keep ringin
#
#func collect_shard():
	#emit_signal("shard_collected")
#
	#if $AudioStreamPlayer2D.playing: # so the shard sounds wont overlap
		#$AudioStreamPlayer2D.stop()
	#$AudioStreamPlayer2D.play()
#
#func _on_body_entered(body: Node2D) -> void:
	#if body.name == "Player":
		#player_in_range = true
#
#func _on_body_exited(body: Node2D) -> void:
	#if body.name == "Player":
		#player_in_range = false
#
#func _on_shard_collected(count: Variant) -> void:
	#pass # Replace with function body.
