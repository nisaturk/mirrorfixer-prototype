extends Control

@onready var start_button = $Menu/StartButton
@onready var credits_button = $Menu/CreditsButton
@onready var quit_button = $Menu/QuitButton

func _ready():
	pass

func _on_start_button_pressed() -> void:
	SceneManager.change_scene(GameConsts.SCENE_BASEMENT)

func _on_credits_button_pressed() -> void:
	SceneManager.change_scene(GameConsts.SCENE_CREDITS)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
