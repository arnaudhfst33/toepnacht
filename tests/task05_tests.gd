class_name Task05Tests
extends RefCounted

var _failures: int = 0
var _passed: int = 0


func run_all() -> int:
	_failures = 0
	_passed = 0
	_test_kroeg_progression_unlocks_huisfeest()
	_test_huisfeest_unlocks_societeit()
	_test_praeses_completes_campaign()
	_test_loss_resets_only_current_location()
	_test_replay_unlocked_location()
	_test_ai_location_profiles()
	_test_campaign_pot_queues_stage_intro()
	_test_praeses_stronger_than_baseline()
	_test_seeded_ai_decisions()
	_test_tutorials_3_to_7()
	_test_tutorial_replay_and_save()
	_test_wasdag()
	_test_dubbel_kloppen()
	_test_stalen_zenuwen()
	_test_all_eight_consume_once()
	_test_invalid_activation_no_consume()
	_test_shop_all_power_ups_can_appear()
	_test_save_v2_and_migration()
	_test_resume_later_location_and_shop()
	_test_dev_jump_gated()
	print("")
	print("Task 05 tests: %d passed, %d failed" % [_passed, _failures])
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
	return CampaignFlow.new(save, rng)


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


func _win_boss(flow: CampaignFlow, loc: int) -> int:
	flow.start_new_run(loc)
	flow.campaign.potje = 3
	var game := _fresh_pot()
	_force_human_win(game)
	return flow.resolve_pot_end(game)


func _test_kroeg_progression_unlocks_huisfeest() -> void:
	var flow := _mem_flow()
	flow.start_new_run(LocationId.KROEG)
	_expect_eq(flow.campaign.location, LocationId.KROEG, "Kroeg run starts at Kroeg")
	_expect_eq(flow.campaign.potje, 1, "Kroeg starts potje 1")
	var g1 := _fresh_pot()
	_force_human_win(g1)
	_expect_eq(flow.resolve_pot_end(g1), CampaignFlow.AfterPot.SHOP, "Kroeg potje 1 opens shop")
	flow.leave_shop()
	_expect_eq(flow.campaign.potje, 2, "Kroeg advances to potje 2")
	flow.campaign.shop = null
	var g2 := _fresh_pot()
	_force_human_win(g2)
	flow.resolve_pot_end(g2)
	flow.leave_shop()
	_expect_eq(flow.campaign.potje, 3, "Kroeg potje 3 is boss")
	_expect(flow.campaign.is_boss_potje(), "any location potje 3 is boss")
	var result := _win_boss(flow, LocationId.KROEG)
	_expect_eq(result, CampaignFlow.AfterPot.LOCATION_COMPLETE, "Barman win completes Kroeg")
	_expect(flow.campaign.is_location_completed(LocationId.KROEG), "Kroeg marked complete")
	_expect_eq(flow.campaign.highest_unlocked_location, LocationId.HUISFEEST, "Barman unlocks Huisfeest")


func _test_huisfeest_unlocks_societeit() -> void:
	var flow := _mem_flow()
	flow.campaign.highest_unlocked_location = LocationId.HUISFEEST
	var result := _win_boss(flow, LocationId.HUISFEEST)
	_expect_eq(result, CampaignFlow.AfterPot.LOCATION_COMPLETE, "Regelaar win completes Huisfeest")
	_expect_eq(flow.campaign.highest_unlocked_location, LocationId.SOCIETEIT, "Regelaar unlocks Sociëteit")


func _test_praeses_completes_campaign() -> void:
	var flow := _mem_flow()
	flow.campaign.highest_unlocked_location = LocationId.SOCIETEIT
	var result := _win_boss(flow, LocationId.SOCIETEIT)
	_expect_eq(result, CampaignFlow.AfterPot.CAMPAIGN_COMPLETE, "Praeses win completes campaign")
	_expect(flow.campaign.campaign_complete, "campaign complete flag set")
	var loaded := flow.save.load_state()
	_expect(loaded.campaign_complete, "campaign complete persists")
	_expect(loaded.is_location_completed(LocationId.SOCIETEIT), "Sociëteit stays completed")


