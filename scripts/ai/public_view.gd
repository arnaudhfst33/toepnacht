class_name PublicView
extends RefCounted

## Snapshot an actor may legally see. No hidden opponent hands.

var player_id: int = -1
var own_hand: Array[Card] = []
var legal_cards: Array[Card] = []
var penalty_points: PackedInt32Array = PackedInt32Array()
var active_in_round: PackedByteArray = PackedByteArray()
var eliminated: PackedByteArray = PackedByteArray()
var hand_counts: PackedInt32Array = PackedInt32Array()
var trick_player_ids: Array[int] = []
var trick_cards: Array[Card] = []
var round_stake: int = 1
var tricks_completed: int = 0
var can_knock: bool = false
var can_pass: bool = false
var must_respond_to_knock: bool = false
var can_declare_toep: bool = false
var can_use_kans: bool = false
var can_call_vuile_was: bool = false
var can_declare_witte_was: bool = false
var can_challenge_vuile_was: bool = false
var can_skip_specials: bool = false
var flags_toep: bool = false
var flags_kans: bool = false
var flags_vuile: bool = false
var flags_witte: bool = false
var own_armoede: bool = false
var public_played_keys: PackedStringArray = PackedStringArray()
var knock_initiator_id: int = -1
var was_caller_id: int = -1


static func from_game(game: ToepenGame, player_id: int) -> PublicView:
	var view := PublicView.new()
	view.player_id = player_id
	var self_player := game.players[player_id]
	for card in self_player.hand:
		view.own_hand.append(card)
	for card in game.legal_cards(player_id):
		view.legal_cards.append(card)
	for player in game.players:
		view.penalty_points.append(player.penalty_points)
		view.active_in_round.append(1 if player.is_active_in_round else 0)
		view.eliminated.append(1 if player.is_eliminated else 0)
		view.hand_counts.append(player.hand.size())
	if game.current_trick != null:
		for i in game.current_trick.play_count():
			view.trick_player_ids.append(game.current_trick.player_ids[i])
			view.trick_cards.append(game.current_trick.cards[i])
	view.round_stake = game.round_stake
	view.tricks_completed = game.tricks_completed
	view.can_knock = game.can_knock(player_id)
	view.can_pass = game.can_pass(player_id)
	view.must_respond_to_knock = game.current_knock_responder_id() == player_id
	view.can_declare_toep = game.can_declare_toep(player_id)
	view.can_use_kans = game.can_use_kans(player_id)
	view.can_call_vuile_was = game.can_call_vuile_was(player_id)
	view.can_declare_witte_was = game.can_declare_witte_was(player_id)
	view.can_challenge_vuile_was = game.current_vuile_was_challenger_id() == player_id
	view.can_skip_specials = game.current_specials_actor_id() == player_id
	var flags := game.detect_player_specials(player_id)
	view.flags_toep = flags.toep
	view.flags_kans = flags.kans_op_toep
	view.flags_vuile = flags.vuile_was
	view.flags_witte = flags.witte_was
	view.own_armoede = game.player_is_armoede(player_id)
	view.public_played_keys = game.public_played_keys.duplicate()
	view.knock_initiator_id = game.knock_initiator_id
	view.was_caller_id = game.vuile_was_caller_id
	return view


func contains_hidden_card_from(game: ToepenGame) -> bool:
	for player in game.players:
		if player.id == player_id:
			continue
		for hidden in player.hand:
			var in_own := false
			for own in own_hand:
				if own.equals(hidden):
					in_own = true
			var in_trick := false
			for shown in trick_cards:
				if shown.equals(hidden):
					in_trick = true
			if in_own or in_trick:
				continue
			for own in own_hand:
				if own.equals(hidden):
					return true
			for shown in trick_cards:
				if shown.equals(hidden):
					return true
	return false
