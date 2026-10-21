class_name CampaignTests
extends RefCounted

var _failures: int = 0
var _passed: int = 0


func run_all() -> int:
	_failures = 0
	_passed = 0
	_test_new_run_starts_potje_1()
	_test_restart_run_preserves_progress()
	_test_win_potje_1_opens_shop()
	_test_leave_shop_goes_to_potje_2()
	_test_win_potje_2_opens_shop()
	_test_leave_shop_goes_to_boss()
	_test_boss_win_completes_and_unlocks_kroeg()
	_test_loss_potje_1_resets()
	_test_loss_potje_2_resets()
	_test_loss_boss_resets()
	_test_round_reward()
	_test_knock_bonus()
	_test_potje_and_toep_and_boss_rewards()
	_test_no_duplicate_round_reward()
	_test_loss_clears_beer_caps()
	_test_shop_three_offerings()
	_test_shop_descriptions()
	_test_shop_prices_and_slots()
	_test_shop_visit_does_not_reroll()
	_test_kaartje_ruilen()
	_test_kaartje_ruilen_illegal_timing()
	_test_even_spieken_human_only()
	_test_op_het_randje()
	_test_rondje_van_de_zaak()
	_test_huisvoordeel()
	_test_save_load_run_and_unlock()
	_test_loss_persists_reset()
	_test_boss_completion_persists()
	_test_save_version()
	_test_ai_profiles_legal_and_hidden()
	_test_boss_profile_imperfect()
	print("")
	print("Campaign tests: %d passed, %d failed" % [_passed, _failures])
	return _failures


func _expect(condition: bool, name: String) -> void:
	if condition:
		_passed += 1
		print("PASS  %s" % name)
	else:
		_failures += 1
		print("FAIL  %s" % name)


func _expect_eq(actual: Variant, expected: Variant, name: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [name, str(expected), str(actual)])


func _c(suit: Card.Suit, rank: Card.Rank) -> Card:
	return Card.new(suit, rank)


func _mem_flow(seed: int = 7) -> CampaignFlow:
	var save := SaveGame.new()
	save.memory_only = true
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var flow := CampaignFlow.new(save, rng)
	return flow


func _force_human_win(game: ToepenGame) -> void:
	game.apply_penalty(1, 15)
	game.apply_penalty(2, 15)
	game.apply_penalty(3, 15)


func _force_human_loss(game: ToepenGame) -> void:
	game.apply_penalty(0, 15)
	game.apply_penalty(1, 15)
	game.apply_penalty(2, 15)


func _fresh_pot() -> ToepenGame:
	var game := ToepenGame.new()
	game.start_pot()
	return game


func _test_new_run_starts_potje_1() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	_expect(flow.campaign.run_active, "new campaign run is active")
	_expect_eq(flow.campaign.location, LocationId.STUDENTENHUIS, "starts at Studentenhuis")
	_expect_eq(flow.campaign.potje, 1, "starts at potje 1")
	_expect_eq(flow.campaign.beer_caps, 0, "new run has 0 beer caps")
	_expect_eq(flow.campaign.inventory.size(), 0, "new run has empty inventory")


func _test_restart_run_preserves_progress() -> void:
	var flow := _mem_flow()
	flow.campaign.highest_unlocked_location = LocationId.HUISFEEST
	flow.campaign.mark_location_completed(LocationId.STUDENTENHUIS)
	flow.campaign.tutorial_blanco_done = true
	flow.campaign.settings["tips_on"] = false
	flow.campaign.start_new_run(LocationId.KROEG)
	flow.campaign.potje = 2
	flow.campaign.beer_caps = 9
	flow.campaign.add_power_up(PowerUpId.EVEN_SPIEKEN)
	flow.start_new_studentenhuis_run()
	_expect_eq(flow.campaign.location, LocationId.STUDENTENHUIS, "restart returns to Studentenhuis")
	_expect_eq(flow.campaign.potje, 1, "restart returns to potje 1")
	_expect_eq(flow.campaign.beer_caps, 0, "restart clears beer caps")
	_expect_eq(flow.campaign.inventory.size(), 0, "restart clears power-ups")
	_expect_eq(flow.campaign.highest_unlocked_location, LocationId.HUISFEEST, "restart preserves unlocked levels")
	_expect(flow.campaign.is_location_completed(LocationId.STUDENTENHUIS), "restart preserves completed levels")
	_expect(flow.campaign.tutorial_blanco_done, "restart preserves tutorials")
	_expect_eq(flow.campaign.settings["tips_on"], false, "restart preserves settings")


