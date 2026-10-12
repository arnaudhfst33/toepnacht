class_name Card
extends RefCounted

## 32-card Toepen deck: 4 suits × 8 ranks.
## Rank order low → high matches GDD: Boer, Vrouw, Heer, Aas, 7, 8, 9, 10.

enum Suit { HEARTS, DIAMONDS, CLUBS, SPADES }
enum Rank { JACK, QUEEN, KING, ACE, SEVEN, EIGHT, NINE, TEN }

var suit: Suit
var rank: Rank


func _init(p_suit: Suit = Suit.HEARTS, p_rank: Rank = Rank.JACK) -> void:
	suit = p_suit
	rank = p_rank


func equals(other: Card) -> bool:
	return other != null and suit == other.suit and rank == other.rank


func strength() -> int:
	return int(rank)


func is_picture() -> bool:
	return rank == Rank.JACK or rank == Rank.QUEEN or rank == Rank.KING or rank == Rank.ACE


func is_seven() -> bool:
	return rank == Rank.SEVEN


func key() -> String:
	return "%d_%d" % [int(suit), int(rank)]


func rank_name() -> String:
	match rank:
		Rank.JACK:
			return "Boer"
		Rank.QUEEN:
			return "Vrouw"
		Rank.KING:
			return "Heer"
		Rank.ACE:
			return "Aas"
		Rank.SEVEN:
			return "7"
		Rank.EIGHT:
			return "8"
		Rank.NINE:
			return "9"
		Rank.TEN:
			return "10"
		_:
			return "?"


func suit_name() -> String:
	match suit:
		Suit.HEARTS:
			return "Harten"
		Suit.DIAMONDS:
			return "Ruiten"
		Suit.CLUBS:
			return "Klaveren"
		Suit.SPADES:
			return "Schoppen"
		_:
			return "?"


func _to_string() -> String:
	return "%s %s" % [rank_name(), suit_name()]
