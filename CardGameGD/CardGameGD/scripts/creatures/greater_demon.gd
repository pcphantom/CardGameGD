extends BaseCreature
class_name GreaterDemon

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

	# Greater Demon damages all opponent creatures and opponent for fire strength (capped at 10)
	var power: int = 0
	if owner != null and owner.has_method("get_player_info"):
		var owner_info = owner.get_player_info()
		if owner_info != null:
			power = owner_info.get_strength_fire()

	# Cap power at 10
	if power > 10:
		power = 10

	# Damage all opponent creatures and the opponent player
	damage_all(opponent, power)
	damage_opponent(power)

func on_attack() -> void:
	super.on_attack()
