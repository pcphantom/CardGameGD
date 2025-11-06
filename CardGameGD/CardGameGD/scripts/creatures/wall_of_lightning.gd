extends BaseCreature
class_name WallOfLightning

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_attack() -> void:
	# Wall of Lightning does not attack
	pass

func start_of_turn_check() -> void:
	# Deal 4 damage to opponent player at start of turn
	damage_opponent(4)
