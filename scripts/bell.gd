extends Interactable
signal bell_rung(count)

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
var ring_count: int = 0

func _ready():
	$AnimatedSprite2D.frame = 0

# removed the input stuff, moved it to player, now there's just interact()
func interact():
	ring_bell()

func ring_bell():
	ring_count += 1
	emit_signal("bell_rung", ring_count)
	
	anim_sprite.frame = 0
	anim_sprite.play("ring")

	if audio.playing:
		audio.stop()
	audio.play()
