extends CanvasLayer

signal dialogue_cancelled(caller_node)
signal action_triggered(action_name, caller_node)

const portrait_map = { # new portrait library hehe
	"player_default": "res://assets/ui/portraits/thep-idle.png",
	"missmanager_default": "res://assets/ui/portraits/missmanager-idle.png",
	"maxime_default": "res://assets/ui/portraits/maxime.png",
	"ninh_default":"res://assets/ui/portraits/ninh.png" }
	
@onready var portrait_box = $MainLayout/PortraitBox
@onready var portrait_texture = $MainLayout/PortraitBox/PortraitTexture
@onready var dialogue_label = $MainLayout/ContentBox/MainLayoutContainer/MarginContainer/DialogueLabel
@onready var choice_container = $MainLayout/ContentBox/MainLayoutContainer/ChoiceContainer

var current_caller = null
var current_node_id: String = ""
var current_start_id: String = ""

func _ready():
	hide_box()
	
func process_node(id: String):
	for button in choice_container.get_children():
		button.queue_free()
	
	if id == "end":
		if not GlobalState.finished_dialogues.has(current_start_id):
			GlobalState.finished_dialogues.append(current_start_id)
			print("dialogue is dooone: ", current_start_id)
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
		var variable_name = node_data.get("variable", "")
		var is_condition_met = false
		
		if variable_name != "" and GlobalState.get(variable_name):
			is_condition_met = true
			
		if is_condition_met: 
			process_node(node_data.get("on_true", "end")) 
		else: 
			process_node(node_data.get("on_false", "end"))

# extra_portrait_id parameter added (for parented objs)
func start_dialogue(start_id: String, caller, extra_portrait_id: String = ""):
	if start_id.is_empty():
		return
	
	current_start_id = start_id
	current_caller = caller
	visible = true
	
	var key_to_use = extra_portrait_id
	
	if key_to_use and portrait_map.has(key_to_use):
		portrait_texture.texture = load(portrait_map[key_to_use])
		portrait_box.show()
	elif caller and portrait_map.has(caller.name):
		portrait_texture.texture = load(portrait_map[caller.name])
		portrait_box.show()
	else:
		portrait_box.hide()
	
	process_node(start_id)

func _on_choice_made(next_id: String):
	process_node(next_id)

func hide_box():
	visible = false
	current_caller = ""
	current_node_id = ""
	portrait_box.hide()
	
	# clear buttons when hiding
	for button in choice_container.get_children():
		button.queue_free()

# replaced _input with this
func _unhandled_input(event):
	if not visible:
		return
		
	var node_data = DialogueData.get_dialogue_node(current_node_id)
	if not node_data:
		return

	if node_data["type"] == "line" and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		var next_id = node_data.get("next_id", "end")
		process_node(next_id)

# handles the "action" tags from the JSON
func handle_action(action_name: String):
	# updated with a signal instead of the if blocks :')
	emit_signal("action_triggered", action_name, current_caller)
