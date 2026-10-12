class_name CampaignState
extends RefCounted

const SAVE_VERSION := 2

var save_version: int = SAVE_VERSION
var highest_unlocked_location: int = LocationId.STUDENTENHUIS
var studentenhuis_completed: bool = false
var completed_locations: Array[int] = []
var campaign_complete: bool = false
var tutorial_blanco_done: bool = false
var tutorial_kloppen_done: bool = false
var tutorial_bluffen_done: bool = false
var tutorial_was_done: bool = false
var tutorial_toep_done: bool = false
var tutorial_armoede_done: bool = false
var tutorial_winkel_done: bool = false
var settings: Dictionary = default_settings()

var run_active: bool = false
var location: int = LocationId.STUDENTENHUIS
var potje: int = 1
var beer_caps: int = 0
var inventory: PackedStringArray = PackedStringArray()
var rewarded_keys: Dictionary = {}
var shop: ShopVisit = null
var dubbel_armed: bool = false
var wasdag_armed: bool = false
var stalen_zenuwen_active: bool = false

var peek_opponent_id: int = -1
var peek_card_key: String = ""
var peek_label: String = ""


static func default_settings() -> Dictionary:
	return {
		"music_on": true,
		"music_volume": 1.0,
		"sfx_on": true,
		"sfx_volume": 1.0,
		"haptics_on": true,
		"tips_on": true,
		"animation_speed": "normal",
	}


func has_inventory_slot() -> bool:
	return inventory.size() < PowerUpId.MAX_SLOTS


func has_power_up(id: String) -> bool:
	return inventory.find(id) >= 0


func consume_power_up(id: String) -> bool:
	var idx := inventory.find(id)
	if idx < 0:
		return false
	inventory.remove_at(idx)
	return true


func add_power_up(id: String) -> bool:
	if not has_inventory_slot():
		return false
	inventory.append(id)
	return true


func clear_peek() -> void:
	peek_opponent_id = -1
	peek_card_key = ""
	peek_label = ""


func set_peek(opponent_id: int, card: Card) -> void:
	peek_opponent_id = opponent_id
	peek_card_key = card.key()
	peek_label = "%s van %s" % [str(card), _opponent_placeholder(opponent_id)]


func _opponent_placeholder(opponent_id: int) -> String:
	return "tegenstander %d" % opponent_id


func is_location_completed(loc: int) -> bool:
	return completed_locations.has(loc)


func mark_location_completed(loc: int) -> void:
	if not completed_locations.has(loc):
		completed_locations.append(loc)
	if loc == LocationId.STUDENTENHUIS:
		studentenhuis_completed = true


func tutorial_done(index: int) -> bool:
	match index:
		1:
			return tutorial_blanco_done
		2:
			return tutorial_kloppen_done
		3:
			return tutorial_bluffen_done
		4:
			return tutorial_was_done
		5:
			return tutorial_toep_done
		6:
			return tutorial_armoede_done
		7:
			return tutorial_winkel_done
		_:
			return false


func reset_run_to_potje_1() -> void:
	run_active = true
	potje = 1
	beer_caps = 0
	inventory = PackedStringArray()
	rewarded_keys.clear()
	shop = null
	dubbel_armed = false
	wasdag_armed = false
	stalen_zenuwen_active = false
	clear_peek()


func start_new_run(p_location: int) -> void:
	reset_run_to_potje_1()
	location = p_location


func start_new_studentenhuis_run() -> void:
	start_new_run(LocationId.STUDENTENHUIS)


func is_boss_potje() -> bool:
	return potje == 3


func to_dict() -> Dictionary:
	var inv: Array = []
	for id in inventory:
		inv.append(id)
	var completed: Array = []
	for loc in completed_locations:
		completed.append(loc)
	var data := {
		"version": save_version,
		"highest_unlocked_location": highest_unlocked_location,
		"studentenhuis_completed": studentenhuis_completed,
		"completed_locations": completed,
		"campaign_complete": campaign_complete,
		"tutorial_blanco_done": tutorial_blanco_done,
		"tutorial_kloppen_done": tutorial_kloppen_done,
		"tutorial_bluffen_done": tutorial_bluffen_done,
		"tutorial_was_done": tutorial_was_done,
		"tutorial_toep_done": tutorial_toep_done,
		"tutorial_armoede_done": tutorial_armoede_done,
		"tutorial_winkel_done": tutorial_winkel_done,
		"settings": settings.duplicate(true),
		"run_active": run_active,
		"location": location,
		"potje": potje,
		"beer_caps": beer_caps,
		"inventory": inv,
		"rewarded_keys": rewarded_keys.duplicate(true),
		"dubbel_armed": dubbel_armed,
		"wasdag_armed": wasdag_armed,
		"stalen_zenuwen_active": stalen_zenuwen_active,
		"shop": null,
	}
	if shop != null:
		data["shop"] = shop.to_dict()
	return data


static func from_dict(data: Dictionary) -> CampaignState:
	var state := CampaignState.new()
	state.save_version = int(data.get("version", SAVE_VERSION))
	state.highest_unlocked_location = int(data.get("highest_unlocked_location", LocationId.STUDENTENHUIS))
	state.studentenhuis_completed = bool(data.get("studentenhuis_completed", false))
	state.campaign_complete = bool(data.get("campaign_complete", false))
	state.completed_locations.clear()
	var loaded_completed: Array = data.get("completed_locations", [])
	for loc in loaded_completed:
		state.completed_locations.append(int(loc))
	if state.save_version < 2:
		_migrate_v1(state)
	state.save_version = SAVE_VERSION
	state.tutorial_blanco_done = bool(data.get("tutorial_blanco_done", false))
	state.tutorial_kloppen_done = bool(data.get("tutorial_kloppen_done", false))
	state.tutorial_bluffen_done = bool(data.get("tutorial_bluffen_done", false))
	state.tutorial_was_done = bool(data.get("tutorial_was_done", false))
	state.tutorial_toep_done = bool(data.get("tutorial_toep_done", false))
	state.tutorial_armoede_done = bool(data.get("tutorial_armoede_done", false))
	state.tutorial_winkel_done = bool(data.get("tutorial_winkel_done", false))
	var loaded_settings: Dictionary = data.get("settings", {})
	state.settings = default_settings()
	for key in loaded_settings:
		state.settings[key] = loaded_settings[key]
	state.run_active = bool(data.get("run_active", false))
	state.location = int(data.get("location", LocationId.STUDENTENHUIS))
	state.potje = int(data.get("potje", 1))
	state.beer_caps = int(data.get("beer_caps", 0))
	state.inventory = PackedStringArray()
	var inv: Array = data.get("inventory", [])
	for item in inv:
		state.inventory.append(str(item))
	state.rewarded_keys = data.get("rewarded_keys", {}).duplicate(true)
	state.dubbel_armed = bool(data.get("dubbel_armed", false))
	state.wasdag_armed = bool(data.get("wasdag_armed", false))
	state.stalen_zenuwen_active = bool(data.get("stalen_zenuwen_active", false))
	var shop_data = data.get("shop", null)
	if shop_data is Dictionary:
		state.shop = ShopVisit.from_dict(shop_data)
		if not state.shop.active:
			state.shop = null
	return state


static func _migrate_v1(state: CampaignState) -> void:
	if state.studentenhuis_completed and not state.completed_locations.has(LocationId.STUDENTENHUIS):
		state.completed_locations.append(LocationId.STUDENTENHUIS)
	if state.studentenhuis_completed:
		state.highest_unlocked_location = maxi(state.highest_unlocked_location, LocationId.KROEG)
