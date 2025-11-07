extends BaseSpell
class_name Poison

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Deal 14 damage to targeted opponent creature
	if targeted_card_image != null:
		var index: int = -1
		if targeted_card_image.has_method("get_creature"):
			var creature = targeted_card_image.get_creature()
			if creature != null and creature.has_method("get_index"):
				index = creature.get_index()

		if index >= 0:
			damage_slot(targeted_card_image, index, opponent, adjust_damage(14))
