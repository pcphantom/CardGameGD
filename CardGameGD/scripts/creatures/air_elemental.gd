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
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.AIR, 1)

	# Java: super.onSummoned(); (line 19)
	super.on_summoned()

func start_of_turn_check() -> void:
	# Update attack to current air strength at start of turn
	if card != null and owner_player != null:
		var old_attack := card.get_attack()
		var air_strength := owner_player.get_strength_air()
		card.set_attack(air_strength)
		print("[AIR ELEMENTAL] start_of_turn_check: updated attack %d → %d (air strength: %d)" % [old_attack, card.get_attack(), air_strength])
