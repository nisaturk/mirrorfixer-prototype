extends Node

signal notebook_updated

var unlocked_page_ids: Array[String] = []

func add_page(page_id: String):
	if page_id not in JournalDB.PAGES:
		printerr("Page ID not found in database: ", page_id)
		return

	if page_id not in unlocked_page_ids:
		unlocked_page_ids.append(page_id)
		emit_signal("notebook_updated")

func get_texture_path(page_id: String) -> String:
	return JournalDB.PAGES.get(page_id, "")

func _ready():
	# for testestesttyyyy
	add_page("page_1")
	add_page("page_2")
	add_page("page_3")
	add_page("page_4")
