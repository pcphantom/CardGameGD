extends BaseSpell
class_name GolemsJustice

func _init(p_game_state, p_card: Card, p_card_image, p_owner, p_opponent):
	super(p_game_state, p_card, p_card_image, p_owner, p_opponent)

func on_cast() -> void:
	super.on_cast()
