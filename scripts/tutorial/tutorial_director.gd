class_name TutorialDirector
extends RefCounted

enum Kind { NONE, BLANCO, KLOPPEN, BLUFFEN, WAS, TOEP, ARMOEDE, WINKEL }

var kind: Kind = Kind.NONE
var cards_open: bool = false
var force_ai_knock: bool = false
var force_ai_knock_strong: bool = false
var force_ai_knock_bluff: bool = false
var bluff_phase: int = 1
var was_variant: String = ""
var title: String = ""
var intro: String = ""
var scripted_offerings: PackedStringArray = PackedStringArray()
var scripted_power_up: String = ""


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


func setup_bluffen(game: ToepenGame) -> void:
	kind = Kind.BLUFFEN
	cards_open = true
	bluff_phase = 1
	force_ai_knock = true
	force_ai_knock_strong = true
	force_ai_knock_bluff = false
	title = "Tutorial 3 — Bluffen"
	intro = "Een klop belooft niets. Eerst klopt iemand met een sterke hand, daarna met een zwakke. Jij kiest MEE of PAS."
	game.cards_open = true
	game.setup_controlled_round(_bluff_strong_hands(), 0)
	game.cards_open = true


func advance_bluffen(game: ToepenGame) -> void:
	if kind != Kind.BLUFFEN:
		return
	bluff_phase = 2
	force_ai_knock = true
	force_ai_knock_strong = false
	force_ai_knock_bluff = true
	intro = "Nu klopt iemand met een zwakke hand. Een klop is geen garantie."
	game.cards_open = true
	game.setup_controlled_round(_bluff_weak_hands(), 0)
	game.cards_open = true


func setup_was(game: ToepenGame, variant: String = "true") -> void:
	kind = Kind.WAS
	cards_open = true
	was_variant = variant
	title = "Tutorial 4 — Vuile Was / Witte Was"
	intro = "Vuile Was: 3 plaatjes + 7. Witte Was: 4 plaatjes. Anderen mogen betwisten. Echt: caller nieuwe hand, betwister +1. Bluf: caller +1. Onbetwist: nieuwe hand zonder straf."
	game.cards_open = true
	if variant == "witte":
		game.setup_controlled_specials(_witte_hands(), 0)
	elif variant == "bluff":
		game.setup_controlled_specials(_was_bluff_hands(), 0)
	else:
		game.setup_controlled_specials(_vuile_true_hands(), 0)
	game.cards_open = true


func setup_toep(game: ToepenGame, variant: String = "toep") -> void:
	kind = Kind.TOEP
	cards_open = true
	was_variant = variant
	title = "Tutorial 5 — Toep / Kans op Toep"
	if variant == "kans":
		intro = "Drie gelijke rangen = Kans op Toep. Wissel de afwijkende kaart. Geen bluf: je wisselt altijd de off-rank kaart."
		game.setup_controlled_specials(_kans_hands(), 0)
	else:
		intro = "Vier gelijke rangen = Toep. Andere spelers +3 strafpunten, daarna nieuwe ronde."
		game.setup_controlled_specials(_toep_hands(), 0)
	game.cards_open = true


func setup_armoede(game: ToepenGame) -> void:
	kind = Kind.ARMOEDE
	cards_open = true
	title = "Tutorial 6 — Armoede"
	intro = "14 strafpunten = Armoede (14/15). Bij 15 of meer val je af. Hoge straf maakt elke ronde riskant."
	game.cards_open = true
	game.setup_controlled_round(_blanco_hands(), 0)
	game.players[0].penalty_points = 14
	game.players[1].penalty_points = 12
	game.players[2].penalty_points = 10
	game.players[3].penalty_points = 8
	game.cards_open = true


func setup_winkel() -> void:
	kind = Kind.WINKEL
	cards_open = true
	title = "Tutorial 7 — De Avondwinkel"
	intro = "Bierdopjes koop je in De Avondwinkel: 3 aanbiedingen, max 2 power-ups, eenmalig gebruik. Hier is een scripted winkel en daarna gebruik je een power-up."
	scripted_offerings = PackedStringArray([PowerUpId.EVEN_SPIEKEN, PowerUpId.KAARTJE_RUILEN, PowerUpId.WASDAG])
	scripted_power_up = PowerUpId.EVEN_SPIEKEN


func setup_winkel_table(game: ToepenGame) -> void:
	setup_winkel()
	game.cards_open = true
	game.setup_controlled_round(_blanco_hands(), 0)
	game.cards_open = true


func tip_for(game: ToepenGame) -> String:
	match kind:
		Kind.BLANCO:
			return _tip_blanco(game)
		Kind.KLOPPEN:
			return _tip_kloppen(game)
		Kind.BLUFFEN:
			return _tip_bluffen(game)
		Kind.WAS:
			return _tip_was(game)
		Kind.TOEP:
			return _tip_toep(game)
		Kind.ARMOEDE:
			return _tip_armoede(game)
		Kind.WINKEL:
			return "Power-ups zijn eenmalig. Ongeldig activeren verbruikt niets. AI ziet nooit verborgen kaarten."
		_:
			return ""


