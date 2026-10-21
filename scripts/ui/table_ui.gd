extends Control

## Mobile-first retro table. Gameplay remains in TableSession and core classes.

var session: TableSession
var status_label: Label
var stake_label: Label
var trick_label: Label
var trick_table: RetroTrickTable
var scores_label: Label
var hand_row: HBoxContainer
var knock_button: Button
var mee_button: Button
var pas_button: Button
var next_round_button: Button
var toep_button: Button
var kans_button: Button
var vuile_button: Button
var witte_button: Button
var skip_specials_button: Button
var challenge_button: Button
var decline_button: Button
var tip_label: Label
var card_tip_bubble: VBoxContainer
var card_tip_panel: PanelContainer
var armoede_label: Label
var caps_label: Label
var peek_label: Label
var power_row: HBoxContainer
var huis_row: HFlowContainer
var campaign_button: Button
var title_label: Label
var tips_button: Button
var menu_button: Button
var leave_dialog: ConfirmationDialog
var bg_rect: RetroTableBackdrop
var skip_wasdag_button: Button
var hand_strength_label: Label
var animation_layer: Control
var opponent_portraits: Dictionary = {}
var animation_running: bool = false


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	_build_layout()
	session = TableSession.new()
	match Boot.mode:
		"blanco":
			Boot.ensure_flow()
			session.start_tutorial_blanco()
			Boot.flow.mark_tutorial(1)
		"kloppen":
			Boot.ensure_flow()
			session.start_tutorial_kloppen()
			Boot.flow.mark_tutorial(2)
		"bluffen":
			Boot.ensure_flow()
			session.start_tutorial_bluffen()
			Boot.flow.mark_tutorial(3)
		"was":
			Boot.ensure_flow()
			session.start_tutorial_was()
			Boot.flow.mark_tutorial(4)
		"toep":
			Boot.ensure_flow()
			session.start_tutorial_toep()
			Boot.flow.mark_tutorial(5)
		"armoede":
			Boot.ensure_flow()
			session.start_tutorial_armoede()
			Boot.flow.mark_tutorial(6)
		"winkel":
			Boot.ensure_flow()
			session.start_tutorial_winkel()
			Boot.flow.mark_tutorial(7)
		_:
			Boot.ensure_flow()
			session.bind_campaign(Boot.flow)
			if not Boot.flow.campaign.run_active:
				Boot.flow.start_new_studentenhuis_run()
			session.start_campaign_pot()
	_refresh()


