extends Area2D

class_name Interactable

@export var dialogue_id: String = ""
@export var prioritylevel: int = 0
@export var portrait_id: String = ""
@export var hint_text: String = "interact"
@export var single_use: bool = false

@onready var hint_label: Label = $HintLabel

# new UPDATED functions hell yeah
func show_hint():
	if hint_label:
		hint_label.text = "[" + hint_text + "]"
		hint_label.show()

func hide_hint():
	if hint_label:
		hint_label.hide()

# new function to turn off some interactions after theyve been interacted with
func can_interact() -> bool:
	if single_use and GlobalState.finished_dialogues.has(dialogue_id):
		return false
	return true
