extends BaseSpell
class_name NaturalHealing

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()
	# Heals 18 life to all owner's creatures
	heal_all(18)
