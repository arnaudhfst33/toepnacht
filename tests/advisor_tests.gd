class_name AdvisorTests
extends RefCounted

var _failures: int = 0
var _passed: int = 0


func run_all() -> int:
	_failures = 0
	_passed = 0
	_test_hand_strength_is_explainable()
	_test_card_tooltip_explains_legality()
	_test_final_trick_advice()
	_test_studentenhuis_cast()
	print("")
	print("Advisor tests: %d passed, %d failed" % [_passed, _failures])
	return _failures


func _expect(condition: bool, name: String) -> void:
	if condition:
		_passed += 1
		print("PASS  %s" % name)
	else:
		_failures += 1
		print("FAIL  %s" % name)


func _test_hand_strength_is_explainable() -> void:
	var weak: Array[Card] = [
		_c(Card.Suit.HEARTS, Card.Rank.JACK),
		_c(Card.Suit.DIAMONDS, Card.Rank.QUEEN),
		_c(Card.Suit.CLUBS, Card.Rank.KING),
		_c(Card.Suit.SPADES, Card.Rank.ACE),
	]
	var strong: Array[Card] = [
		_c(Card.Suit.HEARTS, Card.Rank.TEN),
		_c(Card.Suit.DIAMONDS, Card.Rank.TEN),
		_c(Card.Suit.CLUBS, Card.Rank.NINE),
		_c(Card.Suit.SPADES, Card.Rank.NINE),
	]
	_expect(CardAdvisor.hand_score(strong) > CardAdvisor.hand_score(weak), "high cards score higher")
	_expect(CardAdvisor.hand_summary(strong).contains("/100"), "hand summary shows a bounded score")


func _test_card_tooltip_explains_legality() -> void:
	var ten := _c(Card.Suit.HEARTS, Card.Rank.TEN)
	_expect(CardAdvisor.card_tooltip(ten, true).contains("hoogste"), "ten is explained as highest")
	_expect(
		CardAdvisor.card_tooltip(ten, false).contains("kleur bekennen"),
		"illegal card explains follow suit"
	)


func _test_final_trick_advice() -> void:
	var game := ToepenGame.new()
	game.setup_controlled_round(_hands(), 0)
	game.tricks_completed = 3
	game.current_trick.add_play(1, _c(Card.Suit.HEARTS, Card.Rank.EIGHT))
	game.current_actor_id = 0
	var tip := CardAdvisor.turn_tip(game)
	_expect(tip.contains("Laatste slag"), "advisor names the decisive fourth trick")
	_expect(tip.contains("Harten"), "advisor names a concrete legal card")


func _test_studentenhuis_cast() -> void:
	var names := [
		AiProfile.for_location(LocationId.STUDENTENHUIS, 1, 1).display_name,
		AiProfile.for_location(LocationId.STUDENTENHUIS, 1, 2).display_name,
		AiProfile.for_location(LocationId.STUDENTENHUIS, 1, 3).display_name,
	]
	_expect(names == ["Feut", "Sjaars", "Huisoudste"], "first table uses the agreed student cast")


func _hands() -> Array:
	return [
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.HEARTS, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.JACK),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.JACK),
			_c(Card.Suit.CLUBS, Card.Rank.JACK),
			_c(Card.Suit.SPADES, Card.Rank.QUEEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.QUEEN),
			_c(Card.Suit.SPADES, Card.Rank.KING),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.KING),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
	]


func _c(suit: Card.Suit, rank: Card.Rank) -> Card:
	return Card.new(suit, rank)

