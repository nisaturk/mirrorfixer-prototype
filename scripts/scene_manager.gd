extends CanvasLayer
@onready var animation_player = $AnimationPlayer

const SCENES = {
	"BASEMENT": "res://scenes/basement.tscn",
	"LOBBY": "res://scenes/lobby.tscn",
	"FLOOR_2": "res://scenes/floor.tscn",
	"FLAT_1": "res://scenes/flat.tscn"
}

func fade_in():
	animation_player.play("fade_to_black")
	await animation_player.animation_finished

func fade_out():
	animation_player.play("fade_from_black")
	await animation_player.animation_finished

func change_scene(scene_key: String):
	if not SCENES.has(scene_key):
		print("scene key not found: ", scene_key)
		return
		
	var scene_path = SCENES[scene_key]
	await fade_in() 
	var error = get_tree().change_scene_to_file(scene_path)
	
	if error != OK:
		print("could not change scene to: ", scene_path)
	await fade_out()
