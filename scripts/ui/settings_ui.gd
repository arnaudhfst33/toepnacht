extends Control


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	Boot.ensure_flow()
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.12, 0.14)
	UiLayout.fill_rect(bg, 0)
	add_child(bg)
	var box := UiLayout.vbox(10)
	UiLayout.fill_rect(box, 12)
	add_child(box)
	var title := UiLayout.wrap_label()
	title.text = "Instellingen"
	box.add_child(title)
	_toggle(box, "Muziek", "music_on")
	_toggle(box, "SFX", "sfx_on")
	_toggle(box, "Haptics", "haptics_on")
	_toggle(box, "Tips", "tips_on")
	var back := Button.new()
	back.text = "TERUG"
	UiLayout.fit_button(back)
	back.custom_minimum_size = Vector2(0, 44)
	back.pressed.connect(func() -> void:
		Boot.flow.persist()
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	)
	box.add_child(back)


func _toggle(parent: Node, label: String, key: String) -> void:
	var button := Button.new()
	_refresh_toggle(button, label, key)
	UiLayout.fit_button(button)
	button.custom_minimum_size = Vector2(0, 40)
	button.pressed.connect(func() -> void:
		var s := Boot.flow.campaign.settings
		s[key] = not bool(s.get(key, true))
		_refresh_toggle(button, label, key)
		Boot.flow.persist()
	)
	parent.add_child(button)


func _refresh_toggle(button: Button, label: String, key: String) -> void:
	var on := bool(Boot.flow.campaign.settings.get(key, true))
	button.text = "%s: %s" % [label, "aan" if on else "uit"]
