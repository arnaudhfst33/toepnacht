extends Control


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	Boot.ensure_flow()
	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.12, 0.14)
	UiLayout.fill_rect(bg, 0)
	add_child(bg)
	var box := UiLayout.vbox(10)
	UiLayout.fill_rect(box, 12)
	add_child(box)
	var title := UiLayout.wrap_label()
	title.text = "Campagne"
	if Boot.test_all_levels:
		title.text += "\nTESTVERSIE · ALLE LEVELS OPEN"
	if Boot.flow.campaign.campaign_complete:
		title.text += "\nTOEPNACHT UITGESPEELD"
	box.add_child(title)
	if Boot.flow.campaign.run_active:
		var active := UiLayout.wrap_label()
		active.text = "Actieve run: %s potje %d" % [
			LocationId.display_name(Boot.flow.campaign.location),
			Boot.flow.campaign.potje,
		]
		box.add_child(active)
	for loc in range(LocationId.COUNT):
		var button := _make_button(_location_label(loc))
		var captured := loc
		button.disabled = (not Boot.test_all_levels) and loc > Boot.flow.campaign.highest_unlocked_location
		button.pressed.connect(func() -> void:
			_pick_location(captured)
		)
		box.add_child(button)
	box.add_child(_make_button("TERUG"))
	box.get_child(box.get_child_count() - 1).pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	)
	if OS.is_debug_build():
		var dev := UiLayout.wrap_label()
		dev.text = "DEV"
		box.add_child(dev)
		var b1 := _make_button("DEV: Kroeg potje 2")
		b1.pressed.connect(func() -> void:
			_dev_jump(LocationId.KROEG, 2, 12)
		)
		box.add_child(b1)
		var b2 := _make_button("DEV: Sociëteit boss")
		b2.pressed.connect(func() -> void:
			_dev_jump(LocationId.SOCIETEIT, 3, 20)
		)
		box.add_child(b2)
		var b3 := _make_button("DEV: +Wasdag")
		b3.pressed.connect(func() -> void:
			var c := Boot.flow.campaign
			c.add_power_up(PowerUpId.WASDAG)
			Boot.flow.persist()
		)
		box.add_child(b3)


func _location_label(loc: int) -> String:
	var c := Boot.flow.campaign
	var label := LocationId.display_name(loc)
	if loc > c.highest_unlocked_location:
		label += " (vergrendeld)"
	elif c.is_location_completed(loc):
		label += " (voltooid)"
	if c.run_active and c.location == loc:
		label += " · actief"
	return label


func _make_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	UiLayout.fit_button(button)
	button.custom_minimum_size = Vector2(0, 40)
	return button


func _pick_location(loc: int) -> void:
	var c := Boot.flow.campaign
	if c.run_active and c.location == loc:
		Boot.mode = "continue"
		if c.shop != null and c.shop.active:
			get_tree().change_scene_to_file("res://scenes/shop.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/table.tscn")
		return
	Boot.flow.start_new_run(loc)
	Boot.mode = "play"
	get_tree().change_scene_to_file("res://scenes/table.tscn")


func _dev_jump(loc: int, potje: int, caps: int) -> void:
	if not OS.is_debug_build():
		return
	var c := Boot.flow.campaign
	c.highest_unlocked_location = maxi(c.highest_unlocked_location, loc)
	c.start_new_run(loc)
	c.potje = potje
	c.beer_caps = caps
	Boot.flow.persist()
	Boot.mode = "play"
	get_tree().change_scene_to_file("res://scenes/table.tscn")
