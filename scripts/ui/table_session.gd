class_name TableSession
extends RefCounted

## Wires the core engine to baseline AI. UI stays presentation-only.

var game: ToepenGame
var ai: BaselineAI
var tutorial: TutorialDirector
var status_text: String = ""
var tip_text: String = ""
var flow: CampaignFlow = null
var power_service: PowerUpService = null
var seat_ai: Array = []
var opponent_names: PackedStringArray = PackedStringArray(["AI 1", "AI 2", "AI 3"])
var last_after_pot: int = CampaignFlow.AfterPot.NONE
var power_mode: String = ""
var pending_wasdag_choice: bool = false
var pending_was_challenger_id: int = -1
var presentation_events: Array[Dictionary] = []


func _init() -> void:
	game = ToepenGame.new()
	ai = BaselineAI.new()
	tutorial = TutorialDirector.new()
	seat_ai = [null, ai, ai, ai]


func bind_campaign(p_flow: CampaignFlow) -> void:
	flow = p_flow
	power_service = PowerUpService.new()


func start_new_pot() -> void:
	tutorial = TutorialDirector.new()
	game.cards_open = false
	game.start_pot()
	status_text = "Nieuwe pot. Specials vóór de eerste kaart, daarna spelen."
	resolve_ai()


func start_campaign_pot() -> void:
	tutorial = TutorialDirector.new()
	game = ToepenGame.new()
	_configure_campaign_table()
	game.cards_open = _campaign_cards_are_open()
	game.start_pot()
	status_text = "%s — potje %d." % [LocationId.display_name(flow.campaign.location), flow.campaign.potje]
	if game.cards_open:
		status_text += " Leerstand: kaarten van tegenstanders zijn open."
	if flow.campaign.is_boss_potje():
		status_text += " Boss: %s." % LocationId.boss_name(flow.campaign.location)
	resolve_ai()


func _campaign_cards_are_open() -> bool:
	if flow == null:
		return false
	var campaign := flow.campaign
	return (
		campaign.location == LocationId.STUDENTENHUIS
		and campaign.potje == 1
		and bool(campaign.settings.get("open_first_pot", true))
	)


func _configure_campaign_table() -> void:
	var potje := flow.campaign.potje
	opponent_names = PackedStringArray()
	seat_ai = [null]
	for seat in range(1, 4):
		var profile := AiProfile.for_location(flow.campaign.location, potje, seat)
		opponent_names.append(profile.display_name)
		seat_ai.append(BaselineAI.new(profile))
	var run := flow.campaign
	game.penalty_adjuster = func(player_id: int, amount: int) -> int:
		return power_service.adjust_penalty(game, run, player_id, amount)


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


func start_tutorial_bluffen() -> void:
	tutorial.setup_bluffen(game)
	status_text = tutorial.intro
	tip_text = tutorial.tip_for(game)
	resolve_ai()


func start_tutorial_was() -> void:
	tutorial.setup_was(game, "true")
	status_text = tutorial.intro
	tip_text = tutorial.tip_for(game)
	resolve_ai()


func start_tutorial_toep() -> void:
	tutorial.setup_toep(game, "toep")
	status_text = tutorial.intro
	tip_text = tutorial.tip_for(game)
	resolve_ai()


func start_tutorial_armoede() -> void:
	tutorial.setup_armoede(game)
	status_text = tutorial.intro
	tip_text = tutorial.tip_for(game)
	resolve_ai()


func start_tutorial_winkel() -> void:
	tutorial.setup_winkel_table(game)
	var save := SaveGame.new()
	save.memory_only = true
	flow = CampaignFlow.new(save)
	flow.start_new_studentenhuis_run()
	flow.campaign.beer_caps = 20
	power_service = PowerUpService.new()
	flow.campaign.add_power_up(PowerUpId.EVEN_SPIEKEN)
	flow.open_scripted_shop(tutorial.scripted_offerings)
	status_text = tutorial.intro
	tip_text = tutorial.tip_for(game)
	resolve_ai()


