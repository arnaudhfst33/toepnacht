class_name CoreTests
extends RefCounted

var _failures: int = 0
var _passed: int = 0


func run_all() -> int:
	_failures = 0
	_passed = 0
	_test_32_unique_cards()
	_test_rank_ordering()
	_test_deal_four_cards()
	_test_follow_suit_enforcement()
	_test_highest_led_suit_wins()
	_test_fourth_trick_winner_wins_round()
	_test_15_points_eliminates()
	_test_toep_detection()
	_test_kans_op_toep_detection()
	_test_vuile_was_detection()
	_test_witte_was_detection()
	_test_armoede_detection()
	_test_same_seed_same_shuffle()
	_test_human_leads_first_round()
	_test_previous_round_winner_leads()
	_test_normal_round_scoring()
	_test_knock_raises_stake()
	_test_pass_pays_immediately()
	_test_mee_does_not_pay_yet()
	_test_second_knock_raises_stake()
	_test_round_end_pays_final_stake()
	_test_pass_can_eliminate()
	_test_knock_rejected_off_turn()
	_test_all_pass_knocker_wins()
	_test_placeholder_ai_uses_own_legal_cards()
	_test_table_session_starts()
	_test_round_score_presentation_event()
	print("")
	print("Core tests: %d passed, %d failed" % [_passed, _failures])
	return _failures


func _expect(condition: bool, name: String) -> void:
	if condition:
		_passed += 1
		print("PASS  %s" % name)
	else:
		_failures += 1
		print("FAIL  %s" % name)


func _expect_eq(actual: Variant, expected: Variant, name: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [name, str(expected), str(actual)])


func _c(suit: Card.Suit, rank: Card.Rank) -> Card:
	return Card.new(suit, rank)


func _test_32_unique_cards() -> void:
	var deck := Deck.standard()
	_expect_eq(deck.remaining(), 32, "standard deck has 32 cards")
	var seen := {}
	for card in deck.cards:
		seen[card.key()] = true
	_expect_eq(seen.size(), 32, "all 32 cards are unique")


func _test_rank_ordering() -> void:
	_expect(Card.Rank.JACK < Card.Rank.QUEEN, "Boer < Vrouw")
	_expect(Card.Rank.QUEEN < Card.Rank.KING, "Vrouw < Heer")
	_expect(Card.Rank.KING < Card.Rank.ACE, "Heer < Aas")
	_expect(Card.Rank.ACE < Card.Rank.SEVEN, "Aas < 7")
	_expect(Card.Rank.SEVEN < Card.Rank.EIGHT, "7 < 8")
	_expect(Card.Rank.EIGHT < Card.Rank.NINE, "8 < 9")
	_expect(Card.Rank.NINE < Card.Rank.TEN, "9 < 10")
	var jack := _c(Card.Suit.HEARTS, Card.Rank.JACK)
	var ten := _c(Card.Suit.HEARTS, Card.Rank.TEN)
	_expect(jack.strength() < ten.strength(), "Boer is weaker than 10")


func _test_deal_four_cards() -> void:
	var game := ToepenGame.new()
	game.start_pot()
	_expect_eq(game.players.size(), 4, "pot has 4 players")
	_expect(game.players[0].is_human, "player 0 is human")
	_expect(not game.players[1].is_human, "player 1 is AI placeholder")
	_expect(not game.players[2].is_human, "player 2 is AI placeholder")
	_expect(not game.players[3].is_human, "player 3 is AI placeholder")
	var keys := {}
	for player in game.players:
		_expect_eq(player.hand.size(), 4, "player %d received 4 cards" % player.id)
		for card in player.hand:
			keys[card.key()] = true
	_expect_eq(keys.size(), 16, "dealt cards are unique")
	_expect_eq(game.deck.remaining(), 16, "16 cards remain after the deal")
	_expect_eq(game.state, ToepenGame.State.PRE_ROUND_SPECIALS, "state is pre-round specials after deal")


