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
	title.text = "De Avondwinkel"
	root.add_child(title)
	caps_label = UiLayout.wrap_label()
	root.add_child(caps_label)
	slots_label = UiLayout.wrap_label()
	root.add_child(slots_label)
	offer_row = UiLayout.vbox(10)
	offer_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(offer_row)
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
		var card := UiLayout.vbox(4)
		var info := UiLayout.wrap_label(HORIZONTAL_ALIGNMENT_LEFT)
		info.text = "%s\n%d dopjes" % [PowerUpCatalog.display_name(id), PowerUpCatalog.cost(id)]
		card.add_child(info)
		var buy := Button.new()
		buy.text = "KOOP"
		UiLayout.fit_button(buy)
		buy.custom_minimum_size = Vector2(0, 36)
		var idx := i
		buy.pressed.connect(func() -> void:
			Boot.flow.buy_shop_index(idx)
			_refresh()
		)
		buy.disabled = (not run.has_inventory_slot()) or run.beer_caps < PowerUpCatalog.cost(id)
		card.add_child(buy)
		offer_row.add_child(card)


func _on_verder() -> void:
	Boot.flow.leave_shop()
	Boot.mode = "continue"
	get_tree().change_scene_to_file("res://scenes/table.tscn")
