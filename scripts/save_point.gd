extends Interactable

@export var required_flag: String = "unlocked_save_point"

func _ready():
	if GlobalState.story_flags.get(required_flag) == true: hint_text = "Save"

func interact(_player):
	if required_flag == "" or GlobalState.story_flags.get(required_flag) == true:
		SaveManager.save_game()
		print("Game be saved, unlike you.")
	else:
		print("cant.")
