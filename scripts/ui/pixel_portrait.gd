class_name PixelPortrait
extends Control

var seat_seed: int = 1
var active: bool = false
var boss: bool = false


func configure(p_seed: int, p_active: bool, p_boss: bool = false) -> void:
	seat_seed = p_seed
	active = p_active
	boss = p_boss
	custom_minimum_size = Vector2(56, 54)
	queue_redraw()


func _draw() -> void:
	var skin_colors := [Color("d9a066"), Color("e8b37a"), Color("9b5c3f")]
	var shirt_colors := [Color("c94f5d"), Color("4f78c9"), Color("d19a3a")]
	var skin: Color = skin_colors[seat_seed % skin_colors.size()]
	var shirt: Color = shirt_colors[seat_seed % shirt_colors.size()]
	var hair := Color("332521") if seat_seed % 2 == 0 else Color("c49a3a")
	var outline := Color("151318")
	var x := (size.x - 40.0) * 0.5
	draw_rect(Rect2(x + 8, 4, 24, 4), hair)
	draw_rect(Rect2(x + 4, 8, 32, 16), hair)
	draw_rect(Rect2(x + 8, 12, 24, 24), skin)
	draw_rect(Rect2(x + 8, 20, 4, 4), outline)
	draw_rect(Rect2(x + 28, 20, 4, 4), outline)
	draw_rect(Rect2(x + 16, 30, 8, 2), outline)
	draw_rect(Rect2(x + 4, 38, 32, 14), shirt)
	draw_rect(Rect2(x, 44, 40, 8), shirt)
	if boss:
		draw_rect(Rect2(x + 6, 0, 28, 4), Color("f5cf55"))
		draw_rect(Rect2(x + 10, -4, 4, 8), Color("f5cf55"))
		draw_rect(Rect2(x + 26, -4, 4, 8), Color("f5cf55"))
	if active:
		draw_rect(Rect2(1, 1, size.x - 2, size.y - 2), Color("f6db75"), false, 3.0)

