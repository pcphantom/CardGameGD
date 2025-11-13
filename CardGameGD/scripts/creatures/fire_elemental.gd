extends BaseCreature
class_name FireElemental

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Java: this.card.setAttack(ownerPlayer.getStrengthFire()); (line 17)
	if card != null and owner_player != null:
		card.set_attack(owner_player.get_strength_fire())

	# Java: ownerPlayer.incrementStrength(CardType.FIRE, 1); (line 18)
	# Increase fire growth rate by +1 per turn while alive
	if owner_player != null:
		owner_player.increment_growth_rate(CardType.Type.FIRE, 1)

	# Java: damageAll(opponent, 3); (line 19)
	damage_all(opponent, 3)

	# Java: damagePlayer(opponent, 3); (line 20)
	damage_player(opponent, 3)

	# Java: super.onSummoned(); (line 21)
	super.on_summoned()

func on_dying() -> void:
	# Reverse the growth rate bonus when elemental dies
	if owner_player != null:
		owner_player.decrement_growth_rate(CardType.Type.FIRE, 1)
	super.on_dying()

func start_of_turn_check() -> void:
	# Update attack to current fire strength at start of turn
	if card != null and owner_player != null:
		card.set_attack(owner_player.get_strength_fire())