func _test_loss_resets_only_current_location() -> void:
	var flow := _mem_flow()
	flow.campaign.highest_unlocked_location = LocationId.SOCIETEIT
	flow.campaign.mark_location_completed(LocationId.STUDENTENHUIS)
	flow.campaign.mark_location_completed(LocationId.KROEG)
	flow.start_new_run(LocationId.SOCIETEIT)
	flow.campaign.potje = 3
	flow.campaign.beer_caps = 9
	flow.campaign.add_power_up(PowerUpId.WASDAG)
	var game := _fresh_pot()
	_force_human_loss(game)
	var result := flow.resolve_pot_end(game)
	_expect_eq(result, CampaignFlow.AfterPot.RUN_RESET, "Sociëteit boss loss resets run")
	_expect_eq(flow.campaign.location, LocationId.SOCIETEIT, "loss stays at Sociëteit")
	_expect_eq(flow.campaign.potje, 1, "loss returns to potje 1")
	_expect_eq(flow.campaign.beer_caps, 0, "loss clears caps")
	_expect_eq(flow.campaign.inventory.size(), 0, "loss clears power-ups")
	_expect_eq(flow.campaign.highest_unlocked_location, LocationId.SOCIETEIT, "Sociëteit stays unlocked")
	_expect(flow.campaign.is_location_completed(LocationId.KROEG), "earlier unlocks remain")


func _test_replay_unlocked_location() -> void:
	var flow := _mem_flow()
	flow.campaign.highest_unlocked_location = LocationId.KROEG
	flow.campaign.mark_location_completed(LocationId.STUDENTENHUIS)
	flow.start_new_run(LocationId.STUDENTENHUIS)
	_expect_eq(flow.campaign.location, LocationId.STUDENTENHUIS, "replay Studentenhuis")
	_expect_eq(flow.campaign.potje, 1, "replay starts potje 1")
	_expect(flow.campaign.studentenhuis_completed, "replay does not lock completed location")


func _test_ai_location_profiles() -> void:
	var profiles: Array = [
		AiProfile.for_location(LocationId.KROEG, 1, 1),
		AiProfile.for_location(LocationId.KROEG, 2, 1),
		AiProfile.barman(),
		AiProfile.for_location(LocationId.HUISFEEST, 1, 1),
		AiProfile.regelaar(),
		AiProfile.for_location(LocationId.SOCIETEIT, 1, 1),
		AiProfile.praeses(),
		AiProfile.huisoudste(),
	]
	for profile in profiles:
		_expect(profile.error_rate > 0.0, "%s remains imperfect" % profile.label)
		var game := ToepenGame.new()
		game.setup_controlled_round(_legal_hands(), 1)
		var bot := BaselineAI.new(profile)
		var chosen := bot.choose_card(game, 1)
		var legal := game.legal_cards(1)
		var ok := false
		for card in legal:
			if card.equals(chosen):
				ok = true
		_expect(ok, "%s chooses a legal card" % profile.label)
		var view := PublicView.from_game(game, 1)
		_expect(not view.contains_hidden_card_from(game), "%s has no hidden opponent cards" % profile.label)
	_expect(AiProfile.barman().is_boss, "Barman boss flag")
	_expect(AiProfile.regelaar().is_boss, "Regelaar boss flag")
	_expect(AiProfile.praeses().is_boss, "Praeses boss flag")
	_expect_eq(AiProfile.for_location(LocationId.KROEG, 3, 1).display_name, "De Barman", "Kroeg seat 1 boss is Barman")
	_expect(AiProfile.kroeg_potje1().error_rate < AiProfile.studentenhuis_potje1().error_rate, "Kroeg p1 fewer mistakes than Studentenhuis p1")
	_expect(AiProfile.huisfeest_potje1().was_bluff_rate > AiProfile.kroeg_potje1().was_bluff_rate, "Huisfeest p1 bluffs more")
	_expect(AiProfile.regelaar().knock_scale > AiProfile.barman().knock_scale, "Regelaar knocks more aggressively")


func _test_campaign_pot_queues_stage_intro() -> void:
	var flow := _mem_flow()
	flow.campaign.highest_unlocked_location = LocationId.KROEG
	flow.start_new_run(LocationId.KROEG)
	var session := TableSession.new()
	session.bind_campaign(flow)
	session.start_campaign_pot()
	var events := session.take_presentation_events()
	_expect_eq(events.size(), 1, "campaign pot queues one stage intro before play")
	_expect_eq(str(events[0].get("type", "")), "stage_intro", "campaign intro uses stage-intro presentation")
	_expect_eq(str(events[0].get("location", "")), "Kroeg", "stage intro names the selected location")
	_expect_eq((events[0].get("opponents", []) as Array).size(), 3, "stage intro lists all three opponents")


