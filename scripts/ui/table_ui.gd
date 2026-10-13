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
var armoede_label: Label
var caps_label: Label
var peek_label: Label
var power_row: HBoxContainer
var huis_row: HFlowContainer
var campaign_button: Button
var title_label: Label
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

	title_label = UiLayout.wrap_label()
	title_label.text = "Toepnacht"
	middle.add_child(title_label)

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
	middle.add_child(tip_label)

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
	tip_label.text = "TIP · %s" % session.tip_text
	tip_label.visible = _tips_enabled() and session.tip_text != ""
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
		button.tooltip_text = card_tip
		button.mouse_entered.connect(func() -> void:
			if _tips_enabled():
				tip_label.text = "KAART · %s" % card_tip
				tip_label.visible = true
			_animate_card(button, Vector2(1.04, 1.04))
		)
		button.mouse_exited.connect(func() -> void:
			tip_label.text = "TIP · %s" % session.tip_text
			tip_label.visible = _tips_enabled() and session.tip_text != ""
			_animate_card(button, Vector2.ONE)
		)
		button.button_down.connect(func() -> void: _animate_card(button, Vector2(0.96, 0.96)))
		button.button_up.connect(func() -> void: _animate_card(button, Vector2.ONE))
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


func _play_presentation_events() -> void:
	if animation_running:
		return
	animation_running = true
	animation_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	var events := session.take_presentation_events()
	await get_tree().process_frame
	for event in events:
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


func _tips_enabled() -> bool:
	if session == null or session.flow == null:
		return true
	return bool(session.flow.campaign.settings.get("tips_on", true))


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
