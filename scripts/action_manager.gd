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
		player.interacted.connect(_on_Player_interacted)
	else:
		print("manager failure: (oh no!)(player is now null).")

func _on_DialogueUI_action_triggered(action_name: String, caller_node):
	if action_handler.has(action_name):
		action_handler[action_name].call(caller_node)
	else:
		print("manager failure: tf you doin buddy?: ", action_name)

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

func _action_go_to_floor_2(_caller_node):
	DialogueData.just_used_elevator = true
	SceneManager.change_scene("FLOOR_2", "ElevatorSpawn")

func _action_go_to_floor_1(_caller_node):
	DialogueData.just_used_elevator = true
	SceneManager.change_scene("LOBBY", "ElevatorSpawn")

func _action_go_to_flat_1(_caller_node):
	DialogueData.just_used_elevator = true
	SceneManager.change_scene("FLAT_1", "FlatSpawn")
		
func _action_go_out(_caller_node):
	DialogueData.just_used_elevator = true 
	SceneManager.change_scene("FLOOR_2", "FlatSpawn")

func _action_go_upstairs(_caller_node):
	print("go upstairs action was called?")
	SceneManager.change_scene("LOBBY", "LobbyStairs")

func _action_go_downstairs(_caller_node):
	SceneManager.change_scene("BASEMENT", "StairsSpawn")
	
# run when player emits signal interacted
func _on_Player_interacted(interactable_node):
	var object_id = interactable_node.dialogue_id
	var caller = interactable_node.get_parent()
	
	if not object_id.is_empty():
		DialogueUI.start_dialogue(object_id, caller)