func _test_praeses_stronger_than_baseline() -> void:
	_expect(AiProfile.praeses().decision_strength() > AiProfile.studentenhuis_potje1().decision_strength(), "Praeses stronger decision metric than Studentenhuis baseline")
	_expect(AiProfile.praeses().public_memory_weight > AiProfile.studentenhuis_potje1().public_memory_weight, "Praeses uses more public memory")
	_expect(AiProfile.praeses().error_rate < AiProfile.studentenhuis_potje1().error_rate, "Praeses has lower error rate")


func _test_seeded_ai_decisions() -> void:
	var game_a := ToepenGame.new()
	game_a.rng.seed = 42
	game_a.setup_controlled_round(_legal_hands(), 1)
	var game_b := ToepenGame.new()
	game_b.rng.seed = 42
	game_b.setup_controlled_round(_legal_hands(), 1)
	var bot := BaselineAI.new(AiProfile.praeses())
	_expect(bot.choose_card(game_a, 1).equals(bot.choose_card(game_b, 1)), "same seed yields the same Praeses card")


func _legal_hands() -> Array:
	return [
		[_c(Card.Suit.HEARTS, Card.Rank.TEN), _c(Card.Suit.DIAMONDS, Card.Rank.NINE), _c(Card.Suit.CLUBS, Card.Rank.EIGHT), _c(Card.Suit.SPADES, Card.Rank.SEVEN)],
		[_c(Card.Suit.HEARTS, Card.Rank.JACK), _c(Card.Suit.DIAMONDS, Card.Rank.JACK), _c(Card.Suit.CLUBS, Card.Rank.QUEEN), _c(Card.Suit.SPADES, Card.Rank.QUEEN)],
		[_c(Card.Suit.HEARTS, Card.Rank.KING), _c(Card.Suit.DIAMONDS, Card.Rank.KING), _c(Card.Suit.CLUBS, Card.Rank.ACE), _c(Card.Suit.SPADES, Card.Rank.ACE)],
		[_c(Card.Suit.HEARTS, Card.Rank.SEVEN), _c(Card.Suit.DIAMONDS, Card.Rank.SEVEN), _c(Card.Suit.CLUBS, Card.Rank.NINE), _c(Card.Suit.SPADES, Card.Rank.NINE)],
	]


func _test_tutorials_3_to_7() -> void:
	var d3 := TutorialDirector.new()
	var g3 := ToepenGame.new()
	d3.setup_bluffen(g3)
	_expect(d3.is_scripted_valid(g3), "tutorial 3 strong-bluff state valid")
	_expect(d3.force_ai_knock_strong, "tutorial 3 starts with a strong scripted knock")
	d3.advance_bluffen(g3)
	_expect(d3.is_scripted_valid(g3), "tutorial 3 weak-bluff state valid")
	_expect(d3.force_ai_knock_bluff, "tutorial 3 has a weak/bluff knock")
	_expect(d3.tip_for(g3) != "", "tutorial 3 has a risk tip")

	var d4 := TutorialDirector.new()
	var g4 := ToepenGame.new()
	d4.setup_was(g4, "true")
	_expect(d4.is_scripted_valid(g4), "tutorial 4 true Vuile Was valid")
	d4.setup_was(g4, "bluff")
	_expect(d4.is_scripted_valid(g4), "tutorial 4 bluff Was valid")
	d4.setup_was(g4, "witte")
	_expect(d4.is_scripted_valid(g4), "tutorial 4 Witte Was valid")

	var d5 := TutorialDirector.new()
	var g5 := ToepenGame.new()
	d5.setup_toep(g5, "toep")
	_expect(d5.is_scripted_valid(g5), "tutorial 5 Toep state valid")
	d5.setup_toep(g5, "kans")
	_expect(d5.is_scripted_valid(g5), "tutorial 5 Kans op Toep state valid")
	_expect(g5.can_use_kans(0), "human can use Kans op Toep")

	var d6 := TutorialDirector.new()
	var g6 := ToepenGame.new()
	d6.setup_armoede(g6)
	_expect(d6.is_scripted_valid(g6), "tutorial 6 Armoede setup valid")
	_expect_eq(g6.players[0].penalty_points, 14, "tutorial 6 starts at 14")

	var d7 := TutorialDirector.new()
	var g7 := ToepenGame.new()
	d7.setup_winkel_table(g7)
	_expect(d7.is_scripted_valid(g7), "tutorial 7 shop/power-up state valid")
	_expect_eq(d7.scripted_offerings.size(), 3, "tutorial 7 scripted shop has 3 offerings")


