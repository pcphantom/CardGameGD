extends BaseCreature
class_name AirElemental

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Java: this.card.setAttack(ownerPlayer.getStrengthAir()); (line 16)
	if card != null and owner_player != null:
		card.set_attack(owner_player.get_strength_air())

	# Java: damageOpponent(8); (line 17)
	damage_opponent(8)

	# Java: ownerPlayer.incrementStrength(CardType.AIR, 1); (line 18)
	# Increase air growth rate by +1 per turn while alive
	if owner_player != null:
		owner_player.increment_growth_rate(CardType.Type.AIR, 1)

	# Java: super.onSummoned(); (line 19)
	super.on_summoned()

func on_dying() -> void:
	# Reverse the growth rate bonus when elemental dies
	if owner_player != null:
		owner_player.decrement_growth_rate(CardType.Type.AIR, 1)
	super.on_dying()

func start_of_turn_check() -> void:
	# Update attack to current air strength at start of turn
	if card != null and owner_player != null:
		card.set_attack(owner_player.get_strength_air())
