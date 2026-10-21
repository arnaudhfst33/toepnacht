class_name CardBackFan
extends Control

## Compact row of face-down cards that makes an opponent's hand size visible.

var card_count: int = 0


func configure(p_card_count: int) -> void:
	card_count = clampi(p_card_count, 0, ToepenGame.TRICKS_PER_ROUND)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	if card_count <= 0:
		return
	var card_size := Vector2(13, 19)
	var gap := 7.0
	var row_width := card_size.x + gap * float(card_count - 1)
	var start_x := (size.x - row_width) * 0.5
	for index in card_count:
		var pos := Vector2(start_x + gap * index, 1.0 + absf(float(index) - 1.5) * 0.7)
		var rect := Rect2(pos, card_size)
		draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size), Color("111018aa"))
		draw_rect(rect, Color("efe2bd"))
		draw_rect(rect.grow(-2), Color("71375f"))
		draw_rect(rect.grow(-4), Color("54b9b0"), false, 1.0)
		draw_line(rect.position + Vector2(3, 4), rect.end - Vector2(3, 4), Color("e05a78aa"), 1.0)
		draw_line(Vector2(rect.end.x - 3, rect.position.y + 4), Vector2(rect.position.x + 3, rect.end.y - 4), Color("e05a78aa"), 1.0)