func _test_win_potje_1_opens_shop() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	var game := _fresh_pot()
	_force_human_win(game)
	var result := flow.resolve_pot_end(game)
	_expect_eq(result, CampaignFlow.AfterPot.SHOP, "win potje 1 advances to shop")
	_expect(flow.campaign.shop != null and flow.campaign.shop.active, "shop visit is active")
	_expect_eq(flow.campaign.potje, 1, "potje stays 1 until leaving shop")


func _test_leave_shop_goes_to_potje_2() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	var game := _fresh_pot()
	_force_human_win(game)
	flow.resolve_pot_end(game)
	flow.leave_shop()
	_expect(flow.campaign.shop == null, "shop closed")
	_expect_eq(flow.campaign.potje, 2, "leaving shop advances to potje 2")


func _test_win_potje_2_opens_shop() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	flow.campaign.potje = 2
	var game := _fresh_pot()
	_force_human_win(game)
	var result := flow.resolve_pot_end(game)
	_expect_eq(result, CampaignFlow.AfterPot.SHOP, "win potje 2 advances to shop")
	_expect_eq(flow.campaign.potje, 2, "still potje 2 in shop")


func _test_leave_shop_goes_to_boss() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	flow.campaign.potje = 2
	var game := _fresh_pot()
	_force_human_win(game)
	flow.resolve_pot_end(game)
	flow.leave_shop()
	_expect_eq(flow.campaign.potje, 3, "leaving shop advances to boss potje")
	_expect(flow.campaign.is_boss_potje(), "potje 3 is the boss table")


func _test_boss_win_completes_and_unlocks_kroeg() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	flow.campaign.potje = 3
	var game := _fresh_pot()
	_force_human_win(game)
	var result := flow.resolve_pot_end(game)
	_expect_eq(result, CampaignFlow.AfterPot.LOCATION_COMPLETE, "boss win completes Studentenhuis")
	_expect(flow.campaign.studentenhuis_completed, "Studentenhuis marked complete")
	_expect_eq(flow.campaign.highest_unlocked_location, LocationId.KROEG, "boss win unlocks Kroeg")
	_expect(not flow.campaign.run_active, "run ends after boss")
	_expect(flow.campaign.shop == null, "no shop after boss")


func _test_loss_potje_1_resets() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	flow.campaign.beer_caps = 9
	flow.campaign.add_power_up(PowerUpId.EVEN_SPIEKEN)
	var game := _fresh_pot()
	_force_human_loss(game)
	var result := flow.resolve_pot_end(game)
	_expect_eq(result, CampaignFlow.AfterPot.RUN_RESET, "loss in potje 1 resets the run")
	_expect_eq(flow.campaign.potje, 1, "loss returns to potje 1")
	_expect_eq(flow.campaign.beer_caps, 0, "loss clears beer caps")
	_expect_eq(flow.campaign.inventory.size(), 0, "loss clears power-ups")
	_expect(flow.campaign.run_active, "reset run stays continue-able")


func _test_loss_potje_2_resets() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	flow.campaign.potje = 2
	flow.campaign.beer_caps = 4
	var game := _fresh_pot()
	_force_human_loss(game)
	flow.resolve_pot_end(game)
	_expect_eq(flow.campaign.potje, 1, "loss in potje 2 resets to potje 1")
	_expect_eq(flow.campaign.beer_caps, 0, "potje 2 loss clears caps")


