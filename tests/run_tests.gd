extends SceneTree

func _initialize() -> void:
	print("=== Toepnacht core tests ===")
	var core := CoreTests.new()
	var failures := core.run_all()
	var special := SpecialTests.new()
	failures += special.run_all()
	var campaign := CampaignTests.new()
	failures += campaign.run_all()
	var layout := LayoutTests.new()
	failures += layout.run_all()
	var task05 := Task05Tests.new()
	failures += task05.run_all()
	quit(1 if failures > 0 else 0)
