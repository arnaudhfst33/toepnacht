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
