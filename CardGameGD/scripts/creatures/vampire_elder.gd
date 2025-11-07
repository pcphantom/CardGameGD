extends BaseCreature
class_name VampireElder

func _init(p_game_state, p_card: Card, p_card_image, p_slot_index: int, p_owner, p_opponent):
	super(p_game_state, p_card, p_card_image, p_slot_index, p_owner, p_opponent)

func on_summoned() -> void:
	super.on_summoned()
	
	var nl: int = slot_index - 1
	var nr: int = slot_index + 1
	
	var slots = owner.get_slots()
	
	# Summon Initiate creatures into neighboring empty slots
	if nl >= 0 and owner_cards[nl] == null:
		add_creature("Initiate", nl, slots[nl])
	
	if nr <= 5 and owner_cards[nr] == null:
		add_creature("Initiate", nr, slots[nr])

func on_attack() -> void:
	super.on_attack()
