extends BaseCreature
class_name DampingTower

func _init(p_game_state, p_card: Card, p_card_image, p_slot_index: int, p_owner, p_opponent):
	super(p_game_state, p_card, p_card_image, p_slot_index, p_owner, p_opponent)

func on_summoned() -> void:
	super.on_summoned()
	
	# Increase all opponent card costs by 1
	for type in Player.TYPES:
		var cards = opposing_player.get_cards(type)
		for ci in cards:
			var cost: int = ci.card.get_cost()
			ci.card.set_cost(cost + 1)

func on_attack() -> void:
	# Does not attack
	pass

func on_dying() -> void:
	super.on_dying()
	
	# Decrease all opponent card costs by 1
	for type in Player.TYPES:
		var cards = opposing_player.get_cards(type)
		for ci in cards:
			var cost: int = ci.card.get_cost()
			ci.card.set_cost(cost - 1)
