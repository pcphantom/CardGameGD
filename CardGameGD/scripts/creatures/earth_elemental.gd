extends BaseCreature
class_name EarthElemental

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Java: this.card.setAttack(ownerPlayer.getStrengthEarth()); (line 16)
	if card != null and owner_player != null:
		card.set_attack(owner_player.get_strength_earth())

	# Java: ownerPlayer.incrementStrength(CardType.EARTH, 1); (line 17)
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.EARTH, 1)

	# Java: super.onSummoned(); (line 18)
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func start_of_turn_check() -> void:
	# Update attack to current earth strength at start of turn
	if card != null and owner_player != null:
		var old_attack := card.get_attack()
		var earth_strength := owner_player.get_strength(CardType.Type.EARTH)
		card.set_attack(earth_strength)
		print("[EARTH ELEMENTAL] start_of_turn_check: updated attack %d → %d (earth strength: %d)" % [old_attack, card.get_attack(), earth_strength])
