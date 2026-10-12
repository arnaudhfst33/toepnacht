extends Control

var title: Label
var play_button: Button
var continue_button: Button


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.14, 0.12)
	UiLayout.fill_rect(bg, 0)
	add_child(bg)
	var box := UiLayout.vbox(12)
	UiLayout.fill_rect(box, 16)
	add_child(box)
	title = UiLayout.wrap_label()
	title.text = "Toepnacht"
	box.add_child(title)
	var sub := UiLayout.wrap_label()
	Boot.ensure_flow()
	sub.text = _status_line()
	box.add_child(sub)
	play_button = _add_button(box, "SPELEN")
	play_button.pressed.connect(_on_play)
	continue_button = _add_button(box, "DOORGAAN")
	continue_button.pressed.connect(_on_continue)
	_add_button(box, "HOE WERKT TOEPEN?").pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/tutorials.tscn")
	)
	_add_button(box, "INSTELLINGEN").pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/settings.tscn")
	)
	_refresh_buttons()


func _status_line() -> String:
	var c := Boot.flow.campaign
	var line := "Vrijgespeeld tot: %s" % LocationId.display_name(c.highest_unlocked_location)
	if c.campaign_complete:
		line += "\nCampagne voltooid."
	elif c.studentenhuis_completed:
		line += "\nStudentenhuis voltooid."
	if c.run_active:
		line += "\nActieve run: %s potje %d" % [LocationId.display_name(c.location), c.potje]
	return line


func _refresh_buttons() -> void:
	var active := Boot.flow.campaign.run_active
	play_button.visible = not active
	continue_button.visible = active


func _add_button(parent: Node, text: String) -> Button:
	var button := Button.new()
	button.text = text
	UiLayout.fit_button(button)
	button.custom_minimum_size = Vector2(0, 44)
	parent.add_child(button)
	return button


func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/campaign.tscn")


func _on_continue() -> void:
	Boot.ensure_flow()
	Boot.mode = "continue"
	if Boot.flow.campaign.shop != null and Boot.flow.campaign.shop.active:
		get_tree().change_scene_to_file("res://scenes/shop.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/table.tscn")