func next_round() -> void:
	if game.state != ToepenGame.State.ROUND_END:
		return
	if flow != null:
		flow.campaign.clear_peek()
	power_mode = ""
	pending_wasdag_choice = false
	if tutorial.kind == TutorialDirector.Kind.BLUFFEN and tutorial.bluff_phase == 1:
		tutorial.advance_bluffen(game)
		status_text = tutorial.intro
		resolve_ai()
		return
	game.start_round()
	status_text = "Nieuwe ronde. Inzet %d." % game.round_stake
	resolve_ai()


func human_knock() -> bool:
	if not game.request_knock(ToepenGame.HUMAN_PLAYER_ID):
		return false
	if flow != null and power_service != null:
		power_service.consume_dubbel_on_knock(game, flow.campaign)
		flow.persist()
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
	_queue_card_event(ToepenGame.HUMAN_PLAYER_ID, card)
	status_text = "Jij speelt %s." % str(card)
	resolve_ai()
	return true


func human_toep() -> bool:
	if not game.declare_toep(ToepenGame.HUMAN_PLAYER_ID):
		return false
	status_text = game.last_event
	if flow != null:
		flow.apply_toep_reward(game)
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
	if power_service != null and flow != null:
		power_service.resolve_wasdag(game, flow.campaign)
		flow.persist()
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
	if pending_wasdag_choice:
		return true
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
		_update_tip()
		if game.state == ToepenGame.State.GAME_END:
			status_text = "Pot gedaan. Winnaar: %s." % _name(game.pot_winner_id)
			_handle_pot_end()
			return
		if game.state == ToepenGame.State.ROUND_END:
			if flow != null:
				flow.apply_round_rewards(game)
			if status_text == "":
				status_text = "Ronde voorbij. Winnaar: %s." % _name(game.last_round_winner_id)
			return
		var actor := _current_ai_actor()
		if actor < 0:
			return
		if game.players[actor].is_human:
			return
		if game.state == ToepenGame.State.VUILE_WAS_CHALLENGE \
				and game.vuile_was_caller_id == ToepenGame.HUMAN_PLAYER_ID \
				and flow != null and flow.campaign.has_power_up(PowerUpId.WASDAG) \
				and not flow.campaign.wasdag_armed \
				and not pending_wasdag_choice:
			var view := PublicView.from_game(game, actor)
			var action := _ai_for(actor).decide(view, game.rng)
			if str(action.get("type", "")) == "challenge":
				pending_wasdag_choice = true
				pending_was_challenger_id = actor
				status_text = "Je Was-claim wordt betwist. Wasdag nu, of laat de betwisting doorgaan."
				return
		_apply_ai(actor)


func _update_tip() -> void:
	var tutorial_tip := tutorial.tip_for(game)
	if tutorial_tip != "":
		tip_text = tutorial_tip
	else:
		tip_text = CardAdvisor.turn_tip(game)


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
		tutorial.force_ai_knock_strong = false
		tutorial.force_ai_knock_bluff = false
		return
	var view := PublicView.from_game(game, player_id)
	var actor_ai: BaselineAI = _ai_for(player_id)
	var action := actor_ai.decide(view, game.rng)
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
			if power_service != null and flow != null:
				power_service.resolve_wasdag(game, flow.campaign)
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
		"mee":
			game.respond_to_knock(player_id, true)
			status_text = "%s gaat mee." % _name(player_id)
		"play":
			var card: Card = action.get("card")
			if card != null:
				if game.play_card(player_id, card) == ToepenGame.PlayError.NONE:
					_queue_card_event(player_id, card)
		_:
			if game.state == ToepenGame.State.KNOCK_DECISIONS:
				game.respond_to_knock(player_id, true)
			elif game.state == ToepenGame.State.PRE_ROUND_SPECIALS:
				game.skip_specials(player_id)
			elif game.state == ToepenGame.State.NORMAL_PLAY:
				var legal := game.legal_cards(player_id)
				if legal.size() > 0:
					var fallback: Card = legal[0]
					if game.play_card(player_id, fallback) == ToepenGame.PlayError.NONE:
						_queue_card_event(player_id, fallback)


