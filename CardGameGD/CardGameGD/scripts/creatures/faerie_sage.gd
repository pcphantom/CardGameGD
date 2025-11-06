extends BaseCreature
class_name FaerieSage

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Heal owner based on earth strength (max 10)
	var value: int = 0
	if owner != null and owner.has_method("get_player_info"):
		var player_info = owner.get_player_info()
		if player_info != null:
			value = player_info.get_strength(CardType.Type.EARTH)

	# Cap healing at 10
	if value > 10:
		value = 10

	# Heal owner
	if owner != null and owner.has_method("increment_life"):
		if game != null:
			owner.increment_life(value, game)

func on_attack() -> void:
	super.on_attack()
