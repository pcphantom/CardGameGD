extends BaseSpell
class_name Meditation

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Java: super.onCast(); (line 15)
	super.on_cast()

	# Java: ownerPlayer.incrementStrength(CardType.AIR, 1); (line 16)
	# Java: ownerPlayer.incrementStrength(CardType.FIRE, 1); (line 17)
	# Java: ownerPlayer.incrementStrength(CardType.EARTH, 1); (line 18)
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.AIR, 1)
		owner_player.increment_strength(CardType.Type.FIRE, 1)
		owner_player.increment_strength(CardType.Type.EARTH, 1)

		if game != null and game.has_method("log_message"):
			game.log_message("Meditation: +1 Air (%d), +1 Fire (%d), +1 Earth (%d)" % [
				owner_player.get_strength_air(),
				owner_player.get_strength_fire(),
				owner_player.get_strength_earth()
			])