func _build_layout() -> void:
	bg_rect = RetroTableBackdrop.new()
	UiLayout.fill_rect(bg_rect, 0)
	add_child(bg_rect)

	var margins := UiLayout.portrait_margins()
	add_child(margins)

	var root := UiLayout.vbox(6)
	margins.add_child(root)

	var middle := UiLayout.vbox(4)
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.clip_contents = true
	root.add_child(middle)

	var table_toolbar := UiLayout.hbox(6)
	middle.add_child(table_toolbar)
	menu_button = Button.new()
	menu_button.text = "MENU"
	menu_button.custom_minimum_size = Vector2(76, 34)
	menu_button.pressed.connect(_on_menu_requested)
	table_toolbar.add_child(menu_button)
	title_label = UiLayout.wrap_label()
	title_label.text = "Toepnacht"
	title_label.size_flags_stretch_ratio = 1.5
	table_toolbar.add_child(title_label)
	tips_button = Button.new()
	tips_button.custom_minimum_size = Vector2(86, 34)
	tips_button.pressed.connect(_on_toggle_tips)
	table_toolbar.add_child(tips_button)

	var hud := UiLayout.hbox(8)
	scores_label = UiLayout.wrap_label(HORIZONTAL_ALIGNMENT_LEFT)
	caps_label = UiLayout.wrap_label(HORIZONTAL_ALIGNMENT_RIGHT)
	hud.add_child(scores_label)
	hud.add_child(caps_label)
	middle.add_child(hud)

	stake_label = UiLayout.wrap_label()
	middle.add_child(stake_label)

	trick_label = UiLayout.wrap_label()
	middle.add_child(trick_label)

	trick_table = RetroTrickTable.new()
	trick_table.custom_minimum_size.y = 245
	trick_table.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.add_child(trick_table)

	status_label = UiLayout.wrap_label()
	middle.add_child(status_label)

	tip_label = UiLayout.wrap_label()

	armoede_label = UiLayout.wrap_label()
	middle.add_child(armoede_label)

	peek_label = UiLayout.wrap_label()
	middle.add_child(peek_label)

	var bottom := UiLayout.vbox(6)
	bottom.size_flags_vertical = Control.SIZE_SHRINK_END
	root.add_child(bottom)

	power_row = UiLayout.hbox(6)
	bottom.add_child(power_row)

	huis_row = UiLayout.flow(6)
	bottom.add_child(huis_row)

	var actions := UiLayout.flow(6)
	bottom.add_child(actions)

	knock_button = Button.new()
	knock_button.text = "KLOP"
	knock_button.pressed.connect(_on_knock)
	actions.add_child(knock_button)

	mee_button = Button.new()
	mee_button.text = "MEE"
	mee_button.pressed.connect(_on_mee)
	actions.add_child(mee_button)

	pas_button = Button.new()
	pas_button.text = "PAS"
	pas_button.pressed.connect(_on_pas)
	actions.add_child(pas_button)

	next_round_button = Button.new()
	next_round_button.text = "Volgende ronde"
	next_round_button.pressed.connect(_on_next_round)
	actions.add_child(next_round_button)

	toep_button = Button.new()
	toep_button.text = "TOEP"
	toep_button.pressed.connect(func() -> void: session.human_toep(); _refresh())
	actions.add_child(toep_button)
	kans_button = Button.new()
	kans_button.text = "KANS"
	kans_button.pressed.connect(func() -> void: session.human_kans(); _refresh())
	actions.add_child(kans_button)
	vuile_button = Button.new()
	vuile_button.text = "VUILE WAS"
	vuile_button.pressed.connect(func() -> void: session.human_vuile_was(); _refresh())
	actions.add_child(vuile_button)
	witte_button = Button.new()
	witte_button.text = "WITTE WAS"
	witte_button.pressed.connect(func() -> void: session.human_witte_was(); _refresh())
	actions.add_child(witte_button)
	skip_specials_button = Button.new()
	skip_specials_button.text = "VERDER"
	skip_specials_button.pressed.connect(func() -> void: session.human_skip_specials(); _refresh())
	actions.add_child(skip_specials_button)
	challenge_button = Button.new()
	challenge_button.text = "BETWIST"
	challenge_button.pressed.connect(func() -> void: session.human_challenge(); _refresh())
	actions.add_child(challenge_button)
	decline_button = Button.new()
	decline_button.text = "LAAT"
	decline_button.pressed.connect(func() -> void: session.human_decline_challenge(); _refresh())
	actions.add_child(decline_button)
	skip_wasdag_button = Button.new()
	skip_wasdag_button.text = "GEEN WASDAG"
	skip_wasdag_button.pressed.connect(func() -> void: session.skip_wasdag(); _refresh())
	actions.add_child(skip_wasdag_button)

	campaign_button = Button.new()
	campaign_button.text = "VERDER"
	campaign_button.pressed.connect(_on_campaign_continue)
	campaign_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(campaign_button)

	var hand_title := UiLayout.wrap_label()
	hand_title.text = "Jouw hand"
	bottom.add_child(hand_title)

	hand_strength_label = UiLayout.wrap_label()
	hand_strength_label.add_theme_font_size_override("font_size", 12)
	bottom.add_child(hand_strength_label)

	hand_row = UiLayout.hbox(6)
	hand_row.size_flags_vertical = Control.SIZE_SHRINK_END
	hand_row.custom_minimum_size.y = 92
	bottom.add_child(hand_row)

	animation_layer = Control.new()
	animation_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiLayout.fill_rect(animation_layer, 0)
	add_child(animation_layer)

	card_tip_bubble = VBoxContainer.new()
	card_tip_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tip_bubble.custom_minimum_size = Vector2(300, 80)
	card_tip_bubble.z_index = 100
	card_tip_bubble.add_theme_constant_override("separation", -5)
	add_child(card_tip_bubble)

	card_tip_panel = PanelContainer.new()
	card_tip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_tip_panel.custom_minimum_size = Vector2(300, 68)
	card_tip_panel.add_theme_stylebox_override("panel", UiLayout.pixel_panel(Color("17151cf2"), Color("e7bd4c")))
	tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_tip_panel.add_child(tip_label)
	card_tip_bubble.add_child(card_tip_panel)
	var tip_tail := Label.new()
	tip_tail.text = "▼"
	tip_tail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_tail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tip_tail.add_theme_color_override("font_color", Color("e7bd4c"))
	card_tip_bubble.add_child(tip_tail)
	card_tip_bubble.visible = false

	_bind_hold_tip(knock_button, "Kloppen verhoogt de inzet met 1. De anderen moeten MEE of PAS kiezen.")
	_bind_hold_tip(mee_button, "MEE: je blijft in de ronde. Verlies je, dan krijg je de huidige inzet als strafpunten.")
	_bind_hold_tip(pas_button, "PAS: je legt je kaarten blind weg en krijgt direct de huidige inzet als strafpunten.")
	_bind_hold_tip(toep_button, "TOEP: vier kaarten met dezelfde waarde. Jij wint direct; alle anderen krijgen +3.")
	_bind_hold_tip(kans_button, "KANS OP TOEP: met drie gelijke kaarten ruil je de afwijkende kaart één keer.")
	_bind_hold_tip(vuile_button, "VUILE WAS: drie plaatjes en een 7. Je vraagt vier nieuwe kaarten. Bluffen mag, maar iemand kan je betwisten.")
	_bind_hold_tip(witte_button, "WITTE WAS: vier plaatjes. Je vraagt vier nieuwe kaarten. Bluffen mag, maar iemand kan je betwisten.")
	_bind_hold_tip(skip_specials_button, "VERDER: je gebruikt geen special en speelt door met deze vier kaarten.")
	_bind_hold_tip(challenge_button, "BETWIST: draai de geclaimde was om. Bij echte was krijg jij +1; bij bluf krijgt de ander +1.")
	_bind_hold_tip(decline_button, "LAAT: je controleert de was niet en krijgt geen strafpunt.")
	_build_leave_dialog()


