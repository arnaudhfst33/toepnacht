class_name Economy
extends RefCounted

const ROUND_WIN := 1
const HUMAN_KNOCK_BONUS := 1
const POTJE_WIN := 3
const TOEP_BONUS := 3
const BOSS_WIN := 5


func grant_once(run: CampaignState, key: String, amount: int) -> int:
	if amount <= 0:
		return 0
	if run.rewarded_keys.has(key):
		return 0
	run.rewarded_keys[key] = true
	run.beer_caps += amount
	return amount


func grant_round_win(run: CampaignState, game: ToepenGame) -> int:
	if game.last_round_winner_id != ToepenGame.HUMAN_PLAYER_ID:
		return 0
	var key := "round:%d:%d:%d" % [run.location, run.potje, game.round_serial]
	var total := grant_once(run, key, ROUND_WIN)
	if game.human_knocked_this_round:
		total += grant_once(run, key + ":knock", HUMAN_KNOCK_BONUS)
	return total


func grant_toep(run: CampaignState, game: ToepenGame) -> int:
	if game.last_toep_declarer_id != ToepenGame.HUMAN_PLAYER_ID:
		return 0
	var key := "toep:%d:%d:%d" % [run.location, run.potje, game.last_toep_event_id]
	return grant_once(run, key, TOEP_BONUS)


func grant_potje_win(run: CampaignState, is_boss: bool) -> int:
	var key := "potje:%d:%d" % [run.location, run.potje]
	var total := grant_once(run, key, POTJE_WIN)
	if is_boss:
		total += grant_once(run, key + ":boss", BOSS_WIN)
	return total
