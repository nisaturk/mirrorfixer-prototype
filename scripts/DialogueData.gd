extends Node

var dialogue_data: Dictionary = {}
var has_shard: bool = false

func _ready():
	var file = FileAccess.open("res://dialogue/dialogue-prototype.json", FileAccess.READ)
	if file == null:
		print("ERROR: Could not load dialogue.json")
		return

	var content = file.get_as_text()
	var json_data = JSON.parse_string(content)

	if json_data:
		dialogue_data = json_data
	else:
		print("ERROR: Could not parse dialogue.json")

# function to get a dialogue node (object) for an ID
func get_dialogue_node(id: String):
	if dialogue_data.has(id):
		return dialogue_data[id]
	else:
		print("ERROR: No dialogue found for ID: " + id)
		return null
