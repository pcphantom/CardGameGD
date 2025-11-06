extends BaseCreature
class_name GolemGuide

func _init(p_game_state, p_card: Card, p_card_image, p_slot_index: int, p_owner, p_opponent):
	super(p_game_state, p_card, p_card_image, p_slot_index, p_owner, p_opponent)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()
