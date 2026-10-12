class_name UiLayout
extends RefCounted

## Shared placeholder layout helpers for the 390×844 portrait viewport.

const EDGE_MARGIN := 8
const MIN_BOTTOM_SAFE_MARGIN := 28


static func bottom_safe_margin() -> int:
	var win := DisplayServer.window_get_size()
	var safe := DisplayServer.get_display_safe_area()
	var inset := 0
	if win.y > 0:
		inset = win.y - (safe.position.y + safe.size.y)
	if inset < 0:
		inset = 0
	return maxi(inset, MIN_BOTTOM_SAFE_MARGIN)


static func fill_rect(ctrl: Control, margin: float = 12.0) -> void:
	ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	ctrl.offset_left = margin
	ctrl.offset_top = margin
	ctrl.offset_right = -margin
	ctrl.offset_bottom = -margin
	ctrl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	ctrl.grow_vertical = Control.GROW_DIRECTION_BOTH


static func portrait_margins() -> MarginContainer:
	var box := MarginContainer.new()
	fill_rect(box, 0)
	box.add_theme_constant_override("margin_left", EDGE_MARGIN)
	box.add_theme_constant_override("margin_right", EDGE_MARGIN)
	box.add_theme_constant_override("margin_top", EDGE_MARGIN)
	box.add_theme_constant_override("margin_bottom", bottom_safe_margin())
	return box


static func wrap_label(align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var label := Label.new()
	label.horizontal_alignment = align
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.clip_text = false
	return label


static func vbox(separation: int = 8) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", separation)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return box


static func flow(separation: int = 6) -> HFlowContainer:
	var box := HFlowContainer.new()
	box.add_theme_constant_override("h_separation", separation)
	box.add_theme_constant_override("v_separation", separation)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return box


static func hbox(separation: int = 6) -> HBoxContainer:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", separation)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	return box


static func compact_card(card: Card) -> String:
	var suit := "?"
	match card.suit:
		Card.Suit.HEARTS:
			suit = "H"
		Card.Suit.DIAMONDS:
			suit = "R"
		Card.Suit.CLUBS:
			suit = "K"
		Card.Suit.SPADES:
			suit = "S"
	return "%s %s" % [card.rank_name(), suit]


static func fit_button(button: Button) -> void:
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.clip_text = true
	button.autowrap_mode = TextServer.AUTOWRAP_OFF


static func pixel_panel(fill: Color, border: Color = Color("17151c")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style


static func style_card_button(button: Button, red_suit: bool) -> void:
	var ink := Color("8f2636") if red_suit else Color("191821")
	button.add_theme_color_override("font_color", ink)
	button.add_theme_color_override("font_hover_color", ink)
	button.add_theme_color_override("font_pressed_color", ink)
	button.add_theme_color_override("font_disabled_color", Color(ink, 0.38))
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_stylebox_override("normal", pixel_panel(Color("f4ead0")))
	button.add_theme_stylebox_override("hover", pixel_panel(Color("fff4cc"), Color("e7bd4c")))
	button.add_theme_stylebox_override("pressed", pixel_panel(Color("dfd1b2"), Color("e7bd4c")))
	button.add_theme_stylebox_override("disabled", pixel_panel(Color("a89f8d"), Color("5b5660")))


static func highlight_card_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", pixel_panel(Color("fff2bd"), Color("f2c94c")))
	button.add_theme_stylebox_override("hover", pixel_panel(Color("fff7d6"), Color("ffe072")))
	button.add_theme_stylebox_override("pressed", pixel_panel(Color("e7d49a"), Color("f2c94c")))
