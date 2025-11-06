extends BaseCreature
class_name DemonQuartermaster

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

	# Boost demonic strength by 1 on summon
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.DEMONIC, 1)

func on_attack() -> void:
	super.on_attack()

func on_dying() -> void:
	super.on_dying()

	# When DemonQuartermaster dies, it transforms into EnragedQuartermaster
	if owner != null and owner.has_method("get_slots"):
		var slots = owner.get_slots()
		if slots != null and slot_index < slots.size():
			add_creature("EnragedQuartermaster", slot_index, slots[slot_index])
