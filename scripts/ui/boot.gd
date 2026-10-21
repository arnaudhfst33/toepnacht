class_name Boot
extends RefCounted

static var mode: String = "play"
static var flow: CampaignFlow = null
static var test_all_levels: bool = false


static func ensure_flow() -> CampaignFlow:
	if flow == null:
		if _url_requests_all_levels():
			activate_all_levels_test()
		else:
			flow = CampaignFlow.new()
			flow.load_or_new()
	return flow


static func activate_all_levels_test() -> void:
	test_all_levels = true
	var test_save := SaveGame.new()
	test_save.memory_only = true
	flow = CampaignFlow.new(test_save)
	flow.load_or_new()
	flow.campaign.highest_unlocked_location = LocationId.SOCIETEIT


static func _url_requests_all_levels() -> bool:
	if not OS.has_feature("web"):
		return false
	var requested: Variant = JavaScriptBridge.eval(
		"new URLSearchParams(window.location.search).get('test_levels') === 'all'"
	)
	return bool(requested)


static func reset() -> void:
	mode = "play"
	flow = null
	test_all_levels = false
