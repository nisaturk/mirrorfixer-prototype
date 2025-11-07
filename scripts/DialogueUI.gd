extends CanvasLayer

@onready var dialogue_label = $PanelContainer/MainLayoutContainer/MarginContainer/DialogueLabel
@onready var choice_container = $PanelContainer/MainLayoutContainer/ChoiceContainer

var current_caller = null
var current_node_id: String = "" # tracks our current position in the dialogue JSON

func _ready():
	hide_box()

# takes a starting ID and the node that triggered the dialogue.
func start_dialogue(start_id: String, caller):
	if start_id.is_empty():
		return
		
	current_caller = caller
	visible = true
	process_node(start_id)

func process_node(id: String):
	# clear any old buttons
	for button in choice_container.get_children():
		button.queue_free()
	
	# "end" is the keyword to close the dialogue
	if id == "end":
		hide_box()
		return
	
	# get the dialogue data from the singleton
	var node_data = DialogueData.get_dialogue_node(id)
	
	if not node_data:
		hide_box()
		return
	
	# store current ID
	current_node_id = id
	
	# set the main text
	dialogue_label.text = node_data.get("text", "...")
	
	# check for special game logic actions
	if node_data.has("action"):
		handle_action(node_data["action"])
	
	# check the type to see what to do next
	if node_data["type"] == "line":
		pass
		
	elif node_data["type"] == "choice":
		# choices gotta be made. need to create buttons.
		var options = node_data.get("options", [])
		for option_data in options:
			var button = Button.new()
			button.text = option_data.get("text", "...")
			
			# connect the button's "pressed" signal to a new function
			# .bind() the "next_id" from the JSON to the function call
			button.pressed.connect(self._on_choice_made.bind(option_data.get("next_id", "end")))
			
			choice_container.add_child(button)

# called when a choice button is pressed
func _on_choice_made(next_id: String):
	process_node(next_id)

# handles hiding the box
func hide_box():
	visible = false
	current_caller = ""
	current_node_id = ""
	# clear buttons when hiding
	for button in choice_container.get_children():
		button.queue_free()

func _input(event):
	# do if the dialogue box is visible
	if not visible:
		return
		
	# get the data for our current node
	var node_data = DialogueData.get_dialogue_node(current_node_id)
	if not node_data:
		return

	# only advance on "interact" if it's a "line" node.
	# choices are handled by their buttons.
	if node_data["type"] == "line" and Input.is_action_just_pressed("interact"):
		get_viewport().set_input_as_handled()
		# get the next ID and process it
		var next_id = node_data.get("next_id", "end")
		process_node(next_id)

# handles the "action" tags from the JSON
func handle_action(action_name: String):
	if action_name == "allow_pass" and current_caller:
		# Check if the caller (Miss Manager) has the "allow_pass" function
		if current_caller.has_method("allow_pass"):
			current_caller.allow_pass()

func _process(delta):
	# Only run this if the box is visible
	if not visible:
		return

	# get the container that holds both your label and your buttons
	var main_layout = $PanelContainer/MainLayoutContainer
	
	# get the minimum size that the layout *wants* to be
	var content_height = main_layout.get_combined_minimum_size().y
	
	# set the parent PanelContainer's offset_top
	# to be that height (but negative, since it's an offset from the bottom)
	$PanelContainer.offset_top = -content_height
