extends BaseCreature
class_name ElfHermit

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Elf Hermit boosts earth strength by 2
	if owner_player != null:
		var old_strength = owner_player.get_strength(CardType.Type.EARTH)
		owner_player.increment_strength(CardType.Type.EARTH, 2)
		var new_strength = owner_player.get_strength(CardType.Type.EARTH)
		print("[ELF HERMIT] Increased earth strength: %d → %d" % [old_strength, new_strength])
	else:
		push_error("[ELF HERMIT] owner_player is NULL!")

func on_attack() -> void:
	super.on_attack()
