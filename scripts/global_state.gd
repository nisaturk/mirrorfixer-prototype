extends Node

var next_spawn_point: String = ""
var has_shard: bool:
	get:
		return collected_shards > 0
var collected_shards: int = 0
var spoke_to_miss_manager: bool = false
var finished_dialogues: Array = []
var just_used_elevator: bool = false

const SAVE_PATH = "user://savegame.json"

func save_game():
	var save_data = {
		"spoke_to_miss_manager": spoke_to_miss_manager,
		"next_spawn_point": next_spawn_point,
		"collected_shards": collected_shards,
		"finished_dialogues": finished_dialogues
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Game saved successfully.")
	else:
		print("ERROR: Could not save game.")

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found.")
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var data = JSON.parse_string(content)
		
		if data:
			spoke_to_miss_manager = data.get("spoke_to_miss_manager", false)
			next_spawn_point = data.get("next_spawn_point", GameConsts.SCENE_LOBBY)
			collected_shards = data.get("collected_shards", 0)
			finished_dialogues = data.get("finished_dialogues", [])
			
			print("Game loaded successfully.")
			return true
		else:
			print("ERROR: Could not parse save data.")
			return false
	else:
		print("ERROR: Could not open save file.")
		return false

func save_file_exists():
	return FileAccess.file_exists(SAVE_PATH)
