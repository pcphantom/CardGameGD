extends BaseCreature
class_name ForestSprite

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	# Forest Sprite attacks differently than normal creatures
	# First perform the normal attack
	super.on_attack()

	# Get attack value
	var attack: int = card.get_attack() if card != null else 0

	# Damage all opponent creatures except the one directly opposite
	damage_all_except_current_index(attack, opponent)

	# Check if there's an opponent creature opposite this one
	var enemy_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		enemy_cards = opponent.get_slot_cards()

	# If there is a creature opposite, damage the opponent player anyway
	if slot_index < enemy_cards.size() and enemy_cards[slot_index] != null:
		damage_opponent(attack)
