class_name EndToEndTests
extends RefCounted

## Long-running journeys that cross subsystem boundaries. These tests deliberately
## use the same TableSession entry points as the playable table, so an AI turn
## that stops advancing is reported instead of being hidden by unit tests.

const MAX_ACTIONS_PER_POT := 6000

var _failures: int = 0
var _passed: int = 0


func run_all() -> int:
	_failures = 0
	_passed = 0
	_test_every_campaign_table_finishes_without_ai_stall()
	_test_complete_twelve_pot_campaign_with_shop_and_resume()
	print("")
	print("End-to-end tests: %d passed, %d failed" % [_passed, _failures])
	return _failures


func _expect(condition: bool, name: String) -> void:
	if condition:
		_passed += 1
		print("PASS  %s" % name)
	else:
		_failures += 1
		print("FAIL  %s" % name)


func _mem_flow(seed: int = 77) -> CampaignFlow:
	var save := SaveGame.new()
	save.memory_only = true
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	return CampaignFlow.new(save, rng)


func _fresh_finished_game_with_human_win() -> ToepenGame:
	var game := ToepenGame.new()
	game.start_pot()
	game.apply_penalty(1, ToepenGame.ELIMINATION_POINTS)
	game.apply_penalty(2, ToepenGame.ELIMINATION_POINTS)
	game.apply_penalty(3, ToepenGame.ELIMINATION_POINTS)
	return game


func _test_every_campaign_table_finishes_without_ai_stall() -> void:
	for location in range(LocationId.COUNT):
		for potje in range(1, 4):
			var result := _autoplay_table(location, potje, 9000 + location * 100 + potje)
			var label := "%s potje %d" % [LocationId.display_name(location), potje]
			_expect(bool(result.get("finished", false)), "%s reaches GAME_END without a stuck bot" % label)
			_expect(int(result.get("rounds", 0)) >= 1, "%s completes at least one round" % label)
			_expect(int(result.get("winner", -1)) in range(ToepenGame.PLAYER_COUNT), "%s has a valid pot winner" % label)


func _autoplay_table(location: int, potje: int, seed: int) -> Dictionary:
	var flow := _mem_flow(seed)
	flow.campaign.highest_unlocked_location = LocationId.SOCIETEIT
	flow.start_new_run(location)
	flow.campaign.potje = potje
	var session := TableSession.new()
	session.bind_campaign(flow)
	session.start_campaign_pot()
	# The first deal is intentionally left intact. This seed drives every later
	# AI decision and shuffle, giving each table a stable regression journey.
	session.game.rng.seed = seed
	var actions := 0
	var rounds := 0
	var last_round_serial := session.game.round_serial
	while actions < MAX_ACTIONS_PER_POT:
		actions += 1
		if session.game.round_serial != last_round_serial:
			last_round_serial = session.game.round_serial
		if session.game.state == ToepenGame.State.GAME_END:
			return {
				"finished": true,
				"winner": session.game.pot_winner_id,
				"rounds": session.game.round_serial,
				"actions": actions,
			}
		if session.game.state == ToepenGame.State.ROUND_END:
			rounds += 1
			session.next_round()
			continue
		if session.pending_wasdag_choice:
			session.skip_wasdag()
			continue
		if not session.waiting_for_human():
			# A non-human state after resolve_ai means its 500-step safety guard
			# expired without progressing the table.
			return {"finished": false, "winner": -1, "rounds": rounds, "actions": actions}
		match session.game.state:
			ToepenGame.State.PRE_ROUND_SPECIALS:
				if not session.human_skip_specials():
					return {"finished": false, "winner": -1, "rounds": rounds, "actions": actions}
			ToepenGame.State.VUILE_WAS_CHALLENGE:
				if not session.human_decline_challenge():
					return {"finished": false, "winner": -1, "rounds": rounds, "actions": actions}
			ToepenGame.State.KNOCK_DECISIONS:
				if not session.human_mee():
					return {"finished": false, "winner": -1, "rounds": rounds, "actions": actions}
			ToepenGame.State.NORMAL_PLAY:
				var legal := session.game.legal_cards(ToepenGame.HUMAN_PLAYER_ID)
				if legal.is_empty() or not session.human_play(legal[0]):
					return {"finished": false, "winner": -1, "rounds": rounds, "actions": actions}
			_:
				return {"finished": false, "winner": -1, "rounds": rounds, "actions": actions}
	return {"finished": false, "winner": -1, "rounds": rounds, "actions": actions}


func _test_complete_twelve_pot_campaign_with_shop_and_resume() -> void:
	var flow := _mem_flow(4242)
	flow.start_new_run(LocationId.STUDENTENHUIS)
	var pots_completed := 0
	var shops_opened := 0
	for location in range(LocationId.COUNT):
		if location > LocationId.STUDENTENHUIS:
			flow.start_new_run(location)
		for potje in range(1, 4):
			_expect(flow.campaign.location == location and flow.campaign.potje == potje,
				"campaign enters %s potje %d" % [LocationId.display_name(location), potje])
			var result := flow.resolve_pot_end(_fresh_finished_game_with_human_win())
			pots_completed += 1
			if potje < 3:
				shops_opened += 1
				_expect(result == CampaignFlow.AfterPot.SHOP, "shop opens after non-boss win %d" % pots_completed)
				_expect(flow.campaign.shop != null and flow.campaign.shop.offerings.size() == 3,
					"shop %d contains three explained items" % shops_opened)
				for id in flow.campaign.shop.offerings:
					_expect(PowerUpCatalog.description(str(id)).length() >= 20,
						"%s has a readable shop description" % str(id))
				# Recreate the flow from the same save to exercise DOORGAAN at each shop.
				var resumed := CampaignFlow.new(flow.save, flow.rng)
				resumed.load_or_new()
				flow = resumed
				_expect(flow.campaign.shop != null and flow.campaign.shop.active,
					"continue restores shop %d" % shops_opened)
				flow.leave_shop()
			else:
				var expected := CampaignFlow.AfterPot.CAMPAIGN_COMPLETE if location == LocationId.SOCIETEIT else CampaignFlow.AfterPot.LOCATION_COMPLETE
				_expect(result == expected, "%s boss gives the correct completion result" % LocationId.display_name(location))
				_expect(flow.campaign.is_location_completed(location), "%s remains completed" % LocationId.display_name(location))
	_expect(pots_completed == 12, "the journey completes all 12 campaign pots")
	_expect(shops_opened == 8, "the journey visits all 8 campaign shops")
	_expect(flow.campaign.campaign_complete, "the final Praeses win completes the campaign")
	_expect(not flow.campaign.run_active, "no stale run remains after campaign completion")
	var final_state := flow.save.load_state()
	_expect(final_state.campaign_complete, "campaign completion survives save and load")
	_expect(final_state.completed_locations.size() == LocationId.COUNT, "all four locations remain completed")
