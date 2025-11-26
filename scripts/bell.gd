extends Interactable
signal bell_rung(count)

var ring_count: int = 0

func _ready():
	$AnimatedSprite2D.frame = 0

# removed the input stuff, moved it to player, now there's just interact()
func interact():
	ring_bell()

func ring_bell():
	ring_count += 1
	emit_signal("bell_rung", ring_count)
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("ring")

	if $AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.stop()
	$AudioStreamPlayer2D.play()
	
#func deactivate():
	#$CollisionShape2D.set_deferred("disabled", true)
	#$AnimatedSprite2D.stop()
