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
	_toggle(box, "Open kaarten in eerste pot", "open_first_pot")
	_animation_speed(box)
	var animation_help := UiLayout.wrap_label()
	animation_help.text = (
		"Rustig laat kaartbewegingen langer zien. "
		+ "Snel is bedoeld voor spelers die Toepen al kennen."
	)
	animation_help.modulate = Color(0.78, 0.78, 0.72)
	box.add_child(animation_help)
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


func _animation_speed(parent: Node) -> void:
	var button := Button.new()
	_refresh_animation_speed(button)
	UiLayout.fit_button(button)
	button.custom_minimum_size = Vector2(0, 40)
	button.pressed.connect(func() -> void:
		var settings := Boot.flow.campaign.settings
		var current := str(settings.get("animation_speed", "normal"))
		settings["animation_speed"] = "fast" if current == "normal" else "normal"
		_refresh_animation_speed(button)
		Boot.flow.persist()
	)
	parent.add_child(button)


func _refresh_animation_speed(button: Button) -> void:
	var speed := str(Boot.flow.campaign.settings.get("animation_speed", "normal"))
	button.text = "Animaties: %s" % ("snel" if speed == "fast" else "rustig")
