class_name SpecialTests
extends RefCounted

var _failures: int = 0
var _passed: int = 0


func run_all() -> int:
	_failures = 0
	_passed = 0
	_test_toep_resolution()
	_test_kans_success()
	_test_kans_failure()
	_test_vuile_was_true()
	_test_vuile_was_bluff()
	_test_vuile_was_unchallenged()
	_test_witte_was_true()
	_test_witte_was_bluff()
	_test_witte_was_unchallenged()
	_test_kans_discard_stays_out()
	_test_new_round_rebuilds_full_deck()
	_test_armoede_announcement()
	_test_first_game_lead()
	_test_previous_winner_lead()
	_test_pas_only_on_knock()
	_test_pas_blocked_after_play()
	_test_ai_must_mee_after_playing()
	_test_ai_legal_cards()
	_test_ai_view_hides_hidden_cards()
	_test_tutorial_blanco_state()
	_test_tutorial_kloppen_state()
	print("")
	print("Special tests: %d passed, %d failed" % [_passed, _failures])
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


func _junk_hand() -> Array:
	return [
		_c(Card.Suit.HEARTS, Card.Rank.JACK),
		_c(Card.Suit.DIAMONDS, Card.Rank.QUEEN),
		_c(Card.Suit.CLUBS, Card.Rank.KING),
		_c(Card.Suit.SPADES, Card.Rank.EIGHT),
	]


func _test_toep_resolution() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_specials([
		[
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.DIAMONDS, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.NINE),
		],
		_junk_hand(),
		[
			_c(Card.Suit.HEARTS, Card.Rank.SEVEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.QUEEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.KING),
		],
	], 0)
	_expect(game.can_declare_toep(0), "toep can be declared")
	_expect(game.declare_toep(0), "toep declaration succeeds")
	_expect_eq(game.last_toep_declarer_id, 0, "toep declarer recorded")
	_expect_eq(game.players[1].penalty_points, 3, "other player +3 for toep")
	_expect_eq(game.players[2].penalty_points, 3, "p2 +3 for toep")
	_expect_eq(game.players[3].penalty_points, 3, "p3 +3 for toep")
	_expect_eq(game.players[0].penalty_points, 0, "declarer gets 0")
	_expect_eq(game.state, ToepenGame.State.PRE_ROUND_SPECIALS, "toep starts a new round")
	_expect_eq(game.players[0].hand.size(), 4, "new round is dealt after toep")


func _test_kans_success() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_specials([
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.TEN),
			_c(Card.Suit.SPADES, Card.Rank.JACK),
		],
		_junk_hand(),
		[
			_c(Card.Suit.HEARTS, Card.Rank.SEVEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.QUEEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.KING),
		],
	], 0)
	game.deck.cards = [_c(Card.Suit.SPADES, Card.Rank.TEN)]
	_expect(game.use_kans(0), "kans exchange runs")
	_expect(game.last_kans_completed_toep, "kans completed toep")
	_expect_eq(game.players[1].penalty_points, 3, "kans-toep penalizes others")


func _test_kans_failure() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_specials([
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.TEN),
			_c(Card.Suit.SPADES, Card.Rank.JACK),
		],
		_junk_hand(),
		[
			_c(Card.Suit.HEARTS, Card.Rank.SEVEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.QUEEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.KING),
		],
	], 0)
	game.deck.cards = [_c(Card.Suit.SPADES, Card.Rank.SEVEN)]
	_expect(game.use_kans(0), "kans exchange still runs")
	_expect(not game.last_kans_completed_toep, "kans did not complete toep")
	_expect_eq(game.players[0].hand.size(), 4, "hand still has 4 cards")
	_expect(not game.detect_player_specials(0).toep, "hand is not toep")
	_expect_eq(game.players[1].penalty_points, 0, "no toep penalty on failed kans")


