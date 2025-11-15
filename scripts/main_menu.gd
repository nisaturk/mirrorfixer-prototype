extends Control

@onready var start_button = $Menu/StartButton
@onready var credits_button = $Menu/CreditsButton
@onready var quit_button = $Menu/QuitButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	SceneManager.change_scene("BASEMENT")

func _on_credits_pressed():
	SceneManager.change_scene("CREDITS")

func _on_quit_pressed():
	get_tree().quit()
