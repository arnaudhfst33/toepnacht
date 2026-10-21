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
	var table := _table_color(base)
	draw_rect(Rect2(Vector2.ZERO, size), wall)
	draw_rect(Rect2(0, size.y * 0.62, size.x, size.y * 0.38), floor)
	for y in range(int(size.y * 0.62), int(size.y), 18):
		draw_rect(Rect2(0, y, size.x, 2), floor.lightened(0.07))
	for x in range(-40, int(size.x) + 40, 48):
		draw_line(Vector2(x, size.y), Vector2(x + 70, size.y * 0.62), floor.lightened(0.05), 2)
	var table_rect := Rect2(size.x * 0.07, size.y * 0.31, size.x * 0.86, size.y * 0.38)
	draw_rect(table_rect, table)
	draw_rect(table_rect.grow(-5), table.lightened(0.08), false, 4.0)
	match location_id:
		LocationId.KROEG:
			_draw_kroeg()
		LocationId.HUISFEEST:
			_draw_huisfeest()
		LocationId.SOCIETEIT:
			_draw_societeit()
		_:
			_draw_studentenhuis()


func _table_color(base: Color) -> Color:
	match location_id:
		LocationId.KROEG:
			return Color("4b2d20")
		LocationId.HUISFEEST:
			return Color("3a2247")
		LocationId.SOCIETEIT:
			return Color("17324a")
		_:
			return base.darkened(0.36)


func _draw_studentenhuis() -> void:
	draw_rect(Rect2(size.x * 0.08, 22, 42, 56), Color("d8d0b8"))
	draw_rect(Rect2(size.x * 0.1, 28, 34, 4), Color("8c3b3b"))
	draw_rect(Rect2(size.x * 0.8, 30, 32, 44), Color("342c25"))
	draw_rect(Rect2(size.x * 0.82, 36, 6, 30), Color("d7b34e"))
	# Scheve afwas en een vergeten pizzadoos: studentikoos, maar rustig op de achtergrond.
	draw_rect(Rect2(size.x * 0.68, 78, 36, 8), Color("a66a3e"))
	draw_rect(Rect2(size.x * 0.7, 74, 30, 4), Color("d1a05b"))


func _draw_kroeg() -> void:
	# Herkenbaar krijtbord met drie gekoppelde tapkranen en kleine glazen.
	var board := Rect2(size.x * 0.08, 22, 82, 52)
	draw_rect(board, Color("201916"))
	draw_rect(board, Color("8a6445"), false, 4)
	var font := get_theme_default_font()
	draw_string(font, board.position + Vector2(0, 33), "TOEP", HORIZONTAL_ALIGNMENT_CENTER, board.size.x, 18, Color("ead38b"))
	var tap_bar_x := size.x * 0.66
	draw_rect(Rect2(tap_bar_x, 24, 62, 5), Color("8c6635"))
	for x in range(0, 3):
		var tap_x := tap_bar_x + 7 + x * 22
		draw_rect(Rect2(tap_x, 28, 6, 30), Color("c79b48"))
		draw_rect(Rect2(tap_x - 4, 26, 14, 6), Color("e2c875"))
		draw_rect(Rect2(tap_x + 4, 50, 8, 4), Color("c79b48"))
		draw_rect(Rect2(tap_x + 6, 57, 12, 15), Color("e8d9ae99"), false, 2)
		draw_rect(Rect2(tap_x + 8, 64, 8, 6), Color("e3b94f99"))


func _draw_huisfeest() -> void:
	# Een simpele slinger en twee speakers geven beweging zonder extra UI-elementen.
	for x in range(0, 7):
		var flag_x := 24.0 + x * 52.0
		var flag_color := Color("e05a78") if x % 2 == 0 else Color("57c7d4")
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(flag_x, 24),
				Vector2(flag_x + 22, 24),
				Vector2(flag_x + 11, 42),
			]),
			flag_color,
		)
	for speaker_x in [24.0, size.x - 54.0]:
		draw_rect(Rect2(speaker_x, 60, 30, 58), Color("17131c"))
		draw_circle(Vector2(speaker_x + 15, 96), 9, Color("8b4ab0"))


func _draw_societeit() -> void:
	# Donker hout, vaandel en messing lampen voor de laatste locatie.
	draw_rect(Rect2(size.x * 0.1, 18, 54, 78), Color("6e2435"))
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(size.x * 0.1, 96),
			Vector2(size.x * 0.1 + 54, 96),
			Vector2(size.x * 0.1 + 27, 116),
		]),
		Color("6e2435"),
	)
	for lamp_x in [size.x * 0.68, size.x * 0.84]:
		draw_rect(Rect2(lamp_x, 22, 4, 30), Color("c8a84e"))
		draw_circle(Vector2(lamp_x + 2, 56), 8, Color("f0d77a"))

