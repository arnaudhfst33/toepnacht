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
