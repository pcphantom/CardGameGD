extends BaseCreature
class_name Zealot

func _init(p_game_state, p_card: Card, p_card_image, p_slot_index: int, p_owner, p_opponent):
	super(p_game_state, p_card, p_card_image, p_slot_index, p_owner, p_opponent)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()
	# Damage self equal to attack after attacking
	var attack: int = creature_card.get_attack()
	card_image.decrement_life(self, attack, game_state)

func start_of_turn_check() -> void:
	# Gain +2 attack each turn
	creature_card.increment_attack(2)
