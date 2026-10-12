class_name Player
extends RefCounted

var id: int = 0
var is_human: bool = false
var hand: Array[Card] = []
var penalty_points: int = 0
var is_active_in_round: bool = true
var is_eliminated: bool = false


func has_card(card: Card) -> bool:
	return find_card_index(card) >= 0


func find_card_index(card: Card) -> int:
	for i in hand.size():
		if hand[i].equals(card):
			return i
	return -1


func take_card(card: Card) -> Card:
	var idx := find_card_index(card)
	if idx < 0:
		return null
	var taken: Card = hand[idx]
	hand.remove_at(idx)
	return taken


func has_suit(suit: Card.Suit) -> bool:
	for card in hand:
		if card.suit == suit:
			return true
	return false


func reset_for_new_pot() -> void:
	hand.clear()
	penalty_points = 0
	is_active_in_round = true
	is_eliminated = false
