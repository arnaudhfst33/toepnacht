class_name ToepenGame
extends RefCounted

## Headless Toepen rules engine. Presentation and later campaign systems stay out.

enum State {
	DEALING,
	PRE_ROUND_SPECIALS,
	VUILE_WAS_CHALLENGE,
	NORMAL_PLAY,
	KNOCK_DECISIONS,
	ROUND_END,
	GAME_END,
}

enum PlayError {
	NONE,
	WRONG_STATE,
	NOT_YOUR_TURN,
	PLAYER_INACTIVE,
	PLAYER_ELIMINATED,
	CARD_NOT_IN_HAND,
	ILLEGAL_FOLLOW_SUIT,
}

const PLAYER_COUNT := 4
const HAND_SIZE := 4
const TRICKS_PER_ROUND := 4
const ELIMINATION_POINTS := 15
const HUMAN_PLAYER_ID := 0
const BASE_ROUND_STAKE := 1
const TOEP_PENALTY := 3
const WAS_PENALTY := 1

var rng: RandomNumberGenerator
var players: Array[Player] = []
var deck: Deck
var state: State = State.DEALING
var current_trick: Trick
var tricks_completed: int = 0
var current_leader_id: int = HUMAN_PLAYER_ID
var current_actor_id: int = HUMAN_PLAYER_ID
var last_round_winner_id: int = HUMAN_PLAYER_ID
var pot_winner_id: int = -1
var first_ever_round: bool = true
var knock_initiator_id: int = -1
var knock_pending: Array[int] = []
var round_stake: int = BASE_ROUND_STAKE
var specials_pending: Array[int] = []
var vuile_was_caller_id: int = -1
var vuile_was_challenge_pending: Array[int] = []
var last_event: String = ""
var last_toep_declarer_id: int = -1
var last_kans_completed_toep: bool = false
var last_vuile_was_bluff: bool = false
var last_witte_was_declarer_id: int = -1
var last_witte_was_bluff: bool = false
var was_claim_is_witte: bool = false
var cards_open: bool = false
var round_serial: int = 0
var last_toep_event_id: int = 0
var human_knocked_this_round: bool = false
var human_played_this_round: bool = false
var penalty_adjuster: Callable = Callable()


func _init(p_rng: RandomNumberGenerator = null) -> void:
	if p_rng == null:
		rng = RandomNumberGenerator.new()
		rng.seed = 1
	else:
		rng = p_rng
	for i in PLAYER_COUNT:
		var player := Player.new()
		player.id = i
		player.is_human = i == HUMAN_PLAYER_ID
		players.append(player)


func start_pot() -> void:
	pot_winner_id = -1
	for player in players:
		player.reset_for_new_pot()
	start_round()


func start_round() -> void:
	assert(pot_winner_id < 0, "Cannot start a round after the pot has ended.")
	state = State.DEALING
	tricks_completed = 0
	knock_initiator_id = -1
	knock_pending.clear()
	specials_pending.clear()
	vuile_was_caller_id = -1
	vuile_was_challenge_pending.clear()
	was_claim_is_witte = false
	round_stake = BASE_ROUND_STAKE
	round_serial += 1
	human_knocked_this_round = false
	human_played_this_round = false
	current_trick = Trick.new()
	deck = Deck.standard()
	deck.shuffle(rng)

	for player in players:
		player.hand.clear()
		player.is_active_in_round = not player.is_eliminated

	if first_ever_round:
		current_leader_id = HUMAN_PLAYER_ID
		first_ever_round = false
	else:
		current_leader_id = last_round_winner_id
		if players[current_leader_id].is_eliminated:
			current_leader_id = _next_in_pot(current_leader_id)

	_deal_one_at_a_time()
	current_actor_id = current_leader_id
	_queue_specials()
	state = State.PRE_ROUND_SPECIALS
	_announce_armoede()


func begin_play() -> void:
	if state == State.PRE_ROUND_SPECIALS or state == State.VUILE_WAS_CHALLENGE:
		specials_pending.clear()
		vuile_was_caller_id = -1
		vuile_was_challenge_pending.clear()
		was_claim_is_witte = false
		state = State.NORMAL_PLAY
		current_actor_id = current_leader_id


