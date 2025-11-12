extends Area2D

@export var dialogue_id: String = ""
@export var prioritylevel: int = 0
@onready var interaction_hint: Label = $InteractionHint

# new functions HELL YEAH
func show_hint():
	interaction_hint.show()

func hide_hint():
	interaction_hint.hide()