func _queue_card_event(player_id: int, card: Card) -> void:
	presentation_events.append({
		"player_id": player_id,
		"label": UiLayout.compact_card(card),
		"red": card.suit == Card.Suit.HEARTS or card.suit == Card.Suit.DIAMONDS,
	})


func take_presentation_events() -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	events.assign(presentation_events)
	presentation_events.clear()
	return events


func _ai_for(player_id: int) -> BaselineAI:
	if player_id >= 0 and player_id < seat_ai.size() and seat_ai[player_id] != null:
		return seat_ai[player_id]
	return ai


func _handle_pot_end() -> void:
	if flow == null:
		return
	last_after_pot = flow.resolve_pot_end(game)


func opponent_name(player_id: int) -> String:
	if player_id <= 0 or player_id > opponent_names.size():
		return "AI %d" % player_id
	return opponent_names[player_id - 1]


func _name(player_id: int) -> String:
	if player_id == ToepenGame.HUMAN_PLAYER_ID:
		return "Jij"
	if player_id < 0:
		return "?"
	return opponent_name(player_id)


func can_use_power(id: String) -> bool:
	if flow == null or power_service == null:
		return false
	return power_service.can_activate(id, game, flow.campaign)


func use_kaartje_ruilen(card: Card) -> bool:
	if power_service == null or flow == null:
		return false
	if not power_service.use_kaartje_ruilen(game, flow.campaign, card):
		return false
	power_mode = ""
	status_text = "Kaartje Ruilen: nieuwe kaart."
	flow.persist()
	return true


func use_even_spieken(opponent_id: int) -> bool:
	if power_service == null or flow == null:
		return false
	if not power_service.use_even_spieken(game, flow.campaign, opponent_id, game.rng):
		return false
	power_mode = ""
	status_text = "Je spiekt: %s." % flow.campaign.peek_label
	flow.persist()
	return true


func use_rondje() -> bool:
	if power_service == null or flow == null:
		return false
	if not power_service.use_rondje(game, flow.campaign):
		return false
	status_text = "Rondje van de Zaak: -1 strafpunt."
	flow.persist()
	return true


func begin_huisvoordeel(card: Card) -> bool:
	if power_service == null or flow == null:
		return false
	if not power_service.begin_huisvoordeel(game, flow.campaign, card):
		return false
	power_mode = "huis_choose"
	status_text = "Huisvoordeel: kies een van de twee kaarten."
	return true


func finish_huisvoordeel(index: int) -> bool:
	if power_service == null or flow == null:
		return false
	if not power_service.finish_huisvoordeel(game, flow.campaign, index):
		return false
	power_mode = ""
	status_text = "Huisvoordeel toegepast."
	flow.persist()
	return true


func arm_wasdag() -> bool:
	if power_service == null or flow == null:
		return false
	if not power_service.arm_wasdag(game, flow.campaign):
		return false
	status_text = "Wasdag klaar. De betwisting volgt."
	_continue_pending_was_challenge()
	return true


func skip_wasdag() -> bool:
	if not pending_wasdag_choice:
		return false
	_continue_pending_was_challenge()
	return true


func _continue_pending_was_challenge() -> void:
	var challenger := pending_was_challenger_id
	pending_wasdag_choice = false
	pending_was_challenger_id = -1
	if challenger >= 0:
		game.challenge_vuile_was(challenger)
		if power_service != null and flow != null:
			power_service.resolve_wasdag(game, flow.campaign)
			flow.persist()
		status_text = game.last_event
	resolve_ai()


func arm_dubbel_kloppen() -> bool:
	if power_service == null or flow == null:
		return false
	if not power_service.arm_dubbel_kloppen(game, flow.campaign):
		return false
	status_text = "Dubbel Kloppen: de volgende KLOP is geboost."
	flow.persist()
	return true


func use_stalen_zenuwen() -> bool:
	if power_service == null or flow == null:
		return false
	if not power_service.use_stalen_zenuwen(game, flow.campaign):
		return false
	status_text = "Stalen Zenuwen: je gaat mee; bij verlies -1 strafpunt."
	flow.persist()
	return human_mee()
