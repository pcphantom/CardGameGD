extends BaseCreature
class_name Banshee

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Banshee damages opposing creature for half its current HP
	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	if slot_index < opponent_cards.size():
		var ci = opponent_cards[slot_index]
		if ci != null:
			# Get the opposing creature's current HP
			var opposing_hp: int = 0
			if ci.has_method("get_card"):
				var opposing_card = ci.get_card()
				if opposing_card != null:
					opposing_hp = opposing_card.get_life()

			# Damage for half of its HP
			var damage: int = opposing_hp / 2
			damage_slot(ci, slot_index, opponent, damage)

func on_attack() -> void:
	super.on_attack()