func _test_follow_suit_enforcement() -> void:
	var game := ToepenGame.new()
	var hands := [
		[_c(Card.Suit.HEARTS, Card.Rank.EIGHT)],
		[_c(Card.Suit.HEARTS, Card.Rank.NINE), _c(Card.Suit.SPADES, Card.Rank.TEN)],
		[_c(Card.Suit.CLUBS, Card.Rank.TEN)],
		[_c(Card.Suit.DIAMONDS, Card.Rank.TEN)],
	]
	game.setup_controlled_round(hands, 0)
	_expect_eq(game.play_card(0, hands[0][0]), ToepenGame.PlayError.NONE, "leader may play any card")
	var illegal := game.play_card(1, hands[1][1])
	_expect_eq(illegal, ToepenGame.PlayError.ILLEGAL_FOLLOW_SUIT, "must follow hearts when holding hearts")
	_expect_eq(game.players[1].hand.size(), 2, "illegal play did not remove the card")
	_expect_eq(game.play_card(1, hands[1][0]), ToepenGame.PlayError.NONE, "following hearts is legal")


func _test_highest_led_suit_wins() -> void:
	var game := ToepenGame.new()
	# 10 of diamonds is higher rank but off-suit; Boer of hearts is lowest of the led suit.
	var hands := [
		[_c(Card.Suit.HEARTS, Card.Rank.EIGHT)],
		[_c(Card.Suit.DIAMONDS, Card.Rank.TEN)],
		[_c(Card.Suit.HEARTS, Card.Rank.TEN)],
		[_c(Card.Suit.HEARTS, Card.Rank.JACK)],
	]
	game.setup_controlled_round(hands, 0)
	game.play_card(0, hands[0][0])
	game.play_card(1, hands[1][0])
	game.play_card(2, hands[2][0])
	game.play_card(3, hands[3][0])
	_expect_eq(game.current_leader_id, 2, "highest hearts (10) wins the trick")
	_expect_eq(game.tricks_completed, 1, "one trick completed")


func _test_fourth_trick_winner_wins_round() -> void:
	var game := ToepenGame.new()
	var hands := [
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.JACK),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.JACK),
			_c(Card.Suit.HEARTS, Card.Rank.QUEEN),
			_c(Card.Suit.HEARTS, Card.Rank.KING),
			_c(Card.Suit.CLUBS, Card.Rank.TEN),
		],
		[
			_c(Card.Suit.DIAMONDS, Card.Rank.JACK),
			_c(Card.Suit.DIAMONDS, Card.Rank.QUEEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.KING),
			_c(Card.Suit.DIAMONDS, Card.Rank.ACE),
		],
		[
			_c(Card.Suit.SPADES, Card.Rank.JACK),
			_c(Card.Suit.SPADES, Card.Rank.QUEEN),
			_c(Card.Suit.SPADES, Card.Rank.KING),
			_c(Card.Suit.SPADES, Card.Rank.ACE),
		],
	]
	game.setup_controlled_round(hands, 0)
	# Tricks 1-3: player 0 wins with 10/9/8 hearts over lower hearts.
	for trick_i in 3:
		_expect_eq(game.play_card(0, game.players[0].hand[0]), ToepenGame.PlayError.NONE, "p0 trick %d" % (trick_i + 1))
		_expect_eq(game.play_card(1, game.players[1].hand[0]), ToepenGame.PlayError.NONE, "p1 trick %d" % (trick_i + 1))
		_expect_eq(game.play_card(2, game.players[2].hand[0]), ToepenGame.PlayError.NONE, "p2 trick %d" % (trick_i + 1))
		_expect_eq(game.play_card(3, game.players[3].hand[0]), ToepenGame.PlayError.NONE, "p3 trick %d" % (trick_i + 1))
		_expect_eq(game.current_leader_id, 0, "player 0 still leads after trick %d" % (trick_i + 1))
	# Trick 4: player 0 plays jack of clubs, player 1 wins with 10 of clubs.
	_expect_eq(game.play_card(0, game.players[0].hand[0]), ToepenGame.PlayError.NONE, "p0 trick 4")
	_expect_eq(game.play_card(1, game.players[1].hand[0]), ToepenGame.PlayError.NONE, "p1 trick 4")
	_expect_eq(game.play_card(2, game.players[2].hand[0]), ToepenGame.PlayError.NONE, "p2 trick 4")
	_expect_eq(game.play_card(3, game.players[3].hand[0]), ToepenGame.PlayError.NONE, "p3 trick 4")
	_expect_eq(game.state, ToepenGame.State.ROUND_END, "round ends after fourth trick")
	_expect_eq(game.last_round_winner_id, 1, "fourth-trick winner wins the round")
	_expect_eq(game.tricks_completed, 4, "four tricks were played")
	_expect_eq(game.players[0].penalty_points, 1, "active non-winner p0 gets +1")
	_expect_eq(game.players[1].penalty_points, 0, "round winner gets 0")
	_expect_eq(game.players[2].penalty_points, 1, "active non-winner p2 gets +1")
	_expect_eq(game.players[3].penalty_points, 1, "active non-winner p3 gets +1")


