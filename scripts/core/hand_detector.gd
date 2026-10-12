class_name HandDetector
extends RefCounted

## Detection only. Interaction flows (claims, exchange, bluff resolution) come later.


static func analyze(hand: Array[Card]) -> SpecialHandFlags:
	var flags := SpecialHandFlags.new()
	if hand.size() != 4:
		return flags

	var rank_counts := {}
	var picture_count := 0
	var seven_count := 0
	for card in hand:
		rank_counts[card.rank] = int(rank_counts.get(card.rank, 0)) + 1
		if card.is_picture():
			picture_count += 1
		if card.is_seven():
			seven_count += 1

	for rank in rank_counts:
		var count: int = rank_counts[rank]
		if count == 4:
			flags.toep = true
		elif count == 3:
			flags.kans_op_toep = true

	flags.witte_was = picture_count == 4
	flags.vuile_was = picture_count == 3 and seven_count == 1
	return flags


static func is_armoede(penalty_points: int) -> bool:
	return penalty_points == 14


static func kans_off_card(hand: Array[Card]) -> Card:
	var rank_counts := {}
	for card in hand:
		rank_counts[card.rank] = int(rank_counts.get(card.rank, 0)) + 1
	var triple_rank: Variant = null
	for rank in rank_counts:
		if int(rank_counts[rank]) == 3:
			triple_rank = rank
			break
	if triple_rank == null:
		return null
	for card in hand:
		if card.rank != triple_rank:
			return card
	return null


static func kans_triple_rank(hand: Array[Card]) -> int:
	var rank_counts := {}
	for card in hand:
		rank_counts[card.rank] = int(rank_counts.get(card.rank, 0)) + 1
	for rank in rank_counts:
		if int(rank_counts[rank]) == 3:
			return int(rank)
	return -1

