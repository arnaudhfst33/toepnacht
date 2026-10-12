extends Control


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	Boot.ensure_flow()
	var bg := ColorRect.new()
	bg.color = Color(0.11, 0.13, 0.16)
	UiLayout.fill_rect(bg, 0)
	add_child(bg)
	var box := UiLayout.vbox(8)
	UiLayout.fill_rect(box, 12)
	add_child(box)
	var title := UiLayout.wrap_label()
	title.text = "Hoe werkt Toepen?"
	box.add_child(title)
	var items := [
		["Tutorial 1 — Blanco", "blanco", 1],
		["Tutorial 2 — Kloppen", "kloppen", 2],
		["Tutorial 3 — Bluffen", "bluffen", 3],
		["Tutorial 4 — Vuile Was", "was", 4],
		["Tutorial 5 — Toep", "toep", 5],
		["Tutorial 6 — Armoede", "armoede", 6],
		["Tutorial 7 — Avondwinkel", "winkel", 7],
	]
	for item in items:
		var done := Boot.flow.campaign.tutorial_done(int(item[2]))
		var label := str(item[0])
		if done:
			label += " (gedaan)"
		var mode := str(item[1])
		var button := Button.new()
		button.text = label
		UiLayout.fit_button(button)
		button.custom_minimum_size = Vector2(0, 40)
		button.pressed.connect(func() -> void:
			Boot.mode = mode
			get_tree().change_scene_to_file("res://scenes/table.tscn")
		)
		box.add_child(button)
	var back := Button.new()
	back.text = "TERUG NAAR CAMPAGNE"
	UiLayout.fit_button(back)
	back.custom_minimum_size = Vector2(0, 44)
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	)
	box.add_child(back)
