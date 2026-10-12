extends Control

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.14, 0.12)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	var box := VBoxContainer.new()
	box.set_anchors_preset(PRESET_FULL_RECT)
	box.offset_left = 40
	box.offset_top = 80
	box.offset_right = -40
	box.offset_bottom = -80
	box.add_theme_constant_override("separation", 16)
	add_child(box)
	var title := Label.new()
	title.text = "Toepnacht"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	_add_button(box, "SPELEN", "play")
	_add_button(box, "TUTORIAL 1 — Blanco Toepen", "blanco")
	_add_button(box, "TUTORIAL 2 — Kloppen", "kloppen")


func _add_button(parent: Node, text: String, mode: String) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(func() -> void:
		Boot.mode = mode
		get_tree().change_scene_to_file("res://scenes/table.tscn")
	)
	parent.add_child(button)
