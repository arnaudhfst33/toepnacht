class_name TableSession
extends RefCounted

## Wires the core engine to baseline AI. UI stays presentation-only.

var game: ToepenGame
var ai: BaselineAI
var tutorial: TutorialDirector
var status_text: String = ""
var tip_text: String = ""


func _init() -> void:
	game = ToepenGame.new()
	ai = BaselineAI.new()
	tutorial = TutorialDirector.new()


func start_new_pot() -> void:
	tutorial = TutorialDirector.new()
	game.cards_open = false
	game.start_pot()
	status_text = "Nieuwe pot. Specials vóór de eerste kaart, daarna spelen."
	resolve_ai()


func start_tutorial_blanco() -> void:
	tutorial.setup_blanco(game)
	status_text = tutorial.intro
	tip_text = tutorial.tip_for(game)
	resolve_ai()


func start_tutorial_kloppen() -> void:
	tutorial.setup_kloppen(game)
	status_text = tutorial.intro
	tip_text = tutorial.tip_for(game)
	resolve_ai()


func next_round() -> void:
	if game.state != ToepenGame.State.ROUND_END:
		return
	game.start_round()
	status_text = "Nieuwe ronde. Inzet %d." % game.round_stake
	resolve_ai()


func human_knock() -> bool:
	if not game.request_knock(ToepenGame.HUMAN_PLAYER_ID):
		return false
	status_text = "Jij klopt. Inzet is nu %d." % game.round_stake
	resolve_ai()
	return true


func human_mee() -> bool:
	if not game.respond_to_knock(ToepenGame.HUMAN_PLAYER_ID, true):
		return false
	status_text = "Jij gaat mee."
	resolve_ai()
	return true


func human_pas() -> bool:
	if not game.can_pass(ToepenGame.HUMAN_PLAYER_ID):
		status_text = "PAS mag nu niet."
		return false
	if not game.respond_to_knock(ToepenGame.HUMAN_PLAYER_ID, false):
		return false
	status_text = "Jij past en krijgt %d strafpunt(en)." % game.round_stake
	resolve_ai()
	return true


func human_play(card: Card) -> bool:
	var err := game.play_card(ToepenGame.HUMAN_PLAYER_ID, card)
	if err != ToepenGame.PlayError.NONE:
		return false
	status_text = "Jij speelt %s." % str(card)
	resolve_ai()
	return true


func human_toep() -> bool:
	if not game.declare_toep(ToepenGame.HUMAN_PLAYER_ID):
		return false
	status_text = game.last_event
	resolve_ai()
	return true


func human_kans() -> bool:
	if not game.use_kans(ToepenGame.HUMAN_PLAYER_ID):
		return false
	status_text = game.last_event
	resolve_ai()
	return true


func human_vuile_was() -> bool:
	if not game.call_vuile_was(ToepenGame.HUMAN_PLAYER_ID):
		return false
	status_text = game.last_event
	resolve_ai()
	return true


func human_witte_was() -> bool:
	if not game.declare_witte_was(ToepenGame.HUMAN_PLAYER_ID):
		return false
	status_text = game.last_event
	resolve_ai()
	return true


func human_skip_specials() -> bool:
	if not game.skip_specials(ToepenGame.HUMAN_PLAYER_ID):
		return false
	status_text = "Jij slaat specials over."
	resolve_ai()
	return true


func human_challenge() -> bool:
	if not game.challenge_vuile_was(ToepenGame.HUMAN_PLAYER_ID):
		return false
	status_text = game.last_event
	resolve_ai()
	return true


func human_decline_challenge() -> bool:
	if not game.decline_vuile_was_challenge(ToepenGame.HUMAN_PLAYER_ID):
		return false
	status_text = "Jij betwist niet."
	resolve_ai()
	return true


