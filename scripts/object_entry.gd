extends MarginContainer

@onready var icon_texture = $HBoxContainer/Icon
@onready var title_label = $HBoxContainer/VBoxContainer/Title
@onready var desc_label = $HBoxContainer/VBoxContainer/Description

func set_entry_data(item_name: String, description: String, icon_path: String):
	title_label.text = item_name
	desc_label.text = description
	
	if icon_path != "":
		icon_texture.texture = load(icon_path)
		icon_texture.visible = true
	else:
		icon_texture.visible = false
