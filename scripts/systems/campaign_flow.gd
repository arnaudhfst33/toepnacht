class_name CampaignFlow
extends RefCounted

enum AfterPot {
	NONE,
	SHOP,
	LOCATION_COMPLETE,
	RUN_RESET,
	CAMPAIGN_COMPLETE,
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
	start_new_run(LocationId.STUDENTENHUIS)


func start_new_run(location: int) -> void:
	campaign.start_new_run(location)
	persist()


func mark_tutorial(index: int) -> void:
	match index:
		1:
			campaign.tutorial_blanco_done = true
		2:
			campaign.tutorial_kloppen_done = true
		3:
			campaign.tutorial_bluffen_done = true
		4:
			campaign.tutorial_was_done = true
		5:
			campaign.tutorial_toep_done = true
		6:
			campaign.tutorial_armoede_done = true
		7:
			campaign.tutorial_winkel_done = true
	persist()


func mark_tutorial_blanco() -> void:
	mark_tutorial(1)


func mark_tutorial_kloppen() -> void:
	mark_tutorial(2)


func open_shop() -> void:
	campaign.shop = ShopVisit.generate(rng)
	persist()


func open_scripted_shop(offerings: PackedStringArray) -> void:
	campaign.shop = ShopVisit.scripted(offerings)
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
			campaign.mark_location_completed(campaign.location)
			var nxt := LocationId.next_location(campaign.location)
			campaign.run_active = false
			campaign.shop = null
			if nxt < 0:
				campaign.campaign_complete = true
				persist()
				return AfterPot.CAMPAIGN_COMPLETE
			campaign.highest_unlocked_location = maxi(campaign.highest_unlocked_location, nxt)
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
