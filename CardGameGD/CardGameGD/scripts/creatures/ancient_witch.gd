extends BaseCreature
class_name AncientWitch

func _init(p_game_state, p_card: Card, p_card_image, p_slot_index: int, p_owner, p_opponent):
	super(p_game_state, p_card, p_card_image, p_slot_index, p_owner, p_opponent)

func on_summoned() -> void:
	super.on_summoned()
	
	# Decrease all opponent elemental powers by 2
	opposing_player.decrement_strength(CardType.Type.FIRE, 2)
	opposing_player.decrement_strength(CardType.Type.AIR, 2)
	opposing_player.decrement_strength(CardType.Type.EARTH, 2)
	opposing_player.decrement_strength(CardType.Type.WATER, 2)
	opposing_player.decrement_strength(CardType.Type.OTHER, 2)
