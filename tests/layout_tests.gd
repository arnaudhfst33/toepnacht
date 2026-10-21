class_name LayoutTests
extends RefCounted

var _failures: int = 0
var _passed: int = 0


func run_all() -> int:
	_failures = 0
	_passed = 0
	_test_compact_card()
	_test_fill_rect_margins()
	_test_bottom_safe_margin()
	_test_visual_playing_card()
	_test_location_portrait_style()
	_test_retro_trick_table_seats()
	_test_new_placeholder_screens()
	print("")
	print("Layout tests: %d passed, %d failed" % [_passed, _failures])
	return _failures


func _expect(condition: bool, name: String) -> void:
	if condition:
		_passed += 1
		print("PASS  %s" % name)
	else:
		_failures += 1
		print("FAIL  %s" % name)


func _test_compact_card() -> void:
	var card := Card.new(Card.Suit.HEARTS, Card.Rank.JACK)
	var text := UiLayout.compact_card(card)
	_expect(text == "Boer H", "compact card uses a short suit letter")
	_expect(text.length() < str(card).length(), "compact card is shorter than the full name")


func _test_fill_rect_margins() -> void:
	var ctrl := Control.new()
	UiLayout.fill_rect(ctrl, 8)
	_expect(is_equal_approx(ctrl.offset_left, 8), "left margin is applied")
	_expect(is_equal_approx(ctrl.offset_right, -8), "right margin is applied")
	ctrl.free()


func _test_bottom_safe_margin() -> void:
	_expect(UiLayout.MIN_BOTTOM_SAFE_MARGIN >= 28, "minimum bottom safe-area margin is reserved")
	_expect(UiLayout.bottom_safe_margin() >= UiLayout.MIN_BOTTOM_SAFE_MARGIN, "bottom safe-area is at least the minimum")
	var margins := UiLayout.portrait_margins()
	_expect(margins.get_theme_constant("margin_bottom") >= UiLayout.MIN_BOTTOM_SAFE_MARGIN, "portrait margins keep a bottom safe-area")
	margins.free()


func _test_visual_playing_card() -> void:
	var face := PlayingCardFace.new()
	var card := Card.new(Card.Suit.HEARTS, Card.Rank.TEN)
	face.configure(card, true)
	_expect(face.card.equals(card), "visual card keeps the played card")
	_expect(face.recommended, "visual card supports the advice highlight")
	face.free()


func _test_location_portrait_style() -> void:
	var portrait := PixelPortrait.new()
	portrait.configure(1, true, true, LocationId.KROEG, "De Barman")
	_expect(portrait.location_id == LocationId.KROEG, "portrait keeps its location outfit")
	_expect(portrait.role_name == "De Barman" and portrait.boss, "portrait keeps role and boss styling")
	portrait.free()


func _test_retro_trick_table_seats() -> void:
	var table := RetroTrickTable.new()
	table.size = Vector2(360, 245)
	var human := table.card_target_global(0)
	var left := table.card_target_global(1)
	var top := table.card_target_global(2)
	var right := table.card_target_global(3)
	var human_score := table.score_target_global(0)
	var top_score := table.score_target_global(2)
	_expect(human.y > top.y, "human played card is positioned at the bottom seat")
	_expect(left.x < top.x and right.x > top.x, "opponent cards are positioned left, top and right")
	_expect(human_score.y > top_score.y, "score splashes follow the four seat positions")
	table.free()


func _test_new_placeholder_screens() -> void:
	var save := SaveGame.new()
	save.memory_only = true
	Boot.flow = CampaignFlow.new(save)
	for path in [
		"res://scenes/campaign.tscn",
		"res://scenes/tutorials.tscn",
		"res://scenes/settings.tscn",
		"res://scenes/complete.tscn",
		"res://scenes/menu.tscn",
	]:
		var packed := load(path)
		_expect(packed != null, "%s loads" % path)
		var node: Control = packed.instantiate()
		_expect(is_equal_approx(node.anchor_right, 1.0), "%s stretches horizontally" % path)
		_expect(is_equal_approx(node.anchor_bottom, 1.0), "%s stretches vertically" % path)
		node.free()
	var margins := UiLayout.portrait_margins()
	_expect(margins.get_theme_constant("margin_bottom") >= 28, "campaign screens keep bottom safe-area")
	margins.free()
	Boot.reset()
