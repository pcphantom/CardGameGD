extends BaseSpell
class_name Tornado

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	# Destroy the targeted creature
	if targeted_card_image != null:
		var target_index: int = -1
		if targeted_card_image.has_method("get_creature"):
			var creature = targeted_card_image.get_creature()
			if creature != null:
				target_index = creature.get_index()

		if target_index >= 0:
			dispose_card_image(opponent, target_index, true)