func _test_vuile_was_true() -> void:
	var game := ToepenGame.new()
	var old_hand: Array[Card] = [
		_c(Card.Suit.HEARTS, Card.Rank.JACK),
		_c(Card.Suit.HEARTS, Card.Rank.QUEEN),
		_c(Card.Suit.HEARTS, Card.Rank.KING),
		_c(Card.Suit.HEARTS, Card.Rank.SEVEN),
	]
	game.setup_controlled_specials([
		old_hand,
		_junk_hand(),
		[
			_c(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.SEVEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.NINE),
		],
	], 0)
	_expect(game.detect_player_specials(0).vuile_was, "hand is vuile was")
	_expect(game.call_vuile_was(0), "vuile was can be called")
	_expect(game.challenge_vuile_was(1), "p1 challenges")
	_expect(not game.last_vuile_was_bluff, "true claim is not a bluff")
	_expect_eq(game.players[1].penalty_points, 1, "challenger +1")
	_expect_eq(game.players[0].penalty_points, 0, "true caller not penalized")
	_expect_eq(game.players[0].hand.size(), 4, "caller received a new hand")
	var same := true
	for i in 4:
		if not game.players[0].hand[i].equals(old_hand[i]):
			same = false
	_expect(not same, "true vuile was replaced the hand")


func _test_vuile_was_bluff() -> void:
	var game := ToepenGame.new()
	var old_hand := _junk_hand()
	game.setup_controlled_specials([
		old_hand,
		[
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.DIAMONDS, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.QUEEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.SEVEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.KING),
		],
	], 0)
	_expect(not game.detect_player_specials(0).vuile_was, "caller is bluffing")
	game.call_vuile_was(0)
	game.challenge_vuile_was(1)
	_expect(game.last_vuile_was_bluff, "bluff recorded")
	_expect_eq(game.players[0].penalty_points, 1, "bluffing caller +1")
	_expect_eq(game.players[1].penalty_points, 0, "challenger of bluff not penalized")
	_expect(game.players[0].has_card(old_hand[0]), "bluffer keeps the hand")


func _test_vuile_was_unchallenged() -> void:
	var game := ToepenGame.new()
	var old_hand := _junk_hand()
	game.setup_controlled_specials([
		old_hand,
		[
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.DIAMONDS, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.QUEEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.SEVEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.KING),
		],
	], 0)
	game.call_vuile_was(0)
	game.decline_vuile_was_challenge(1)
	game.decline_vuile_was_challenge(2)
	game.decline_vuile_was_challenge(3)
	_expect_eq(game.players[0].penalty_points, 0, "unchallenged caller is not penalized")
	_expect_eq(game.players[0].hand.size(), 4, "unchallenged caller gets a fresh hand")
	_expect(not game.players[0].has_card(old_hand[0]), "unchallenged believed claim replaces the hand")


func _test_witte_was_true() -> void:
	var game := ToepenGame.new()
	var old_hand: Array[Card] = [
		_c(Card.Suit.HEARTS, Card.Rank.JACK),
		_c(Card.Suit.DIAMONDS, Card.Rank.QUEEN),
		_c(Card.Suit.CLUBS, Card.Rank.KING),
		_c(Card.Suit.SPADES, Card.Rank.ACE),
	]
	game.setup_controlled_specials([
		old_hand,
		_junk_hand(),
		[
			_c(Card.Suit.HEARTS, Card.Rank.SEVEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.NINE),
		],
	], 0)
	_expect(game.detect_player_specials(0).witte_was, "4 pictures is witte was")
	_expect(game.declare_witte_was(0), "witte was can be called")
	_expect_eq(game.state, ToepenGame.State.VUILE_WAS_CHALLENGE, "witte was uses the challenge flow")
	_expect(game.challenge_vuile_was(1), "witte was can be challenged")
	_expect(not game.last_witte_was_bluff, "true witte was is not a bluff")
	_expect_eq(game.players[1].penalty_points, 1, "witte was challenger +1")
	_expect_eq(game.players[0].penalty_points, 0, "true witte was caller not penalized")
	_expect_eq(game.players[0].hand.size(), 4, "true witte was caller gets a new hand")
	_expect(not game.players[0].has_card(old_hand[0]), "true witte was replaced the hand")


