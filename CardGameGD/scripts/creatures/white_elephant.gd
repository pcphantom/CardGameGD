extends BaseCreature
class_name WhiteElephant

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()
	swap_card("Trumpet", CardType.Type.BEAST, "WhiteElephant", owner)

func on_dying() -> void:
	super.on_dying()
	swap_card("WhiteElephant", CardType.Type.BEAST, "Trumpet", owner)
