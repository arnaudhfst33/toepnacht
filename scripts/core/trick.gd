class_name Trick
extends RefCounted

var led_suit: Card.Suit = Card.Suit.HEARTS
var has_led_suit: bool = false
var player_ids: Array[int] = []
var cards: Array[Card] = []


func add_play(player_id: int, card: Card) -> void:
	if not has_led_suit:
		led_suit = card.suit
		has_led_suit = true
	player_ids.append(player_id)
	cards.append(card)


func play_count() -> int:
	return cards.size()


func is_complete(expected_plays: int) -> bool:
	return cards.size() == expected_plays


func winner_id() -> int:
	return winner_id_among([])


func winner_id_among(eligible_ids: Array[int]) -> int:
	assert(has_led_suit and cards.size() > 0, "Cannot resolve an empty trick.")
	var best_index := -1
	var best_strength := -1
	for i in cards.size():
		if eligible_ids.size() > 0 and not eligible_ids.has(player_ids[i]):
			continue
		var card: Card = cards[i]
		if card.suit != led_suit:
			continue
		if card.strength() > best_strength:
			best_strength = card.strength()
			best_index = i
	if best_index < 0:
		if eligible_ids.size() > 0:
			return winner_id_among([])
		return player_ids[0]
	return player_ids[best_index]


func has_play_from(player_id: int) -> bool:
	return player_ids.has(player_id)
