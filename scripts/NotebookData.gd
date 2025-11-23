extends Node

signal notebook_updated

# master dicc tionary
var unlocked_content: Dictionary = {
	"npcs": [],
	"items": [],
	"thoughts": []
}

var notebook_db: Dictionary = {}

func _ready():
	load_notebook_data()
	# testestestest
	unlock_entry("npcs", "maxime")
	unlock_entry("npcs", "ninh")
	unlock_entry("items", "shard_lobby")
	unlock_entry("items", "bell")
	unlock_entry("items", "cutie")
	unlock_entry("items", "patootie")
	unlock_entry("thoughts", "day1") 

func load_notebook_data():
	var file = FileAccess.open("res://jsonfiles/notebook-prototype.json", FileAccess.READ)
	if file:
		notebook_db = JSON.parse_string(file.get_as_text())
		print("Notebook Data Loaded!")
	else:
		printerr("Failed to load notebook-prototype.json")

func unlock_entry(category: String, id: String):
	if not notebook_db.has(category):
		printerr("Category not found in DB: " + category)
		return

	if not notebook_db[category].has(id):
		printerr("ID '" + id + "' not found in category '" + category + "'")
		return

	if id not in unlocked_content[category]:
		unlocked_content[category].append(id)
		emit_signal("notebook_updated")

func get_entry_data(category: String, id: String) -> Dictionary:
	if notebook_db.has(category):
		return notebook_db[category].get(id, {})
	return {}
