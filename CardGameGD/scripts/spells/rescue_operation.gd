extends BaseSpell
class_name RescueOperation

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Move target creature to random empty slot
	if targeted_card_image != null:
		if targeted_card_image.has_method("get_creature"):
			var creature = targeted_card_image.get_creature()
			if creature != null:
				var creature_owner = null
				if creature.has_method("get_owner"):
					creature_owner = creature.owner

				# Move to another random slot
				try_move_to_another_random_open_slot(creature_owner, targeted_card_image, target_slot)
