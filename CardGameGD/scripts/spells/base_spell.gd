extends BaseFunctions
class_name BaseSpell

var targeted_card_image = null
var target_slot: int = -1

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	is_spell = true

	game = game_ref
	card = card_ref
	card_image = card_image_ref

	owner = owner_ref
	opponent = opponent_ref

	if opponent != null and opponent.has_method("get_player_info"):
		opposing_player = opponent.get_player_info()

	if owner != null and owner.has_method("get_player_info"):
		owner_player = owner.get_player_info()

func set_targeted(target) -> void:
	targeted_card_image = target

func set_target_slot(index: int) -> void:
	target_slot = index

func get_target():
	return targeted_card_image

func get_target_slot() -> int:
	return target_slot

func on_cast() -> void:
	var cost: int = card.get_cost() if card != null else 0

	if owner_player != null and card != null:
		owner_player.decrement_strength(card.get_type(), cost)

	var owner_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		owner_cards = owner.get_slot_cards()

	for index in range(6):
		if index >= owner_cards.size():
			continue
		var ci = owner_cards[index]
		if ci == null:
			continue
		if ci.has_method("get_card"):
			var owner_card: Card = ci.get_card()
			if owner_card.get_name().to_lower() == "reaver":
				if game != null and game.has_method("log_message"):
					var class_title: String = ""
					if owner_player != null and owner_player.has_method("get_player_class"):
						var player_class = owner_player.get_player_class()
						if player_class != null:
							class_title = player_class.get_title()
					game.log_message("%s casting failed" % class_title)
				if game != null and game.has_method("play_sound"):
					game.play_sound("negative_effect")
				return

	if game != null and game.has_method("log_message"):
		var class_title: String = ""
		if owner_player != null and owner_player.has_method("get_player_class"):
			var player_class = owner_player.get_player_class()
			if player_class != null:
				class_title = player_class.get_title()

		game.log_message("%s casts %s" % [
			class_title,
			card.get_cardname() if card != null else "Unknown"
		])

	# Play spell sound effect
	if SoundManager:
		var spell_class_name: String = get_script().get_global_name() if get_script() else ""
		if not spell_class_name.is_empty():
			# Try to play spell-specific sound
			SoundManager.play_spell_sound_by_class(spell_class_name)
			# Note: play_spell_sound_by_class returns void, fallback handled internally
		else:
			# No class name, use generic magic sound
			SoundManager.play_sound(SoundTypes.Sound.MAGIC)

	if game != null and game.has_method("play_spell_sound"):
		game.play_spell_sound(self)

	if game != null and game.has_method("move_card_actor_on_magic"):
		game.move_card_actor_on_magic(card_image, owner)

func cast() -> void:
	if card != null and card.get_self_inflicting_damage() > 0:
		var self_damage: int = card.get_self_inflicting_damage()
		if game != null and game.has_method("log_message"):
			game.log_message("%s inflicts %d damage to caster" % [
				card.get_cardname(),
				self_damage
			])
		if owner != null and owner.has_method("decrement_life"):
			# Java: owner.decrementLife(value, game) - needs game parameter
			owner.decrement_life(self_damage, game)

	on_cast()

func adjust_damage(current_damage_value: int) -> int:
	var qualified_damage_value: int = current_damage_value

	var team_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		team_cards = owner.get_slot_cards()

	for ci in team_cards:
		if ci == null:
			continue
		if not ci.has_method("get_card"):
			continue

		var team_card: Card = ci.get_card()
		var card_name: String = team_card.get_name().to_lower()

		if card_name == "faerieapprentice":
			qualified_damage_value += 1

	for ci in team_cards:
		if ci == null:
			continue
		if not ci.has_method("get_card"):
			continue

		var team_card: Card = ci.get_card()
		var card_name: String = team_card.get_name().to_lower()

		if card_name == "dragon":
			qualified_damage_value += int(qualified_damage_value / 2)

	return qualified_damage_value

# All damage/attack/card manipulation/movement functions are inherited from BaseFunctions
# with correct Java signatures. No need to override them here.

## ============================================================================
## CAMELCASE WRAPPERS FOR JAVA API COMPATIBILITY
## ============================================================================
## These methods wrap the snake_case implementations to match Java API calls
## from BattleRoundThread and other systems that expect Java naming

func onCast() -> void:
	on_cast()

func setTargeted(target) -> void:
	set_targeted(target)

func setTargetSlot(index: int) -> void:
	set_target_slot(index)
