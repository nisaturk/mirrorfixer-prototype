extends Node

var player = null 
var action_handler = {}
var TRANSITION_DATA = {
	"go_to_floor_2": {
		"scene": GameConsts.SCENE_FLOOR_2, 
		"spawn": GameConsts.SPAWN_ELEVATOR, 
		"elevator": true
	},
	"go_to_floor_1": {
		"scene": GameConsts.SCENE_LOBBY,   
		"spawn": GameConsts.SPAWN_ELEVATOR, 
		"elevator": true
	},
	"go_to_flat_1": {
		"scene": GameConsts.SCENE_FLAT_1,  
		"spawn": GameConsts.SPAWN_FLAT,     
		"elevator": false
	},
	"go_out": {
		"scene": GameConsts.SCENE_FLOOR_2, 
		"spawn": GameConsts.SPAWN_FLAT,     
		"elevator": false
	},
	"go_upstairs": {
		"scene": GameConsts.SCENE_LOBBY,    
		"spawn": GameConsts.SPAWN_STAIRS,   
		"elevator": false
	},
	"go_downstairs": {
		"scene": GameConsts.SCENE_BASEMENT, 
		"spawn": GameConsts.SPAWN_STAIRS,   
		"elevator": false
	}
}

func _ready():
	Events.action_triggered.connect(_on_action_triggered)	
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

func _on_action_triggered(action_name: String, caller_node):
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
	GlobalState.just_used_elevator = used_elevator
	SceneManager.change_scene(scene_name, spawn_point)

func _action_take_shard(caller_node):
	GlobalState.collected_shards += 1
	
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
	# get variables JUST in case the object is a simple Area2D node
	var object_id = interactable_node.get("dialogue_id")
	var portrait_id = interactable_node.get("portrait_id")
	# if it's a child node (like Miss Manager's interactable), the caller is the parent
	# if it's the object itself (like the Bell), the caller is the bell itself so
	var caller = interactable_node.get_parent()
	
	if object_id and not object_id.is_empty():
		DialogueUI.start_dialogue(object_id, caller, portrait_id)
	elif interactable_node.has_method("interact"):
		interactable_node.interact()
