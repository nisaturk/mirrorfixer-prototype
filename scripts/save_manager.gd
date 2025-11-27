extends Node

const SAVE_PATH = "user://savegame.json"

func save_game():
	var save_data = {
		"spoke_to_miss_manager": GlobalState.spoke_to_miss_manager,
		"next_spawn_point": GlobalState.next_spawn_point,
		"collected_shards": GlobalState.collected_shards,
		"finished_dialogues": GlobalState.finished_dialogues,
		"unlocked_notebook_ids": GlobalState.unlocked_notebook_ids,
		"story_flags": GlobalState.story_flags
	}

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
	GlobalState.spoke_to_miss_manager = data.get("spoke_to_miss_manager", false)
	GlobalState.next_spawn_point = data.get("next_spawn_point", "res://scenes/lobby.tscn") 
	GlobalState.collected_shards = data.get("collected_shards", 0)
	GlobalState.finished_dialogues = data.get("finished_dialogues", [])
	GlobalState.unlocked_notebook_ids = data.get("unlocked_notebook_ids", [])
	GlobalState.story_flags = data.get("story_flags", {})

func save_file_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save():
	DirAccess.remove_absolute(SAVE_PATH)
