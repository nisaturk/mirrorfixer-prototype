extends Node

# signals for dialogues
signal request_dialogue(start_id: String, caller: Node, portrait_id: String)
signal dialogue_started
signal dialogue_ended(caller: Node)

# signals for actions!! + game logic stuff
signal action_triggered(action_name: String, caller: Node)
