extends BaseCreature
class_name DevotedServant

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func start_of_turn_check() -> void:
	# Java: this.card.incrementAttack(1); (line 25)
	# Gains +1 attack each turn
	if card != null:
		card.increment_attack(1)

func on_dying() -> void:
	super.on_dying()
	# Java: owner.getPlayerInfo().incrementStrength(CardType.VAMPIRIC, this.card.getAttack()); (line 30)
	# When dying, grant owner VAMPIRIC strength equal to this card's attack
	if owner != null and owner.has_method("get_player_info") and card != null:
		var player_info = owner.get_player_info()
		if player_info != null:
			player_info.increment_strength(CardType.Type.VAMPIRIC, card.get_attack())
