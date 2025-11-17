extends Area2D

@export var dialogue_id: String = ""
@export var prioritylevel: int = 0
@export var portrait_id: String = ""
@onready var interaction_hint: Label = $HintLabel
@export var hint_text: String = "interact"

# new functions HELL YEAH
func show_hint():
	$HintLabel.text = "[" + hint_text + "]"
	$HintLabel.show()

func hide_hint():
	interaction_hint.hide()
