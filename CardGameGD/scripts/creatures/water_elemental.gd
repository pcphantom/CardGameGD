extends BaseCreature
class_name WaterElemental

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Set attack to current water strength
	if card != null and owner_player != null:
		card.set_attack(owner_player.get_strength_water())

	# Heal owner for 10 HP
	if owner != null and owner.has_method("increment_life"):
		if game != null:
			owner.increment_life(10, game)

	# Increment water strength by 1
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.WATER, 1)

	# Call parent implementation
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func start_of_turn_check() -> void:
	# Update attack to current water strength at start of turn
	if card != null and owner_player != null:
		card.set_attack(owner_player.get_strength_water())
