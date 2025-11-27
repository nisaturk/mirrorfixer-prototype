extends CanvasLayer

const portrait_map = { 
	"player_default": "res://assets/ui/portraits/thep-idle.png",
	"missmanager_default": "res://assets/ui/portraits/missmanager-idle.png",
	"maxime_default": "res://assets/ui/portraits/maxime.png",
	"ninh_default":"res://assets/ui/portraits/ninh.png" 
}

@onready var portrait_box = $MainLayout/PortraitBox
@onready var portrait_texture = $MainLayout/PortraitBox/PortraitTexture
@onready var dialogue_label = $MainLayout/ContentBox/MainLayoutContainer/MarginContainer/DialogueLabel
@onready var choice_container = $MainLayout/ContentBox/MainLayoutContainer/ChoiceContainer

var current_caller = null
var current_node_id: String = ""
var current_start_id: String = ""

# new variables for the text animation
var type_tween: Tween
var is_typing: bool = false
const TEXT_SPEED: float = 0.06 # remember, lower is faster

func _ready():
	hide_box()
	Events.request_dialogue.connect(start_dialogue)

func process_node(id: String):	
	for button in choice_container.get_children():
		button.queue_free()
	
	if id == "end":
		if current_start_id != "" and not GlobalState.finished_dialogues.has(current_start_id):
			GlobalState.finished_dialogues.append(current_start_id)
			
		hide_box()
		Events.dialogue_ended.emit(current_caller)
		return
		
	var node_data = DialogueData.get_dialogue_node(id)
	if not node_data:
		hide_box()
		return

	current_node_id = id
	# adding + setting flags for the new save system
	if node_data.has("set_flag"):
		var flag_name = node_data["set_flag"]
		GlobalState.story_flags[flag_name] = true
		print("Flag Set: ", flag_name)
	
	if node_data.has("action"):
		handle_action(node_data["action"])
	
	var full_text = node_data.get("text", "...")
	dialogue_label.text = full_text # preparation for the tween
	dialogue_label.visible_ratio = 0.0
	dialogue_label.show()
	choice_container.hide() 

	if node_data["type"] == "line":
		pass
		
	elif node_data["type"] == "choice":
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
		return 

	start_text_animation(node_data["type"] == "choice")

func start_text_animation(is_choice_node: bool):
	is_typing = true
	dialogue_label.visible_ratio = 0.0
	
	if type_tween:
		type_tween.kill()
	
	type_tween = create_tween()
	var duration = dialogue_label.text.length() * TEXT_SPEED
	
	type_tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)
	type_tween.finished.connect(func(): _on_typing_finished(is_choice_node))

func _on_typing_finished(is_choice_node: bool):
	is_typing = false
	dialogue_label.visible_ratio = 1.0
	
	if is_choice_node:
		choice_container.show()
		if choice_container.get_child_count() > 0:
			choice_container.get_child(0).grab_focus()

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

	Events.dialogue_started.emit()
	process_node(start_id)

func _on_choice_made(next_id: String):
	process_node(next_id)

func hide_box():
	visible = false
	current_caller = ""
	current_node_id = ""
	portrait_box.hide()
	
	if type_tween:
		type_tween.kill()
	
	for button in choice_container.get_children():
		button.queue_free()

func _unhandled_input(event):
	if not visible:
		return
	
	var node_data = DialogueData.get_dialogue_node(current_node_id)
	if not node_data:
		return

	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled() 
		
		if is_typing:
			if type_tween:
				type_tween.kill()
			_on_typing_finished(node_data["type"] == "choice")
			return

		if node_data["type"] == "line":
			var next_id = node_data.get("next_id", "end")
			process_node(next_id)

func handle_action(action_name: String):
	Events.emit_signal("action_triggered", action_name, current_caller)
