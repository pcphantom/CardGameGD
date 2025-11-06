extends BaseCreature
class_name FireElemental

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Set attack to current fire strength
	if card != null and owner_player != null:
		card.set_attack(owner_player.get_strength_fire())

	# Increment fire strength by 1
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.FIRE, 1)

	# Damage all opponent creatures for 3
	damage_all(opponent, 3)

	# Damage opponent player for 3
	damage_player(opponent, 3)

	# Call parent implementation
	super.on_summoned()

func start_of_turn_check() -> void:
	# Update attack to current fire strength at start of turn
	if card != null and owner_player != null:
		card.set_attack(owner_player.get_strength_fire())
