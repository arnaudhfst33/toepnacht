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
	var unlocked := LocationId.display_name(Boot.flow.campaign.highest_unlocked_location)
	sub.text = "Studentenhuis\nVrijgespeeld tot: %s" % unlocked
	if Boot.flow.campaign.studentenhuis_completed:
		sub.text += "\nStudentenhuis voltooid.\nKroeg ontgrendeld."
	box.add_child(sub)
	play_button = _add_button(box, "SPELEN")
	play_button.pressed.connect(_on_play)
	continue_button = _add_button(box, "DOORGAAN")
	continue_button.pressed.connect(_on_continue)
	_add_button(box, "Tutorial 1 Blanco").pressed.connect(func() -> void:
		Boot.mode = "blanco"
		get_tree().change_scene_to_file("res://scenes/table.tscn")
	)
	_add_button(box, "Tutorial 2 Kloppen").pressed.connect(func() -> void:
		Boot.mode = "kloppen"
		get_tree().change_scene_to_file("res://scenes/table.tscn")
	)
	_refresh_buttons()


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
	Boot.ensure_flow()
	Boot.flow.start_new_studentenhuis_run()
	Boot.mode = "play"
	get_tree().change_scene_to_file("res://scenes/table.tscn")


func _on_continue() -> void:
	Boot.ensure_flow()
	Boot.mode = "continue"
	if Boot.flow.campaign.shop != null and Boot.flow.campaign.shop.active:
		get_tree().change_scene_to_file("res://scenes/shop.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/table.tscn")