func _on_knock() -> void:
	if session.human_knock():
		_haptic(90, 0.75)
		_sfx("knock")
	_refresh()


func _on_mee() -> void:
	if session.human_mee():
		_haptic(45, 0.45)
		_sfx("decision")
	_refresh()


func _on_pas() -> void:
	if session.human_pas():
		_haptic(35, 0.3)
		_sfx("decision")
	_refresh()


func _on_next_round() -> void:
	session.next_round()
	_refresh()


func _play_card(card: Card) -> void:
	if session.human_play(card):
		_haptic(24, 0.22)
		_sfx("card")
	_refresh()


func _haptic(duration_ms: int, strength: float) -> void:
	if session == null or session.flow == null:
		return
	if not bool(session.flow.campaign.settings.get("haptics_on", true)):
		return
	Input.vibrate_handheld(duration_ms, strength)


func _sfx(cue: String) -> void:
	if session == null or session.flow == null:
		return
	var settings := session.flow.campaign.settings
	if not bool(settings.get("sfx_on", true)):
		return
	RetroSfx.play(self, cue, float(settings.get("sfx_volume", 1.0)))


func _on_toggle_tips() -> void:
	Boot.ensure_flow()
	var enabled := bool(Boot.flow.campaign.settings.get("tips_on", true))
	Boot.flow.campaign.settings["tips_on"] = not enabled
	Boot.flow.persist()
	_hide_card_tip()
	_refresh()


func _on_menu_requested() -> void:
	if session != null and session.tutorial.kind != TutorialDirector.Kind.NONE:
		_return_to_menu()
		return
	leave_dialog.popup_centered_ratio(0.88)


func _build_leave_dialog() -> void:
	leave_dialog = ConfirmationDialog.new()
	leave_dialog.title = "Terug naar het menu?"
	leave_dialog.dialog_text = (
		"Je level, dopjes en power-ups blijven bewaard.\n"
		+ "Het huidige potje begint opnieuw wanneer je doorgaat."
	)
	leave_dialog.ok_button_text = "NAAR MENU"
	leave_dialog.cancel_button_text = "BLIJVEN SPELEN"
	leave_dialog.confirmed.connect(_return_to_menu)
	add_child(leave_dialog)


