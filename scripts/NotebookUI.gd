extends CanvasLayer

var object_entry_scene = preload("res://scenes/object_entry.tscn")

@onready var page_container = $MainControl/BookBackground/ContentArea
@onready var tabs_container = $MainControl/BookBackground/TabsContainer
@onready var btn_prev = $MainControl/BookBackground/PrevButton
@onready var btn_next = $MainControl/BookBackground/NextButton

var items_per_page = {
	"npcs": 6,
	"items": 3,
	"thoughts": 4
}
var tabs: Dictionary = {}
var current_page: int = 0
var active_category: String = ""

func _ready():
	visible = false 
	NotebookData.notebook_updated.connect(refresh_ui)
	tabs = {
		"npcs": {
			"btn": tabs_container.get_node("NPCbutton"),
			"page": page_container.get_node("ResidentsPage"),
			"list": page_container.get_node("ResidentsPage/GalleryView")
		},
		"items": {
			"btn": tabs_container.get_node("Itembutton"),
			"page": page_container.get_node("Items"),
			"list": page_container.get_node("Items/ItemList")
		},
		"thoughts": {
			"btn": tabs_container.get_node("Thoughtbutton"),
			"page": page_container.get_node("Thoughts"),
			"list": page_container.get_node("Thoughts/JournalList")
		}
	}

	for category in tabs:
		var btn = tabs[category]["btn"]
		btn.pressed.connect(_on_tab_pressed.bind(category))

	if tabs["npcs"]["page"].has_node("ProfileView/BackButton"):
		var back_btn = tabs["npcs"]["page"].get_node("ProfileView/BackButton")
		back_btn.pressed.connect(_on_profile_back_pressed)
		
	btn_prev.pressed.connect(change_page.bind(-1))
	btn_next.pressed.connect(change_page.bind(1))

func _unhandled_input(event):
	if event.is_action_pressed("toggle_notebook"):
		if visible:
			close()
		else:
			open()

func open():
	visible = true
	get_tree().paused = true
	
	if active_category == "":
		_on_tab_pressed("thoughts")
	else:
		refresh_ui()

func close():
	visible = false
	get_tree().paused = false

func _on_tab_pressed(selected_category: String):
	active_category = selected_category
	current_page = 0
	
	for category in tabs:
		var page = tabs[category]["page"]
		page.visible = (category == selected_category)
	
	if selected_category == "npcs":
		_on_profile_back_pressed()
	
	refresh_ui()

func change_page(direction: int):
	current_page += direction
	refresh_ui()

func update_pagination_buttons(total_items: int):
	var limit = items_per_page.get(active_category, 4)
	var max_page = ceil(float(total_items) / float(limit)) - 1
	if max_page < 0: max_page = 0
	
	btn_prev.visible = (current_page > 0)
	btn_next.visible = (current_page < max_page)

	if active_category == "npcs":
		var page = tabs["npcs"]["page"]
		if page.has_node("ProfileView") and page.get_node("ProfileView").visible:
			btn_prev.visible = false
			btn_next.visible = false

func _on_profile_back_pressed():
	var page = tabs["npcs"]["page"]
	if page.has_node("ProfileView") and page.has_node("GalleryView"):
		page.get_node("ProfileView").visible = false
		page.get_node("GalleryView").visible = true
		refresh_ui()

func open_profile(data: Dictionary):
	var page = tabs["npcs"]["page"]
	var profile = page.get_node("ProfileView")
	
	if profile.has_node("NameLabel"): 
		profile.get_node("NameLabel").text = data.get("name", "???")
	
	if profile.has_node("BioLabel"): 
		profile.get_node("BioLabel").text = data.get("bio", "No information available.")
	
	if profile.has_node("Portrait"): 
		var path = data.get("portrait", "")
		if path != "": 
			profile.get_node("Portrait").texture = load(path)
	
	page.get_node("GalleryView").visible = false
	profile.visible = true
	
	btn_prev.visible = false
	btn_next.visible = false

func refresh_ui():
	for category in tabs:
		var container_to_clear = tabs[category]["list"]
		for child in container_to_clear.get_children():
			child.queue_free()

	if active_category == "" or not tabs.has(active_category): return

	var list_container = tabs[active_category]["list"]
	var all_unlocked_ids = NotebookData.unlocked_content.get(active_category, [])
	var limit = items_per_page.get(active_category, 4)
	var start_index = current_page * limit
	var end_index = start_index + limit
	var ids_to_show = all_unlocked_ids.slice(start_index, end_index)
	
	for id in ids_to_show:
		var data = NotebookData.get_entry_data(active_category, id)
		if data.is_empty(): continue
		
		if active_category == "npcs":
			create_npc_button(list_container, data)
		else:
			create_object_entry(list_container, data)

	update_pagination_buttons(all_unlocked_ids.size())

func create_object_entry(container, data):
	var new_entry = object_entry_scene.instantiate()
	container.add_child(new_entry)
	var title = data.get("name", "")
	var desc = data.get("description", data.get("text", "")) 
	var img = data.get("image", "")
	
	if data.has("timestamp"):
		title = data["timestamp"]
	new_entry.set_entry_data(title, desc, img)

func create_npc_button(container, data):
	var btn = Button.new()
	btn.text = data.get("name", "???")
	
	var icon_path = data.get("portrait", "")
	if icon_path != "":
		btn.icon = load(icon_path)
	
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	btn.expand_icon = true
	btn.custom_minimum_size = Vector2(100, 130)
	btn.pressed.connect(open_profile.bind(data))
	container.add_child(btn)
