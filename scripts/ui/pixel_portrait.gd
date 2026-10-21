class_name PixelPortrait
extends Control

var seat_seed: int = 1
var active: bool = false
var boss: bool = false
var location_id: int = LocationId.STUDENTENHUIS
var role_name: String = ""


func configure(p_seed: int, p_active: bool, p_boss: bool = false, p_location: int = LocationId.STUDENTENHUIS, p_role: String = "") -> void:
	seat_seed = p_seed
	active = p_active
	boss = p_boss
	location_id = p_location
	role_name = p_role
	custom_minimum_size = Vector2(72, 68)
	queue_redraw()


func _draw() -> void:
	var skin_colors := [Color("d9a066"), Color("e8b37a"), Color("9b5c3f")]
	var shirt_colors := _shirt_colors()
	var skin: Color = skin_colors[seat_seed % skin_colors.size()]
	var shirt: Color = shirt_colors[seat_seed % shirt_colors.size()]
	var hair := Color("332521") if seat_seed % 2 == 0 else Color("c49a3a")
	var outline := Color("151318")
	var pixel_scale := minf((size.x - 4.0) / 40.0, (size.y - 8.0) / 56.0)
	var origin := Vector2((size.x - 40.0 * pixel_scale) * 0.5, 5.0 * pixel_scale)
	draw_set_transform(origin, 0.0, Vector2(pixel_scale, pixel_scale))
	var x := 0.0
	draw_rect(Rect2(x + 8, 4, 24, 4), hair)
	draw_rect(Rect2(x + 4, 8, 32, 16), hair)
	draw_rect(Rect2(x + 8, 12, 24, 24), skin)
	draw_rect(Rect2(x + 8, 20, 4, 4), outline)
	draw_rect(Rect2(x + 28, 20, 4, 4), outline)
	draw_rect(Rect2(x + 16, 30, 8, 2), outline)
	draw_rect(Rect2(x + 4, 38, 32, 14), shirt)
	draw_rect(Rect2(x, 44, 40, 8), shirt)
	_draw_location_outfit(x, outline)
	_draw_role_detail(x, outline)
	if boss:
		draw_rect(Rect2(x + 6, 0, 28, 4), Color("f5cf55"))
		draw_rect(Rect2(x + 10, -4, 4, 8), Color("f5cf55"))
		draw_rect(Rect2(x + 26, -4, 4, 8), Color("f5cf55"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if active:
		draw_rect(Rect2(1, 1, size.x - 2, size.y - 2), Color("f6db75"), false, 3.0)


func _shirt_colors() -> Array[Color]:
	match location_id:
		LocationId.KROEG:
			return [Color("7b3f2d"), Color("b2763d"), Color("42664f")]
		LocationId.HUISFEEST:
			return [Color("df4d85"), Color("4dc7d9"), Color("8f55d1")]
		LocationId.SOCIETEIT:
			return [Color("213f68"), Color("6b2438"), Color("2f526f")]
		_:
			return [Color("c94f5d"), Color("4f78c9"), Color("d19a3a")]


func _draw_location_outfit(x: float, outline: Color) -> void:
	match location_id:
		LocationId.KROEG:
			# Schort, snor en een goud naamplaatje voor de kroegtafel.
			draw_rect(Rect2(x + 10, 38, 20, 14), Color("e3d8bd"))
			draw_rect(Rect2(x + 18, 38, 4, 14), Color("6c5137"))
			draw_rect(Rect2(x + 14, 28, 12, 3), outline)
			if boss or role_name.to_lower().contains("bar"):
				draw_rect(Rect2(x + 24, 41, 5, 3), Color("e1b94f"))
		LocationId.HUISFEEST:
			# Zonnebril en, bij de DJ, blokvormige koptelefoon.
			draw_rect(Rect2(x + 7, 18, 26, 5), Color("17151c"))
			draw_rect(Rect2(x + 11, 19, 6, 3), Color("62dbea"))
			draw_rect(Rect2(x + 23, 19, 6, 3), Color("ef5b95"))
			if role_name.to_lower().contains("dj"):
				draw_rect(Rect2(x + 2, 14, 5, 16), Color("17151c"))
				draw_rect(Rect2(x + 33, 14, 5, 16), Color("17151c"))
		LocationId.SOCIETEIT:
			# Wit overhemd, das en goud detail voor de formele eindtafel.
			draw_rect(Rect2(x + 13, 38, 14, 14), Color("e8e2d3"))
			draw_colored_polygon(PackedVector2Array([
				Vector2(x + 20, 39), Vector2(x + 24, 44), Vector2(x + 20, 51), Vector2(x + 16, 44),
			]), Color("b5394f"))
			if boss:
				draw_line(Vector2(x + 8, 39), Vector2(x + 32, 48), Color("e1bd55"), 2.0)


func _draw_role_detail(x: float, outline: Color) -> void:
	var role := role_name.to_lower()
	if role.contains("feut") or role.contains("sjaars") or role.contains("knor"):
		# Scheve studentencap.
		draw_rect(Rect2(x + 5, 5, 28, 4), Color("7b3157"))
		draw_rect(Rect2(x + 27, 8, 10, 3), Color("7b3157"))
	if role.contains("henk") or role.contains("huisoudste") or role.contains("kroegbaas"):
		# Een stevige snor geeft deze vaste kracht meer karakter.
		draw_rect(Rect2(x + 13, 27, 6, 3), outline)
		draw_rect(Rect2(x + 21, 27, 6, 3), outline)
	if role.contains("dealer"):
		# Fluorescerend kettinkje als rustig, fictief karakterdetail.
		draw_line(Vector2(x + 13, 39), Vector2(x + 20, 46), Color("70e0c1"), 2.0)
		draw_line(Vector2(x + 27, 39), Vector2(x + 20, 46), Color("70e0c1"), 2.0)

