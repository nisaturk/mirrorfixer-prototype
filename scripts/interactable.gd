extends Area2D

@export var dialogue_id: String = ""
@export var prioritylevel: int = 0
@export var portrait_id: String = ""
@onready var interaction_hint: Label = $HintLabel
@export var hint_text: String = "interact"
@export var single_use: bool = false

# new functions HELL YEAH
func show_hint():
	$HintLabel.text = "[" + hint_text + "]"
	$HintLabel.show()

func hide_hint():
	interaction_hint.hide()

# new function to turn off some interactions after theyve been interacted with
func can_interact() -> bool:
	if single_use and GlobalState.finished_dialogues.has(dialogue_id):
		return false
	return true
