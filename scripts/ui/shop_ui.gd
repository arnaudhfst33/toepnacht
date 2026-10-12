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
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	var root := VBoxContainer.new()
	root.set_anchors_preset(PRESET_FULL_RECT)
	root.offset_left = 20
	root.offset_top = 24
	root.offset_right = -20
	root.offset_bottom = -24
	root.add_theme_constant_override("separation", 12)
	add_child(root)
	var title := Label.new()
	title.text = "De Avondwinkel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)
	caps_label = Label.new()
	caps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(caps_label)
	slots_label = Label.new()
	slots_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slots_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(slots_label)
	offer_row = VBoxContainer.new()
	offer_row.add_theme_constant_override("separation", 8)
	root.add_child(offer_row)
	var verder := Button.new()
	verder.text = "VERDER"
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
	slots_label.text = "Slots: %s  ·  %s" % [held[0], held[1]]
	for child in offer_row.get_children():
		child.queue_free()
	if run.shop == null:
		return
	for i in run.shop.offerings.size():
		var id := str(run.shop.offerings[i])
		var row := HBoxContainer.new()
		var info := Label.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.text = "%s — %d dopjes" % [PowerUpCatalog.display_name(id), PowerUpCatalog.cost(id)]
		row.add_child(info)
		var buy := Button.new()
		buy.text = "KOOP"
		var idx := i
		buy.pressed.connect(func() -> void:
			Boot.flow.buy_shop_index(idx)
			_refresh()
		)
		buy.disabled = (not run.has_inventory_slot()) or run.beer_caps < PowerUpCatalog.cost(id)
		row.add_child(buy)
		offer_row.add_child(row)


func _on_verder() -> void:
	Boot.flow.leave_shop()
	Boot.mode = "continue"
	get_tree().change_scene_to_file("res://scenes/table.tscn")
