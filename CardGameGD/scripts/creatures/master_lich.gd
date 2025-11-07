extends BaseCreature
class_name MasterLich

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Master Lich damages all opponent creatures for 8 on summon
	damage_all(opponent, 8)

func on_attack() -> void:
	# Master Lich has custom attack behavior
	var attack: int = card.get_attack() if card != null else 0

	var enemy_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		enemy_cards = opponent.get_slot_cards()

	# Check if there's a creature in the opposing slot
	if slot_index < enemy_cards.size() and enemy_cards[slot_index] != null:
		# If blocked, attack normally
		damage_slot(enemy_cards[slot_index], slot_index, opponent, attack)
	else:
		# If unblocked, gain 2 death strength and damage player
		if owner_player != null:
			owner_player.increment_strength(CardType.Type.DEATH, 2)
		inflict_damage_to_player(opponent, attack)

	# Move card actor for battle animation
	if game != null and game.has_method("move_card_actor_on_battle"):
		game.move_card_actor_on_battle(card_image, owner)
