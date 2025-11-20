extends Control

@onready var start_button = $Menu/StartButton
@onready var credits_button = $Menu/CreditsButton
@onready var quit_button = $Menu/QuitButton

func _ready():
	pass

func _on_continue_button_pressed() -> void:
	print("no load yet")

func _on_start_button_pressed() -> void:
	SceneManager.change_scene(SceneManager.BASEMENT)

func _on_credits_button_pressed() -> void:
	SceneManager.change_scene(SceneManager.CREDITS)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
