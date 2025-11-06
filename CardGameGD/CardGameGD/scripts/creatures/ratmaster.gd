extends BaseCreature
class_name Ratmaster

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func start_of_turn_check() -> void:
	# Damage all opponent creatures for 6
	damage_all(opponent, 6)

	# Decrease a random opponent power by 3
	if opposing_player != null:
		# Random element type (0-4 for the 5 base types)
		var dice_roll: int = randi() % 5
		var types: Array = [
			CardType.Type.FIRE,
			CardType.Type.WATER,
			CardType.Type.AIR,
			CardType.Type.EARTH,
			CardType.Type.DEATH
		]
		var random_type = types[dice_roll]
		opposing_player.decrement_strength(random_type, 3)
