extends BaseCreature
class_name Ergodemon

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func on_dying() -> void:
	super.on_dying()

	# When Ergodemon dies, it decrements all opponent's element strengths by 1
	if opponent != null and opponent.has_method("get_player_info"):
		var opponent_info = opponent.get_player_info()
		if opponent_info != null:
			# Decrement all element types by 1
			var types = [
				CardType.Type.FIRE,
				CardType.Type.WATER,
				CardType.Type.AIR,
				CardType.Type.EARTH,
				CardType.Type.DEATH,
				CardType.Type.HOLY,
				CardType.Type.ILLUSION,
				CardType.Type.MECHANICAL,
				CardType.Type.DEMONIC,
				CardType.Type.CHAOS
			]
			for type in types:
				opponent_info.decrement_strength(type, 1)
