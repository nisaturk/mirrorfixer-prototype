extends Interactable

var is_active = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var close_timer: Timer = $CloseTimer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	close_timer.timeout.connect(close_doors)
	DialogueUI.dialogue_cancelled.connect(_on_dialogue_cancelled)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	if GlobalState.just_used_elevator:
		GlobalState.just_used_elevator = false
		
		animated_sprite.play("open")
		animated_sprite.stop()
		animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("open") - 1
		
		close_timer.wait_time = 5.0
		close_timer.start()
	else:
		animated_sprite.play("close")
		animated_sprite.stop()
		animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("close") - 1

func open_doors():
	close_timer.stop()
	
	if animated_sprite.animation != "open" or not animated_sprite.is_playing():
		animated_sprite.frame = 0
		animated_sprite.play("open")
		_play_sound()

func close_doors():
	close_timer.stop() 
	
	if animated_sprite.animation != "close" or not animated_sprite.is_playing():
		animated_sprite.frame = 0
		animated_sprite.play("close")
		_play_sound()

func _play_sound():
	if audio_player.playing:
		audio_player.stop()
	audio_player.play()

func _on_animation_finished():
	if animated_sprite.animation == "open":
		close_timer.wait_time = 5.0
		close_timer.start()

func _on_dialogue_cancelled(caller_node):
	if caller_node == self:
		close_timer.wait_time = 5.0
		close_timer.start()