func _return_to_menu() -> void:
	if session != null and session.flow != null:
		session.flow.persist()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _refresh() -> void:
	var game := session.game
	if session.flow != null:
		var loc_id := session.flow.campaign.location
		bg_rect.set_location(loc_id)
		var loc := LocationId.display_name(loc_id)
		var potje := session.flow.campaign.potje
		title_label.text = "%s\n%s potje %d" % [loc.to_upper(), loc, potje]
		if session.flow.campaign.is_boss_potje():
			title_label.text += "\nBOSS: %s" % LocationId.boss_name(loc_id)
		caps_label.text = "Dopjes %d" % session.flow.campaign.beer_caps
		if session.flow.campaign.peek_label != "":
			peek_label.text = "Spiek: %s" % session.flow.campaign.peek_label
		else:
			peek_label.text = ""
	else:
		caps_label.text = ""
		peek_label.text = ""
		if session.tutorial.kind != TutorialDirector.Kind.NONE:
			title_label.text = session.tutorial.title
	_rebuild_table(game)
	scores_label.text = _score_line(game)
	stake_label.text = "Inzet %d" % game.round_stake
	if game.cards_open:
		stake_label.text += " · LEERSTAND: OPEN KAARTEN"
	trick_label.text = _trick_title(game)
	status_label.text = session.status_text
	tips_button.text = "TIPS AAN" if _tips_enabled() else "TIPS UIT"
	if not _tips_enabled():
		_hide_card_tip()
	hand_strength_label.text = CardAdvisor.hand_summary(game.players[0].hand)
	if CardAdvisor.recommended_card(game) != null and _tips_enabled():
		hand_strength_label.text += " · gouden rand = advies"
	hand_strength_label.visible = _tips_enabled()
	armoede_label.text = _armoede_line(game)
	_rebuild_power_slots()
	_rebuild_huis_row()
	_rebuild_hand(game)

	var human_turn := game.state == ToepenGame.State.NORMAL_PLAY and game.current_actor_id == 0
	var human_responds := game.state == ToepenGame.State.KNOCK_DECISIONS and game.current_knock_responder_id() == 0
	var human_specials := game.state == ToepenGame.State.PRE_ROUND_SPECIALS and game.current_specials_actor_id() == 0
	var human_challenge := game.state == ToepenGame.State.VUILE_WAS_CHALLENGE and game.current_vuile_was_challenger_id() == 0
	knock_button.visible = human_turn and game.can_knock(0)
	mee_button.visible = human_responds
	pas_button.visible = human_responds and game.can_pass(0)
	next_round_button.visible = game.state == ToepenGame.State.ROUND_END
	toep_button.visible = human_specials and game.can_declare_toep(0)
	kans_button.visible = human_specials and game.can_use_kans(0)
	vuile_button.visible = human_specials and game.can_call_vuile_was(0)
	witte_button.visible = human_specials and game.can_declare_witte_was(0)
	skip_specials_button.visible = human_specials
	challenge_button.visible = human_challenge
	decline_button.visible = human_challenge
	campaign_button.visible = game.state == ToepenGame.State.GAME_END and session.flow != null
	if session.last_after_pot == CampaignFlow.AfterPot.SHOP:
		campaign_button.text = "AVONDWINKEL"
	elif session.last_after_pot == CampaignFlow.AfterPot.LOCATION_COMPLETE:
		campaign_button.text = "VOLTOOID"
	elif session.last_after_pot == CampaignFlow.AfterPot.CAMPAIGN_COMPLETE:
		campaign_button.text = "UITGESPEELD"
	elif session.last_after_pot == CampaignFlow.AfterPot.RUN_RESET:
		campaign_button.text = "POTJE 1"
	else:
		campaign_button.text = "VERDER"
	skip_wasdag_button.visible = session.pending_wasdag_choice
	if game.state == ToepenGame.State.GAME_END:
		knock_button.visible = false
		mee_button.visible = false
		pas_button.visible = false
		next_round_button.visible = false
	if not animation_running and not session.presentation_events.is_empty():
		_play_presentation_events.call_deferred()


func _rebuild_table(game: ToepenGame) -> void:
	var location := LocationId.STUDENTENHUIS
	var is_boss := false
	if session.flow != null:
		location = session.flow.campaign.location
		is_boss = session.flow.campaign.is_boss_potje()
	trick_table.configure(game, session.visual_trick_cards, session.opponent_names, is_boss, location)
	opponent_portraits = trick_table.portraits


func _armoede_line(game: ToepenGame) -> String:
	var ids := game.armoede_player_ids()
	if ids.is_empty():
		return ""
	return "Armoede 14/15: " + str(ids)


func _score_line(game: ToepenGame) -> String:
	return "Jij %d/15" % game.players[0].penalty_points


func _trick_title(game: ToepenGame) -> String:
	if session.visual_trick_cards.is_empty():
		return "TAFEL · wacht op de eerste kaart"
	var shown_trick := game.tricks_completed
	if game.current_trick != null and game.current_trick.play_count() > 0 and game.state != ToepenGame.State.ROUND_END:
		shown_trick += 1
	shown_trick = clampi(shown_trick, 1, ToepenGame.TRICKS_PER_ROUND)
	return "TAFEL · SLAG %d VAN %d" % [shown_trick, ToepenGame.TRICKS_PER_ROUND]


