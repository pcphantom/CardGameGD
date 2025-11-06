extends BaseCreature
class_name AirElemental

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Set attack to current air strength
	if card != null and owner_player != null:
		card.set_attack(owner_player.get_strength_air())

	# Deal 8 damage to opponent player
	damage_opponent(8)

	# Increment air strength by 1
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.AIR, 1)

	# Call parent implementation
	super.on_summoned()

func start_of_turn_check() -> void:
	# Update attack to current air strength at start of turn
	if card != null and owner_player != null:
		card.set_attack(owner_player.get_strength_air())
