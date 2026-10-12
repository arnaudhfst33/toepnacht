class_name CampaignState
extends RefCounted

const SAVE_VERSION := 1

var save_version: int = SAVE_VERSION
var highest_unlocked_location: int = LocationId.STUDENTENHUIS
var studentenhuis_completed: bool = false
var tutorial_blanco_done: bool = false
var tutorial_kloppen_done: bool = false
var settings: Dictionary = default_settings()

var run_active: bool = false
var location: int = LocationId.STUDENTENHUIS
var potje: int = 1
var beer_caps: int = 0
var inventory: PackedStringArray = PackedStringArray()
var rewarded_keys: Dictionary = {}
var shop: ShopVisit = null

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


func reset_run_to_potje_1() -> void:
	run_active = true
	location = LocationId.STUDENTENHUIS
	potje = 1
	beer_caps = 0
	inventory = PackedStringArray()
	rewarded_keys.clear()
	shop = null
	clear_peek()


func start_new_studentenhuis_run() -> void:
	reset_run_to_potje_1()


func is_boss_potje() -> bool:
	return location == LocationId.STUDENTENHUIS and potje == 3


func to_dict() -> Dictionary:
	var inv: Array = []
	for id in inventory:
		inv.append(id)
	var data := {
		"version": save_version,
		"highest_unlocked_location": highest_unlocked_location,
		"studentenhuis_completed": studentenhuis_completed,
		"tutorial_blanco_done": tutorial_blanco_done,
		"tutorial_kloppen_done": tutorial_kloppen_done,
		"settings": settings.duplicate(true),
		"run_active": run_active,
		"location": location,
		"potje": potje,
		"beer_caps": beer_caps,
		"inventory": inv,
		"rewarded_keys": rewarded_keys.duplicate(true),
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
	state.tutorial_blanco_done = bool(data.get("tutorial_blanco_done", false))
	state.tutorial_kloppen_done = bool(data.get("tutorial_kloppen_done", false))
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
	var shop_data = data.get("shop", null)
	if shop_data is Dictionary:
		state.shop = ShopVisit.from_dict(shop_data)
		if not state.shop.active:
			state.shop = null
	return state
