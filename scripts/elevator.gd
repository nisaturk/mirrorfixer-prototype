extends Area2D

var player_in_range: bool = false
var is_active = true

func _ready():
	$AnimatedSprite2D.frame = 0

func _input(event):
	if not is_active: return
	
	if not player_in_range:
		return

	if DialogueUI.visible: #autoload change
		return

	if event.is_action_pressed("interact"):
		open_doors()
		#get_viewport().set_input_as_handled() # consume input so it wont keep ringin

func open_doors():
	#emit_signal("doors_opened")
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("open")

	if $AudioStreamPlayer2D.playing: # so the sounds wont overlap
		$AudioStreamPlayer2D.stop()
	$AudioStreamPlayer2D.play()
	
func close_doors():
	#emit_signal("doors_opened")
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("close")

	if $AudioStreamPlayer2D.playing: # so the sounds wont overlap
		$AudioStreamPlayer2D.stop()
	$AudioStreamPlayer2D.play()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
