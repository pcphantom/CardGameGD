extends BaseSpell
class_name BloodRitual

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	var damage: int = 0

	# Destroy the targeted creature and get its HP
	if targeted_card_image != null:
		if targeted_card_image.has_method("get_card"):
			var target_card = targeted_card_image.get_card()
			if target_card != null:
				damage = target_card.get_life()

		# Destroy the targeted creature
		var target_index: int = -1
		if targeted_card_image.has_method("get_creature"):
			var creature = targeted_card_image.get_creature()
			if creature != null:
				target_index = creature.get_index()

		if target_index >= 0:
			dispose_card_image(opponent, target_index)

	# Apply damage adjustments
	damage = adjust_damage(damage)

	# Cap damage at 32
	if damage > 32:
		damage = 32

	# Deal damage to all opponent creatures
	damage_all(opponent, damage)
