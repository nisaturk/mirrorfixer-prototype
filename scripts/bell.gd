extends Area2D

signal bell_rung(count)

var player_in_range: bool = false
var ring_count: int = 0

func _ready():
	$AnimatedSprite2D.frame = 0

func _input(event):
	if not player_in_range:
		return

	if event.is_action_pressed("interact") \
	or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		ring_bell()

func ring_bell():

	ring_count += 1
	emit_signal("bell_rung", ring_count)
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("ring")

	if $AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.stop()
	$AudioStreamPlayer2D.play()

	print("Bell rung! Count:", ring_count)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false 
