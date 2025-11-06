extends BaseSpell
class_name ArmyOfRats

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Damage all opponent creatures for 12
	damage_all(opponent, adjust_damage(12))

	# Damage a random friendly creature for 12
	var cards: Array = []
	var owner_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		owner_cards = owner.get_slot_cards()

	for index in range(6):
		if index >= owner_cards.size():
			continue
		var ci = owner_cards[index]
		if ci == null:
			continue
		cards.append(ci)

	if cards.size() == 0:
		return

	# Pick random creature
	var random_index: int = randi() % cards.size()
	var ci = cards[random_index]

	if ci != null and ci.has_method("get_creature"):
		var creature = ci.get_creature()
		if creature != null and creature.has_method("get_index"):
			var creature_index: int = creature.get_index()
			damage_slot(ci, creature_index, owner, adjust_damage(12))