func is_scripted_valid(game: ToepenGame) -> bool:
	if game.players.size() != 4:
		return false
	for player in game.players:
		if player.hand.size() != 4:
			return false
	if kind == Kind.WINKEL:
		return scripted_offerings.size() == 3 and scripted_power_up != ""
	if not game.cards_open:
		return false
	if kind == Kind.KLOPPEN and not force_ai_knock:
		return false
	if kind == Kind.BLUFFEN:
		if bluff_phase == 1:
			return force_ai_knock_strong and _hand_has_tens(game.players[1].hand, 2)
		return force_ai_knock_bluff and _hand_has_tens(game.players[1].hand, 0)
	if kind == Kind.WAS:
		var flags := HandDetector.analyze(game.players[0].hand)
		if was_variant == "witte":
			return flags.witte_was
		if was_variant == "true":
			return flags.vuile_was
		if was_variant == "bluff":
			return (not flags.vuile_was) and (not flags.witte_was)
	if kind == Kind.TOEP:
		var flags_t := HandDetector.analyze(game.players[0].hand)
		if was_variant == "kans":
			return flags_t.kans_op_toep and not flags_t.toep
		return flags_t.toep
	if kind == Kind.ARMOEDE:
		return game.players[0].penalty_points == 14 and game.player_is_armoede(0)
	if kind == Kind.BLANCO:
		return game.current_leader_id == 0
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


func _tip_bluffen(game: ToepenGame) -> String:
	if bluff_phase == 1:
		if game.state == ToepenGame.State.KNOCK_DECISIONS:
			return "Deze tegenstander heeft twee tienen — een sterke reden om te kloppen. MEE is veiliger, maar de inzet stijgt."
		return "Let op de open kaarten. Een klop met twee tienen is geloofwaardig."
	if game.state == ToepenGame.State.KNOCK_DECISIONS:
		return "Zwakke hand, toch een klop: dat is bluffen. PAS is veiliger als je zelf niks hebt; MEE is riskant."
	return "Een klop zegt niets over de echte hand. Je moet het risico zelf inschatten."


func _tip_was(game: ToepenGame) -> String:
	if game.state == ToepenGame.State.VUILE_WAS_CHALLENGE:
		return "Betwisten: als de claim echt is, krijgt de betwister +1 en de caller een nieuwe hand. Als het bluf is, krijgt de caller +1."
	if game.state == ToepenGame.State.PRE_ROUND_SPECIALS:
		return "Roep Vuile Was of Witte Was vóór de eerste kaart, of sla over. Kans op Toep mag je niet bluffen."
	return "Onbetwiste claim: nieuwe hand, geen straf. Bluf die niemand betwist, slaagt dus."


func _tip_toep(game: ToepenGame) -> String:
	if was_variant == "kans":
		return "Kans op Toep wisselt automatisch de afwijkende kaart. Lukt het vier gelijke: Toep. Lukt het niet: verder spelen."
	return "Toep: vier dezelfde rangen. Iedereen anders +3. Geen extra inzet-truc; het is een speciale hand."


func _tip_armoede(game: ToepenGame) -> String:
	if game.player_is_armoede(0):
		return "Jij staat op 14/15. Nog 1 strafpunt en je valt af. PAS of een verloren ronde kan fataal zijn."
	return "Armoede is alleen 14. 15 of meer is aflegging."


func _hand_has_tens(hand: Array[Card], n: int) -> bool:
	var c := 0
	for card in hand:
		if card.rank == Card.Rank.TEN:
			c += 1
	return c == n


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


func _bluff_strong_hands() -> Array:
	return [
		[
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.SEVEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.JACK),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.SPADES, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.QUEEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.KING),
			_c(Card.Suit.DIAMONDS, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.ACE),
			_c(Card.Suit.DIAMONDS, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.NINE),
		],
	]


func _bluff_weak_hands() -> Array:
	return [
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.TEN),
			_c(Card.Suit.SPADES, Card.Rank.NINE),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.JACK),
			_c(Card.Suit.SPADES, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.QUEEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.KING),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.DIAMONDS, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.ACE),
		],
	]


func _vuile_true_hands() -> Array:
	return [
		[
			_c(Card.Suit.HEARTS, Card.Rank.JACK),
			_c(Card.Suit.DIAMONDS, Card.Rank.QUEEN),
			_c(Card.Suit.CLUBS, Card.Rank.KING),
			_c(Card.Suit.SPADES, Card.Rank.SEVEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.SPADES, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.DIAMONDS, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.NINE),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
	]


func _was_bluff_hands() -> Array:
	return [
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.SEVEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.JACK),
			_c(Card.Suit.SPADES, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.QUEEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.KING),
			_c(Card.Suit.SPADES, Card.Rank.NINE),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.ACE),
			_c(Card.Suit.DIAMONDS, Card.Rank.KING),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
	]


func _witte_hands() -> Array:
	return [
		[
			_c(Card.Suit.HEARTS, Card.Rank.JACK),
			_c(Card.Suit.DIAMONDS, Card.Rank.QUEEN),
			_c(Card.Suit.CLUBS, Card.Rank.KING),
			_c(Card.Suit.SPADES, Card.Rank.ACE),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.SPADES, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.DIAMONDS, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.NINE),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
	]


func _toep_hands() -> Array:
	return [
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.TEN),
			_c(Card.Suit.SPADES, Card.Rank.TEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.QUEEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.QUEEN),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.JACK),
			_c(Card.Suit.DIAMONDS, Card.Rank.KING),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.SEVEN),
		],
	]


func _kans_hands() -> Array:
	return [
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.TEN),
			_c(Card.Suit.CLUBS, Card.Rank.TEN),
			_c(Card.Suit.SPADES, Card.Rank.JACK),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.DIAMONDS, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.QUEEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.QUEEN),
			_c(Card.Suit.CLUBS, Card.Rank.SEVEN),
			_c(Card.Suit.SPADES, Card.Rank.EIGHT),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.ACE),
			_c(Card.Suit.DIAMONDS, Card.Rank.KING),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.SEVEN),
		],
	]


func _c(suit: Card.Suit, rank: Card.Rank) -> Card:
	return Card.new(suit, rank)
