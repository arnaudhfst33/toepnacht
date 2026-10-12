class_name ToepenGame
extends RefCounted

## Headless Toepen rules engine. Presentation and later campaign systems stay out.

enum State {
	DEALING,
	PRE_ROUND_SPECIALS,
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

# TODO_UNSPECIFIED_RULE: GDD does not specify round-loss penalty amounts, knock stake increases,
# or PAS/fold scoring. apply_penalty() is the only scoring entry point for this task.
# TODO_UNSPECIFIED_RULE: GDD does not specify who leads the first round of a later potje.
# TODO_UNSPECIFIED_RULE: GDD does not specify deal start position; cards are dealt one-at-a-time
# clockwise from the round leader to non-eliminated players.
# TODO_UNSPECIFIED_RULE: A player who PAS is marked inactive and skipped for the rest of the round.


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
	state = State.PRE_ROUND_SPECIALS


func begin_play() -> void:
	if state == State.PRE_ROUND_SPECIALS:
		state = State.NORMAL_PLAY


func request_knock(player_id: int) -> bool:
	if state != State.NORMAL_PLAY:
		return false
	if player_id != current_actor_id:
		return false
	# Knock is allowed on your turn before you play a card this trick.
	state = State.KNOCK_DECISIONS
	knock_initiator_id = player_id
	return true


func respond_to_knock(player_id: int, mee: bool) -> bool:
	if state != State.KNOCK_DECISIONS:
		return false
	if player_id == knock_initiator_id:
		return false
	if players[player_id].is_eliminated:
		return false
	if not mee:
		players[player_id].is_active_in_round = false
	return true


func resume_after_knock() -> void:
	if state == State.KNOCK_DECISIONS:
		state = State.NORMAL_PLAY
		if players[current_actor_id].is_eliminated or not players[current_actor_id].is_active_in_round:
			current_actor_id = _next_active_in_round(current_actor_id)


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
	current_trick.add_play(player_id, taken)

	if current_trick.is_complete(_active_in_round_count()):
		_resolve_trick()
	else:
		current_actor_id = _next_active_in_round(player_id)
	return PlayError.NONE


func apply_penalty(player_id: int, amount: int) -> void:
	var player := players[player_id]
	if player.is_eliminated:
		return
	player.penalty_points += amount
	if player.penalty_points >= ELIMINATION_POINTS:
		player.is_eliminated = true
		player.is_active_in_round = false
		player.penalty_points = maxi(player.penalty_points, ELIMINATION_POINTS)
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
	current_trick = Trick.new()
	current_leader_id = leader_id
	current_actor_id = leader_id
	first_ever_round = false
	for i in players.size():
		var player := players[i]
		player.hand.clear()
		player.is_active_in_round = not player.is_eliminated
		if i < hands.size():
			for card in hands[i]:
				player.hand.append(card)
	state = State.NORMAL_PLAY


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


func _resolve_trick() -> void:
	var winner_id := current_trick.winner_id()
	tricks_completed += 1
	if tricks_completed >= TRICKS_PER_ROUND:
		last_round_winner_id = winner_id
		state = State.ROUND_END
		return
	current_leader_id = winner_id
	current_actor_id = winner_id
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
