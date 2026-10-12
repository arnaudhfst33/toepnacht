class_name RetroTableBackdrop
extends Control

var location_id: int = LocationId.STUDENTENHUIS


func set_location(p_location_id: int) -> void:
	location_id = p_location_id
	queue_redraw()


func _draw() -> void:
	var base := LocationId.placeholder_color(location_id)
	var wall := base.lightened(0.08)
	var floor := base.darkened(0.22)
	var table := base.darkened(0.36)
	draw_rect(Rect2(Vector2.ZERO, size), wall)
	draw_rect(Rect2(0, size.y * 0.62, size.x, size.y * 0.38), floor)
	for y in range(int(size.y * 0.62), int(size.y), 18):
		draw_rect(Rect2(0, y, size.x, 2), floor.lightened(0.07))
	for x in range(-40, int(size.x) + 40, 48):
		draw_line(Vector2(x, size.y), Vector2(x + 70, size.y * 0.62), floor.lightened(0.05), 2)
	var table_rect := Rect2(size.x * 0.07, size.y * 0.31, size.x * 0.86, size.y * 0.38)
	draw_rect(table_rect, table)
	draw_rect(table_rect.grow(-5), table.lightened(0.08), false, 4.0)
	if location_id == LocationId.STUDENTENHUIS:
		draw_rect(Rect2(size.x * 0.08, 22, 42, 56), Color("d8d0b8"))
		draw_rect(Rect2(size.x * 0.1, 28, 34, 4), Color("8c3b3b"))
		draw_rect(Rect2(size.x * 0.8, 30, 32, 44), Color("342c25"))
		draw_rect(Rect2(size.x * 0.82, 36, 6, 30), Color("d7b34e"))

