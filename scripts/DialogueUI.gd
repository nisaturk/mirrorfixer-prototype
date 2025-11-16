extends CanvasLayer

signal dialogue_cancelled(caller_node)
signal action_triggered(action_name, caller_node)

const portrait_map = { # new portrait library hehe
	"Player": "res://assets/ui/portraits/thep-idle.png",
	"IAAreas": "res://assets/ui/portraits/thep-idle.png",
	"MissManager": "res://assets/ui/portraits/missmanager-idle.png",
	"Maxime": "res://assets/ui/portraits/maxime.png",
	"Ninh":"res://assets/ui/portraits/ninh.png" }
	
@onready var portrait_box = $MainLayout/PortraitBox
@onready var portrait_texture = $MainLayout/PortraitBox/PortraitTexture
@onready var dialogue_label = $MainLayout/ContentBox/MainLayoutContainer/MarginContainer/DialogueLabel
@onready var choice_container = $MainLayout/ContentBox/MainLayoutContainer/ChoiceContainer

var current_caller = null
var current_node_id: String = ""

func _ready():
	hide_box()
	
func process_node(id: String):
	for button in choice_container.get_children():
		button.queue_free()
	
	if id == "end":
		emit_signal("dialogue_cancelled", current_caller)
		hide_box()
		return
	
	var node_data = DialogueData.get_dialogue_node(id)
	if not node_data:
		hide_box()
		return

	current_node_id = id
	
	if node_data.has("action"):
		handle_action(node_data["action"])
	
	if node_data["type"] == "line":
		dialogue_label.show()
		dialogue_label.text = node_data.get("text", "...")
		choice_container.hide()
		
	elif node_data["type"] == "choice":
		dialogue_label.show()
		dialogue_label.text = node_data.get("text", "...")
		choice_container.show()

		var options = node_data.get("options", [])
		for option_data in options:
			var button = Button.new()
			button.text = option_data.get("text", "...")
			button.pressed.connect(self._on_choice_made.bind(option_data.get("next_id", "end")))
			choice_container.add_child(button)
	
	elif node_data["type"] == "conditional":
		if DialogueData.has_shard == true: 
			process_node(node_data.get("on_true", "end")) 
		else: 
			process_node(node_data.get("on_false", "end"))

func start_dialogue(start_id: String, caller):
	if start_id.is_empty():
		return
		
	current_caller = caller
	visible = true
	
	var portrait_key = caller.get("portrait_id")

	if portrait_key and portrait_map.has(portrait_key):
		portrait_texture.texture = load(portrait_map[portrait_key])
		portrait_box.show()
	elif caller and portrait_map.has(caller.name):
		portrait_texture.texture = load(portrait_map[caller.name])
		portrait_box.show()
	else:
		portrait_box.hide()
	
	process_node(start_id)

# called when a choice button is pressed
func _on_choice_made(next_id: String):
	if next_id == "end":
		emit_signal("dialogue_cancelled", current_caller)
	process_node(next_id)

func hide_box():
	visible = false
	current_caller = ""
	current_node_id = ""
	portrait_box.hide()
	
	# clear buttons when hiding
	for button in choice_container.get_children():
		button.queue_free()

func _input(_event):
	if not visible:
		return
		
	var node_data = DialogueData.get_dialogue_node(current_node_id)
	if not node_data:
		return
	# only advance on "interact" if it's a "line" node
	# choices are handled by the buttons above
	if node_data["type"] == "line" and Input.is_action_just_pressed("interact"):
		get_viewport().set_input_as_handled()
		# get the next ID and process it
		var next_id = node_data.get("next_id", "end")
		process_node(next_id)

# handles the "action" tags from the JSON
func handle_action(action_name: String):
	# updated with a signal instead of the if blocks :')
	emit_signal("action_triggered", action_name, current_caller)
