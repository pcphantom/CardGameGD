extends BaseCreature
class_name Lemure

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func on_dying() -> void:
	super.on_dying()

	# When Lemure dies, it transforms into ScrambledLemure
	if owner != null and owner.has_method("get_slots"):
		var slots = owner.get_slots()
		if slots != null and slot_index < slots.size():
			add_creature("ScrambledLemure", slot_index, slots[slot_index])