func current_specials_actor_id() -> int:
	if state != State.PRE_ROUND_SPECIALS or specials_pending.is_empty():
		return -1
	return specials_pending[0]


func can_declare_toep(player_id: int) -> bool:
	if players[player_id].is_eliminated or not players[player_id].is_active_in_round:
		return false
	if players[player_id].hand.size() != HAND_SIZE:
		return false
	if not detect_player_specials(player_id).toep:
		return false
	if state == State.PRE_ROUND_SPECIALS:
		return current_specials_actor_id() == player_id
	if state == State.NORMAL_PLAY:
		return player_id == current_actor_id and current_trick.play_count() == 0 and tricks_completed == 0
	return false


func declare_toep(player_id: int) -> bool:
	if not can_declare_toep(player_id):
		return false
	_resolve_toep(player_id)
	return true


func can_use_kans(player_id: int) -> bool:
	if players[player_id].is_eliminated or not players[player_id].is_active_in_round:
		return false
	if not detect_player_specials(player_id).kans_op_toep:
		return false
	if deck == null or deck.remaining() <= 0:
		return false
	if state == State.PRE_ROUND_SPECIALS:
		return current_specials_actor_id() == player_id
	if state == State.NORMAL_PLAY:
		return player_id == current_actor_id and current_trick.play_count() == 0 and tricks_completed == 0
	return false


func use_kans(player_id: int) -> bool:
	if not can_use_kans(player_id):
		return false
	var player := players[player_id]
	var off_card := HandDetector.kans_off_card(player.hand)
	if off_card == null:
		return false
	player.take_card(off_card)
	var drawn := deck.draw()
	player.hand.append(drawn)
	last_event = "Speler %d wisselt voor Kans op Toep." % player_id
	if detect_player_specials(player_id).toep:
		last_kans_completed_toep = true
		_resolve_toep(player_id)
		return true
	last_kans_completed_toep = false
	_advance_specials(player_id)
	return true


func can_call_vuile_was(player_id: int) -> bool:
	if not _before_first_card():
		return false
	if players[player_id].is_eliminated or not players[player_id].is_active_in_round:
		return false
	if state != State.PRE_ROUND_SPECIALS:
		return false
	return current_specials_actor_id() == player_id


func call_vuile_was(player_id: int) -> bool:
	return _begin_was_claim(player_id, false)


func current_vuile_was_challenger_id() -> int:
	if state != State.VUILE_WAS_CHALLENGE or vuile_was_challenge_pending.is_empty():
		return -1
	return vuile_was_challenge_pending[0]


func challenge_vuile_was(player_id: int) -> bool:
	if state != State.VUILE_WAS_CHALLENGE:
		return false
	if not vuile_was_challenge_pending.has(player_id):
		return false
	var caller := vuile_was_caller_id
	var genuine := _was_claim_is_genuine(caller)
	_set_last_was_bluff(not genuine)
	if genuine:
		_replace_hand_from_stock(caller)
		apply_penalty(player_id, WAS_PENALTY)
		last_event = "%s was echt. Caller nieuwe hand; betwister +%d." % [_was_label(), WAS_PENALTY]
	else:
		apply_penalty(caller, WAS_PENALTY)
		last_event = "%s was bluf. Caller +%d en houdt de hand." % [_was_label(), WAS_PENALTY]
	_finish_vuile_was_flow()
	return true


func decline_vuile_was_challenge(player_id: int) -> bool:
	if state != State.VUILE_WAS_CHALLENGE:
		return false
	if not vuile_was_challenge_pending.has(player_id):
		return false
	vuile_was_challenge_pending.erase(player_id)
	if vuile_was_challenge_pending.is_empty():
		_resolve_was_unchallenged()
	return true


func can_declare_witte_was(player_id: int) -> bool:
	return can_call_vuile_was(player_id)


func declare_witte_was(player_id: int) -> bool:
	return _begin_was_claim(player_id, true)


func skip_specials(player_id: int) -> bool:
	if state != State.PRE_ROUND_SPECIALS:
		return false
	if current_specials_actor_id() != player_id:
		return false
	_advance_specials(player_id)
	return true


func can_pass(player_id: int) -> bool:
	if state != State.KNOCK_DECISIONS:
		return false
	if not knock_pending.has(player_id):
		return false
	if current_trick.has_play_from(player_id):
		return false
	return true


