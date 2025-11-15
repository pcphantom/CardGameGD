extends BaseCreature
class_name GiantSpider

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Summon ForestSpider tokens in adjacent empty slots
	var nl: int = slot_index - 1
	var nr: int = slot_index + 1

	var slots: Array = []
	if owner != null and owner.has_method("get_slots"):
		slots = owner.get_slots()

	var owner_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		owner_cards = owner.get_slot_cards()

	# Summon ForestSpider to the left if slot is empty
	if nl >= 0 and nl < owner_cards.size():
		if owner_cards[nl] == null and nl < slots.size():
			add_creature("ForestSpider", nl, slots[nl])

	# Summon ForestSpider to the right if slot is empty
	if nr <= 5 and nr < owner_cards.size():
		if owner_cards[nr] == null and nr < slots.size():
			add_creature("ForestSpider", nr, slots[nr])
