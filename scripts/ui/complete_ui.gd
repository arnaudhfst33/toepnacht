extends Control


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.16, 0.2)
	UiLayout.fill_rect(bg, 0)
	add_child(bg)
	var box := UiLayout.vbox(16)
	UiLayout.fill_rect(box, 16)
	add_child(box)
	var title := UiLayout.wrap_label()
	title.text = "Studentenhuis voltooid.\nKroeg is permanent ontgrendeld."
	title.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(title)
	var button := Button.new()
	button.text = "HOOFDMENU"
	UiLayout.fit_button(button)
	button.custom_minimum_size = Vector2(0, 44)
	button.pressed.connect(func() -> void:
		Boot.mode = "play"
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	)
	box.add_child(button)
