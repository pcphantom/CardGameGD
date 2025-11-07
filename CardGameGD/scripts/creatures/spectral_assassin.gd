extends BaseCreature
class_name SpectralAssassin

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Spectral Assassin deals 12 damage to opponent player on summon
	damage_opponent(12)

func on_attack() -> void:
	super.on_attack()
