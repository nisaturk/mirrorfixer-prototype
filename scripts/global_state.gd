extends Node

var next_spawn_point: String = ""
var has_shard: bool:
	get:
		return collected_shards > 0
var collected_shards: int = 0
var spoke_to_miss_manager: bool = false
var finished_dialogues: Array = []
var just_used_elevator: bool = false
var unlocked_notebook_ids: Array = []

var story_flags: Dictionary = {}

# moved the saving stuff to save_manager because a tutorial on youtube said so..
