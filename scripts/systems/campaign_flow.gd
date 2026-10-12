class_name CampaignFlow
extends RefCounted

enum AfterPot {
	NONE,
	SHOP,
	LOCATION_COMPLETE,
	RUN_RESET,
}

var campaign: CampaignState
var save: SaveGame
var economy: Economy
var rng: RandomNumberGenerator


func _init(p_save: SaveGame = null, p_rng: RandomNumberGenerator = null) -> void:
	save = p_save if p_save != null else SaveGame.new()
	campaign = CampaignState.new()
	economy = Economy.new()
	if p_rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	else:
		rng = p_rng


func load_or_new() -> void:
	campaign = save.load_state()


func persist() -> void:
	save.save_state(campaign)


func start_new_studentenhuis_run() -> void:
	campaign.start_new_studentenhuis_run()
	persist()


func mark_tutorial_blanco() -> void:
	campaign.tutorial_blanco_done = true
	persist()


func mark_tutorial_kloppen() -> void:
	campaign.tutorial_kloppen_done = true
	persist()


func open_shop() -> void:
	campaign.shop = ShopVisit.generate(rng)
	persist()


func leave_shop() -> void:
	campaign.shop = null
	if campaign.potje < 3:
		campaign.potje += 1
	campaign.rewarded_keys.clear()
	persist()


func apply_round_rewards(game: ToepenGame) -> int:
	var granted := economy.grant_round_win(campaign, game)
	persist()
	return granted


func apply_toep_reward(game: ToepenGame) -> int:
	var granted := economy.grant_toep(campaign, game)
	persist()
	return granted


func resolve_pot_end(game: ToepenGame) -> AfterPot:
	if game.pot_winner_id < 0:
		return AfterPot.NONE
	if game.pot_winner_id == ToepenGame.HUMAN_PLAYER_ID:
		var boss := campaign.is_boss_potje()
		economy.grant_potje_win(campaign, boss)
		if boss:
			campaign.studentenhuis_completed = true
			campaign.highest_unlocked_location = maxi(campaign.highest_unlocked_location, LocationId.KROEG)
			campaign.run_active = false
			campaign.shop = null
			persist()
			return AfterPot.LOCATION_COMPLETE
		open_shop()
		return AfterPot.SHOP
	campaign.reset_run_to_potje_1()
	persist()
	return AfterPot.RUN_RESET


func buy_shop_index(index: int) -> bool:
	if campaign.shop == null or not campaign.shop.active:
		return false
	if index < 0 or index >= campaign.shop.offerings.size():
		return false
	var id := str(campaign.shop.offerings[index])
	if not PowerUpCatalog.is_implemented(id):
		return false
	if not campaign.has_inventory_slot():
		return false
	var price := PowerUpCatalog.cost(id)
	if campaign.beer_caps < price:
		return false
	campaign.beer_caps -= price
	campaign.add_power_up(id)
	persist()
	return true
