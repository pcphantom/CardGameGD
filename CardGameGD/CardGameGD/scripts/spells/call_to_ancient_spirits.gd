extends BaseSpell
class_name CalltoAncientSpirits

func _init(p_game_state, p_card: Card, p_card_image, p_owner, p_opponent):
	super(p_game_state, p_card, p_card_image, p_owner, p_opponent)

func on_cast() -> void:
	super.on_cast()
	# Deal 10 damage to all opponent creatures
	damage_all(opponent, adjust_damage(10))
	# Deal 5 damage to all friendly creatures
	damage_all(owner, adjust_damage(5))
