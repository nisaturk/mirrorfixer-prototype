extends Node

# new script who dis?? time to confront miss manager ;D
var player = null # wait for the player to register itself
var action_handler = {} # dictionary for actions

func _ready():
	#  will listen for signals from other nodes and decide what to do
	DialogueUI.action_triggered.connect(_on_DialogueUI_action_triggered)
	
	action_handler = {
		"take_shard": _action_take_shard,
		"allow_pass": _action_allow_pass,
		"open_elevator": _action_open_elevator,
		
		"go_to_floor_2": _action_go_to_floor_2,
		"go_to_floor_1": _action_go_to_floor_1,
		"go_to_flat_1": _action_go_to_flat_1,
		"go_out": _action_go_out,
		"go_upstairs": _action_go_upstairs,
		"go_downstairs": _action_go_downstairs
	}

# player registry for debugging
func register_player(player_node):
	if player_node:
		player = player_node
		if not player.interacted.is_connected(_on_Player_interacted):
			player.interacted.connect(_on_Player_interacted)
	else:
		print("manager failure: (oh no!)(player is now null).")

func _on_DialogueUI_action_triggered(action_name: String, caller_node):
	if action_handler.has(action_name):
		action_handler[action_name].call(caller_node)
	else:
		print("manager failure: tf you doin buddy?: ", action_name)

# new function to be more efficient
func _change_location(scene_name: String, spawn_point: String, used_elevator: bool):
	DialogueData.just_used_elevator = used_elevator
	SceneManager.change_scene(scene_name, spawn_point)

# action handlers are the same (may change)
func _action_take_shard(caller_node):
	DialogueData.has_shard = true
	if caller_node:
		caller_node.queue_free() # the shard object disappears

func _action_allow_pass(caller_node):
	if caller_node and caller_node.has_method("allow_pass"):
		caller_node.allow_pass()

func _action_open_elevator(caller_node):
	if caller_node and caller_node.has_method("open_doors"):
		caller_node.open_doors()

# re-imagined transition actions using the helper function
func _action_go_to_floor_2(_caller_node):
	_change_location("FLOOR_2", "ElevatorSpawn", true)

func _action_go_to_floor_1(_caller_node):
	_change_location("LOBBY", "ElevatorSpawn", true)

func _action_go_to_flat_1(_caller_node):
	_change_location("FLAT_1", "FlatSpawn", false)
		
func _action_go_out(_caller_node):
	_change_location("FLOOR_2", "FlatSpawn", false)

func _action_go_upstairs(_caller_node):
	_change_location("LOBBY", "StairsSpawn", false)

func _action_go_downstairs(_caller_node):
	_change_location("BASEMENT", "StairsSpawn", false)
	
# runs when player emits signal interacted
func _on_Player_interacted(interactable_node):
	var object_id = interactable_node.dialogue_id
	var caller = interactable_node.get_parent()
	
	var pee_id = interactable_node.portrait_id 
	if not object_id.is_empty():
		DialogueUI.start_dialogue(object_id, caller, pee_id)