func armoede_player_ids() -> Array[int]:
	var ids: Array[int] = []
	for player in players:
		if player_is_armoede(player.id):
			ids.append(player.id)
	return ids


func can_knock(player_id: int) -> bool:
	if state != State.NORMAL_PLAY:
		return false
	if player_id != current_actor_id:
		return false
	var player := players[player_id]
	if player.is_eliminated or not player.is_active_in_round:
		return false
	return _active_in_round_count() >= 2


func request_knock(player_id: int) -> bool:
	if not can_knock(player_id):
		return false
	round_stake += 1
	state = State.KNOCK_DECISIONS
	knock_initiator_id = player_id
	knock_pending.clear()
	var id := _next_active_in_round(player_id)
	while id != player_id:
		knock_pending.append(id)
		id = _next_active_in_round(id)
	if player_id == HUMAN_PLAYER_ID:
		human_knocked_this_round = true
	if knock_pending.is_empty():
		_finish_knock()
	return true


func current_knock_responder_id() -> int:
	if state != State.KNOCK_DECISIONS or knock_pending.is_empty():
		return -1
	return knock_pending[0]


func respond_to_knock(player_id: int, mee: bool) -> bool:
	if state != State.KNOCK_DECISIONS:
		return false
	if not knock_pending.has(player_id):
		return false
	if player_id == knock_initiator_id:
		return false
	if players[player_id].is_eliminated:
		return false
	if not mee and not can_pass(player_id):
		return false
	knock_pending.erase(player_id)
	if not mee:
		apply_penalty(player_id, round_stake)
		players[player_id].is_active_in_round = false
	if knock_pending.is_empty():
		_finish_knock()
	return true


func resume_after_knock() -> void:
	if state == State.KNOCK_DECISIONS and knock_pending.is_empty():
		_finish_knock()


func legal_cards(player_id: int) -> Array[Card]:
	var player := players[player_id]
	var result: Array[Card] = []
	for card in player.hand:
		if _is_legal_play(player, card):
			result.append(card)
	return result


func play_card(player_id: int, card: Card) -> PlayError:
	if state != State.NORMAL_PLAY:
		return PlayError.WRONG_STATE
	if player_id != current_actor_id:
		return PlayError.NOT_YOUR_TURN
	var player := players[player_id]
	if player.is_eliminated:
		return PlayError.PLAYER_ELIMINATED
	if not player.is_active_in_round:
		return PlayError.PLAYER_INACTIVE
	if not player.has_card(card):
		return PlayError.CARD_NOT_IN_HAND
	if not _is_legal_play(player, card):
		return PlayError.ILLEGAL_FOLLOW_SUIT

	var taken := player.take_card(card)
	if player_id == HUMAN_PLAYER_ID:
		human_played_this_round = true
	current_trick.add_play(player_id, taken)

	if _all_active_have_played():
		_resolve_trick()
	else:
		current_actor_id = _next_active_in_round(player_id)
	return PlayError.NONE


func apply_penalty(player_id: int, amount: int) -> void:
	if amount <= 0:
		return
	var intercepted := false
	if penalty_adjuster.is_valid():
		amount = int(penalty_adjuster.call(player_id, amount))
		intercepted = amount <= 0
	if amount <= 0:
		if intercepted:
			_announce_armoede()
			_refresh_pot_winner()
		return
	var player := players[player_id]
	if player.is_eliminated:
		return
	player.penalty_points += amount
	if player.penalty_points >= ELIMINATION_POINTS:
		player.is_eliminated = true
		player.is_active_in_round = false
		player.penalty_points = maxi(player.penalty_points, ELIMINATION_POINTS)
	_announce_armoede()
	_refresh_pot_winner()


func detect_player_specials(player_id: int) -> SpecialHandFlags:
	return HandDetector.analyze(players[player_id].hand)


func player_is_armoede(player_id: int) -> bool:
	var player := players[player_id]
	return (not player.is_eliminated) and HandDetector.is_armoede(player.penalty_points)


