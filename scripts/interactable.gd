extends Area2D

class_name Interactable

@export var dialogue_id: String = ""
@export var prioritylevel: int = 0
@export var portrait_id: String = ""
@export var hint_text: String = "interact"
@export var single_use: bool = false

# new UPDATED functions hell yeah
func show_hint():
	var label_node = get_node_or_null("HintLabel")
	if label_node:
		label_node.text = "[" + hint_text + "]"
		label_node.show()

func hide_hint():
	var label_node = get_node_or_null("HintLabel")
	if label_node:
		label_node.hide()

# new function to turn off some interactions after theyve been interacted with
func can_interact() -> bool:
	if single_use and GlobalState.finished_dialogues.has(dialogue_id):
		return false
	return true
