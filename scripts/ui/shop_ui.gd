extends Control

## Placeholder De Avondwinkel.

var caps_label: Label
var slots_label: Label
var offer_row: VBoxContainer


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	if Boot.flow == null:
		var save := SaveGame.new()
		save.memory_only = true
		Boot.flow = CampaignFlow.new(save)
		Boot.flow.start_new_studentenhuis_run()
		Boot.flow.campaign.beer_caps = 20
		Boot.flow.open_shop()
	_build()
	_refresh()


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.16, 0.12, 0.08)
	UiLayout.fill_rect(bg, 0)
	add_child(bg)
	var root := UiLayout.vbox(10)
	UiLayout.fill_rect(root, 12)
	add_child(root)
	var title := UiLayout.wrap_label()
	var loc := ""
	if Boot.flow != null:
		loc = LocationId.display_name(Boot.flow.campaign.location)
	title.text = "De Avondwinkel\n%s" % loc
	root.add_child(title)
	caps_label = UiLayout.wrap_label()
	root.add_child(caps_label)
	slots_label = UiLayout.wrap_label()
	root.add_child(slots_label)
	var help := UiLayout.wrap_label()
	help.text = "Kies slim · je kunt maximaal 2 power-ups bewaren"
	help.modulate = Color("d9c98f")
	root.add_child(help)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)
	offer_row = UiLayout.vbox(10)
	offer_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(offer_row)
	var verder := Button.new()
	verder.text = "VERDER"
	UiLayout.fit_button(verder)
	verder.custom_minimum_size = Vector2(0, 44)
	verder.pressed.connect(_on_verder)
	root.add_child(verder)


func _refresh() -> void:
	var run := Boot.flow.campaign
	caps_label.text = "Bierdopjes: %d" % run.beer_caps
	var held: PackedStringArray = PackedStringArray()
	for i in PowerUpId.MAX_SLOTS:
		if i < run.inventory.size():
			held.append(PowerUpCatalog.display_name(run.inventory[i]))
		else:
			held.append("(leeg)")
	slots_label.text = "Slot 1: %s\nSlot 2: %s" % [held[0], held[1]]
	for child in offer_row.get_children():
		child.queue_free()
	if run.shop == null:
		return
	for i in run.shop.offerings.size():
		var id := str(run.shop.offerings[i])
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", UiLayout.pixel_panel(Color("29202ddd"), Color("d6aa4c")))
		offer_row.add_child(panel)
		var card := UiLayout.vbox(5)
		panel.add_child(card)
		var info := UiLayout.wrap_label(HORIZONTAL_ALIGNMENT_LEFT)
		info.text = "%s  ·  %d DOPJES" % [PowerUpCatalog.display_name(id).to_upper(), PowerUpCatalog.cost(id)]
		info.add_theme_color_override("font_color", Color("f2d477"))
		card.add_child(info)
		var effect := UiLayout.wrap_label(HORIZONTAL_ALIGNMENT_LEFT)
		effect.text = PowerUpCatalog.description(id)
		effect.add_theme_font_size_override("font_size", 13)
		card.add_child(effect)
		var timing := UiLayout.wrap_label(HORIZONTAL_ALIGNMENT_LEFT)
		timing.text = PowerUpCatalog.timing(id)
		timing.add_theme_font_size_override("font_size", 11)
		timing.modulate = Color("b8d7cf")
		card.add_child(timing)
		var buy := Button.new()
		buy.text = "KOOP · %d DOPJES" % PowerUpCatalog.cost(id)
		UiLayout.fit_button(buy)
		buy.custom_minimum_size = Vector2(0, 36)
		var idx := i
		buy.pressed.connect(func() -> void:
			Boot.flow.buy_shop_index(idx)
			_refresh()
		)
		buy.disabled = (not run.has_inventory_slot()) or run.beer_caps < PowerUpCatalog.cost(id)
		if not run.has_inventory_slot():
			buy.text = "SLOTS VOL"
		elif run.beer_caps < PowerUpCatalog.cost(id):
			buy.text = "TE WEINIG DOPJES"
		card.add_child(buy)
		panel.modulate.a = 0.0
		panel.position.x = 24.0
		var delay := float(i) * 0.08
		var tween := panel.create_tween().set_parallel(true)
		tween.tween_property(panel, "modulate:a", 1.0, 0.28).set_delay(delay)
		tween.tween_property(panel, "position:x", 0.0, 0.32).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_verder() -> void:
	Boot.flow.leave_shop()
	Boot.mode = "continue"
	get_tree().change_scene_to_file("res://scenes/table.tscn")
