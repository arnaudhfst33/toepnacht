class_name PowerUpService
extends RefCounted

## Campaign power-ups. Mutates ToepenGame through public APIs only.

var pending_huisvoordeel_discard: Card = null
var pending_huisvoordeel_candidates: Array[Card] = []


func can_activate(id: String, game: ToepenGame, run: CampaignState) -> bool:
	if run == null or game == null:
		return false
	if not run.has_power_up(id):
		return false
	if not PowerUpCatalog.is_implemented(id):
		return false
	if PowerUpCatalog.is_passive(id):
		return false
	match id:
		PowerUpId.KAARTJE_RUILEN:
			return _swap_timing_ok(game) and game.deck != null and game.deck.remaining() > 0
		PowerUpId.EVEN_SPIEKEN:
			return _human_decision_moment(game) and _hidden_opponent_exists(game)
		PowerUpId.RONDJE_VAN_DE_ZAAK:
			return _between_trick_or_round(game) and game.players[ToepenGame.HUMAN_PLAYER_ID].penalty_points > 0
		PowerUpId.HUISVOORDEEL:
			return _swap_timing_ok(game) and game.deck != null and game.deck.remaining() >= 2
		_:
			return false


func _swap_timing_ok(game: ToepenGame) -> bool:
	var human := game.players[ToepenGame.HUMAN_PLAYER_ID]
	if human.is_eliminated or not human.is_active_in_round:
		return false
	if human.hand.is_empty():
		return false
	if game.human_played_this_round:
		return false
	if game.state == ToepenGame.State.GAME_END:
		return false
	if game.state == ToepenGame.State.ROUND_END:
		return false
	return game.state == ToepenGame.State.PRE_ROUND_SPECIALS \
		or game.state == ToepenGame.State.VUILE_WAS_CHALLENGE \
		or game.state == ToepenGame.State.NORMAL_PLAY \
		or game.state == ToepenGame.State.KNOCK_DECISIONS \
		or game.state == ToepenGame.State.DEALING


func _human_decision_moment(game: ToepenGame) -> bool:
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
	return false


func _between_trick_or_round(game: ToepenGame) -> bool:
	if game.state == ToepenGame.State.ROUND_END:
		return true
	if game.state == ToepenGame.State.NORMAL_PLAY and game.current_trick != null and game.current_trick.play_count() == 0:
		return true
	if game.state == ToepenGame.State.PRE_ROUND_SPECIALS:
		return true
	return false


func _hidden_opponent_exists(game: ToepenGame) -> bool:
	for player in game.players:
		if player.id == ToepenGame.HUMAN_PLAYER_ID:
			continue
		if player.is_eliminated:
			continue
		if player.hand.size() > 0:
			return true
	return false


func use_kaartje_ruilen(game: ToepenGame, run: CampaignState, discard: Card) -> bool:
	if not can_activate(PowerUpId.KAARTJE_RUILEN, game, run):
		return false
	var human := game.players[ToepenGame.HUMAN_PLAYER_ID]
	if not human.has_card(discard):
		return false
	if game.deck.remaining() <= 0:
		return false
	human.take_card(discard)
	human.hand.append(game.deck.draw())
	run.consume_power_up(PowerUpId.KAARTJE_RUILEN)
	return true


func use_even_spieken(game: ToepenGame, run: CampaignState, opponent_id: int, rng: RandomNumberGenerator) -> bool:
	if not can_activate(PowerUpId.EVEN_SPIEKEN, game, run):
		return false
	if opponent_id == ToepenGame.HUMAN_PLAYER_ID:
		return false
	if opponent_id < 0 or opponent_id >= game.players.size():
		return false
	var opponent := game.players[opponent_id]
	if opponent.is_eliminated or opponent.hand.is_empty():
		return false
	var idx := rng.randi_range(0, opponent.hand.size() - 1)
	run.set_peek(opponent_id, opponent.hand[idx])
	run.consume_power_up(PowerUpId.EVEN_SPIEKEN)
	return true


func use_rondje(game: ToepenGame, run: CampaignState) -> bool:
	if not can_activate(PowerUpId.RONDJE_VAN_DE_ZAAK, game, run):
		return false
	var human := game.players[ToepenGame.HUMAN_PLAYER_ID]
	if human.penalty_points <= 0:
		return false
	human.penalty_points -= 1
	run.consume_power_up(PowerUpId.RONDJE_VAN_DE_ZAAK)
	return true


func begin_huisvoordeel(game: ToepenGame, run: CampaignState, discard: Card) -> bool:
	if not can_activate(PowerUpId.HUISVOORDEEL, game, run):
		return false
	var human := game.players[ToepenGame.HUMAN_PLAYER_ID]
	if not human.has_card(discard):
		return false
	if game.deck.remaining() < 2:
		return false
	pending_huisvoordeel_discard = discard
	pending_huisvoordeel_candidates.clear()
	pending_huisvoordeel_candidates.append(game.deck.draw())
	pending_huisvoordeel_candidates.append(game.deck.draw())
	return true


func finish_huisvoordeel(game: ToepenGame, run: CampaignState, chosen_index: int) -> bool:
	if pending_huisvoordeel_discard == null:
		return false
	if pending_huisvoordeel_candidates.size() != 2:
		return false
	if chosen_index < 0 or chosen_index > 1:
		return false
	if not run.has_power_up(PowerUpId.HUISVOORDEEL):
		_clear_huisvoordeel()
		return false
	var human := game.players[ToepenGame.HUMAN_PLAYER_ID]
	if not human.has_card(pending_huisvoordeel_discard):
		_clear_huisvoordeel()
		return false
	human.take_card(pending_huisvoordeel_discard)
	var chosen: Card = pending_huisvoordeel_candidates[chosen_index]
	var other: Card = pending_huisvoordeel_candidates[1 - chosen_index]
	human.hand.append(chosen)
	game.deck.return_to_stock_deterministic(other)
	run.consume_power_up(PowerUpId.HUISVOORDEEL)
	_clear_huisvoordeel()
	return true


func _clear_huisvoordeel() -> void:
	pending_huisvoordeel_discard = null
	pending_huisvoordeel_candidates.clear()


func adjust_penalty(game: ToepenGame, run: CampaignState, player_id: int, amount: int) -> int:
	if amount <= 0:
		return 0
	if player_id != ToepenGame.HUMAN_PLAYER_ID:
		return amount
	if run == null or not run.has_power_up(PowerUpId.OP_HET_RANDJE):
		return amount
	var player := game.players[player_id]
	if player.is_eliminated:
		return amount
	var projected := player.penalty_points + amount
	if projected < ToepenGame.ELIMINATION_POINTS:
		return amount
	player.penalty_points = 14
	player.is_eliminated = false
	player.is_active_in_round = true
	run.consume_power_up(PowerUpId.OP_HET_RANDJE)
	return 0
