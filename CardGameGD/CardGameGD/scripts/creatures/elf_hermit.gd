extends BaseCreature
class_name ElfHermit

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Elf Hermit boosts earth strength by 2
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.EARTH, 2)

func on_attack() -> void:
	super.on_attack()
