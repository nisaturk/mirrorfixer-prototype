extends Node

signal notebook_updated

var unlocked_npc_ids: Array = []  
var collected_item_ids: Array = []
var journal_entries: Array = [] 

var notebook_db: Dictionary = {}

func _ready():
	load_notebook_data()
	# temporary check-up, these are "unlocked" to test the UI
	unlock_npc("maxime")
	unlock_npc("ninh")
	collect_item("shard_lobby")
	add_note("day1") 
	add_note("day2")

func load_notebook_data():
	var file = FileAccess.open("res://jsonfiles/notebook-prototype.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		notebook_db = JSON.parse_string(json_text)
		print("Notebook Data Loaded!")
	else:
		printerr("Failed to load notebook-prototype.json")

func unlock_npc(id: String):
	if id not in notebook_db["npcs"]:
		printerr("NPC ID not found in DB: " + id)
		return
		
	if id not in unlocked_npc_ids:
		unlocked_npc_ids.append(id)
		emit_signal("notebook_updated")

func collect_item(id: String):
	if id not in notebook_db["items"]:
		printerr("Item ID not found in DB: " + id)
		return
		
	if id not in collected_item_ids:
		collected_item_ids.append(id)
		emit_signal("notebook_updated")

func add_note(id: String):
	if id not in journal_entries:
		journal_entries.append(id)
		emit_signal("notebook_updated")

func get_thought_data(id: String) -> Dictionary:
	if notebook_db.has("thoughts"):
		return notebook_db["thoughts"].get(id, {})
	return {}

func get_item_data(id: String) -> Dictionary:
	return notebook_db["items"].get(id, {})

func get_npc_data(id: String) -> Dictionary:
	return notebook_db["npcs"].get(id, {})
