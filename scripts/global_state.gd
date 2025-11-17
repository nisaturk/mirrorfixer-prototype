extends Node

var next_spawn_point: String = ""
var collected_shards: int = 0
var spoke_to_miss_manager: bool = false
var unlocked_floors: Array[String] = ["BASEMENT", "LOBBY"]
var flat_1_puzzle_solved: bool = false

const SAVE_PATH = "user://savegame.json"

func save_game():
	var save_data = {
		"spoke_to_miss_manager": spoke_to_miss_manager,
		"next_spawn_point": next_spawn_point,
		"collected_shards": collected_shards,
		"unlocked_floors": unlocked_floors,
		"flat_1_puzzle_solved": flat_1_puzzle_solved,
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("this shits saved!")
	else:
		print("ERROR: could not save this shit.")

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
			next_spawn_point = data.get("next_spawn_point", "LOBBY")
			#collected_shards = data.get("collected_shards", 0)
			#unlocked_floors = data.get("unlocked_floors", ["BASEMENT", "LOBBY"])
			# flat_1_puzzle_solved = data.get("flat_1_puzzle_solved", false)
			print("shits loaded!")
			return true
		else:
			print("ERROR: Could not parse the save shit.")
			return false
	else:
		print("ERROR: Could not open the saved shit..")
		return false

func save_file_exists():
	return FileAccess.file_exists(SAVE_PATH)
