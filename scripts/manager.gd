extends Node
# new script who dis?? time to confront miss manager ;D
@onready var player = $Player 

func _ready():
	#  will listen for signals from other nodes and decide what to do
	if player:
		player.interacted.connect(_on_Player_interacted)
	else:
		print("Manager ERROR: Cannot find Player node. Make sure it's named 'Player'.")

	DialogueUI.action_triggered.connect(_on_DialogueUI_action_triggered)

# run when player emits signal interacted
func _on_Player_interacted(interactable_node):
	var object_id = interactable_node.dialogue_id
	var caller = interactable_node.get_parent()
	
	if not object_id.is_empty():
		DialogueUI.start_dialogue(object_id, caller)

func _on_DialogueUI_action_triggered(action_name: String, caller_node):
	# tags from the JSON file
	if action_name == "take_shard":
		DialogueData.has_shard = true
		if caller_node:
			caller_node.queue_free() # the shard object disappears
			
	elif action_name == "allow_pass" and caller_node:
		if caller_node.has_method("allow_pass"):
			caller_node.allow_pass()
	
	elif action_name == "open_elevator":
		if caller_node and caller_node.has_method("open_doors"):
			caller_node.open_doors()
	
	elif action_name == "go_to_floor_2":
		DialogueData.just_used_elevator = true
		get_tree().change_scene_to_file("res://scenes/floor.tscn")
	
	elif action_name == "go_to_floor_1":
		DialogueData.just_used_elevator = true
		get_tree().change_scene_to_file("res://scenes/game.tscn")
		
	elif action_name == "go_to_flat_1":
		DialogueData.just_used_elevator = true
		get_tree().change_scene_to_file("res://scenes/flat.tscn")
		
	elif action_name == "go_out":
		DialogueData.just_used_elevator = true 
		get_tree().change_scene_to_file("res://scenes/floor.tscn")
