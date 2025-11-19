extends Node

var player = null 
var action_handler = {}

const TRANSITION_DATA = {
	"go_to_floor_2":   {"scene": "FLOOR_2",  "spawn": "ElevatorSpawn", "elevator": true},
	"go_to_floor_1":   {"scene": "LOBBY",    "spawn": "ElevatorSpawn", "elevator": true},
	"go_to_flat_1":    {"scene": "FLAT_1",   "spawn": "FlatSpawn",     "elevator": false},
	"go_out":          {"scene": "FLOOR_2",  "spawn": "FlatSpawn",     "elevator": false},
	"go_upstairs":     {"scene": "LOBBY",    "spawn": "StairsSpawn",   "elevator": false},
	"go_downstairs":   {"scene": "BASEMENT", "spawn": "StairsSpawn",   "elevator": false}
}

func _ready():
	DialogueUI.action_triggered.connect(_on_DialogueUI_action_triggered)
	
	action_handler = {
		"take_shard": _action_take_shard,
		"allow_pass": _action_allow_pass,
		"open_elevator": _action_open_elevator
	}

func register_player(player_node):
	if player_node:
		player = player_node
		if not player.interacted.is_connected(_on_Player_interacted):
			player.interacted.connect(_on_Player_interacted)
	else:
		print("manager failure: player is null")

func _on_DialogueUI_action_triggered(action_name: String, caller_node):
	# check if this is a movement action
	if TRANSITION_DATA.has(action_name):
		var data = TRANSITION_DATA[action_name]
		_change_location(data.scene, data.spawn, data.elevator)
		return

	# check if this is a special logic action
	if action_handler.has(action_name):
		action_handler[action_name].call(caller_node)
	else:
		print("Action not found: ", action_name)

func _change_location(scene_name: String, spawn_point: String, used_elevator: bool):
	DialogueData.just_used_elevator = used_elevator
	SceneManager.change_scene(scene_name, spawn_point)

func _action_take_shard(caller_node):
	# DialogueData.has_shard = true # old
	GlobalState.collected_shards += 1 # new
	
	print("shard collected: ", GlobalState.collected_shards)
	if caller_node:
		caller_node.queue_free()

func _action_allow_pass(caller_node):
	if caller_node and caller_node.has_method("allow_pass"):
		caller_node.allow_pass()

func _action_open_elevator(caller_node):
	if caller_node and caller_node.has_method("open_doors"):
		caller_node.open_doors()

func _on_Player_interacted(interactable_node):
	var object_id = interactable_node.dialogue_id
	var caller = interactable_node.get_parent()
	var portrait_id = interactable_node.portrait_id 
	
	if not object_id.is_empty():
		DialogueUI.start_dialogue(object_id, caller, portrait_id)