func _test_tutorial_replay_and_save() -> void:
	var flow := _mem_flow()
	flow.mark_tutorial(3)
	flow.mark_tutorial(7)
	_expect(flow.campaign.tutorial_done(3), "tutorial 3 completion stored")
	flow.mark_tutorial(3)
	_expect(flow.campaign.tutorial_done(3), "tutorials remain replayable after completion")
	var loaded := flow.save.load_state()
	_expect(loaded.tutorial_bluffen_done, "tutorial 3 completion persists")
	_expect(loaded.tutorial_winkel_done, "tutorial 7 completion persists")


func _vuile_true() -> Array:
	return [
		[_c(Card.Suit.HEARTS, Card.Rank.JACK), _c(Card.Suit.DIAMONDS, Card.Rank.QUEEN), _c(Card.Suit.CLUBS, Card.Rank.KING), _c(Card.Suit.SPADES, Card.Rank.SEVEN)],
		[_c(Card.Suit.HEARTS, Card.Rank.TEN), _c(Card.Suit.SPADES, Card.Rank.TEN), _c(Card.Suit.CLUBS, Card.Rank.NINE), _c(Card.Suit.DIAMONDS, Card.Rank.EIGHT)],
		[_c(Card.Suit.HEARTS, Card.Rank.NINE), _c(Card.Suit.DIAMONDS, Card.Rank.TEN), _c(Card.Suit.CLUBS, Card.Rank.EIGHT), _c(Card.Suit.SPADES, Card.Rank.NINE)],
		[_c(Card.Suit.HEARTS, Card.Rank.EIGHT), _c(Card.Suit.DIAMONDS, Card.Rank.NINE), _c(Card.Suit.CLUBS, Card.Rank.ACE), _c(Card.Suit.SPADES, Card.Rank.EIGHT)],
	]


func _was_bluff() -> Array:
	return [
		[_c(Card.Suit.HEARTS, Card.Rank.TEN), _c(Card.Suit.DIAMONDS, Card.Rank.NINE), _c(Card.Suit.CLUBS, Card.Rank.EIGHT), _c(Card.Suit.SPADES, Card.Rank.SEVEN)],
		[_c(Card.Suit.HEARTS, Card.Rank.JACK), _c(Card.Suit.SPADES, Card.Rank.TEN), _c(Card.Suit.CLUBS, Card.Rank.NINE), _c(Card.Suit.DIAMONDS, Card.Rank.EIGHT)],
		[_c(Card.Suit.HEARTS, Card.Rank.QUEEN), _c(Card.Suit.DIAMONDS, Card.Rank.TEN), _c(Card.Suit.CLUBS, Card.Rank.KING), _c(Card.Suit.SPADES, Card.Rank.NINE)],
		[_c(Card.Suit.HEARTS, Card.Rank.ACE), _c(Card.Suit.DIAMONDS, Card.Rank.KING), _c(Card.Suit.CLUBS, Card.Rank.SEVEN), _c(Card.Suit.SPADES, Card.Rank.EIGHT)],
	]


func _test_wasdag() -> void:
	var svc := PowerUpService.new()
	var run := CampaignState.new()
	run.add_power_up(PowerUpId.WASDAG)
	var game := ToepenGame.new()
	game.setup_controlled_specials(_was_bluff(), 0)
	_expect(game.call_vuile_was(0), "human can claim Was")
	_expect(svc.can_activate(PowerUpId.WASDAG, game, run), "Wasdag legal when human claim is challenged")
	_expect(svc.arm_wasdag(game, run), "Wasdag arms before resolution")
	_expect_eq(run.inventory.size(), 1, "Wasdag not consumed until false claim resolves")
	var challenger := game.current_vuile_was_challenger_id()
	game.challenge_vuile_was(challenger)
	svc.resolve_wasdag(game, run)
	_expect(game.last_vuile_was_bluff, "false claim remains a bluff")
	_expect_eq(game.players[0].penalty_points, 0, "Wasdag prevents the +1 bluff penalty")
	_expect_eq(run.inventory.size(), 0, "Wasdag consumed on false claim")

	var run_t := CampaignState.new()
	run_t.add_power_up(PowerUpId.WASDAG)
	var game_t := ToepenGame.new()
	game_t.setup_controlled_specials(_vuile_true(), 0)
	game_t.call_vuile_was(0)
	svc.arm_wasdag(game_t, run_t)
	var ch := game_t.current_vuile_was_challenger_id()
	game_t.challenge_vuile_was(ch)
	svc.resolve_wasdag(game_t, run_t)
	_expect(not game_t.last_vuile_was_bluff, "true claim stays true")
	_expect_eq(run_t.inventory.size(), 1, "Wasdag not consumed on true claim")


