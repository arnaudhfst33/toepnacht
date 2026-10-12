extends Control


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	Boot.ensure_flow()
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.16, 0.2)
	UiLayout.fill_rect(bg, 0)
	add_child(bg)
	var box := UiLayout.vbox(16)
	UiLayout.fill_rect(box, 16)
	add_child(box)
	var title := UiLayout.wrap_label()
	title.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var c := Boot.flow.campaign
	if c.campaign_complete:
		title.text = "TOEPNACHT UITGESPEELD\n\nJe hebt De Praeses verslagen.\nSamenvatting: alle locaties vrijgespeeld.\nJe kunt ontgrendelde locaties opnieuw spelen."
	else:
		title.text = "%s voltooid.\n%s is permanent ontgrendeld." % [
			LocationId.display_name(c.location),
			LocationId.display_name(c.highest_unlocked_location),
		]
	box.add_child(title)
	_add_button(box, "TERUG NAAR MENU").pressed.connect(func() -> void:
		Boot.mode = "play"
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	)
	_add_button(box, "OPNIEUW SPELEN / LOCATIES").pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/campaign.tscn")
	)


func _add_button(parent: Node, text: String) -> Button:
	var button := Button.new()
	button.text = text
	UiLayout.fit_button(button)
	button.custom_minimum_size = Vector2(0, 44)
	parent.add_child(button)
	return button
