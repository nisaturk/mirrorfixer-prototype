extends Node

const SAVE_PATH = "user://savegame.json"

func save_game():
	var save_data = GlobalState.get_save_dict()

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("SaveManager: Game saved successfully.")
	else:
		print("SaveManager: ERROR - Could not save game.")

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("SaveManager: No save file found.")
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var data = JSON.parse_string(content)
		if data:
			_apply_data_to_state(data)
			print("SaveManager: Game loaded successfully.")
			return true
		else:
			print("SaveManager: ERROR - Could not parse save data.")
			return false
	return false
	
func _apply_data_to_state(data: Dictionary):
	GlobalState.load_save_dict(data)

func save_file_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save():
	DirAccess.remove_absolute(SAVE_PATH)