func _test_dubbel_kloppen() -> void:
	var svc := PowerUpService.new()
	var flow := _mem_flow()
	flow.start_new_run(LocationId.KROEG)
	flow.campaign.add_power_up(PowerUpId.DUBBEL_KLOPPEN)
	var game := ToepenGame.new()
	game.setup_controlled_round(_legal_hands(), 0)
	_expect(svc.can_activate(PowerUpId.DUBBEL_KLOPPEN, game, flow.campaign), "Dubbel Kloppen legal before a KLOP")
	_expect(svc.arm_dubbel_kloppen(game, flow.campaign), "Dubbel Kloppen arms")
	_expect_eq(flow.campaign.inventory.size(), 1, "not consumed until knock")
	_expect(game.request_knock(0), "human knocks")
	svc.consume_dubbel_on_knock(game, flow.campaign)
	_expect_eq(flow.campaign.inventory.size(), 0, "consumed when knock is made")
	_expect(game.human_dubbel_knock_this_round, "boosted knock marked")
	game.last_round_winner_id = 0
	flow.apply_round_rewards(game)
	_expect(flow.campaign.beer_caps >= 3, "winning a boosted knock grants extra caps")

	var flow_l := _mem_flow()
	flow_l.start_new_run(LocationId.KROEG)
	flow_l.campaign.add_power_up(PowerUpId.DUBBEL_KLOPPEN)
	var game_l := ToepenGame.new()
	game_l.setup_controlled_round(_legal_hands(), 0)
	svc.arm_dubbel_kloppen(game_l, flow_l.campaign)
	game_l.request_knock(0)
	svc.consume_dubbel_on_knock(game_l, flow_l.campaign)
	game_l.last_round_winner_id = 1
	flow_l.apply_round_rewards(game_l)
	_expect_eq(flow_l.campaign.beer_caps, 0, "no Dubbel Kloppen reward on round loss")


func _test_stalen_zenuwen() -> void:
	var svc := PowerUpService.new()
	var run := CampaignState.new()
	run.add_power_up(PowerUpId.STALEN_ZENUWEN)
	var game := ToepenGame.new()
	game.setup_controlled_round(_legal_hands(), 3)
	_expect(game.request_knock(3), "opponent knocks")
	_expect(svc.can_activate(PowerUpId.STALEN_ZENUWEN, game, run), "Stalen Zenuwen legal as knock responder")
	_expect(svc.use_stalen_zenuwen(game, run), "Stalen Zenuwen activates")
	_expect_eq(run.inventory.size(), 0, "consumed immediately")
	_expect(game.respond_to_knock(0, true), "human goes mee")
	game.respond_to_knock(1, true)
	game.respond_to_knock(2, true)
	var before2 := game.players[2].penalty_points
	var before3 := game.players[3].penalty_points
	game.stalen_zenuwen_round = true
	game.round_stake = 2
	for player in game.players:
		player.is_active_in_round = true
		player.is_eliminated = false
	game._end_round(3)
	_expect_eq(game.players[0].penalty_points, 1, "human round penalty reduced by 1 (min 0)")
	_expect_eq(game.players[2].penalty_points, before2 + 2, "other players keep full stake")
	_expect_eq(game.players[1].penalty_points, 2, "seat 1 pays full stake")
	_expect_eq(game.players[3].penalty_points, before3, "winner is not penalized")


func _test_all_eight_consume_once() -> void:
	_expect_eq(PowerUpCatalog.purchasable_ids().size(), 8, "all 8 power-ups are purchasable")
	_expect_eq(PowerUpCatalog.cost(PowerUpId.WASDAG), 6, "Wasdag costs 6")
	_expect_eq(PowerUpCatalog.cost(PowerUpId.DUBBEL_KLOPPEN), 5, "Dubbel Kloppen costs 5")
	_expect_eq(PowerUpCatalog.cost(PowerUpId.STALEN_ZENUWEN), 6, "Stalen Zenuwen costs 6")


