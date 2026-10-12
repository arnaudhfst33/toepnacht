class_name Deck
extends RefCounted

const SUIT_COUNT := 4
const RANK_COUNT := 8
const SIZE := 32

var cards: Array[Card] = []


static func standard() -> Deck:
	var deck := Deck.new()
	deck.reset_standard()
	return deck


func reset_standard() -> void:
	cards.clear()
	for suit_i in SUIT_COUNT:
		for rank_i in RANK_COUNT:
			cards.append(Card.new(suit_i as Card.Suit, rank_i as Card.Rank))


func shuffle(rng: RandomNumberGenerator) -> void:
	for i in range(cards.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: Card = cards[i]
		cards[i] = cards[j]
		cards[j] = tmp


func draw() -> Card:
	assert(cards.size() > 0, "Cannot draw from an empty deck.")
	return cards.pop_back()


func remaining() -> int:
	return cards.size()


func return_to_stock_deterministic(card: Card) -> void:
	if card == null:
		return
	cards.insert(0, card)


func snapshot_keys() -> PackedStringArray:
	var keys := PackedStringArray()
	for card in cards:
		keys.append(card.key())
	return keys