func _test_witte_was_bluff() -> void:
	var game := ToepenGame.new()
	var old_hand := _junk_hand()
	game.setup_controlled_specials([
		old_hand,
		[
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.DIAMONDS, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.QUEEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.SEVEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.KING),
		],
	], 0)
	_expect(not game.detect_player_specials(0).witte_was, "caller does not have witte was")
	game.declare_witte_was(0)
	game.challenge_vuile_was(1)
	_expect(game.last_witte_was_bluff, "witte was bluff recorded")
	_expect_eq(game.players[0].penalty_points, 1, "witte was bluff caller +1")
	_expect(game.players[0].has_card(old_hand[0]), "witte was bluffer keeps the hand")


func _test_witte_was_unchallenged() -> void:
	var game := ToepenGame.new()
	var old_hand: Array[Card] = [
		_c(Card.Suit.HEARTS, Card.Rank.JACK),
		_c(Card.Suit.DIAMONDS, Card.Rank.QUEEN),
		_c(Card.Suit.CLUBS, Card.Rank.KING),
		_c(Card.Suit.SPADES, Card.Rank.ACE),
	]
	game.setup_controlled_specials([
		old_hand,
		_junk_hand(),
		[
			_c(Card.Suit.HEARTS, Card.Rank.SEVEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.NINE),
		],
	], 0)
	game.declare_witte_was(0)
	game.decline_vuile_was_challenge(1)
	game.decline_vuile_was_challenge(2)
	game.decline_vuile_was_challenge(3)
	_expect_eq(game.players[0].penalty_points, 0, "unchallenged witte was has no penalty")
	_expect(not game.players[0].has_card(old_hand[0]), "unchallenged witte was gets a fresh hand")


func _test_kans_discard_stays_out() -> void:
	var game := ToepenGame.new()
	var off := _c(Card.Suit.SPADES, Card.Rank.JACK)
	game.setup_controlled_specials([
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.TEN),
			off,
		],
		_junk_hand(),
		[
			_c(Card.Suit.HEARTS, Card.Rank.SEVEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.QUEEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.KING),
		],
	], 0)
	game.deck.cards = [_c(Card.Suit.SPADES, Card.Rank.SEVEN)]
	game.use_kans(0)
	var back_in_stock := false
	for card in game.deck.cards:
		if card.equals(off):
			back_in_stock = true
	_expect(not back_in_stock, "kans discard does not return to the stock")
	_expect(not game.players[0].has_card(off), "off-rank card left the hand")


func _test_new_round_rebuilds_full_deck() -> void:
	var game := ToepenGame.new()
	game.start_pot()
	_expect_eq(game.deck.remaining(), 16, "16 cards remain after the first deal")
	game.start_round()
	var seen := {}
	for player in game.players:
		for card in player.hand:
			seen[card.key()] = true
	for card in game.deck.cards:
		seen[card.key()] = true
	_expect_eq(seen.size(), 32, "a new round rebuilds the full 32-card deck")
	_expect_eq(game.deck.remaining(), 16, "new round deals 16 and leaves 16")


func _test_armoede_announcement() -> void:
	var game := ToepenGame.new()
	game.apply_penalty(2, 14)
	_expect(game.player_is_armoede(2), "14 is armoede")
	_expect(game.armoede_player_ids().has(2), "armoede id listed")
	_expect(game.last_event.contains("Armoede"), "armoede is announced")
	game.apply_penalty(2, 1)
	_expect(not game.player_is_armoede(2), "15 is eliminated, not armoede")


func _test_first_game_lead() -> void:
	var game := ToepenGame.new()
	game.start_pot()
	_expect_eq(game.current_leader_id, 0, "human leads the first real game")


