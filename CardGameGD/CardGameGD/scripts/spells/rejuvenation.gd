extends BaseSpell
class_name Rejuvenation

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	# Calculate healing: earth strength * 2
	var heal: int = 0
	if owner_player != null:
		heal = owner_player.get_strength_earth() * 2

	# Heal owner
	if owner != null and owner.has_method("increment_life"):
		if game != null:
			owner.increment_life(heal, game)
