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
	if uses_picture_art():
		_draw_picture_art(face_rect, ink, font, suit, center_size)
	else:
		draw_string(font, Vector2(face_rect.position.x, face_rect.position.y + face_rect.size.y * 0.62), suit, HORIZONTAL_ALIGNMENT_CENTER, face_rect.size.x, center_size, ink)
	draw_string(font, Vector2(face_rect.position.x + 5, face_rect.end.y - 7), short_rank + suit, HORIZONTAL_ALIGNMENT_RIGHT, face_rect.size.x - 10, corner_size, ink)


func uses_picture_art() -> bool:
	return card != null and card.is_picture()


func _draw_picture_art(face_rect: Rect2, ink: Color, font: Font, suit: String, suit_size: int) -> void:
	var center := face_rect.get_center() + Vector2(0, 3)
	var art_width := minf(face_rect.size.x * 0.58, 42.0)
	var art_height := minf(face_rect.size.y * 0.54, 52.0)
	var art := Rect2(center - Vector2(art_width, art_height) * 0.5, Vector2(art_width, art_height))
	draw_rect(art, Color("ead7aa"))
	draw_rect(art.grow(-2), Color("4d6b8f"))
	draw_rect(art.grow(-4), Color("f2dfb7"))

	if card.rank == Card.Rank.ACE:
		var diamond := PackedVector2Array([
			center + Vector2(0, -art_height * 0.38),
			center + Vector2(art_width * 0.36, 0),
			center + Vector2(0, art_height * 0.38),
			center + Vector2(-art_width * 0.36, 0),
		])
		draw_colored_polygon(diamond, Color("fff0c9"))
		draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), ink, 2.0)
		draw_string(font, Vector2(art.position.x, center.y + suit_size * 0.32), suit, HORIZONTAL_ALIGNMENT_CENTER, art.size.x, suit_size, ink)
		return

	var skin := Color("d99a68")
	var coat := Color("b73555") if _is_red() else Color("345d91")
	var head_center := center + Vector2(0, -art_height * 0.13)
	draw_rect(Rect2(center.x - art_width * 0.30, center.y + art_height * 0.12, art_width * 0.60, art_height * 0.28), coat)
	draw_circle(head_center, maxf(5.0, art_width * 0.17), skin)
	draw_rect(Rect2(head_center + Vector2(-art_width * 0.16, -art_width * 0.18), Vector2(art_width * 0.32, 3)), Color("3b2823"))
	draw_rect(Rect2(head_center + Vector2(-art_width * 0.09, -1), Vector2(2, 2)), Color("18151b"))
	draw_rect(Rect2(head_center + Vector2(art_width * 0.06, -1), Vector2(2, 2)), Color("18151b"))

	match card.rank:
		Card.Rank.JACK:
			draw_rect(Rect2(head_center + Vector2(-art_width * 0.23, -art_width * 0.24), Vector2(art_width * 0.46, 4)), Color("4b8a78"))
			draw_rect(Rect2(head_center + Vector2(art_width * 0.1, -art_width * 0.18), Vector2(art_width * 0.18, 3)), Color("e6c95e"))
		Card.Rank.QUEEN:
			draw_colored_polygon(PackedVector2Array([
				head_center + Vector2(-art_width * 0.22, -art_width * 0.17),
				head_center + Vector2(-art_width * 0.14, -art_width * 0.35),
				head_center + Vector2(0, -art_width * 0.2),
				head_center + Vector2(art_width * 0.14, -art_width * 0.35),
				head_center + Vector2(art_width * 0.22, -art_width * 0.17),
			]), Color("e4bf4f"))
			draw_rect(Rect2(head_center + Vector2(-art_width * 0.24, 2), Vector2(4, art_width * 0.24)), Color("6b343e"))
			draw_rect(Rect2(head_center + Vector2(art_width * 0.15, 2), Vector2(4, art_width * 0.24)), Color("6b343e"))
		Card.Rank.KING:
			draw_colored_polygon(PackedVector2Array([
				head_center + Vector2(-art_width * 0.23, -art_width * 0.16),
				head_center + Vector2(-art_width * 0.18, -art_width * 0.36),
				head_center + Vector2(0, -art_width * 0.22),
				head_center + Vector2(art_width * 0.18, -art_width * 0.36),
				head_center + Vector2(art_width * 0.23, -art_width * 0.16),
			]), Color("e4bf4f"))
			draw_colored_polygon(PackedVector2Array([
				head_center + Vector2(-art_width * 0.16, art_width * 0.1),
				head_center + Vector2(0, art_width * 0.27),
				head_center + Vector2(art_width * 0.16, art_width * 0.1),
			]), Color("654037"))


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
