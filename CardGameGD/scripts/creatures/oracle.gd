extends BaseCreature
class_name Oracle

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func start_of_turn_check() -> void:
	# Oracle deals damage equal to special (illusion) strength to opponent at turn start
	if owner_player != null:
		var special_strength: int = owner_player.get_strength_special()
		damage_opponent(special_strength)
