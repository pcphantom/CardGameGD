extends BaseCreature
class_name Phoenix

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func on_dying() -> void:
	# Call parent dying logic first
	super.on_dying()

	# Phoenix respawns if fire strength >= 10
	if owner_player != null and owner_player.get_strength_fire() >= 10:
		var slots: Array = []
		if owner != null and owner.has_method("get_slots"):
			slots = owner.get_slots()

		if slot_index < slots.size():
			# Respawn the Phoenix in its current slot
			add_creature("Phoenix", slot_index, slots[slot_index])