func _test_loss_boss_resets() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	flow.campaign.potje = 3
	flow.campaign.beer_caps = 11
	var game := _fresh_pot()
	_force_human_loss(game)
	flow.resolve_pot_end(game)
	_expect_eq(flow.campaign.potje, 1, "loss against boss resets to potje 1")
	_expect(not flow.campaign.studentenhuis_completed, "boss loss does not complete location")
	_expect_eq(flow.campaign.highest_unlocked_location, LocationId.STUDENTENHUIS, "boss loss does not unlock Kroeg")


func _test_round_reward() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	var game := ToepenGame.new()
	game.round_serial = 1
	game.last_round_winner_id = 0
	game.human_knocked_this_round = false
	_expect_eq(flow.apply_round_rewards(game), 1, "round win grants +1")
	_expect_eq(flow.campaign.beer_caps, 1, "beer caps after round win")


func _test_knock_bonus() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	var game := ToepenGame.new()
	game.round_serial = 2
	game.last_round_winner_id = 0
	game.human_knocked_this_round = true
	_expect_eq(flow.apply_round_rewards(game), 2, "round win after human knock grants +1 extra")


func _test_potje_and_toep_and_boss_rewards() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	var game := ToepenGame.new()
	game.last_toep_declarer_id = 0
	game.last_toep_event_id = 1
	_expect_eq(flow.apply_toep_reward(game), 3, "human Toep grants +3")
	flow.campaign.potje = 3
	game = _fresh_pot()
	_force_human_win(game)
	flow.resolve_pot_end(game)
	_expect_eq(flow.campaign.beer_caps, 3 + 3 + 5, "potje win +3 and boss +5 extra")


func _test_no_duplicate_round_reward() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	var game := ToepenGame.new()
	game.round_serial = 4
	game.last_round_winner_id = 0
	flow.apply_round_rewards(game)
	_expect_eq(flow.apply_round_rewards(game), 0, "same round is not rewarded twice")
	_expect_eq(flow.campaign.beer_caps, 1, "caps stay at a single round reward")


func _test_loss_clears_beer_caps() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	flow.campaign.beer_caps = 12
	var game := _fresh_pot()
	_force_human_loss(game)
	flow.resolve_pot_end(game)
	_expect_eq(flow.campaign.beer_caps, 0, "loss clears beer caps")


func _test_shop_three_offerings() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	flow.open_shop()
	_expect_eq(flow.campaign.shop.offerings.size(), 3, "shop shows exactly 3 offerings")
	for id in flow.campaign.shop.offerings:
		_expect(PowerUpCatalog.is_implemented(str(id)), "shop offering is implemented")


func _test_shop_descriptions() -> void:
	for id in PowerUpId.all_ids():
		_expect(PowerUpCatalog.description(id).length() >= 20, "%s has a clear shop effect" % id)
		_expect(PowerUpCatalog.timing(id).length() >= 15, "%s explains when it can be used" % id)


func _test_shop_prices_and_slots() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	flow.open_shop()
	var id := str(flow.campaign.shop.offerings[0])
	var price := PowerUpCatalog.cost(id)
	flow.campaign.beer_caps = price - 1
	_expect(not flow.buy_shop_index(0), "cannot buy without enough beer caps")
	flow.campaign.beer_caps = price
	_expect(flow.buy_shop_index(0), "can buy when affordable")
	_expect_eq(flow.campaign.beer_caps, 0, "buying deducts beer caps")
	_expect_eq(flow.campaign.inventory.size(), 1, "purchased item enters inventory")
	_expect_eq(str(flow.campaign.inventory[0]), id, "inventory holds the purchased id")
	flow.campaign.beer_caps = 99
	flow.campaign.add_power_up(PowerUpId.KAARTJE_RUILEN)
	_expect_eq(flow.campaign.inventory.size(), 2, "two slots fill")
	_expect(not flow.campaign.has_inventory_slot(), "cannot hold more than 2 items")
	_expect(not flow.buy_shop_index(1), "purchase rejected when slots are full")


