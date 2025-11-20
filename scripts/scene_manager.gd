extends CanvasLayer

signal scene_ready

@onready var animation_player = $AnimationPlayer

const MAIN_MENU = "MAIN_MENU"
const CREDITS = "CREDITS"
const BASEMENT = "BASEMENT"
const LOBBY = "LOBBY"
const FLOOR_2 = "FLOOR_2"
const FLAT_1 = "FLAT_1"

const SCENES = {
	"MAIN_MENU": "res://scenes/main_menu.tscn",
	"CREDITS": "res://scenes/credits.tscn",
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

func change_scene(scene_key: String, spawn_point: String = ""):
	if not SCENES.has(scene_key):
		print("scene key not found: ", scene_key)
		return
		
	get_tree().paused = false
	if get_tree().root.has_node("DialogueUI"):
		DialogueUI.hide()
	if get_tree().root.has_node("PauseMenu"):
		PauseMenu.hide()
	
	GlobalState.next_spawn_point = spawn_point
	
	var scene_path = SCENES[scene_key]
	await fade_in()
	
	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		print("could not change scene to: ", scene_path)
	await fade_out()
	
	emit_signal("scene_ready")
