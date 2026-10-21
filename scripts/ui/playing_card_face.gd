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
	var corner_size := clampi(int(size.x * 0.23), 13, 20)
	draw_string(font, face_rect.position + Vector2(7, 20), short_rank, HORIZONTAL_ALIGNMENT_LEFT, -1, corner_size, ink)
	_draw_suit_icon(face_rect.position + Vector2(14, 32), clampf(face_rect.size.x * 0.07, 4.0, 6.0), ink)
	if uses_picture_art():
		_draw_picture_art(face_rect, ink)
	else:
		_draw_pip_layout(face_rect, ink)
	draw_string(font, Vector2(face_rect.position.x + 5, face_rect.end.y - 7), short_rank, HORIZONTAL_ALIGNMENT_RIGHT, face_rect.size.x - 10, corner_size, ink)
	_draw_suit_icon(face_rect.end - Vector2(14, 25), clampf(face_rect.size.x * 0.065, 3.5, 5.5), ink)


func uses_picture_art() -> bool:
	return card != null and card.rank in [Card.Rank.JACK, Card.Rank.QUEEN, Card.Rank.KING]


func _draw_picture_art(face_rect: Rect2, ink: Color) -> void:
	var center := face_rect.get_center() + Vector2(0, 3)
	var art_width := minf(face_rect.size.x * 0.58, 42.0)
	var art_height := minf(face_rect.size.y * 0.54, 52.0)
	var art := Rect2(center - Vector2(art_width, art_height) * 0.5, Vector2(art_width, art_height))
	draw_rect(art, Color("ead7aa"))
	draw_rect(art.grow(-2), Color("4d6b8f"))
	draw_rect(art.grow(-4), Color("f2dfb7"))

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
	_draw_suit_icon(center + Vector2(0, art_height * 0.28), clampf(art_width * 0.13, 4.0, 6.0), ink)


func _draw_pip_layout(face_rect: Rect2, ink: Color) -> void:
	var center := face_rect.get_center() + Vector2(0, 2)
	if card.rank == Card.Rank.ACE:
		_draw_suit_icon(center, clampf(face_rect.size.x * 0.2, 9.0, 16.0), ink)
		return
	var normalized_positions: Array[Vector2] = []
	var left := 0.34
	var right := 0.66
	match card.rank:
		Card.Rank.SEVEN:
			normalized_positions = [Vector2(left, 0.27), Vector2(right, 0.27), Vector2(0.5, 0.38), Vector2(left, 0.5), Vector2(right, 0.5), Vector2(left, 0.73), Vector2(right, 0.73)]
		Card.Rank.EIGHT:
			normalized_positions = [Vector2(left, 0.25), Vector2(right, 0.25), Vector2(0.5, 0.37), Vector2(left, 0.5), Vector2(right, 0.5), Vector2(0.5, 0.63), Vector2(left, 0.75), Vector2(right, 0.75)]
		Card.Rank.NINE:
			normalized_positions = [Vector2(left, 0.23), Vector2(right, 0.23), Vector2(left, 0.41), Vector2(right, 0.41), Vector2(0.5, 0.5), Vector2(left, 0.59), Vector2(right, 0.59), Vector2(left, 0.77), Vector2(right, 0.77)]
		Card.Rank.TEN:
			normalized_positions = [Vector2(left, 0.21), Vector2(right, 0.21), Vector2(0.5, 0.32), Vector2(left, 0.41), Vector2(right, 0.41), Vector2(left, 0.59), Vector2(right, 0.59), Vector2(0.5, 0.68), Vector2(left, 0.79), Vector2(right, 0.79)]
	var pip_size := clampf(face_rect.size.x * 0.055, 3.2, 5.4)
	for point in normalized_positions:
		_draw_suit_icon(face_rect.position + Vector2(face_rect.size.x * point.x, face_rect.size.y * point.y), pip_size, ink)


func _draw_suit_icon(center: Vector2, radius: float, ink: Color) -> void:
	match card.suit:
		Card.Suit.HEARTS:
			draw_circle(center + Vector2(-radius * 0.38, -radius * 0.25), radius * 0.52, ink)
			draw_circle(center + Vector2(radius * 0.38, -radius * 0.25), radius * 0.52, ink)
			draw_colored_polygon(PackedVector2Array([
				center + Vector2(-radius * 0.83, -radius * 0.12),
				center + Vector2(radius * 0.83, -radius * 0.12),
				center + Vector2(0, radius),
			]), ink)
		Card.Suit.DIAMONDS:
			draw_colored_polygon(PackedVector2Array([
				center + Vector2(0, -radius), center + Vector2(radius * 0.72, 0),
				center + Vector2(0, radius), center + Vector2(-radius * 0.72, 0),
			]), ink)
		Card.Suit.CLUBS:
			draw_circle(center + Vector2(0, -radius * 0.42), radius * 0.5, ink)
			draw_circle(center + Vector2(-radius * 0.48, radius * 0.08), radius * 0.5, ink)
			draw_circle(center + Vector2(radius * 0.48, radius * 0.08), radius * 0.5, ink)
			draw_colored_polygon(PackedVector2Array([
				center + Vector2(-radius * 0.18, radius * 0.15), center + Vector2(radius * 0.18, radius * 0.15),
				center + Vector2(radius * 0.34, radius), center + Vector2(-radius * 0.34, radius),
			]), ink)
		Card.Suit.SPADES:
			draw_colored_polygon(PackedVector2Array([
				center + Vector2(0, -radius), center + Vector2(radius * 0.86, radius * 0.08),
				center + Vector2(radius * 0.35, radius * 0.35), center,
				center + Vector2(-radius * 0.35, radius * 0.35), center + Vector2(-radius * 0.86, radius * 0.08),
			]), ink)
			draw_colored_polygon(PackedVector2Array([
				center + Vector2(-radius * 0.16, radius * 0.15), center + Vector2(radius * 0.16, radius * 0.15),
				center + Vector2(radius * 0.34, radius), center + Vector2(-radius * 0.34, radius),
			]), ink)


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


func _is_red() -> bool:
	return card.suit == Card.Suit.HEARTS or card.suit == Card.Suit.DIAMONDS