func _test_shop_visit_does_not_reroll() -> void:
	var flow := _mem_flow(11)
	flow.start_new_studentenhuis_run()
	flow.open_shop()
	var first := PackedStringArray()
	for id in flow.campaign.shop.offerings:
		first.append(id)
	var loaded := flow.save.load_state()
	_expect_eq(loaded.shop.offerings.size(), 3, "loaded shop still has 3 offerings")
	for i in first.size():
		_expect_eq(str(loaded.shop.offerings[i]), str(first[i]), "same shop visit does not reroll")


func _swap_hands() -> Array:
	return [
		[
			_c(Card.Suit.HEARTS, Card.Rank.TEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.NINE),
			_c(Card.Suit.CLUBS, Card.Rank.EIGHT),
			_c(Card.Suit.SPADES, Card.Rank.SEVEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.JACK),
			_c(Card.Suit.DIAMONDS, Card.Rank.JACK),
			_c(Card.Suit.CLUBS, Card.Rank.QUEEN),
			_c(Card.Suit.SPADES, Card.Rank.QUEEN),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.KING),
			_c(Card.Suit.DIAMONDS, Card.Rank.KING),
			_c(Card.Suit.CLUBS, Card.Rank.ACE),
			_c(Card.Suit.SPADES, Card.Rank.ACE),
		],
		[
			_c(Card.Suit.HEARTS, Card.Rank.SEVEN),
			_c(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
			_c(Card.Suit.CLUBS, Card.Rank.NINE),
			_c(Card.Suit.SPADES, Card.Rank.NINE),
		],
	]


func _test_kaartje_ruilen() -> void:
	var run := CampaignState.new()
	run.add_power_up(PowerUpId.KAARTJE_RUILEN)
	var game := ToepenGame.new()
	game.setup_controlled_round(_swap_hands(), 0)
	var svc := PowerUpService.new()
	var discard: Card = game.players[0].hand[0]
	_expect(svc.can_activate(PowerUpId.KAARTJE_RUILEN, game, run), "Kaartje Ruilen valid before first card")
	_expect(svc.use_kaartje_ruilen(game, run, discard), "Kaartje Ruilen activation succeeds")
	_expect_eq(run.inventory.size(), 0, "Kaartje Ruilen is consumed")
	_expect(not game.players[0].has_card(discard), "discarded card left the hand")
	var in_stock := false
	for card in game.deck.cards:
		if card.equals(discard):
			in_stock = true
	_expect(not in_stock, "discarded Kaartje Ruilen card stays out of stock")
	_expect_eq(game.players[0].hand.size(), 4, "hand still has 4 cards")


func _test_kaartje_ruilen_illegal_timing() -> void:
	var run := CampaignState.new()
	run.add_power_up(PowerUpId.KAARTJE_RUILEN)
	var game := ToepenGame.new()
	game.setup_controlled_round(_swap_hands(), 0)
	game.play_card(0, game.players[0].hand[0])
	var svc := PowerUpService.new()
	_expect(not svc.can_activate(PowerUpId.KAARTJE_RUILEN, game, run), "Kaartje Ruilen illegal after human played")
	_expect(not svc.use_kaartje_ruilen(game, run, game.players[0].hand[0]), "illegal Kaartje Ruilen rejected")
	_expect_eq(run.inventory.size(), 1, "failed use does not consume")