func _test_previous_winner_lead() -> void:
	var game := ToepenGame.new()
	game.start_pot()
	game.last_round_winner_id = 3
	game.start_round()
	_expect_eq(game.current_leader_id, 3, "previous round winner leads next")


func _test_pas_only_on_knock() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_four_play_hands(), 0)
	_expect(not game.can_pass(0), "pas is illegal outside a knock")
	_expect(not game.respond_to_knock(1, false), "pas rejected when no knock")


func _test_pas_blocked_after_play() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_four_play_hands(), 0)
	game.play_card(0, game.players[0].hand[0])
	_expect(game.request_knock(1), "p1 may knock after p0 played")
	_expect(not game.can_pass(0), "p0 cannot pas after already playing this trick")
	_expect(not game.respond_to_knock(0, false), "pas after playing is rejected")
	_expect(game.respond_to_knock(0, true), "p0 may still mee")


func _test_ai_must_mee_after_playing() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_four_play_hands(), 0)
	game.play_card(0, game.players[0].hand[0])
	game.play_card(1, game.players[1].hand[0])
	_expect(game.request_knock(2), "AI may knock after earlier players have played")
	game.respond_to_knock(3, true)
	game.respond_to_knock(0, true)
	var view := PublicView.from_game(game, 1)
	_expect(view.must_respond_to_knock, "public view marks current knock responder")
	_expect(not view.can_pass, "responder that already played cannot pass")
	var ai := BaselineAI.new()
	var action := ai.decide(view, game.rng)
	_expect_eq(str(action.get("type", "")), "mee", "AI chooses mandatory mee instead of an illegal card play")
	var session := TableSession.new()
	session.game = game
	session._apply_ai(1)
	_expect_eq(game.state, ToepenGame.State.NORMAL_PLAY, "mandatory AI mee resumes normal play")
	_expect_eq(game.current_actor_id, 2, "the knocker can play after all responses")


func _test_ai_legal_cards() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var ai := BaselineAI.new()
	for _i in 12:
		var game := ToepenGame.new(rng)
		game.start_pot()
		game.begin_play()
		var view := PublicView.from_game(game, 1)
		if view.legal_cards.is_empty():
			continue
		var card := ai.choose_card(game, 1)
		var legal := false
		for option in game.legal_cards(1):
			if option.equals(card):
				legal = true
		_expect(legal, "baseline AI plays a legal card")
		break


func _test_ai_view_hides_hidden_cards() -> void:
	var game := ToepenGame.new()
	game.start_pot()
	game.begin_play()
	var view := PublicView.from_game(game, 1)
	for other_id in [0, 2, 3]:
		for hidden in game.players[other_id].hand:
			var leaked := false
			for own in view.own_hand:
				if own.equals(hidden):
					leaked = true
			for legal in view.legal_cards:
				if legal.equals(hidden):
					leaked = true
			_expect(not leaked, "AI view does not contain hidden card of player %d" % other_id)


func _test_tutorial_blanco_state() -> void:
	var game := ToepenGame.new()
	var director := TutorialDirector.new()
	director.setup_blanco(game)
	_expect(director.is_scripted_valid(game), "blanco tutorial scripted state is valid")
	_expect(game.cards_open, "blanco tutorial has open cards")
	_expect_eq(game.current_leader_id, 0, "blanco tutorial human leads")
	_expect(director.tip_for(game) != "", "blanco tutorial has a why-tip")


func _test_tutorial_kloppen_state() -> void:
	var game := ToepenGame.new()
	var director := TutorialDirector.new()
	director.setup_kloppen(game)
	_expect(director.is_scripted_valid(game), "kloppen tutorial scripted state is valid")
	_expect(director.force_ai_knock, "kloppen tutorial has a scripted knock")
	_expect(game.cards_open, "kloppen tutorial has open cards")
	_expect(game.can_knock(0), "human can klop in tutorial 2")


func _four_play_hands() -> Array:
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
