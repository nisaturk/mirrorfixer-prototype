extends Area2D

signal bell_rung(count)

var ring_count: int = 0
# trying to unify the interactables so added some new variables
var dialogue_id: String = ""
var prioritylevel: int = 0
var portrait_id: String = ""

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

func show_hint():
	# maybe i will add a hint because the bell is somewhat important
	pass 

func hide_hint():
	pass

func can_interact() -> bool:
	return true
