extends BaseCreature
class_name WaterElemental

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Java: this.card.setAttack(ownerPlayer.getStrengthWater()); (line 16)
	if card != null and owner_player != null:
		card.set_attack(owner_player.get_strength_water())

	# Java: owner.incrementLife(10, game); (line 17)
	if owner != null and owner.has_method("increment_life"):
		if game != null:
			owner.increment_life(10, game)

	# Java: ownerPlayer.incrementStrength(CardType.WATER, 1); (line 18)
	# Increase water growth rate by +1 per turn while alive
	if owner_player != null:
		owner_player.increment_growth_rate(CardType.Type.WATER, 1)

	# Java: super.onSummoned(); (line 19)
	super.on_summoned()

func on_dying() -> void:
	# Reverse the growth rate bonus when elemental dies
	if owner_player != null:
		owner_player.decrement_growth_rate(CardType.Type.WATER, 1)
	super.on_dying()

func on_attack() -> void:
	super.on_attack()

func start_of_turn_check() -> void:
	# Update attack to current water strength at start of turn
	if card != null and owner_player != null:
		card.set_attack(owner_player.get_strength_water())
