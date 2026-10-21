extends Control

var title: Label
var continue_button: Button
var restart_button: Button
var level_select_button: Button
var restart_dialog: ConfirmationDialog


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
	continue_button = _add_button(box, "DOORGAAN")
	continue_button.pressed.connect(_on_continue)
	restart_button = _add_button(box, "OPNIEUW BEGINNEN")
	restart_button.pressed.connect(_on_restart_requested)
	level_select_button = _add_button(box, "LEVEL SELECT")
	level_select_button.pressed.connect(_on_level_select)
	_add_button(box, "HOE WERKT TOEPEN?").pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/tutorials.tscn")
	)
	_add_button(box, "INSTELLINGEN").pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/settings.tscn")
	)
	_build_restart_dialog()
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
	continue_button.disabled = not active
	continue_button.text = "DOORGAAN" if active else "DOORGAAN · GEEN ACTIEVE RUN"
	level_select_button.disabled = false


func _add_button(parent: Node, text: String) -> Button:
	var button := Button.new()
	button.text = text
	UiLayout.fit_button(button)
	button.custom_minimum_size = Vector2(0, 44)
	parent.add_child(button)
	return button


func _on_level_select() -> void:
	get_tree().change_scene_to_file("res://scenes/campaign.tscn")


func _on_restart_requested() -> void:
	if not Boot.flow.campaign.run_active:
		_on_restart_confirmed()
		return
	restart_dialog.popup_centered_ratio(0.88)


func _build_restart_dialog() -> void:
	restart_dialog = ConfirmationDialog.new()
	restart_dialog.title = "Opnieuw beginnen?"
	restart_dialog.dialog_text = (
		"Je actieve run, dopjes en power-ups vervallen.\n"
		+ "Vrijgespeelde levels, instellingen en tutorials blijven bewaard."
	)
	restart_dialog.ok_button_text = "OPNIEUW BEGINNEN"
	restart_dialog.cancel_button_text = "ANNULEREN"
	restart_dialog.confirmed.connect(_on_restart_confirmed)
	add_child(restart_dialog)


func _on_restart_confirmed() -> void:
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
