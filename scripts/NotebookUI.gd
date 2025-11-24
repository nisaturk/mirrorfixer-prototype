extends CanvasLayer

@onready var book_bg = $MainControl/BookBackground
@onready var left_page = $MainControl/BookBackground/LeftPage
@onready var right_page = $MainControl/BookBackground/RightPage
@onready var btn_prev = $MainControl/BookBackground/PrevButton
@onready var btn_next = $MainControl/BookBackground/NextButton

var current_spread_index: int = 0 

func _ready():
	visible = false
	NotebookData.notebook_updated.connect(refresh_ui)
	btn_prev.pressed.connect(change_page.bind(-2))
	btn_next.pressed.connect(change_page.bind(2))

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

func close():
	visible = false
	get_tree().paused = false

func change_page(amount: int):
	current_spread_index += amount
	refresh_ui()

func refresh_ui():
	var total_pages = NotebookData.unlocked_page_ids.size()
	
	if current_spread_index < 0: current_spread_index = 0
	if current_spread_index >= total_pages and total_pages > 0: 
		current_spread_index = (total_pages - 1) / 2 * 2
	
	if current_spread_index < total_pages:
		var id = NotebookData.unlocked_page_ids[current_spread_index]
		var path = NotebookData.get_texture_path(id)
		left_page.texture = load(path)
	else:
		left_page.texture = null

	if current_spread_index + 1 < total_pages:
		var id = NotebookData.unlocked_page_ids[current_spread_index + 1]
		var path = NotebookData.get_texture_path(id)
		right_page.texture = load(path)
	else:
		right_page.texture = null

	btn_prev.visible = (current_spread_index > 0)
	btn_next.visible = (current_spread_index + 2 < total_pages)
