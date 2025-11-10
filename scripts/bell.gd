extends Area2D

signal bell_rung(count)

var player_in_range: bool = false
var ring_count: int = 0
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
		ring_bell()
		get_viewport().set_input_as_handled() # consume input so it wont keep ringin

func ring_bell():
	ring_count += 1
	emit_signal("bell_rung", ring_count)
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("ring")

	if $AudioStreamPlayer2D.playing: # so the bell sounds wont overlap
		$AudioStreamPlayer2D.stop()
	$AudioStreamPlayer2D.play()

	#print("Bell rung! Count:", ring_count)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false

func deactivate():
	is_active = false
	print("Bell has been deactivated.")
