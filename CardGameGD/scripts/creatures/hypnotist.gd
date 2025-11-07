extends BaseCreature
class_name Hypnotist

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Deal 5 damage to all opponent creatures
	damage_all(opponent, 5)

	# Deal 5 damage to opponent player
	damage_opponent(5)

	# Boost illusion strength by 1
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.ILLUSION, 1)

func on_attack() -> void:
	super.on_attack()
