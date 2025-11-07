extends BaseCreature
class_name MagisterofBlood

func _init(p_game_state, p_card: Card, p_card_image, p_slot_index: int, p_owner, p_opponent):
	super(p_game_state, p_card, p_card_image, p_slot_index, p_owner, p_opponent)

func on_summoned() -> void:
	super.on_summoned()
	
	# Damage opponent directly
	damage_opponent(16)
	
	# Damage all opponent creatures that are blocked (have a friendly creature in the same slot)
	for index in range(6):
		var ci1 = opponent_cards[index]
		var ci2 = owner_cards[index]
		if ci1 == null:
			continue
		if ci2 == null:
			continue  # Only damage blocked targets
		damage_slot(ci1, index, opponent, 16)

func on_attack() -> void:
	super.on_attack()
