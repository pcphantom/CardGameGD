extends BaseCreature
class_name Zealot

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()
	# Java: int attack = this.card.getAttack(); cardImage.decrementLife(this, attack, game); (lines 20-21)
	# Damage self equal to attack after attacking
	if card != null and card_image != null:
		var attack: int = card.get_attack()
		card_image.decrement_life(self, attack, game)

func start_of_turn_check() -> void:
	# Java: card.incrementAttack(2); (line 26)
	# Gain +2 attack each turn
	if card != null:
		card.increment_attack(2)