func _rebuild_hand(game: ToepenGame) -> void:
	_hide_card_tip()
	for child in hand_row.get_children():
		child.queue_free()
	var human := game.players[0]
	var legal := game.legal_cards(0)
	var human_turn := game.state == ToepenGame.State.NORMAL_PLAY and game.current_actor_id == 0
	var recommended := CardAdvisor.recommended_card(game) if _tips_enabled() else null
	for card in human.hand:
		var button := Button.new()
		button.text = ""
		UiLayout.fit_button(button)
		button.flat = true
		button.custom_minimum_size = Vector2(0, 88)
		var is_legal := false
		for legal_card in legal:
			if legal_card.equals(card):
				is_legal = true
				break
		button.disabled = (not human_turn) or (not is_legal)
		if session.power_mode == "ruilen" or session.power_mode == "huis_discard":
			button.disabled = false
		var face := PlayingCardFace.new()
		face.set_anchors_preset(Control.PRESET_FULL_RECT)
		face.configure(card, recommended != null and recommended.equals(card))
		face.modulate = Color(1, 1, 1, 0.42) if button.disabled else Color.WHITE
		button.add_child(face)
		var card_tip := CardAdvisor.card_tooltip(card, is_legal)
		if recommended != null and recommended.equals(card):
			card_tip = "Aanbevolen. " + card_tip
		button.mouse_entered.connect(func() -> void:
			if _tips_enabled():
				_show_tip_bubble(card_tip, button)
			_animate_card(button, Vector2(1.04, 1.04))
		)
		button.mouse_exited.connect(func() -> void:
			_hide_card_tip()
			_animate_card(button, Vector2.ONE)
		)
		button.button_down.connect(func() -> void:
			if _tips_enabled():
				_show_tip_bubble(card_tip, button)
			_animate_card(button, Vector2(0.96, 0.96))
		)
		button.button_up.connect(func() -> void:
			_hide_card_tip()
			_animate_card(button, Vector2.ONE)
		)
		var captured := card
		button.pressed.connect(func() -> void:
			if session.power_mode == "ruilen":
				session.use_kaartje_ruilen(captured)
				_refresh()
			elif session.power_mode == "huis_discard":
				session.begin_huisvoordeel(captured)
				_refresh()
			else:
				_play_card(captured)
		)
		hand_row.add_child(button)


func _animate_card(button: Button, target: Vector2) -> void:
	button.pivot_offset = button.size * 0.5
	var duration := 0.14
	if session.flow != null and str(session.flow.campaign.settings.get("animation_speed", "normal")) == "fast":
		duration = 0.07
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target, duration)


