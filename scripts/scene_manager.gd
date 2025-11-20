extends CanvasLayer

signal scene_ready

@onready var animation_player = $AnimationPlayer

# updated dictionary using new consts
const SCENES = {
	GameConsts.SCENE_MAIN_MENU: "res://scenes/main_menu.tscn",
	GameConsts.SCENE_CREDITS: "res://scenes/credits.tscn",
	GameConsts.SCENE_BASEMENT: "res://scenes/basement.tscn",
	GameConsts.SCENE_LOBBY: "res://scenes/lobby.tscn",
	GameConsts.SCENE_FLOOR_2: "res://scenes/floor.tscn",
	GameConsts.SCENE_FLAT_1: "res://scenes/flat.tscn"
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
