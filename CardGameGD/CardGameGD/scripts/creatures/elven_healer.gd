extends BaseCreature
class_name ElvenHealer

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_attack() -> void:
	super.on_attack()

func start_of_turn_check() -> void:
	# Elven Healer heals owner 3 HP at start of turn
	if owner != null and owner.has_method("increment_life"):
		if game != null:
			owner.increment_life(3, game)