func _show_tip_bubble(text: String, anchor_control: Control) -> void:
	if card_tip_bubble == null:
		return
	tip_label.text = text
	var bubble_width := minf(320.0, maxf(260.0, size.x - 24.0))
	card_tip_panel.custom_minimum_size.x = bubble_width
	card_tip_bubble.size = Vector2(bubble_width, 80)
	var card_center := anchor_control.global_position.x - global_position.x + anchor_control.size.x * 0.5
	var card_top := anchor_control.global_position.y - global_position.y
	card_tip_bubble.position = Vector2(
		clampf(card_center - bubble_width * 0.5, 12.0, size.x - bubble_width - 12.0),
		maxf(12.0, card_top - 94.0)
	)
	card_tip_bubble.visible = true
	card_tip_bubble.modulate.a = 0.0
	card_tip_bubble.scale = Vector2(0.94, 0.94)
	card_tip_bubble.pivot_offset = Vector2(bubble_width * 0.5, 80.0)
	var tween := card_tip_bubble.create_tween().set_parallel(true)
	tween.tween_property(card_tip_bubble, "modulate:a", 1.0, 0.08)
	tween.tween_property(card_tip_bubble, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _bind_hold_tip(button: Button, text: String) -> void:
	button.mouse_entered.connect(func() -> void:
		if _tips_enabled() and button.visible:
			_show_tip_bubble(text, button)
	)
	button.mouse_exited.connect(_hide_card_tip)
	button.button_down.connect(func() -> void:
		if _tips_enabled():
			_show_tip_bubble(text, button)
	)
	button.button_up.connect(_hide_card_tip)


func _hide_card_tip() -> void:
	if card_tip_bubble != null:
		card_tip_bubble.visible = false


func _play_presentation_events() -> void:
	if animation_running:
		return
	animation_running = true
	animation_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	var events := session.take_presentation_events()
	await get_tree().process_frame
	for event in events:
		match str(event.get("type", "play_card")):
			"round_score":
				await _animate_round_score_event(event)
			"special":
				await _animate_special_event(event)
			"decision":
				await _animate_decision_event(event)
			"stage_intro":
				await _animate_stage_intro(event)
			_:
				await _animate_play_event(event)
	animation_running = false
	animation_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_refresh()
	if not session.presentation_events.is_empty():
		_play_presentation_events.call_deferred()


func _animate_play_event(event: Dictionary) -> void:
	_sfx("card")
	var ghost := PlayingCardFace.new()
	ghost.custom_minimum_size = Vector2(64, 86)
	ghost.size = Vector2(64, 86)
	var played_card: Card = event.get("card")
	ghost.configure(played_card)
	animation_layer.add_child(ghost)
	status_label.text = "%s speelt %s" % [str(event.get("player_name", "Speler")), str(played_card)]
	var player_id := int(event.get("player_id", 0))
	var start_global := Vector2(size.x * 0.5 - 32, size.y - 130)
	if player_id > 0 and opponent_portraits.has(player_id):
		var portrait: Control = opponent_portraits[player_id]
		start_global = portrait.global_position + portrait.size * 0.5 - Vector2(32, 43)
	var end_global := trick_table.card_target_global(player_id)
	ghost.global_position = start_global
	ghost.scale = Vector2(0.72, 0.72)
	ghost.rotation = -0.12 if player_id % 2 == 0 else 0.12
	ghost.modulate.a = 0.0
	var duration := 0.52
	if session.flow != null and str(session.flow.campaign.settings.get("animation_speed", "normal")) == "fast":
		duration = 0.24
	var tween := ghost.create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(ghost, "global_position", end_global, duration)
	tween.tween_property(ghost, "scale", Vector2.ONE, duration)
	tween.tween_property(ghost, "rotation", 0.0, duration)
	tween.tween_property(ghost, "modulate:a", 1.0, minf(duration, 0.1))
	await tween.finished
	var settle := ghost.create_tween()
	settle.tween_property(ghost, "scale", Vector2(1.06, 0.96), 0.08)
	settle.tween_property(ghost, "scale", Vector2.ONE, 0.1)
	await settle.finished
	var pause := 0.34 if duration > 0.3 else 0.12
	await get_tree().create_timer(pause).timeout
	ghost.queue_free()


func _animate_round_score_event(event: Dictionary) -> void:
	_sfx("decision")
	var banner := Label.new()
	var winner_id := int(event.get("winner_id", -1))
	var winner_name := "?"
	if winner_id == 0:
		winner_name = "JIJ"
	elif winner_id > 0:
		winner_name = session.opponent_name(winner_id).to_upper()
	banner.text = "RONDE UITSLAG · %s WINT" % winner_name
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_font_size_override("font_size", 21)
	banner.add_theme_color_override("font_color", Color("f6d66a"))
	banner.add_theme_constant_override("outline_size", 7)
	banner.add_theme_color_override("font_outline_color", Color("17151c"))
	banner.size = Vector2(minf(300.0, size.x - 32.0), 44)
	banner.position = Vector2((size.x - banner.size.x) * 0.5, maxf(14.0, trick_table.global_position.y - global_position.y + 28.0))
	animation_layer.add_child(banner)
	banner.modulate.a = 0.0
	banner.scale = Vector2(0.75, 0.75)
	banner.pivot_offset = banner.size * 0.5
	var banner_tween := banner.create_tween().set_parallel(true)
	banner_tween.tween_property(banner, "modulate:a", 1.0, 0.16)
	banner_tween.tween_property(banner, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var deltas: Array = event.get("deltas", [])
	var totals: Array = event.get("totals", [])
	var splashes: Array[Control] = []
	for player_id in ToepenGame.PLAYER_COUNT:
		var delta := int(deltas[player_id]) if player_id < deltas.size() else 0
		var total := int(totals[player_id]) if player_id < totals.size() else 0
		var splash := VBoxContainer.new()
		splash.size = Vector2(96, 76)
		splash.add_theme_constant_override("separation", -7)
		var amount_label := Label.new()
		amount_label.text = "+%d" % delta if delta >= 0 else str(delta)
		amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		amount_label.add_theme_font_size_override("font_size", 34)
		amount_label.add_theme_constant_override("outline_size", 9)
		amount_label.add_theme_color_override("font_outline_color", Color("17151c"))
		amount_label.add_theme_color_override("font_color", Color("ff625f") if delta > 0 else Color("f6d66a"))
		splash.add_child(amount_label)
		var total_label := Label.new()
		total_label.text = "totaal %d/15" % total
		total_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		total_label.add_theme_font_size_override("font_size", 11)
		total_label.add_theme_constant_override("outline_size", 4)
		total_label.add_theme_color_override("font_outline_color", Color("17151c"))
		splash.add_child(total_label)
		var target := trick_table.score_target_global(player_id) - global_position - splash.size * 0.5
		splash.position = target + Vector2(0, 16)
		splash.pivot_offset = splash.size * 0.5
		splash.modulate.a = 0.0
		splash.scale = Vector2(0.35, 0.35)
		animation_layer.add_child(splash)
		splashes.append(splash)
		var delay := float(player_id) * 0.08
		var tween := splash.create_tween().set_parallel(true)
		tween.tween_property(splash, "modulate:a", 1.0, 0.16).set_delay(delay)
		tween.tween_property(splash, "position", target - Vector2(0, 18), 0.38).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(splash, "scale", Vector2.ONE, 0.32).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var hold_time := 1.8
	if session.flow != null and str(session.flow.campaign.settings.get("animation_speed", "normal")) == "fast":
		hold_time = 0.9
	await get_tree().create_timer(hold_time).timeout
	var fade := animation_layer.create_tween().set_parallel(true)
	fade.tween_property(banner, "modulate:a", 0.0, 0.22)
	for splash in splashes:
		fade.tween_property(splash, "modulate:a", 0.0, 0.22)
	await fade.finished
	banner.queue_free()
	for splash in splashes:
		splash.queue_free()


func _animate_special_event(event: Dictionary) -> void:
	_sfx("decision")
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", UiLayout.pixel_panel(Color("17151cf4"), Color("e7bd4c")))
	panel.size = Vector2(minf(330.0, size.x - 32.0), 112)
	panel.position = Vector2((size.x - panel.size.x) * 0.5, trick_table.global_position.y - global_position.y + trick_table.size.y * 0.42)
	animation_layer.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	panel.add_child(content)
	var title := Label.new()
	title.text = str(event.get("title", "SPECIAL"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("f6d66a"))
	content.add_child(title)
	var detail := Label.new()
	detail.text = str(event.get("detail", ""))
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size", 13)
	content.add_child(detail)
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2(0.72, 0.72)
	panel.modulate.a = 0.0
	var intro := panel.create_tween().set_parallel(true)
	intro.tween_property(panel, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	intro.tween_property(panel, "modulate:a", 1.0, 0.12)
	await intro.finished
	var hold_time := 1.25
	if session.flow != null and str(session.flow.campaign.settings.get("animation_speed", "normal")) == "fast":
		hold_time = 0.65
	await get_tree().create_timer(hold_time).timeout
	var outro := panel.create_tween().set_parallel(true)
	outro.tween_property(panel, "scale", Vector2(1.05, 1.05), 0.18)
	outro.tween_property(panel, "modulate:a", 0.0, 0.18)
	await outro.finished
	panel.queue_free()


func _animate_decision_event(event: Dictionary) -> void:
	var player_id := int(event.get("player_id", 0))
	var bubble := PanelContainer.new()
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bubble.add_theme_stylebox_override("panel", UiLayout.pixel_panel(Color("17151cf2"), Color("60d5c1")))
	bubble.size = Vector2(138, 66)
	var target := trick_table.score_target_global(player_id) - global_position
	bubble.position = Vector2(
		clampf(target.x - bubble.size.x * 0.5, 10.0, size.x - bubble.size.x - 10.0),
		clampf(target.y - 84.0, 10.0, size.y - bubble.size.y - 10.0)
	)
	animation_layer.add_child(bubble)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", -2)
	bubble.add_child(content)
	var title := Label.new()
	title.text = str(event.get("title", ""))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 21)
	title.add_theme_color_override("font_color", Color("f6d66a") if title.text == "KLOP!" else Color("f1f0db"))
	content.add_child(title)
	var detail := Label.new()
	detail.text = str(event.get("detail", ""))
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.add_theme_font_size_override("font_size", 11)
	content.add_child(detail)
	bubble.pivot_offset = bubble.size * 0.5
	bubble.scale = Vector2(0.55, 0.55)
	bubble.modulate.a = 0.0
	var intro := bubble.create_tween().set_parallel(true)
	intro.tween_property(bubble, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	intro.tween_property(bubble, "modulate:a", 1.0, 0.08)
	await intro.finished
	var hold_time := 0.72
	if session.flow != null and str(session.flow.campaign.settings.get("animation_speed", "normal")) == "fast":
		hold_time = 0.32
	await get_tree().create_timer(hold_time).timeout
	var outro := bubble.create_tween().set_parallel(true)
	outro.tween_property(bubble, "position:y", bubble.position.y - 12.0, 0.16)
	outro.tween_property(bubble, "modulate:a", 0.0, 0.16)
	await outro.finished
	bubble.queue_free()


func _animate_stage_intro(event: Dictionary) -> void:
	_sfx("decision")
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", UiLayout.pixel_panel(Color("10151af5"), Color("e7bd4c")))
	panel.size = Vector2(minf(338.0, size.x - 28.0), 154)
	panel.position = Vector2((size.x - panel.size.x) * 0.5, trick_table.global_position.y - global_position.y + trick_table.size.y * 0.28)
	animation_layer.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	panel.add_child(content)
	var title := Label.new()
	title.text = str(event.get("location", "LOCATIE")).to_upper()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("f6d66a"))
	content.add_child(title)
	var potje := int(event.get("potje", 1))
	var subtitle := Label.new()
	subtitle.text = "BOSS · %s" % str(event.get("boss_name", "")) if bool(event.get("boss", false)) else "POTJE %d VAN 3" % potje
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 17)
	content.add_child(subtitle)
	var opponents: Array = event.get("opponents", [])
	var names := Label.new()
	names.text = "Aan tafel: " + " · ".join(PackedStringArray(opponents))
	names.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	names.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	names.add_theme_font_size_override("font_size", 12)
	names.modulate = Color("d8d3bd")
	content.add_child(names)
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2(0.72, 0.72)
	panel.modulate.a = 0.0
	var intro := panel.create_tween().set_parallel(true)
	intro.tween_property(panel, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	intro.tween_property(panel, "modulate:a", 1.0, 0.12)
	await intro.finished
	var hold_time := 1.65
	if session.flow != null and str(session.flow.campaign.settings.get("animation_speed", "normal")) == "fast":
		hold_time = 0.8
	await get_tree().create_timer(hold_time).timeout
	var outro := panel.create_tween().set_parallel(true)
	outro.tween_property(panel, "scale", Vector2(1.05, 1.05), 0.2)
	outro.tween_property(panel, "modulate:a", 0.0, 0.2)
	await outro.finished
	panel.queue_free()


func _tips_enabled() -> bool:
	Boot.ensure_flow()
	return bool(Boot.flow.campaign.settings.get("tips_on", true))


func _rebuild_power_slots() -> void:
	for child in power_row.get_children():
		child.queue_free()
	if session.flow == null:
		return
	var inv := session.flow.campaign.inventory
	for slot in PowerUpId.MAX_SLOTS:
		var button := Button.new()
		UiLayout.fit_button(button)
		button.custom_minimum_size = Vector2(0, 36)
		if slot >= inv.size():
			button.text = "Slot %d leeg" % (slot + 1)
			button.disabled = true
		else:
			var id := str(inv[slot])
			button.text = PowerUpCatalog.display_name(id)
			if PowerUpCatalog.is_passive(id):
				button.disabled = true
				button.text += " auto"
			else:
				var legal := session.can_use_power(id)
				button.disabled = not legal
				var captured := id
				button.pressed.connect(func() -> void: _on_power_pressed(captured))
		power_row.add_child(button)


func _on_power_pressed(id: String) -> void:
	match id:
		PowerUpId.KAARTJE_RUILEN:
			session.power_mode = "ruilen"
			session.status_text = "Kies een kaart om te ruilen."
		PowerUpId.EVEN_SPIEKEN:
			session.power_mode = "peek"
			session.status_text = "Kies een tegenstander om te spieken."
		PowerUpId.RONDJE_VAN_DE_ZAAK:
			session.use_rondje()
		PowerUpId.HUISVOORDEEL:
			session.power_mode = "huis_discard"
			session.status_text = "Kies een kaart om te vervangen."
		PowerUpId.WASDAG:
			session.arm_wasdag()
		PowerUpId.DUBBEL_KLOPPEN:
			session.arm_dubbel_kloppen()
		PowerUpId.STALEN_ZENUWEN:
			session.use_stalen_zenuwen()
		_:
			pass
	_refresh()


func _rebuild_huis_row() -> void:
	for child in huis_row.get_children():
		child.queue_free()
	if session.power_mode == "peek":
		for pid in range(1, ToepenGame.PLAYER_COUNT):
			var button := Button.new()
			button.text = session.opponent_name(pid)
			UiLayout.fit_button(button)
			var captured := pid
			button.pressed.connect(func() -> void:
				session.use_even_spieken(captured)
				_refresh()
			)
			huis_row.add_child(button)
		return
	if session.power_mode != "huis_choose" or session.power_service == null:
		return
	for i in session.power_service.pending_huisvoordeel_candidates.size():
		var card: Card = session.power_service.pending_huisvoordeel_candidates[i]
		var button := Button.new()
		button.text = UiLayout.compact_card(card)
		UiLayout.fit_button(button)
		var idx := i
		button.pressed.connect(func() -> void:
			session.finish_huisvoordeel(idx)
			_refresh()
		)
		huis_row.add_child(button)


func _on_campaign_continue() -> void:
	match session.last_after_pot:
		CampaignFlow.AfterPot.SHOP:
			get_tree().change_scene_to_file("res://scenes/shop.tscn")
		CampaignFlow.AfterPot.LOCATION_COMPLETE:
			get_tree().change_scene_to_file("res://scenes/complete.tscn")
		CampaignFlow.AfterPot.CAMPAIGN_COMPLETE:
			get_tree().change_scene_to_file("res://scenes/complete.tscn")
		CampaignFlow.AfterPot.RUN_RESET:
			session.start_campaign_pot()
			_refresh()
		_:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")
