extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS	
	hide()

func show_menu():
	show()
	get_tree().paused = true

func _on_continue_button_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_save_button_pressed() -> void:
	GlobalState.save_game()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	hide()
	SceneManager.change_scene("MAIN_MENU")
