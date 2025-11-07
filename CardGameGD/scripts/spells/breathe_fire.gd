extends BaseSpell
class_name BreatheFire

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Deal 10 damage to opponent and all opponent creatures
	damage_all(opponent, adjust_damage(10))
	damage_opponent(adjust_damage(10))
