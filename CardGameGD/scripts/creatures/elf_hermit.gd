extends BaseCreature
class_name ElfHermit

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Elf Hermit increases earth growth rate by +2 per turn
	if owner_player != null:
		owner_player.increment_growth_rate(CardType.Type.EARTH, 2)
	else:
		push_error("[ELF HERMIT] owner_player is NULL!")

func on_dying() -> void:
	# Reverse the growth rate bonus when elf hermit dies
	if owner_player != null:
		owner_player.decrement_growth_rate(CardType.Type.EARTH, 2)
	super.on_dying()

func on_attack() -> void:
	super.on_attack()
