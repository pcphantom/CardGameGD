extends BaseCreature
class_name ThreeHeadedDemon

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

	# Three-headed demon attacks all opponent creatures except the one opposite
	var attack_value: int = 0
	if card != null:
		attack_value = card.get_attack()

	# Damage all opponent creatures except the one at the same slot index
	damage_all_except_current_index(attack_value, opponent)

	# If there's a creature in the opposite slot, also damage the opponent player
	var enemy_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		enemy_cards = opponent.get_slot_cards()

	if slot_index < enemy_cards.size() and enemy_cards[slot_index] != null:
		damage_opponent(attack_value)

func on_dying() -> void:
	super.on_dying()

	# When Three-headed Demon dies, it transforms into DemonApostate
	if owner != null and owner.has_method("get_slots"):
		var slots = owner.get_slots()
		if slots != null and slot_index < slots.size():
			add_creature("DemonApostate", slot_index, slots[slot_index])
