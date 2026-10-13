class_name RetroTrickTable
extends Control

## Four-seat oval table for the portrait mobile layout.

var location_id: int = LocationId.STUDENTENHUIS
var portraits: Dictionary = {}
var played_faces: Dictionary = {}
var seat_labels: Dictionary = {}
var open_hand_labels: Dictionary = {}


func _ready() -> void:
	resized.connect(_layout_seats)
	queue_redraw()


func configure(game: ToepenGame, events: Array[Dictionary], names: PackedStringArray, is_boss: bool, p_location: int) -> void:
	location_id = p_location
	for child in get_children():
		child.queue_free()
	portraits.clear()
	played_faces.clear()
	seat_labels.clear()
	open_hand_labels.clear()

	for player_id in range(1, ToepenGame.PLAYER_COUNT):
		var portrait := PixelPortrait.new()
		portrait.configure(player_id, _active_player_id(game) == player_id, is_boss and player_id == 1)
		add_child(portrait)
		portraits[player_id] = portrait
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 10)
		var player := game.players[player_id]
		var state := "AF" if player.is_eliminated else "%d/15 · %d krt" % [player.penalty_points, player.hand.size()]
		if not player.is_active_in_round and not player.is_eliminated:
			state = "%d/15 · PAS" % player.penalty_points
		label.text = "%s\n%s" % [_opponent_name(names, player_id), state]
		add_child(label)
		seat_labels[player_id] = label
		if game.cards_open and not player.is_eliminated:
			var open_label := Label.new()
			open_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			open_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			open_label.add_theme_font_size_override("font_size", 8)
			var cards: PackedStringArray = PackedStringArray()
			for card in player.hand:
				cards.append(UiLayout.compact_card(card))
			open_label.text = "OPEN · " + "  ".join(cards)
			open_label.modulate = Color("f0dfa3")
			add_child(open_label)
			open_hand_labels[player_id] = open_label

	for event in events:
		var player_id := int(event.get("player_id", -1))
		var card: Card = event.get("card")
		if player_id < 0 or card == null:
			continue
		var face := PlayingCardFace.new()
		face.configure(card)
		add_child(face)
		played_faces[player_id] = face
	queue_redraw()
	_layout_seats.call_deferred()


func portrait_for(player_id: int) -> Control:
	return portraits.get(player_id)


func card_target_global(player_id: int) -> Vector2:
	return global_position + _card_center(player_id) - Vector2(32, 43)


func _layout_seats() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	for player_id in portraits:
		var portrait: Control = portraits[player_id]
		portrait.size = Vector2(56, 54)
		portrait.position = _portrait_center(player_id) - portrait.size * 0.5
		var label: Label = seat_labels[player_id]
		label.size = Vector2(112, 40)
		label.position = _label_position(player_id, label.size)
		if open_hand_labels.has(player_id):
			var open_label: Label = open_hand_labels[player_id]
			open_label.size = Vector2(132, 34)
			open_label.position = _open_hand_position(player_id, open_label.size)
	for player_id in played_faces:
		var face: PlayingCardFace = played_faces[player_id]
		face.size = Vector2(54, 72)
		face.position = _card_center(player_id) - face.size * 0.5


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var center := Vector2(size.x * 0.5, size.y * 0.53)
	var radii := Vector2(size.x * 0.39, size.y * 0.34)
	draw_colored_polygon(_ellipse(center + Vector2(-3, 1), radii + Vector2(12, 10)), Color("39b7b744"))
	draw_colored_polygon(_ellipse(center + Vector2(3, 2), radii + Vector2(12, 10)), Color("c4456844"))
	draw_colored_polygon(_ellipse(center + Vector2(0, 5), radii + Vector2(9, 8)), Color("15131bcc"))
	draw_colored_polygon(_ellipse(center, radii), _felt_color())
	draw_polyline(_closed_ellipse(center, radii - Vector2(7, 6)), Color("d6b85b88"), 2.0)
	for player_id in ToepenGame.PLAYER_COUNT:
		var card_center := _card_center(player_id)
		draw_rect(Rect2(card_center - Vector2(29, 38), Vector2(58, 76)), Color("0d111633"), true)
		draw_rect(Rect2(card_center - Vector2(29, 38), Vector2(58, 76)), Color("f2d47733"), false, 1.0)


func _felt_color() -> Color:
	match location_id:
		LocationId.KROEG:
			return Color("264b3b")
		LocationId.HUISFEEST:
			return Color("3d2850")
		LocationId.SOCIETEIT:
			return Color("193b55")
		_:
			return Color("244636")


func _ellipse(center: Vector2, radii: Vector2, points: int = 48) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for i in points:
		var angle := TAU * float(i) / float(points)
		polygon.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	return polygon


func _closed_ellipse(center: Vector2, radii: Vector2) -> PackedVector2Array:
	var points := _ellipse(center, radii)
	points.append(points[0])
	return points


func _portrait_center(player_id: int) -> Vector2:
	match player_id:
		1:
			return Vector2(size.x * 0.08, size.y * 0.48)
		2:
			return Vector2(size.x * 0.5, size.y * 0.13)
		3:
			return Vector2(size.x * 0.92, size.y * 0.48)
		_:
			return Vector2(size.x * 0.5, size.y * 0.95)


func _card_center(player_id: int) -> Vector2:
	match player_id:
		0:
			return Vector2(size.x * 0.5, size.y * 0.74)
		1:
			return Vector2(size.x * 0.29, size.y * 0.52)
		2:
			return Vector2(size.x * 0.5, size.y * 0.34)
		3:
			return Vector2(size.x * 0.71, size.y * 0.52)
		_:
			return Vector2(size.x * 0.5, size.y * 0.52)


func _label_position(player_id: int, label_size: Vector2) -> Vector2:
	var center := _portrait_center(player_id)
	match player_id:
		1:
			return Vector2(0, size.y * 0.18)
		2:
			return Vector2(center.x + 32, 4)
		3:
			return Vector2(size.x - label_size.x, size.y * 0.18)
		_:
			return center


func _open_hand_position(player_id: int, label_size: Vector2) -> Vector2:
	match player_id:
		1:
			return Vector2(0, size.y - label_size.y - 2)
		2:
			return Vector2(0, 2)
		3:
			return Vector2(size.x - label_size.x, size.y - label_size.y - 2)
		_:
			return Vector2.ZERO


func _active_player_id(game: ToepenGame) -> int:
	if game.state == ToepenGame.State.NORMAL_PLAY:
		return game.current_actor_id
	if game.state == ToepenGame.State.KNOCK_DECISIONS:
		return game.current_knock_responder_id()
	if game.state == ToepenGame.State.VUILE_WAS_CHALLENGE:
		return game.current_vuile_was_challenger_id()
	if game.state == ToepenGame.State.PRE_ROUND_SPECIALS:
		return game.current_specials_actor_id()
	return -1


func _opponent_name(names: PackedStringArray, player_id: int) -> String:
	var index := player_id - 1
	if index >= 0 and index < names.size():
		return names[index]
	return "AI %d" % player_id
