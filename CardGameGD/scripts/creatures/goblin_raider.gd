extends BaseCreature
class_name GoblinRaider

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

	# Summon two more GoblinRaiders into neighboring slots
	var nl: int = slot_index - 1
	var nr: int = slot_index + 1

	var slots: Array = []
	if owner != null and owner.has_method("get_slots"):
		slots = owner.get_slots()

	var owner_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		owner_cards = owner.get_slot_cards()

	# Add to left neighbor if empty
	if nl >= 0 and nl < owner_cards.size() and owner_cards[nl] == null:
		if nl < slots.size():
			add_creature("GoblinRaider", nl, slots[nl])

	# Add to right neighbor if empty
	if nr <= 5 and nr < owner_cards.size() and owner_cards[nr] == null:
		if nr < slots.size():
			add_creature("GoblinRaider", nr, slots[nr])
