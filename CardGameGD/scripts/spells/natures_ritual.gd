extends BaseSpell
class_name NaturesRitual

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	# Heal targeted creature 8 HP if there is one
	if targeted_card_image != null:
		targeted_card_image.increment_life(8, game)

	# Heal owner 8 HP
	owner.increment_life(8, game)
