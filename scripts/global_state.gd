extends Node

var next_spawn_point: String = ""
var has_shard: bool = false
var collected_shards: int = 0
var spoke_to_miss_manager: bool = false
var finished_dialogues: Array = []
var just_used_elevator: bool = false
var unlocked_notebook_ids: Array = []

var story_flags: Dictionary = {}

func get_save_dict() -> Dictionary:
	return {
		"spoke_to_miss_manager": spoke_to_miss_manager,
		"next_spawn_point": next_spawn_point,
		"collected_shards": collected_shards,
		"finished_dialogues": finished_dialogues,
		"unlocked_notebook_ids": unlocked_notebook_ids,
		"story_flags": story_flags
	}

func load_save_dict(data: Dictionary):
	spoke_to_miss_manager = data.get("spoke_to_miss_manager", false)
	var default_spawn = SceneManager.SCENES[GameConsts.SCENE_LOBBY]
	next_spawn_point = data.get("next_spawn_point", default_spawn)
	collected_shards = data.get("collected_shards", 0)
	finished_dialogues = data.get("finished_dialogues", [])
	unlocked_notebook_ids = data.get("unlocked_notebook_ids", [])
	story_flags = data.get("story_flags", {})