func _test_15_points_eliminates() -> void:
	var game := ToepenGame.new()
	game.apply_penalty(1, 14)
	_expect(not game.players[1].is_eliminated, "14 points does not eliminate")
	game.apply_penalty(1, 1)
	_expect(game.players[1].is_eliminated, "15 points eliminates")
	_expect_eq(game.players[1].penalty_points, 15, "eliminated player has 15 points")
	_expect_eq(game.state, ToepenGame.State.DEALING, "pot continues with 3 players left")
	game.apply_penalty(2, 15)
	game.apply_penalty(3, 15)
	_expect(game.players[0].is_eliminated == false, "human still in pot")
	_expect_eq(game.pot_winner_id, 0, "last remaining player wins the pot")
	_expect_eq(game.state, ToepenGame.State.GAME_END, "state is game end")


func _test_toep_detection() -> void:
	var hand: Array[Card] = [
		_c(Card.Suit.HEARTS, Card.Rank.NINE),
		_c(Card.Suit.DIAMONDS, Card.Rank.NINE),
		_c(Card.Suit.CLUBS, Card.Rank.NINE),
		_c(Card.Suit.SPADES, Card.Rank.NINE),
	]
	var flags := HandDetector.analyze(hand)
	_expect(flags.toep, "four nines is Toep")
	_expect(not flags.kans_op_toep, "Toep is not Kans op Toep")


func _test_kans_op_toep_detection() -> void:
	var hand: Array[Card] = [
		_c(Card.Suit.HEARTS, Card.Rank.ACE),
		_c(Card.Suit.DIAMONDS, Card.Rank.ACE),
		_c(Card.Suit.CLUBS, Card.Rank.ACE),
		_c(Card.Suit.SPADES, Card.Rank.EIGHT),
	]
	var flags := HandDetector.analyze(hand)
	_expect(flags.kans_op_toep, "three aces is Kans op Toep")
	_expect(not flags.toep, "three aces is not Toep")


func _test_vuile_was_detection() -> void:
	var hand: Array[Card] = [
		_c(Card.Suit.HEARTS, Card.Rank.JACK),
		_c(Card.Suit.HEARTS, Card.Rank.QUEEN),
		_c(Card.Suit.HEARTS, Card.Rank.KING),
		_c(Card.Suit.HEARTS, Card.Rank.SEVEN),
	]
	var flags := HandDetector.analyze(hand)
	_expect(flags.vuile_was, "3 plaatjes + 7 is Vuile Was")
	_expect(not flags.witte_was, "Vuile Was is not Witte Was")
	var not_vuile := HandDetector.analyze([
		_c(Card.Suit.HEARTS, Card.Rank.JACK),
		_c(Card.Suit.HEARTS, Card.Rank.QUEEN),
		_c(Card.Suit.HEARTS, Card.Rank.KING),
		_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
	])
	_expect(not not_vuile.vuile_was, "3 plaatjes + 8 is not Vuile Was")


func _test_witte_was_detection() -> void:
	var hand: Array[Card] = [
		_c(Card.Suit.HEARTS, Card.Rank.JACK),
		_c(Card.Suit.DIAMONDS, Card.Rank.QUEEN),
		_c(Card.Suit.CLUBS, Card.Rank.KING),
		_c(Card.Suit.SPADES, Card.Rank.ACE),
	]
	var flags := HandDetector.analyze(hand)
	_expect(flags.witte_was, "4 plaatjes is Witte Was")
	_expect(not flags.vuile_was, "Witte Was is not Vuile Was")


func _test_armoede_detection() -> void:
	var game := ToepenGame.new()
	_expect(not game.player_is_armoede(0), "0 points is not Armoede")
	game.apply_penalty(0, 14)
	_expect(game.player_is_armoede(0), "14/15 is Armoede")
	game.apply_penalty(0, 1)
	_expect(not game.player_is_armoede(0), "eliminated player is not Armoede")
	_expect(HandDetector.is_armoede(14), "detector flags 14 as Armoede")
	_expect(not HandDetector.is_armoede(13), "13 is not Armoede")
	_expect(not HandDetector.is_armoede(15), "15 is not Armoede")


