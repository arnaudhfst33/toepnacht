class_name SaveGame
extends RefCounted

const VERSION := CampaignState.SAVE_VERSION
const DEFAULT_PATH := "user://toepnacht_save.json"

var path: String = DEFAULT_PATH
var memory_only: bool = false
var memory_json: String = ""


func save_state(state: CampaignState) -> bool:
	state.save_version = VERSION
	var json := JSON.stringify(state.to_dict())
	if memory_only:
		memory_json = json
		return true
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(json)
	return true


func load_state() -> CampaignState:
	var json := ""
	if memory_only:
		json = memory_json
	else:
		if not FileAccess.file_exists(path):
			return CampaignState.new()
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			return CampaignState.new()
		json = file.get_as_text()
	if json.strip_edges() == "":
		return CampaignState.new()
	var parsed: Variant = JSON.parse_string(json)
	if parsed == null or not (parsed is Dictionary):
		return CampaignState.new()
	return CampaignState.from_dict(parsed)


func exists() -> bool:
	if memory_only:
		return memory_json.strip_edges() != ""
	return FileAccess.file_exists(path)
