class_name CardAdvisor
extends RefCounted

## Explainable beginner advice. It only uses the human hand and public table state.


static func hand_score(hand: Array[Card]) -> int:
	if hand.is_empty():
		return 0
	var rank_total := 0
	var high_cards := 0
	var suit_counts := {}
	for card in hand:
		rank_total += card.strength()
		if card.rank == Card.Rank.NINE or card.rank == Card.Rank.TEN:
			high_cards += 1
		suit_counts[card.suit] = int(suit_counts.get(card.suit, 0)) + 1
	var rank_part := float(rank_total) / float(hand.size() * int(Card.Rank.TEN)) * 78.0
	var control_bonus := high_cards * 6
	var suit_bonus := 0
	for count in suit_counts.values():
		if int(count) >= 2:
			suit_bonus += int(count) - 1
	return clampi(roundi(rank_part) + control_bonus + suit_bonus, 0, 100)


static func hand_label(hand: Array[Card]) -> String:
	var score := hand_score(hand)
	if score >= 76:
		return "zeer sterk"
	if score >= 58:
		return "sterk"
	if score >= 40:
		return "redelijk"
	return "zwak"


static func hand_summary(hand: Array[Card]) -> String:
	return "Hand: %s · %d/100" % [hand_label(hand), hand_score(hand)]


static func card_tooltip(card: Card, legal: bool) -> String:
	var role := "lage kaart"
	if card.rank == Card.Rank.TEN:
		role = "hoogste kaart"
	elif card.rank == Card.Rank.NINE:
		role = "zeer sterke kaart"
	elif card.rank == Card.Rank.EIGHT:
		role = "sterke kaart"
	elif card.rank == Card.Rank.SEVEN:
		role = "middelsterke kaart"
	var text := "%s is een %s." % [str(card), role]
	if not legal:
		text += " Je moet nu kleur bekennen."
	return text


static func turn_tip(game: ToepenGame, player_id: int = ToepenGame.HUMAN_PLAYER_ID) -> String:
	if game.state == ToepenGame.State.KNOCK_DECISIONS \
			and game.current_knock_responder_id() == player_id:
		return knock_tip(game, player_id)
	if game.state != ToepenGame.State.NORMAL_PLAY or game.current_actor_id != player_id:
		return ""
	var legal := game.legal_cards(player_id)
	if legal.is_empty():
		return ""
	var final_trick := game.tricks_completed == 3
	var suggested := _suggest_card(game, legal, final_trick)
	if final_trick:
		if _would_currently_win(game, suggested):
			return "Laatste slag: %s is je laagste kaart die nu kan winnen." % str(suggested)
		return (
			"Laatste slag: je kunt de tafel niet overnemen. Speel %s en beperk je verlies."
			% str(suggested)
		)
	if game.current_trick == null or game.current_trick.play_count() == 0:
		return "Voorstel: kom uit met %s en bewaar je hogere kaarten voor later." % str(suggested)
	if _would_currently_win(game, suggested):
		return "Voorstel: %s wint de slag nu met zo weinig mogelijk kracht." % str(suggested)
	return (
		"Voorstel: leg %s weg; je kunt deze slag met je geldige kaarten niet winnen."
		% str(suggested)
	)


static func recommended_card(
	game: ToepenGame,
	player_id: int = ToepenGame.HUMAN_PLAYER_ID,
) -> Card:
	if game.state != ToepenGame.State.NORMAL_PLAY or game.current_actor_id != player_id:
		return null
	var legal := game.legal_cards(player_id)
	if legal.is_empty():
		return null
	return _suggest_card(game, legal, game.tricks_completed == 3)


static func knock_tip(game: ToepenGame, player_id: int = ToepenGame.HUMAN_PLAYER_ID) -> String:
	var hand := game.players[player_id].hand
	var score := hand_score(hand)
	var remaining := maxi(0, ToepenGame.ELIMINATION_POINTS - game.players[player_id].penalty_points)
	if game.can_pass(player_id) and game.round_stake >= remaining:
		if score >= 65:
			return (
				"MEE is riskant maar logisch met een %s hand. Verlies schakelt je wel uit."
				% hand_label(hand)
			)
		return (
			"PAS geeft nu %d punten en schakelt je uit. MEE geeft nog een kans."
			% game.round_stake
		)
	if score >= 62:
		return (
			"Advies: MEE. Je hand is %s (%d/100); een volgende klop kan de inzet verhogen."
			% [hand_label(hand), score]
		)
	if score <= 35 and game.can_pass(player_id):
		return (
			"Advies: PAS is verdedigbaar. Je hand is %s; PAS zet het verlies vast op %d."
			% [hand_label(hand), game.round_stake]
		)
	return (
		"Twijfelgeval: MEE kan nul punten opleveren; PAS kost %d maar voorkomt overkloppen."
		% game.round_stake
	)


static func _suggest_card(game: ToepenGame, legal: Array[Card], final_trick: bool) -> Card:
	var ordered := legal.duplicate()
	ordered.sort_custom(func(a: Card, b: Card) -> bool: return a.strength() < b.strength())
	if game.current_trick == null or game.current_trick.play_count() == 0:
		return ordered[-1] if final_trick else ordered[0]
	for card in ordered:
		if _would_currently_win(game, card):
			return card
	return ordered[0]


static func _would_currently_win(game: ToepenGame, card: Card) -> bool:
	if game.current_trick == null or game.current_trick.play_count() == 0:
		return true
	if card.suit != game.current_trick.led_suit:
		return false
	var best := -1
	for played in game.current_trick.cards:
		if played.suit == game.current_trick.led_suit:
			best = maxi(best, played.strength())
	return card.strength() > best