func _test_even_spieken_human_only() -> void:
	var run := CampaignState.new()
	run.add_power_up(PowerUpId.EVEN_SPIEKEN)
	var game := ToepenGame.new()
	game.setup_controlled_round(_swap_hands(), 0)
	var svc := PowerUpService.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	_expect(svc.use_even_spieken(game, run, 1, rng), "Even Spieken reveals an opponent card")
	_expect(run.peek_card_key != "", "peek is stored for the human")
	_expect_eq(run.inventory.size(), 0, "Even Spieken is consumed")
	var ai_view := PublicView.from_game(game, 2)
	_expect(not ai_view.contains_hidden_card_from(game), "AI public view has no hidden cards")
	for card in ai_view.own_hand:
		_expect(card.key() != run.peek_card_key or game.players[2].has_card(card), "peek is not copied into another AI hand view")
	var peek_in_ai_view := false
	for card in ai_view.own_hand:
		if card.key() == run.peek_card_key:
			peek_in_ai_view = true
	for card in ai_view.trick_cards:
		if card.key() == run.peek_card_key:
			peek_in_ai_view = true
	_expect(not peek_in_ai_view, "AI cannot access peek information")


func _test_op_het_randje() -> void:
	var run := CampaignState.new()
	run.add_power_up(PowerUpId.OP_HET_RANDJE)
	var game := ToepenGame.new()
	var svc := PowerUpService.new()
	game.penalty_adjuster = func(pid: int, amount: int) -> int:
		return svc.adjust_penalty(game, run, pid, amount)
	game.apply_penalty(0, 10)
	_expect_eq(game.players[0].penalty_points, 10, "Op het Randje does not trigger below 15")
	_expect_eq(run.inventory.size(), 1, "passive unused while below 15")
	game.apply_penalty(0, 5)
	_expect_eq(game.players[0].penalty_points, 14, "Op het Randje sets 14 at the elimination threshold")
	_expect(not game.players[0].is_eliminated, "human is not eliminated")
	_expect_eq(run.inventory.size(), 0, "Op het Randje consumed once")
	game.apply_penalty(0, 5)
	_expect(game.players[0].is_eliminated, "second elimination is not blocked")


func _test_rondje_van_de_zaak() -> void:
	var run := CampaignState.new()
	run.add_power_up(PowerUpId.RONDJE_VAN_DE_ZAAK)
	var game := ToepenGame.new()
	game.setup_controlled_round(_swap_hands(), 0)
	game.players[0].penalty_points = 0
	var svc := PowerUpService.new()
	_expect(not svc.use_rondje(game, run), "Rondje cannot go below 0")
	_expect_eq(run.inventory.size(), 1, "failed Rondje is not consumed")
	game.players[0].penalty_points = 3
	_expect(svc.use_rondje(game, run), "Rondje removes a point")
	_expect_eq(game.players[0].penalty_points, 2, "Rondje removes exactly 1")
	_expect_eq(run.inventory.size(), 0, "Rondje is consumed after success")


func _test_huisvoordeel() -> void:
	var run := CampaignState.new()
	run.add_power_up(PowerUpId.HUISVOORDEEL)
	var game := ToepenGame.new()
	game.setup_controlled_round(_swap_hands(), 0)
	var svc := PowerUpService.new()
	var discard: Card = game.players[0].hand[1]
	_expect(svc.begin_huisvoordeel(game, run, discard), "Huisvoordeel starts")
	_expect_eq(svc.pending_huisvoordeel_candidates.size(), 2, "Huisvoordeel generates 2 candidates")
	var chosen: Card = svc.pending_huisvoordeel_candidates[0]
	var other: Card = svc.pending_huisvoordeel_candidates[1]
	_expect(svc.finish_huisvoordeel(game, run, 0), "Huisvoordeel applies the chosen card")
	_expect(game.players[0].has_card(chosen), "chosen card enters the hand")
	_expect(not game.players[0].has_card(discard), "original discard left the hand")
	var discard_in_stock := false
	var other_in_stock := false
	for card in game.deck.cards:
		if card.equals(discard):
			discard_in_stock = true
		if card.equals(other):
			other_in_stock = true
	_expect(not discard_in_stock, "Huisvoordeel discard stays out of stock")
	_expect(other_in_stock, "unchosen candidate returned to stock")
	_expect_eq(run.inventory.size(), 0, "Huisvoordeel is consumed")


