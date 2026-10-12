extends Control

## Minimal placeholder table. No final art or animation.

var session: TableSession
var status_label: Label
var stake_label: Label
var trick_label: Label
var opponents_box: VBoxContainer
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


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	_build_layout()
	session = TableSession.new()
	match Boot.mode:
		"blanco":
			Boot.ensure_flow()
			session.start_tutorial_blanco()
			Boot.flow.mark_tutorial_blanco()
		"kloppen":
			Boot.ensure_flow()
			session.start_tutorial_kloppen()
			Boot.flow.mark_tutorial_kloppen()
		_:
			Boot.ensure_flow()
			session.bind_campaign(Boot.flow)
			if not Boot.flow.campaign.run_active:
				Boot.flow.start_new_studentenhuis_run()
			session.start_campaign_pot()
	_refresh()


func _build_layout() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.22, 0.16)
	UiLayout.fill_rect(bg, 0)
	add_child(bg)

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

	opponents_box = UiLayout.vbox(2)
	opponents_box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	middle.add_child(opponents_box)

	stake_label = UiLayout.wrap_label()
	middle.add_child(stake_label)

	trick_label = UiLayout.wrap_label()
	trick_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.add_child(trick_label)

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

	campaign_button = Button.new()
	campaign_button.text = "VERDER"
	campaign_button.pressed.connect(_on_campaign_continue)
	campaign_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(campaign_button)

	var hand_title := UiLayout.wrap_label()
	hand_title.text = "Jouw hand"
	bottom.add_child(hand_title)

	hand_row = UiLayout.hbox(6)
	hand_row.size_flags_vertical = Control.SIZE_SHRINK_END
	hand_row.custom_minimum_size.y = 52
	bottom.add_child(hand_row)


func _on_knock() -> void:
	session.human_knock()
	_refresh()


func _on_mee() -> void:
	session.human_mee()
	_refresh()


func _on_pas() -> void:
	session.human_pas()
	_refresh()


func _on_next_round() -> void:
	session.next_round()
	_refresh()


func _play_card(card: Card) -> void:
	session.human_play(card)
	_refresh()


func _refresh() -> void:
	var game := session.game
	if session.flow != null:
		var loc := LocationId.display_name(session.flow.campaign.location)
		var potje := session.flow.campaign.potje
		title_label.text = "%s potje %d" % [loc, potje]
		if session.flow.campaign.is_boss_potje():
			title_label.text += "\nBOSS: %s" % LocationId.boss_name(session.flow.campaign.location)
		caps_label.text = "Dopjes %d" % session.flow.campaign.beer_caps
		if session.flow.campaign.peek_label != "":
			peek_label.text = "Spiek: %s" % session.flow.campaign.peek_label
		else:
			peek_label.text = ""
	else:
		caps_label.text = ""
		peek_label.text = ""
	_rebuild_opponents(game)
	scores_label.text = _score_line(game)
	stake_label.text = "Inzet %d" % game.round_stake
	trick_label.text = _trick_line(game)
	status_label.text = session.status_text
	tip_label.text = session.tip_text
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
	elif session.last_after_pot == CampaignFlow.AfterPot.RUN_RESET:
		campaign_button.text = "POTJE 1"
	else:
		campaign_button.text = "VERDER"
	if game.state == ToepenGame.State.GAME_END:
		knock_button.visible = false
		mee_button.visible = false
		pas_button.visible = false
		next_round_button.visible = false


func _rebuild_opponents(game: ToepenGame) -> void:
	for child in opponents_box.get_children():
		child.queue_free()
	for i in range(1, ToepenGame.PLAYER_COUNT):
		var player := game.players[i]
		var status := "af" if player.is_eliminated else ("%d krt" % player.hand.size())
		if not player.is_active_in_round and not player.is_eliminated:
			status += " · pas"
		var line := "%s  %d/15  %s" % [session.opponent_name(i), player.penalty_points, status]
		if game.cards_open and not player.is_eliminated:
			var cards: PackedStringArray = PackedStringArray()
			for card in player.hand:
				cards.append(UiLayout.compact_card(card))
			line += "\n" + ", ".join(cards)
		var label := UiLayout.wrap_label()
		label.text = line
		opponents_box.add_child(label)


func _armoede_line(game: ToepenGame) -> String:
	var ids := game.armoede_player_ids()
	if ids.is_empty():
		return ""
	return "Armoede 14/15: " + str(ids)


func _score_line(game: ToepenGame) -> String:
	return "Jij %d/15" % game.players[0].penalty_points


func _trick_line(game: ToepenGame) -> String:
	if game.current_trick == null or game.current_trick.play_count() == 0:
		return "Tafel: leeg"
	var parts: PackedStringArray = PackedStringArray()
	for i in game.current_trick.play_count():
		var pid: int = game.current_trick.player_ids[i]
		var pname := "Jij" if pid == 0 else session.opponent_name(pid)
		parts.append("%s: %s" % [pname, UiLayout.compact_card(game.current_trick.cards[i])])
	return "Tafel:\n" + "\n".join(parts)


func _rebuild_hand(game: ToepenGame) -> void:
	for child in hand_row.get_children():
		child.queue_free()
	var human := game.players[0]
	var legal := game.legal_cards(0)
	var human_turn := game.state == ToepenGame.State.NORMAL_PLAY and game.current_actor_id == 0
	for card in human.hand:
		var button := Button.new()
		button.text = UiLayout.compact_card(card)
		UiLayout.fit_button(button)
		button.custom_minimum_size = Vector2(0, 52)
		var is_legal := false
		for legal_card in legal:
			if legal_card.equals(card):
				is_legal = true
				break
		button.disabled = (not human_turn) or (not is_legal)
		if session.power_mode == "ruilen" or session.power_mode == "huis_discard":
			button.disabled = false
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
		CampaignFlow.AfterPot.RUN_RESET:
			session.start_campaign_pot()
			_refresh()
		_:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")
