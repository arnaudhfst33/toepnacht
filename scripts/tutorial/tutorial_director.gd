class_name TutorialDirector
extends RefCounted

enum Kind { NONE, BLANCO, KLOPPEN }

var kind: Kind = Kind.NONE
var cards_open: bool = false
var force_ai_knock: bool = false
var title: String = ""
var intro: String = ""


func setup_blanco(game: ToepenGame) -> void:
	kind = Kind.BLANCO
	cards_open = true
	force_ai_knock = false
	title = "Tutorial 1 — Blanco Toepen"
	intro = "Kaartvolgorde laag → hoog: Boer, Vrouw, Heer, Aas, 7, 8, 9, 10. Je speelt zelf; tips zeggen waarom."
	game.cards_open = true
	game.setup_controlled_round(_blanco_hands(), 0)
	game.cards_open = true


func setup_kloppen(game: ToepenGame) -> void:
	kind = Kind.KLOPPEN
	cards_open = true
	force_ai_knock = true
	title = "Tutorial 2 — Kloppen"
	intro = "KLOP verhoogt de inzet. Anderen kiezen MEE of PAS. PAS mag alleen als antwoord op een klop."
	game.cards_open = true
	game.setup_controlled_round(_kloppen_hands(), 0)
	game.cards_open = true


func tip_for(game: ToepenGame) -> String:
	if kind == Kind.BLANCO:
		return _tip_blanco(game)
	if kind == Kind.KLOPPEN:
		return _tip_kloppen(game)
	return ""


func is_scripted_valid(game: ToepenGame) -> bool:
	if game.players.size() != 4:
		return false
	for player in game.players:
		if player.hand.size() != 4:
			return false
	if game.current_leader_id != 0:
		return false
	if not game.cards_open:
		return false
	if kind == Kind.KLOPPEN and not force_ai_knock:
		return false
	return true


func _tip_blanco(game: ToepenGame) -> String:
	if game.state == ToepenGame.State.ROUND_END:
		return "De vierde slag bepaalt de ronde. De winnaar krijgt 0 strafpunten; wie nog inzat krijgt de inzet (hier 1)."
	if game.tricks_completed == 0 and game.current_trick.play_count() == 0:
		return "Kleur bekennen is verplicht als je de gevraagde kleur hebt. Ongeldige kaarten kun je niet spelen."
	if game.tricks_completed == 0 and game.current_trick.play_count() > 0:
		return "De hoogste kaart van de gevraagde kleur wint de slag. Daarna komt die speler uit."
	if game.tricks_completed == 3:
		return "Dit is de laatste slag. Wie deze wint, wint de ronde — niet wie de eerdere slagen won."
	return "Speel een geldige kaart. Denk na of je de laatste slag wilt kunnen winnen."


func _tip_kloppen(game: ToepenGame) -> String:
	if game.state == ToepenGame.State.KNOCK_DECISIONS:
		if game.can_pass(0):
			return "MEE: je blijft in voor inzet %d. PAS: je krijgt nu %d strafpunt(en) en stapt uit deze ronde." % [game.round_stake, game.round_stake]
		return "Je hebt in deze slag al gespeeld, dus PAS mag niet meer. Alleen MEE."
	if game.can_knock(0):
		return "KLOP voor je speelt. Elke klop verhoogt de inzet met +1. De tegenstander kan daarna ook kloppen."
	if game.state == ToepenGame.State.ROUND_END:
		return "Actieve verliezers betalen de uiteindelijke inzet. Wie paste, betaalde al bij PAS."
	return "Na een klop speel je door met wie MEE ging. De inzet blijft verhoogd."


func _blanco_hands() -> Array:
	return [
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.SEVEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.HEARTS, Card.Rank.JACK),
			_c(Card.Suit.CLUBS, Card.Rank.TEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.QUEEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.NINE),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.KING),
			_c(Card.Suit.DIAMONDS, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
	]


func _kloppen_hands() -> Array:
	return [
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.SPADES, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.JACK),
			_c(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.TEN),
			_c(Card.Suit.SPADES, Card.Rank.QUEEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.QUEEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.KING),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.NINE),
		],
	]


func _c(suit: Card.Suit, rank: Card.Rank) -> Card:
	return Card.new(suit, rank)
