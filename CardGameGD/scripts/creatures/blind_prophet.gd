extends BaseCreature
class_name BlindProphet

func _init(p_game_state, p_card: Card, p_card_image, p_slot_index: int, p_owner, p_opponent):
	super(p_game_state, p_card, p_card_image, p_slot_index, p_owner, p_opponent)

func on_summoned() -> void:
	super.on_summoned()
	
	# Increase Fire, Air, Earth, Water powers by 1
	owner_player.increment_strength(CardType.Type.FIRE, 1)
	owner_player.increment_strength(CardType.Type.AIR, 1)
	owner_player.increment_strength(CardType.Type.EARTH, 1)
	owner_player.increment_strength(CardType.Type.WATER, 1)
	# Decrease OTHER power by 1
	owner_player.decrement_strength(CardType.Type.OTHER, 1)
