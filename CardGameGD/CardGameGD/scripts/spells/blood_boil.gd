extends BaseSpell
class_name BloodBoil

func _init(p_game_state, p_card: Card, p_card_image, p_owner, p_opponent):
	super(p_game_state, p_card, p_card_image, p_owner, p_opponent)

func on_cast() -> void:
	super.on_cast()
	
	var inc: int = 0
	
	# Deal 4 damage to all opponent creatures
	for index in range(6):
		var ci = opponent_cards[index]
		if ci == null:
			continue
		
		var died: bool = ci.decrement_life(self, adjust_damage(4), game_state)
		
		if died:
			dispose_card_image(opponent, index)
			inc += 1
	
	# Increase VAMPIRIC power by the number of creatures killed
	owner.player_info.increment_strength(CardType.Type.VAMPIRIC, inc)
