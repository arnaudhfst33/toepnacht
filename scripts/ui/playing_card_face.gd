class_name PlayingCardFace
extends Control

## Drawn card face used by the hand and play animations. It stays readable on
## small phone screens without depending on external card artwork.

var card: Card = null
var recommended: bool = false
var _pulse: float = 0.0


func configure(p_card: Card, p_recommended: bool = false) -> void:
	card = p_card
	recommended = p_recommended
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(recommended)
	queue_redraw()


func _process(delta: float) -> void:
	_pulse += delta
	queue_redraw()


func _draw() -> void:
	if card == null or size.x < 20.0 or size.y < 30.0:
		return
	var shadow_rect := Rect2(6, 7, size.x - 10, size.y - 11)
	draw_rect(shadow_rect, Color("16131dcc"))
	var face_rect := Rect2(3, 2, size.x - 10, size.y - 11)
	var border := Color("efc65a") if recommended else Color("2a2430")
	var face := StyleBoxFlat.new()
	face.bg_color = Color("f8efd8")
	face.border_color = border
	face.set_border_width_all(3 if recommended else 2)
	face.corner_radius_top_left = 6
	face.corner_radius_top_right = 6
	face.corner_radius_bottom_left = 6
	face.corner_radius_bottom_right = 6
	draw_style_box(face, face_rect)

	# Offset cyan/magenta pixels give a restrained retro print effect.
	draw_rect(Rect2(face_rect.position + Vector2(3, 3), Vector2(2, face_rect.size.y - 6)), Color("43c5c455"))
	draw_rect(Rect2(face_rect.end - Vector2(5, face_rect.size.y - 3), Vector2(2, face_rect.size.y - 6)), Color("df557055"))
	if recommended:
		var glow := 0.12 + sin(_pulse * 3.2) * 0.05
		draw_colored_polygon(PackedVector2Array([
			face_rect.position + Vector2(face_rect.size.x * 0.2, 2),
			face_rect.position + Vector2(face_rect.size.x * 0.42, 2),
			face_rect.position + Vector2(face_rect.size.x * 0.8, face_rect.size.y - 2),
			face_rect.position + Vector2(face_rect.size.x * 0.58, face_rect.size.y - 2),
		]), Color(1.0, 0.88, 0.4, glow))

	var ink := Color("a92f42") if _is_red() else Color("1a1921")
	var font := get_theme_default_font()
	var short_rank := _short_rank()
	var suit := _suit_symbol()
	var corner_size := clampi(int(size.x * 0.23), 13, 20)
	var center_size := clampi(int(size.x * 0.5), 25, 40)
	draw_string(font, face_rect.position + Vector2(7, 20), short_rank, HORIZONTAL_ALIGNMENT_LEFT, -1, corner_size, ink)
	draw_string(font, face_rect.position + Vector2(8, 38), suit, HORIZONTAL_ALIGNMENT_LEFT, -1, corner_size, ink)
	draw_string(font, Vector2(face_rect.position.x, face_rect.position.y + face_rect.size.y * 0.62), suit, HORIZONTAL_ALIGNMENT_CENTER, face_rect.size.x, center_size, ink)
	draw_string(font, Vector2(face_rect.position.x + 5, face_rect.end.y - 7), short_rank + suit, HORIZONTAL_ALIGNMENT_RIGHT, face_rect.size.x - 10, corner_size, ink)


func _short_rank() -> String:
	match card.rank:
		Card.Rank.JACK:
			return "B"
		Card.Rank.QUEEN:
			return "V"
		Card.Rank.KING:
			return "H"
		Card.Rank.ACE:
			return "A"
		Card.Rank.SEVEN:
			return "7"
		Card.Rank.EIGHT:
			return "8"
		Card.Rank.NINE:
			return "9"
		Card.Rank.TEN:
			return "10"
		_:
			return "?"


func _suit_symbol() -> String:
	match card.suit:
		Card.Suit.HEARTS:
			return "♥"
		Card.Suit.DIAMONDS:
			return "♦"
		Card.Suit.CLUBS:
			return "♣"
		Card.Suit.SPADES:
			return "♠"
		_:
			return "?"


func _is_red() -> bool:
	return card.suit == Card.Suit.HEARTS or card.suit == Card.Suit.DIAMONDS
