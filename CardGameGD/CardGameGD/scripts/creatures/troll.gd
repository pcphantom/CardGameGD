extends BaseCreature
class_name Troll

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func start_of_turn_check() -> void:
	# Troll heals itself 4 HP at start of turn
	if card_image != null and card_image.has_method("increment_life"):
		if game != null:
			card_image.increment_life(4, game)
