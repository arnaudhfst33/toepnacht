class_name BaselineAI
extends RefCounted

## Simple imperfect AI. Uses PublicView only — never hidden opponent cards.


func decide(view: PublicView, rng: RandomNumberGenerator) -> Dictionary:
	if view.can_declare_toep and rng.randf() < 0.92:
		return {"type": "toep"}
	if view.can_use_kans and rng.randf() < 0.8:
		return {"type": "kans"}
	if view.can_call_vuile_was:
		if view.flags_vuile and rng.randf() < 0.7:
			return {"type": "vuile_was"}
		if (not view.flags_vuile) and rng.randf() < 0.04:
			return {"type": "vuile_was"}
	if view.can_declare_witte_was:
		if view.flags_witte and rng.randf() < 0.85:
			return {"type": "witte_was"}
		if (not view.flags_witte) and rng.randf() < 0.04:
			return {"type": "witte_was"}
	if view.can_challenge_vuile_was:
		if rng.randf() < 0.18:
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
	if view.round_stake >= 3:
		return rng.randf() < 0.05
	var tens := 0
	for card in view.own_hand:
		if card.rank == Card.Rank.TEN:
			tens += 1
	if tens >= 2:
		return rng.randf() < 0.55
	if tens == 1:
		return rng.randf() < 0.22
	return rng.randf() < 0.08


func _want_mee(view: PublicView, rng: RandomNumberGenerator) -> bool:
	if rng.randf() < 0.12:
		return rng.randf() < 0.5
	var high := 0
	for card in view.own_hand:
		if card.strength() >= int(Card.Rank.NINE):
			high += 1
	if view.round_stake >= 3 and high == 0:
		return rng.randf() < 0.25
	if high >= 2:
		return rng.randf() < 0.9
	return rng.randf() < 0.65


func _choose_card(view: PublicView, rng: RandomNumberGenerator) -> Card:
	if view.legal_cards.is_empty():
		return null
	var aggressive := rng.randf() < 0.45
	var best: Card = view.legal_cards[0]
	for card in view.legal_cards:
		if aggressive:
			if card.strength() > best.strength():
				best = card
		else:
			if card.strength() < best.strength():
				best = card
	if rng.randf() < 0.12:
		return view.legal_cards[rng.randi_range(0, view.legal_cards.size() - 1)]
	return best