func _test_same_seed_same_shuffle() -> void:
	var rng_a := RandomNumberGenerator.new()
	rng_a.seed = 4242
	var rng_b := RandomNumberGenerator.new()
	rng_b.seed = 4242
	var deck_a := Deck.standard()
	var deck_b := Deck.standard()
	deck_a.shuffle(rng_a)
	deck_b.shuffle(rng_b)
	_expect_eq(deck_a.snapshot_keys(), deck_b.snapshot_keys(), "same seed produces the same shuffle")
	var rng_c := RandomNumberGenerator.new()
	rng_c.seed = 7
	var deck_c := Deck.standard()
	deck_c.shuffle(rng_c)
	_expect(deck_a.snapshot_keys() != deck_c.snapshot_keys(), "different seed can produce a different shuffle")


func _test_human_leads_first_round() -> void:
	var game := ToepenGame.new()
	game.start_pot()
	_expect_eq(game.current_leader_id, 0, "human leads the first-ever round")
	_expect_eq(game.current_actor_id, 0, "human acts first in the first-ever round")


func _test_previous_round_winner_leads() -> void:
	var game := ToepenGame.new()
	game.start_pot()
	game.last_round_winner_id = 2
	game.start_round()
	_expect_eq(game.current_leader_id, 2, "previous round winner leads the next round")


func _p1_wins_fourth_hands() -> Array:
	return [
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.JACK),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.JACK),
			_c(Card.Suit.HEARTS, Card.Rank.QUEEN),
			_c(Card.Suit.HEARTS, Card.Rank.KING),
			_c(Card.Suit.CLUBS, Card.Rank.TEN),
		],
		[
			_c(Card.Suit.DIAMONDS, Card.Rank.JACK),
			_c(Card.Suit.DIAMONDS, Card.Rank.QUEEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.KING),
			_c(Card.Suit.DIAMONDS, Card.Rank.ACE),
		],
		[
			_c(Card.Suit.SPADES, Card.Rank.JACK),
			_c(Card.Suit.SPADES, Card.Rank.QUEEN),
			_c(Card.Suit.SPADES, Card.Rank.KING),
			_c(Card.Suit.SPADES, Card.Rank.ACE),
		],
	]


func _play_out_p1_wins_fourth(game: ToepenGame) -> void:
	for _trick_i in 4:
		for _step in 4:
			if game.state != ToepenGame.State.NORMAL_PLAY:
				return
			var actor := game.current_actor_id
			var legal := game.legal_cards(actor)
			if legal.is_empty():
				return
			game.play_card(actor, legal[0])


func _all_mee(game: ToepenGame) -> void:
	while game.state == ToepenGame.State.KNOCK_DECISIONS:
		var responder := game.current_knock_responder_id()
		if responder < 0:
			break
		game.respond_to_knock(responder, true)


func _test_normal_round_scoring() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_p1_wins_fourth_hands(), 0)
	_play_out_p1_wins_fourth(game)
	_expect_eq(game.round_stake, 1, "stake stays 1 without knocks")
	_expect_eq(game.players[1].penalty_points, 0, "winner scores 0 without knocks")
	_expect_eq(game.players[0].penalty_points, 1, "loser scores +1 without knocks")


func _test_knock_raises_stake() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_p1_wins_fourth_hands(), 0)
	_expect(game.request_knock(0), "leader may knock before playing")
	_expect_eq(game.round_stake, 2, "knock raises stake from 1 to 2")
	_expect_eq(game.state, ToepenGame.State.KNOCK_DECISIONS, "knock enters decision state")


func _test_pass_pays_immediately() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_p1_wins_fourth_hands(), 0)
	game.request_knock(0)
	_expect(game.respond_to_knock(1, false), "p1 may pass")
	_expect_eq(game.players[1].penalty_points, 2, "passer pays current stake immediately")
	_expect(not game.players[1].is_active_in_round, "passer leaves the round")
	_expect_eq(game.players[0].penalty_points, 0, "knocker does not pay on someone else's pass")


func _test_mee_does_not_pay_yet() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_p1_wins_fourth_hands(), 0)
	game.request_knock(0)
	_all_mee(game)
	_expect_eq(game.state, ToepenGame.State.NORMAL_PLAY, "all mee returns to play")
	_expect_eq(game.players[1].penalty_points, 0, "mee does not pay immediately")
	_expect_eq(game.players[2].penalty_points, 0, "mee p2 does not pay immediately")
	_expect_eq(game.players[3].penalty_points, 0, "mee p3 does not pay immediately")
	_expect(game.players[1].is_active_in_round, "mee stays in the round")