func setup_controlled_round(hands: Array, leader_id: int) -> void:
	state = State.DEALING
	tricks_completed = 0
	knock_initiator_id = -1
	knock_pending.clear()
	specials_pending.clear()
	vuile_was_caller_id = -1
	vuile_was_challenge_pending.clear()
	was_claim_is_witte = false
	round_stake = BASE_ROUND_STAKE
	round_serial += 1
	human_knocked_this_round = false
	human_played_this_round = false
	current_trick = Trick.new()
	current_leader_id = leader_id
	current_actor_id = leader_id
	first_ever_round = false
	pot_winner_id = -1
	for i in players.size():
		var player := players[i]
		player.hand.clear()
		if not player.is_eliminated:
			player.is_active_in_round = true
		if i < hands.size():
			for card in hands[i]:
				player.hand.append(card)
	_fill_stock_from_unused()
	state = State.NORMAL_PLAY


func setup_controlled_specials(hands: Array, leader_id: int) -> void:
	setup_controlled_round(hands, leader_id)
	_queue_specials()
	state = State.PRE_ROUND_SPECIALS
	current_actor_id = leader_id


func _queue_specials() -> void:
	specials_pending.clear()
	var id := current_leader_id
	for _i in PLAYER_COUNT:
		if not players[id].is_eliminated:
			specials_pending.append(id)
		id = (id + 1) % PLAYER_COUNT


func _advance_specials(player_id: int) -> void:
	specials_pending.erase(player_id)
	if specials_pending.is_empty():
		state = State.NORMAL_PLAY
		current_actor_id = current_leader_id
		if not players[current_actor_id].is_active_in_round:
			current_actor_id = _next_active_in_round(current_actor_id)


func _resolve_toep(player_id: int) -> void:
	last_toep_declarer_id = player_id
	last_toep_event_id += 1
	last_event = "Speler %d declareert Toep. Anderen +%d." % [player_id, TOEP_PENALTY]
	for player in players:
		if player.id == player_id or player.is_eliminated:
			continue
		apply_penalty(player.id, TOEP_PENALTY)
	if pot_winner_id >= 0:
		return
	start_round()


func _before_first_card() -> bool:
	return tricks_completed == 0 and current_trick.play_count() == 0


func _fill_stock_from_unused() -> void:
	var used := {}
	for player in players:
		for card in player.hand:
			used[card.key()] = true
	if current_trick != null:
		for card in current_trick.cards:
			used[card.key()] = true
	deck = Deck.standard()
	var kept: Array[Card] = []
	for card in deck.cards:
		if not used.has(card.key()):
			kept.append(card)
	deck.cards = kept
	if rng != null:
		deck.shuffle(rng)


func _replace_hand_from_stock(player_id: int) -> void:
	var player := players[player_id]
	player.hand.clear()
	for _i in HAND_SIZE:
		if deck.remaining() <= 0:
			break
		player.hand.append(deck.draw())


func _begin_was_claim(player_id: int, is_witte: bool) -> bool:
	if not can_call_vuile_was(player_id):
		return false
	was_claim_is_witte = is_witte
	vuile_was_caller_id = player_id
	if is_witte:
		last_witte_was_declarer_id = player_id
	vuile_was_challenge_pending.clear()
	var id := _next_in_pot(player_id)
	while id != player_id:
		if not players[id].is_eliminated:
			vuile_was_challenge_pending.append(id)
		id = _next_in_pot(id)
	state = State.VUILE_WAS_CHALLENGE
	last_event = "Speler %d claimt %s." % [player_id, _was_label()]
	if vuile_was_challenge_pending.is_empty():
		_resolve_was_unchallenged()
	return true


func _was_label() -> String:
	return "Witte Was" if was_claim_is_witte else "Vuile Was"


func _was_claim_is_genuine(player_id: int) -> bool:
	var flags := detect_player_specials(player_id)
	return flags.witte_was if was_claim_is_witte else flags.vuile_was


func _set_last_was_bluff(is_bluff: bool) -> void:
	if was_claim_is_witte:
		last_witte_was_bluff = is_bluff
	else:
		last_vuile_was_bluff = is_bluff


func _resolve_was_unchallenged() -> void:
	var caller := vuile_was_caller_id
	var genuine := _was_claim_is_genuine(caller)
	_set_last_was_bluff(not genuine)
	_replace_hand_from_stock(caller)
	last_event = "%s onbetwist; claim geldt als geloofd. Caller krijgt een nieuwe hand." % _was_label()
	_finish_vuile_was_flow()


