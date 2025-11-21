extends Node

# signals for dialogues
@warning_ignore("unused_signal") # supressin em bc theyre annoying
signal request_dialogue(start_id: String, caller: Node, portrait_id: String)
@warning_ignore("unused_signal")
signal dialogue_started
@warning_ignore("unused_signal")
signal dialogue_ended(caller: Node)

# signals for actions!!
@warning_ignore("unused_signal")
signal action_triggered(action_name: String, caller: Node)