func _test_save_load_run_and_unlock() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	flow.campaign.potje = 2
	flow.campaign.beer_caps = 6
	flow.campaign.add_power_up(PowerUpId.KAARTJE_RUILEN)
	flow.campaign.highest_unlocked_location = LocationId.STUDENTENHUIS
	flow.persist()
	var loaded := flow.save.load_state()
	_expect_eq(loaded.highest_unlocked_location, LocationId.STUDENTENHUIS, "save/load unlocked location")
	_expect_eq(loaded.potje, 2, "save/load active potje")
	_expect_eq(loaded.beer_caps, 6, "save/load beer caps")
	_expect_eq(str(loaded.inventory[0]), PowerUpId.KAARTJE_RUILEN, "save/load power-ups")
	_expect(loaded.run_active, "save/load active Studentenhuis run")


func _test_loss_persists_reset() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	flow.campaign.potje = 2
	flow.campaign.beer_caps = 8
	flow.campaign.add_power_up(PowerUpId.EVEN_SPIEKEN)
	var game := _fresh_pot()
	_force_human_loss(game)
	flow.resolve_pot_end(game)
	var loaded := flow.save.load_state()
	_expect_eq(loaded.potje, 1, "loss persists reset to potje 1")
	_expect_eq(loaded.beer_caps, 0, "loss persists 0 beer caps")
	_expect_eq(loaded.inventory.size(), 0, "loss persists empty inventory")


func _test_boss_completion_persists() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	flow.campaign.potje = 3
	var game := _fresh_pot()
	_force_human_win(game)
	flow.resolve_pot_end(game)
	var loaded := flow.save.load_state()
	_expect(loaded.studentenhuis_completed, "boss completion persists")
	_expect_eq(loaded.highest_unlocked_location, LocationId.KROEG, "Kroeg unlock persists")
	_expect(not loaded.run_active, "completed run is not active after load")


func _test_save_version() -> void:
	var flow := _mem_flow()
	flow.start_new_studentenhuis_run()
	flow.persist()
	var loaded := flow.save.load_state()
	_expect_eq(loaded.save_version, CampaignState.SAVE_VERSION, "save version exists")
	_expect(SaveGame.VERSION >= 1, "save format version is set from the beginning")


func _test_ai_profiles_legal_and_hidden() -> void:
	var profiles: Array = [
		AiProfile.studentenhuis_potje1(),
		AiProfile.studentenhuis_potje2(),
		AiProfile.studentenhuis_potje3_table(),
		AiProfile.huisoudste(),
	]
	for profile in profiles:
		var game := ToepenGame.new()
		game.setup_controlled_round(_swap_hands(), 1)
		var bot := BaselineAI.new(profile)
		var chosen := bot.choose_card(game, 1)
		var legal := game.legal_cards(1)
		var ok := false
		for card in legal:
			if card.equals(chosen):
				ok = true
		_expect(ok, "%s chooses a legal card" % profile.label)
		var view := PublicView.from_game(game, 1)
		_expect(not view.contains_hidden_card_from(game), "%s has no hidden opponent card access" % profile.label)


func _test_boss_profile_imperfect() -> void:
	var boss := AiProfile.huisoudste()
	_expect(boss.is_boss, "Huisoudste is the boss profile")
	_expect(boss.error_rate > 0.0, "boss profile remains imperfect")
	_expect(boss.knock_scale > AiProfile.studentenhuis_potje1().knock_scale, "boss knocks more confidently than potje 1")
	_expect(boss.knock_scale > AiProfile.studentenhuis_potje2().knock_scale, "boss knocks more confidently than potje 2")
	_expect(boss.error_rate < AiProfile.studentenhuis_potje1().error_rate, "boss makes fewer mistakes than potje 1")
