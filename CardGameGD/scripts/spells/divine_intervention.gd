extends BaseSpell
class_name DivineIntervention

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Java: super.onCast(); (line 17)
	super.on_cast()

	# Java: ownerPlayer.incrementStrength(CardType.AIR, 2); (line 19)
	# Java: ownerPlayer.incrementStrength(CardType.FIRE, 2); (line 20)
	# Java: ownerPlayer.incrementStrength(CardType.EARTH, 2); (line 21)
	# Java: ownerPlayer.incrementStrength(CardType.WATER, 2); (line 22)
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.AIR, 2)
		owner_player.increment_strength(CardType.Type.FIRE, 2)
		owner_player.increment_strength(CardType.Type.EARTH, 2)
		owner_player.increment_strength(CardType.Type.WATER, 2)

	# Java: this.owner.incrementLife(10, game); (line 24)
	if owner != null and owner.has_method("increment_life") and game != null:
		owner.increment_life(10, game)

	if game != null and game.has_method("log_message") and owner_player != null:
		game.log_message("Divine Intervention: +2 to all elements, +10 life")