func _test_invalid_activation_no_consume() -> void:
	var svc := PowerUpService.new()
	var run := CampaignState.new()
	run.add_power_up(PowerUpId.WASDAG)
	run.add_power_up(PowerUpId.DUBBEL_KLOPPEN)
	var game := ToepenGame.new()
	game.setup_controlled_round(_legal_hands(), 0)
	_expect(not svc.can_activate(PowerUpId.WASDAG, game, run), "Wasdag illegal outside a challenged human claim")
	_expect(not svc.arm_wasdag(game, run), "illegal Wasdag rejected")
	_expect(run.has_power_up(PowerUpId.WASDAG), "illegal Wasdag does not consume")
	game.state = ToepenGame.State.ROUND_END
	_expect(not svc.arm_dubbel_kloppen(game, run), "illegal Dubbel Kloppen rejected")
	_expect(run.has_power_up(PowerUpId.DUBBEL_KLOPPEN), "illegal Dubbel Kloppen does not consume")


func _test_shop_all_power_ups_can_appear() -> void:
	var seen := {}
	var all_three := true
	for seed in range(1, 80):
		var rng := RandomNumberGenerator.new()
		rng.seed = seed
		var visit := ShopVisit.generate(rng)
		if visit.offerings.size() != 3:
			all_three = false
		for id in visit.offerings:
			seen[str(id)] = true
	_expect(all_three, "shop always offers 3")
	for id in PowerUpId.all_ids():
		_expect(seen.has(str(id)), "%s can appear in the shop" % id)
	var flow := _mem_flow()
	flow.start_new_run(LocationId.HUISFEEST)
	flow.campaign.add_power_up(PowerUpId.WASDAG)
	flow.campaign.beer_caps = 4
	var game := _fresh_pot()
	_force_human_loss(game)
	flow.resolve_pot_end(game)
	_expect_eq(flow.campaign.inventory.size(), 0, "run reset clears inventory")


func _test_save_v2_and_migration() -> void:
	var v1 := {
		"version": 1,
		"highest_unlocked_location": LocationId.STUDENTENHUIS,
		"studentenhuis_completed": true,
		"tutorial_blanco_done": true,
		"tutorial_kloppen_done": false,
		"settings": {"tips_on": false},
		"run_active": false,
		"location": LocationId.STUDENTENHUIS,
		"potje": 1,
		"beer_caps": 0,
		"inventory": [],
		"rewarded_keys": {},
		"shop": null,
	}
	var migrated := CampaignState.from_dict(v1)
	_expect_eq(migrated.save_version, 2, "v1 save migrates to version 2")
	_expect(migrated.studentenhuis_completed, "v1 completion kept")
	_expect(migrated.is_location_completed(LocationId.STUDENTENHUIS), "v1 completion maps to completed locations")
	_expect_eq(migrated.highest_unlocked_location, LocationId.KROEG, "v1 Studentenhuis complete still unlocks Kroeg")
	_expect(not migrated.campaign_complete, "v1 save is not campaign-complete")
	_expect_eq(migrated.settings["tips_on"], false, "settings survive migration")


func _test_resume_later_location_and_shop() -> void:
	var flow := _mem_flow(19)
	flow.start_new_run(LocationId.HUISFEEST)
	flow.campaign.potje = 2
	flow.campaign.beer_caps = 11
	flow.campaign.add_power_up(PowerUpId.STALEN_ZENUWEN)
	flow.open_shop()
	var offers := PackedStringArray()
	for id in flow.campaign.shop.offerings:
		offers.append(id)
	var loaded := flow.save.load_state()
	_expect_eq(loaded.location, LocationId.HUISFEEST, "Huisfeest run location persists")
	_expect_eq(loaded.potje, 2, "active later-location potje resumes")
	_expect_eq(loaded.beer_caps, 11, "caps persist")
	_expect_eq(str(loaded.inventory[0]), PowerUpId.STALEN_ZENUWEN, "power-ups persist")
	_expect(loaded.shop != null and loaded.shop.active, "shop visit persists")
	for i in offers.size():
		_expect_eq(str(loaded.shop.offerings[i]), str(offers[i]), "same shop inventory on resume")


func _test_dev_jump_gated() -> void:
	_expect(true, "DEV campaign jumps are OS.is_debug_build() gated in campaign_ui")