func _finish_vuile_was_flow() -> void:
	var caller := vuile_was_caller_id
	vuile_was_caller_id = -1
	vuile_was_challenge_pending.clear()
	was_claim_is_witte = false
	if pot_winner_id >= 0:
		return
	state = State.PRE_ROUND_SPECIALS
	_advance_specials(caller)


func _announce_armoede() -> void:
	var ids := armoede_player_ids()
	if ids.is_empty():
		return
	var parts: PackedStringArray = PackedStringArray()
	for id in ids:
		parts.append("speler %d" % id)
	last_event = "Armoede (14/15): %s." % ", ".join(parts)


func _finish_knock() -> void:
	knock_pending.clear()
	if pot_winner_id >= 0:
		return
	var active := _active_in_round_count()
	if active <= 1:
		var winner := knock_initiator_id
		for player in players:
			if player.is_active_in_round and not player.is_eliminated:
				winner = player.id
				break
		_end_round(winner)
		return
	state = State.NORMAL_PLAY
	if players[current_actor_id].is_eliminated or not players[current_actor_id].is_active_in_round:
		current_actor_id = _next_active_in_round(current_actor_id)


func _end_round(winner_id: int) -> void:
	last_round_winner_id = winner_id
	for player in players:
		if player.is_eliminated:
			continue
		if player.is_active_in_round and player.id != winner_id:
			apply_penalty(player.id, round_stake)
	if pot_winner_id >= 0:
		state = State.GAME_END
	else:
		state = State.ROUND_END


func _deal_one_at_a_time() -> void:
	for _card_n in HAND_SIZE:
		var id := current_leader_id
		var dealt := 0
		var in_pot := _in_pot_count()
		while dealt < in_pot:
			var player := players[id]
			if not player.is_eliminated:
				player.hand.append(deck.draw())
				dealt += 1
			id = (id + 1) % PLAYER_COUNT


func _is_legal_play(player: Player, card: Card) -> bool:
	if current_trick.play_count() == 0:
		return true
	if not player.has_suit(current_trick.led_suit):
		return true
	return card.suit == current_trick.led_suit


func _all_active_have_played() -> bool:
	if current_trick.play_count() == 0:
		return false
	for player in players:
		if player.is_active_in_round and not player.is_eliminated:
			if not current_trick.has_play_from(player.id):
				return false
	return true


func _resolve_trick() -> void:
	var winner_id := current_trick.winner_id_among(_active_ids())
	tricks_completed += 1
	if tricks_completed >= TRICKS_PER_ROUND:
		_end_round(winner_id)
		return
	current_leader_id = winner_id
	if players[current_leader_id].is_eliminated or not players[current_leader_id].is_active_in_round:
		current_leader_id = _next_active_in_round(current_leader_id)
	current_actor_id = current_leader_id
	current_trick = Trick.new()


func _refresh_pot_winner() -> void:
	var alive: Array[int] = []
	for player in players:
		if not player.is_eliminated:
			alive.append(player.id)
	if alive.size() == 1:
		pot_winner_id = alive[0]
		state = State.GAME_END
	elif alive.size() == 0:
		pot_winner_id = -1
		state = State.GAME_END


func _in_pot_count() -> int:
	var n := 0
	for player in players:
		if not player.is_eliminated:
			n += 1
	return n


func _active_in_round_count() -> int:
	var n := 0
	for player in players:
		if player.is_active_in_round and not player.is_eliminated:
			n += 1
	return n


func _active_ids() -> Array[int]:
	var ids: Array[int] = []
	for player in players:
		if player.is_active_in_round and not player.is_eliminated:
			ids.append(player.id)
	return ids


func _next_in_pot(from_id: int) -> int:
	var id := from_id
	for _i in PLAYER_COUNT:
		id = (id + 1) % PLAYER_COUNT
		if not players[id].is_eliminated:
			return id
	return from_id


func _next_active_in_round(from_id: int) -> int:
	var id := from_id
	for _i in PLAYER_COUNT:
		id = (id + 1) % PLAYER_COUNT
		if players[id].is_active_in_round and not players[id].is_eliminated:
			return id
	return from_id
