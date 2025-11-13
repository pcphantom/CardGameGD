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

	print("[GIANT SPIDER] on_summoned at slot ", slot_index, " nl=", nl, " nr=", nr)

	var slots: Array = []
	if owner != null and owner.has_method("get_slots"):
		slots = owner.get_slots()
		print("[GIANT SPIDER] Got ", slots.size(), " slots")

	# Use base class owner_cards variable instead of shadowing it
	if owner != null and owner.has_method("get_slot_cards"):
		owner_cards = owner.get_slot_cards()
		print("[GIANT SPIDER] Got ", owner_cards.size(), " owner_cards")

	# Summon ForestSpider to the left if slot is empty
	if nl >= 0 and nl < owner_cards.size():
		print("[GIANT SPIDER] Checking left slot nl=", nl, " occupied=", owner_cards[nl] != null)
		if owner_cards[nl] == null and nl < slots.size():
			print("[GIANT SPIDER] Summoning ForestSpider to left at slot ", nl)
			add_creature("forestspider", nl, slots[nl])
		else:
			print("[GIANT SPIDER] Left slot occupied or invalid")
	else:
		print("[GIANT SPIDER] Left slot out of bounds")

	# Summon ForestSpider to the right if slot is empty
	if nr <= 5 and nr < owner_cards.size():
		print("[GIANT SPIDER] Checking right slot nr=", nr, " occupied=", owner_cards[nr] != null)
		if owner_cards[nr] == null and nr < slots.size():
			print("[GIANT SPIDER] Summoning ForestSpider to right at slot ", nr)
			add_creature("forestspider", nr, slots[nr])
		else:
			print("[GIANT SPIDER] Right slot occupied or invalid")
	else:
		print("[GIANT SPIDER] Right slot out of bounds")
