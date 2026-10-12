extends Control

## Minimal placeholder table. No final art or animation.

var session: TableSession
var status_label: Label
var stake_label: Label
var trick_label: Label
var opponents_label: Label
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


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	_build_layout()
	session = TableSession.new()
	match Boot.mode:
		"blanco":
			session.start_tutorial_blanco()
		"kloppen":
			session.start_tutorial_kloppen()
		_:
			session.start_new_pot()
	_refresh()


func _build_layout() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.22, 0.16)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(PRESET_FULL_RECT)
	root.offset_left = 16
	root.offset_top = 16
	root.offset_right = -16
	root.offset_bottom = -16
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var title := Label.new()
	title.text = "Toepnacht — placeholder tafel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	opponents_label = Label.new()
	opponents_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(opponents_label)

	scores_label = Label.new()
	scores_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(scores_label)

	stake_label = Label.new()
	stake_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(stake_label)

	trick_label = Label.new()
	trick_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trick_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(trick_label)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(status_label)

	tip_label = Label.new()
	tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(tip_label)

	armoede_label = Label.new()
	armoede_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(armoede_label)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 8)
	root.add_child(actions)

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
	decline_button.text = "NIET BETWISTEN"
	decline_button.pressed.connect(func() -> void: session.human_decline_challenge(); _refresh())
	actions.add_child(decline_button)

	var hand_title := Label.new()
	hand_title.text = "Jouw hand"
	hand_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(hand_title)

	hand_row = HBoxContainer.new()
	hand_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hand_row.add_theme_constant_override("separation", 8)
	root.add_child(hand_row)


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
	opponents_label.text = _opponent_line(game)
	scores_label.text = _score_line(game)
	stake_label.text = "Inzet: %d" % game.round_stake
	trick_label.text = _trick_line(game)
	status_label.text = session.status_text
	tip_label.text = session.tip_text
	armoede_label.text = _armoede_line(game)
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
	if game.state == ToepenGame.State.GAME_END:
		knock_button.visible = false
		mee_button.visible = false
		pas_button.visible = false
		next_round_button.visible = false


func _opponent_line(game: ToepenGame) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for i in range(1, ToepenGame.PLAYER_COUNT):
		var player := game.players[i]
		var status := "af" if player.is_eliminated else ("%d kaarten" % player.hand.size())
		if not player.is_active_in_round and not player.is_eliminated:
			status += ", pas"
		if game.cards_open and not player.is_eliminated:
			var cards: PackedStringArray = PackedStringArray()
			for card in player.hand:
				cards.append(str(card))
			status += " [" + ", ".join(cards) + "]"
		parts.append("AI %d — %d/15 — %s" % [i, player.penalty_points, status])
	return "   |   ".join(parts)


func _armoede_line(game: ToepenGame) -> String:
	var ids := game.armoede_player_ids()
	if ids.is_empty():
		return ""
	return "Armoede 14/15: " + str(ids)


func _score_line(game: ToepenGame) -> String:
	return "Jij %d/15" % game.players[0].penalty_points


func _trick_line(game: ToepenGame) -> String:
	if game.current_trick == null or game.current_trick.play_count() == 0:
		return "Tafel: (leeg)"
	var parts: PackedStringArray = PackedStringArray()
	for i in game.current_trick.play_count():
		var pid: int = game.current_trick.player_ids[i]
		var pname := "Jij" if pid == 0 else "AI %d" % pid
		parts.append("%s: %s" % [pname, str(game.current_trick.cards[i])])
	return "Tafel: " + "  ·  ".join(parts)


func _rebuild_hand(game: ToepenGame) -> void:
	for child in hand_row.get_children():
		child.queue_free()
	var human := game.players[0]
	var legal := game.legal_cards(0)
	var human_turn := game.state == ToepenGame.State.NORMAL_PLAY and game.current_actor_id == 0
	for card in human.hand:
		var button := Button.new()
		button.text = str(card)
		var is_legal := false
		for legal_card in legal:
			if legal_card.equals(card):
				is_legal = true
				break
		button.disabled = (not human_turn) or (not is_legal)
		var captured := card
		button.pressed.connect(func() -> void: _play_card(captured))
		hand_row.add_child(button)
