extends BaseCreature
class_name MagicHamster

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

	# Heal 10 life to each neighboring creature
	var nl: int = slot_index - 1
	var nr: int = slot_index + 1
	var team_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		team_cards = owner.get_slot_cards()

	if nl >= 0 and nl < team_cards.size() and team_cards[nl] != null:
		if team_cards[nl].has_method("increment_life") and game != null:
			team_cards[nl].increment_life(10, game)

	if nr <= 5 and nr < team_cards.size() and team_cards[nr] != null:
		if team_cards[nr].has_method("increment_life") and game != null:
			team_cards[nr].increment_life(10, game)

	# Swap to ability card
	swap_card("NaturalHealing", CardType.Type.BEAST, "MagicHamster", owner)

func on_attack() -> void:
	super.on_attack()

func on_dying() -> void:
	super.on_dying()
	swap_card("MagicHamster", CardType.Type.BEAST, "NaturalHealing", owner)
