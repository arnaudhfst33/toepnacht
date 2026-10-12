class_name BaselineAI
extends RefCounted

## Simple imperfect AI. Uses PublicView only — never hidden opponent cards.

var profile: AiProfile


func _init(p_profile: AiProfile = null) -> void:
	profile = p_profile if p_profile != null else AiProfile.baseline()


func decide(view: PublicView, rng: RandomNumberGenerator) -> Dictionary:
	if view.can_declare_toep and rng.randf() < 0.92:
		return {"type": "toep"}
	if view.can_use_kans and rng.randf() < 0.8:
		return {"type": "kans"}
	if view.can_call_vuile_was:
		if view.flags_vuile and rng.randf() < 0.7:
			return {"type": "vuile_was"}
		if (not view.flags_vuile) and rng.randf() < profile.was_bluff_rate:
			return {"type": "vuile_was"}
	if view.can_declare_witte_was:
		if view.flags_witte and rng.randf() < 0.85:
			return {"type": "witte_was"}
		if (not view.flags_witte) and rng.randf() < profile.was_bluff_rate:
			return {"type": "witte_was"}
	if view.can_challenge_vuile_was:
		if rng.randf() < profile.challenge_rate:
			return {"type": "challenge"}
		return {"type": "decline_challenge"}
	if view.can_skip_specials:
		return {"type": "skip_specials"}
	if view.can_knock and _want_knock(view, rng):
		return {"type": "knock"}
	if view.can_pass or (view.round_stake > 1 and view.can_pass == false and false):
		pass
	if view.can_pass and not _want_mee(view, rng):
		return {"type": "pas"}
	if view.legal_cards.size() > 0:
		return {"type": "play", "card": _choose_card(view, rng)}
	return {"type": "wait"}


func choose_card(game: ToepenGame, player_id: int) -> Card:
	var view := PublicView.from_game(game, player_id)
	return _choose_card(view, game.rng)


func should_knock(game: ToepenGame, player_id: int) -> bool:
	var view := PublicView.from_game(game, player_id)
	return view.can_knock and _want_knock(view, game.rng)


func choose_mee(game: ToepenGame, player_id: int) -> bool:
	var view := PublicView.from_game(game, player_id)
	if not view.can_pass:
		return true
	return _want_mee(view, game.rng)


func _want_knock(view: PublicView, rng: RandomNumberGenerator) -> bool:
	var scale := profile.knock_scale
	if view.round_stake >= 3:
		return rng.randf() < clampf(0.05 * scale, 0.0, 0.35)
	var tens := 0
	for card in view.own_hand:
		if card.rank == Card.Rank.TEN:
			tens += 1
	if tens >= 2:
		return rng.randf() < clampf(0.55 * scale, 0.0, 0.92)
	if tens == 1:
		return rng.randf() < clampf(0.22 * scale, 0.0, 0.75)
	return rng.randf() < clampf(0.08 * scale, 0.0, 0.45)


func _want_mee(view: PublicView, rng: RandomNumberGenerator) -> bool:
	if rng.randf() < profile.mee_pass_chaos:
		return rng.randf() < 0.5
	var high := 0
	for card in view.own_hand:
		if card.strength() >= int(Card.Rank.NINE):
			high += 1
	var public_tens := _public_rank_count(view, Card.Rank.TEN)
	var risk := 0.65
	if view.round_stake >= 3 and high == 0:
		risk = 0.22
	elif high >= 2:
		risk = 0.9
	if public_tens >= 2 and high < 2:
		risk -= 0.12 * profile.public_memory_weight
	return rng.randf() < clampf(risk, 0.08, 0.95)


func _choose_card(view: PublicView, rng: RandomNumberGenerator) -> Card:
	if view.legal_cards.is_empty():
		return null
	var preferred := _preferred_legal_card(view)
	if rng.randf() < profile.error_rate:
		return view.legal_cards[rng.randi_range(0, view.legal_cards.size() - 1)]
	return preferred


func _preferred_legal_card(view: PublicView) -> Card:
	var use_memory := profile.public_memory_weight >= 0.4
	if use_memory and view.trick_cards.size() > 0:
		var beating := _cheapest_winner(view)
		if beating != null:
			return beating
		return _lowest(view.legal_cards)
	var aggressive := profile.aggressive_card_rate >= 0.5
	if aggressive:
		return _highest(view.legal_cards)
	return _lowest(view.legal_cards)


func _cheapest_winner(view: PublicView) -> Card:
	if view.trick_cards.is_empty():
		return null
	var lead = view.trick_cards[0].suit
	var best_shown := 0
	for shown in view.trick_cards:
		if shown.suit == lead:
			best_shown = maxi(best_shown, shown.strength())
	var cheapest: Card = null
	for card in view.legal_cards:
		if card.suit == lead and card.strength() > best_shown:
			if cheapest == null or card.strength() < cheapest.strength():
				cheapest = card
	return cheapest


func _lowest(cards: Array[Card]) -> Card:
	var best: Card = cards[0]
	for card in cards:
		if card.strength() < best.strength():
			best = card
	return best


func _highest(cards: Array[Card]) -> Card:
	var best: Card = cards[0]
	for card in cards:
		if card.strength() > best.strength():
			best = card
	return best


func _public_rank_count(view: PublicView, rank: Card.Rank) -> int:
	var n := 0
	for key in view.public_played_keys:
		var parts := key.split("_")
		if parts.size() == 2 and int(parts[1]) == int(rank):
			n += 1
	return n
