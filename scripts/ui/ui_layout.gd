class_name UiLayout
extends RefCounted

## Shared placeholder layout helpers for the 390×844 portrait viewport.


static func fill_rect(ctrl: Control, margin: float = 12.0) -> void:
	ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	ctrl.offset_left = margin
	ctrl.offset_top = margin
	ctrl.offset_right = -margin
	ctrl.offset_bottom = -margin
	ctrl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	ctrl.grow_vertical = Control.GROW_DIRECTION_BOTH


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
