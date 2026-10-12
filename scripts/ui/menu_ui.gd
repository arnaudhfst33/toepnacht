extends Control

var title: Label
var play_button: Button
var continue_button: Button


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
	title = Label.new()
	title.text = "Toepnacht"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var sub := Label.new()
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Boot.ensure_flow()
	var unlocked := LocationId.display_name(Boot.flow.campaign.highest_unlocked_location)
	sub.text = "Studentenhuis  ·  vrijgespeeld tot: %s" % unlocked
	if Boot.flow.campaign.studentenhuis_completed:
		sub.text += "\nStudentenhuis voltooid — Kroeg ontgrendeld."
	box.add_child(sub)
	play_button = _add_button(box, "SPELEN")
	play_button.pressed.connect(_on_play)
	continue_button = _add_button(box, "DOORGAAN")
	continue_button.pressed.connect(_on_continue)
	_add_button(box, "TUTORIAL 1 — Blanco Toepen").pressed.connect(func() -> void:
		Boot.mode = "blanco"
		get_tree().change_scene_to_file("res://scenes/table.tscn")
	)
	_add_button(box, "TUTORIAL 2 — Kloppen").pressed.connect(func() -> void:
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
