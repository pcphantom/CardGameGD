extends BaseCreature
class_name DemonApostate

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func start_of_turn_check() -> void:
	# Demon Apostate heals owner player and all friendly creatures by 2 at start of turn
	if owner != null:
		# Heal the owner player
		if owner.has_method("increment_life") and game != null:
			owner.increment_life(2, game)

		# Heal all friendly creatures
		if owner.has_method("get_slot_cards"):
			var owner_cards = owner.get_slot_cards()
			for index in range(6):
				if index >= owner_cards.size():
					continue

				var ci = owner_cards[index]
				if ci != null and ci.has_method("increment_life") and game != null:
					ci.increment_life(2, game)
