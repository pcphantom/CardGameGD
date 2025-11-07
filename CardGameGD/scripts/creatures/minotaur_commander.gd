extends BaseCreature
class_name MinotaurCommander

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_attack() -> void:
	# Minotaur Commander boosts all friendly creatures' attack by 1
	# This is handled in BaseCreature's on_summoned and on_dying logic
	super.on_attack()
