extends Control


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.16, 0.2)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	var box := VBoxContainer.new()
	box.set_anchors_preset(PRESET_FULL_RECT)
	box.offset_left = 32
	box.offset_top = 120
	box.offset_right = -32
	box.offset_bottom = -120
	box.add_theme_constant_override("separation", 16)
	add_child(box)
	var title := Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.text = "Studentenhuis voltooid.\nKroeg is permanent ontgrendeld."
	box.add_child(title)
	var button := Button.new()
	button.text = "HOOFDMENU"
	button.pressed.connect(func() -> void:
		Boot.mode = "play"
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	)
	box.add_child(button)
