extends CanvasLayer

var object_entry_scene = preload("res://scenes/object_entry.tscn")

# pages
@onready var page_npc = $MainControl/BookBackground/ContentArea/NPCs
@onready var page_items = $MainControl/BookBackground/ContentArea/Items
@onready var page_thoughts = $MainControl/BookBackground/ContentArea/Thoughts

#listsss babeyyy
@onready var npc_grid_container = $MainControl/BookBackground/ContentArea/NPCs
@onready var item_list_container = $MainControl/BookBackground/ContentArea/Items/ItemList
@onready var journal_list_container = $MainControl/BookBackground/ContentArea/Thoughts/JournalList

# tabs
@onready var btn_npc = $MainControl/BookBackground/TabsContainer/NPCbutton
@onready var btn_items = $MainControl/BookBackground/TabsContainer/Itembutton
@onready var btn_thoughts = $MainControl/BookBackground/TabsContainer/Thoughtbutton

func _ready():
	visible = false 
	btn_npc.pressed.connect(show_npc_page)
	btn_items.pressed.connect(show_items_page)
	btn_thoughts.pressed.connect(show_thoughts_page)
	NotebookData.notebook_updated.connect(refresh_ui)

func _unhandled_input(event):
	if event.is_action_pressed("toggle_notebook"):
		if visible:
			close()
		else:
			open()

func open():
	visible = true
	get_tree().paused = true
	refresh_ui()
	show_items_page()

func close():
	visible = false
	get_tree().paused = false

func show_npc_page():
	page_npc.visible = true
	page_items.visible = false
	page_thoughts.visible = false

func show_items_page():
	page_npc.visible = false
	page_items.visible = true
	page_thoughts.visible = false

func show_thoughts_page():
	page_npc.visible = false
	page_items.visible = false
	page_thoughts.visible = true

func refresh_ui():
	for child in item_list_container.get_children(): child.queue_free()
	for child in npc_grid_container.get_children(): child.queue_free()
	for child in journal_list_container.get_children(): child.queue_free()
	
	for item_id in NotebookData.collected_item_ids:
		var data = NotebookData.get_item_data(item_id)
		if data.is_empty(): continue
		
		var new_entry = object_entry_scene.instantiate()
		item_list_container.add_child(new_entry)
		new_entry.set_entry_data(data["name"], data["description"], data["image"])

	for npc_id in NotebookData.unlocked_npc_ids:
		var data = NotebookData.get_npc_data(npc_id)
		if data.is_empty(): continue
		
		var btn = Button.new()
		btn.text = data["name"]
		btn.icon = load(data["portrait"])
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		btn.expand_icon = true
		btn.custom_minimum_size = Vector2(100, 130)
		btn.flat = false
		
		npc_grid_container.add_child(btn)

	for note_id in NotebookData.journal_entries:
		var data = NotebookData.get_thought_data(note_id)
		if data.is_empty(): continue
		
		var new_entry = object_entry_scene.instantiate()
		journal_list_container.add_child(new_entry)
		
		new_entry.set_entry_data(data["timestamp"], data["text"], "")
