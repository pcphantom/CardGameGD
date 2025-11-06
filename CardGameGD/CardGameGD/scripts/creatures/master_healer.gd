extends BaseCreature
class_name MasterHealer

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func start_of_turn_check() -> void:
	# Master Healer heals owner 3 HP at start of turn
	if owner != null and owner.has_method("increment_life"):
		if game != null:
			owner.increment_life(3, game)

	# Heal all friendly creatures 3 HP
	var owner_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		owner_cards = owner.get_slot_cards()

	for index in range(6):
		if index >= owner_cards.size():
			continue

		var ci = owner_cards[index]
		if ci == null:
			continue

		if ci.has_method("increment_life"):
			if game != null:
				ci.increment_life(3, game)