func _test_second_knock_raises_stake() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_p1_wins_fourth_hands(), 0)
	game.request_knock(0)
	_all_mee(game)
	_expect(game.request_knock(0), "same player may knock again before playing")
	_expect_eq(game.round_stake, 3, "second knock raises stake to 3")


func _test_round_end_pays_final_stake() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_p1_wins_fourth_hands(), 0)
	game.request_knock(0)
	_all_mee(game)
	_play_out_p1_wins_fourth(game)
	_expect_eq(game.last_round_winner_id, 1, "p1 still wins the fourth trick")
	_expect_eq(game.players[1].penalty_points, 0, "winner pays 0 at final stake 2")
	_expect_eq(game.players[0].penalty_points, 2, "active non-winner pays final stake")
	_expect_eq(game.players[2].penalty_points, 2, "p2 pays final stake")
	_expect_eq(game.players[3].penalty_points, 2, "p3 pays final stake")


func _test_pass_can_eliminate() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_p1_wins_fourth_hands(), 0)
	game.apply_penalty(1, 13)
	game.request_knock(0)
	game.respond_to_knock(1, false)
	_expect(game.players[1].is_eliminated, "pass to 15 eliminates")
	_expect_eq(game.players[1].penalty_points, 15, "eliminated passer is at 15")


func _test_knock_rejected_off_turn() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_p1_wins_fourth_hands(), 0)
	_expect(not game.can_knock(2), "non-actor cannot knock")
	_expect(not game.request_knock(2), "knock off-turn is rejected")
	_expect_eq(game.round_stake, 1, "rejected knock does not raise stake")
	_expect_eq(game.state, ToepenGame.State.NORMAL_PLAY, "rejected knock stays in play")


func _test_all_pass_knocker_wins() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_p1_wins_fourth_hands(), 0)
	game.request_knock(0)
	game.respond_to_knock(1, false)
	game.respond_to_knock(2, false)
	game.respond_to_knock(3, false)
	_expect_eq(game.state, ToepenGame.State.ROUND_END, "round ends when only knocker remains")
	_expect_eq(game.last_round_winner_id, 0, "knocker wins if everyone else passes")
	_expect_eq(game.players[0].penalty_points, 0, "winning knocker gets 0")
	_expect_eq(game.players[1].penalty_points, 2, "p1 already paid on pass")
	_expect_eq(game.players[2].penalty_points, 2, "p2 already paid on pass")
	_expect_eq(game.players[3].penalty_points, 2, "p3 already paid on pass")


func _test_placeholder_ai_uses_own_legal_cards() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_p1_wins_fourth_hands(), 0)
	game.play_card(0, game.players[0].hand[0])
	var ai := PlaceholderAI.new()
	var chosen := ai.choose_card(game, 1)
	var legal := game.legal_cards(1)
	var found := false
	for card in legal:
		if card.equals(chosen):
			found = true
	_expect(chosen != null, "placeholder AI chooses a card")
	_expect(found, "placeholder AI chooses a legal card from its own hand")
	for other_id in [0, 2, 3]:
		for hidden in game.players[other_id].hand:
			_expect(not chosen.equals(hidden), "AI card is not taken from player %d" % other_id)


func _test_table_session_starts() -> void:
	var session := TableSession.new()
	session.start_new_pot()
	_expect_eq(session.game.players[0].hand.size(), 4, "playable session deals 4 cards")
	_expect_eq(session.game.state, ToepenGame.State.PRE_ROUND_SPECIALS, "session starts at specials")
	_expect_eq(session.game.current_specials_actor_id(), 0, "human handles specials first")
	_expect(session.waiting_for_human(), "session waits for the human to act")


func _test_round_score_presentation_event() -> void:
	var session := TableSession.new()
	session.game.setup_controlled_round(_p1_wins_fourth_hands(), 0)
	session._sync_round_score_baseline()
	_play_out_p1_wins_fourth(session.game)
	session._queue_round_score_event()
	var events := session.take_presentation_events()
	_expect_eq(events.size(), 1, "round end queues one score presentation")
	_expect_eq(str(events[0].get("type", "")), "round_score", "score presentation has the round-score type")
	_expect_eq(events[0].get("deltas", []), [1, 0, 1, 1], "score presentation shows each received penalty")
