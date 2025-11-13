extends Node

const SCENES = {
	"GAME": "res://scenes/game.tscn",
	"FLOOR_2": "res://scenes/floor.tscn",
	"FLAT_1": "res://scenes/flat.tscn"
}

func change_scene(scene_key: String):
	if not SCENES.has(scene_key):
		print("SceneManager ERROR: Scene key not found: ", scene_key)
		return
		
	var scene_path = SCENES[scene_key]
	await SceneTransitioner.fade_in()
	var error = get_tree().change_scene_to_file(scene_path)
	
	if error != OK:
		print("SceneManager ERROR: Could not change scene to: ", scene_path)
	
	await SceneTransitioner.fade_out()