func waiting_for_human() -> bool:
	if game.state == ToepenGame.State.GAME_END:
		return false
	if game.state == ToepenGame.State.ROUND_END:
		return true
	if game.state == ToepenGame.State.KNOCK_DECISIONS:
		return game.current_knock_responder_id() == ToepenGame.HUMAN_PLAYER_ID
	if game.state == ToepenGame.State.VUILE_WAS_CHALLENGE:
		return game.current_vuile_was_challenger_id() == ToepenGame.HUMAN_PLAYER_ID
	if game.state == ToepenGame.State.PRE_ROUND_SPECIALS:
		return game.current_specials_actor_id() == ToepenGame.HUMAN_PLAYER_ID
	if game.state == ToepenGame.State.NORMAL_PLAY:
		return game.current_actor_id == ToepenGame.HUMAN_PLAYER_ID
	return true


func resolve_ai() -> void:
	var guard := 0
	while guard < 500:
		guard += 1
		tip_text = tutorial.tip_for(game)
		if game.state == ToepenGame.State.GAME_END:
			status_text = "Pot gedaan. Winnaar: %s." % _name(game.pot_winner_id)
			return
		if game.state == ToepenGame.State.ROUND_END:
			if status_text == "":
				status_text = "Ronde voorbij. Winnaar: %s." % _name(game.last_round_winner_id)
			return
		var actor := _current_ai_actor()
		if actor < 0:
			return
		if game.players[actor].is_human:
			return
		_apply_ai(actor)


func _current_ai_actor() -> int:
	if game.state == ToepenGame.State.KNOCK_DECISIONS:
		return game.current_knock_responder_id()
	if game.state == ToepenGame.State.VUILE_WAS_CHALLENGE:
		return game.current_vuile_was_challenger_id()
	if game.state == ToepenGame.State.PRE_ROUND_SPECIALS:
		return game.current_specials_actor_id()
	if game.state == ToepenGame.State.NORMAL_PLAY:
		return game.current_actor_id
	return -1


func _apply_ai(player_id: int) -> void:
	if tutorial.force_ai_knock and game.can_knock(player_id) and game.tricks_completed == 0 and game.current_trick.play_count() > 0:
		game.request_knock(player_id)
		status_text = "%s klopt (script). Inzet %d." % [_name(player_id), game.round_stake]
		tutorial.force_ai_knock = false
		return
	var view := PublicView.from_game(game, player_id)
	var action := ai.decide(view, game.rng)
	var kind := str(action.get("type", "wait"))
	match kind:
		"toep":
			game.declare_toep(player_id)
			status_text = game.last_event
		"kans":
			game.use_kans(player_id)
			status_text = game.last_event
		"vuile_was":
			game.call_vuile_was(player_id)
			status_text = game.last_event
		"witte_was":
			game.declare_witte_was(player_id)
			status_text = game.last_event
		"challenge":
			game.challenge_vuile_was(player_id)
			status_text = game.last_event
		"decline_challenge":
			game.decline_vuile_was_challenge(player_id)
		"skip_specials":
			game.skip_specials(player_id)
		"knock":
			game.request_knock(player_id)
			status_text = "%s klopt. Inzet %d." % [_name(player_id), game.round_stake]
		"pas":
			game.respond_to_knock(player_id, false)
			status_text = "%s past." % _name(player_id)
		"play":
			var card: Card = action.get("card")
			if card != null:
				game.play_card(player_id, card)
		_:
			if game.state == ToepenGame.State.KNOCK_DECISIONS:
				game.respond_to_knock(player_id, true)
			elif game.state == ToepenGame.State.PRE_ROUND_SPECIALS:
				game.skip_specials(player_id)
			elif game.state == ToepenGame.State.NORMAL_PLAY:
				var legal := game.legal_cards(player_id)
				if legal.size() > 0:
					game.play_card(player_id, legal[0])


func _name(player_id: int) -> String:
	if player_id == ToepenGame.HUMAN_PLAYER_ID:
		return "Jij"
	if player_id < 0:
		return "?"
	return "AI %d" % player_id
