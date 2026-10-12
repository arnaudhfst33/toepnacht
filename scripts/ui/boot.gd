class_name Boot
extends RefCounted

static var mode: String = "play"
static var flow: CampaignFlow = null


static func ensure_flow() -> CampaignFlow:
	if flow == null:
		flow = CampaignFlow.new()
		flow.load_or_new()
	return flow


static func reset() -> void:
	mode = "play"
	flow = null
