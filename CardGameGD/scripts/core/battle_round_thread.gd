class_name BattleRoundThread
extends RefCounted

## ============================================================================
## BattleRoundThread.gd - EXACT translation of BattleRoundThread.java
## ============================================================================
## Handles the complete turn sequence for both player and AI opponent
##
## Original: src/main/java/org/antinori/cards/BattleRoundThread.java
## Translation: scripts/core/battle_round_thread.gd
##
## TURN SEQUENCE:
## 1. startTurn()
## 2. startOfTurnCheck(player)
## 3. If summoning: creature.onSummoned(), then existing creatures attack
## 4. If casting spell: spell.onCast(), then all creatures attack
## 5. AI turn: pick card, summon/cast, attack with all
## 6. Both players increment strength (+1 to all types)
## 7. enableDisableCards() for both players
## 8. endOfTurnCheck() for both players
## 9. finishTurn()
## ============================================================================

var game  # Cards reference
var player: PlayerImage
var opponent: PlayerImage

var summoned_card_image: CardImage = null
var summoned_slot: int = -1

var spell_card_image: CardImage = null
var targeted_card_image: CardImage = null
var targeted_slot: int = -1
var targeted_card_owner_id: String = ""

## Java: public BattleRoundThread(Cards game, PlayerImage player, PlayerImage opponent, CardImage spellCardImage)
func _init(game_ref, player_ref: PlayerImage, opponent_ref: PlayerImage, summoned_or_spell = null, slot_or_target = null, owner_id: String = ""):
	game = game_ref
	player = player_ref
	opponent = opponent_ref

	# Determine constructor variant based on parameters
	if summoned_or_spell != null:
		if summoned_or_spell is CardImage:
			var card_data: Card = summoned_or_spell.get_card()
			if card_data.is_spell():
				spell_card_image = summoned_or_spell
				if slot_or_target is CardImage:
					targeted_card_image = slot_or_target
				elif slot_or_target is int:
					targeted_slot = slot_or_target
				targeted_card_owner_id = owner_id
			else:
				summoned_card_image = summoned_or_spell
				if slot_or_target is int:
					summoned_slot = slot_or_target

## Main battle round execution
## Java: public void run() (line 65)
func execute() -> void:
	print("[BattleRound] START")

	# Java: game.startTurn(); (line 68)
	game.startTurn()

	if game == null or player == null or opponent == null:
		push_error("BattleRoundThread: Null parameter, cannot take a round")
		game.finishTurn()
		return

	# Java: Cards.logScrollPane.add("________________________"); (line 74)
	if Cards.logScrollPane:
		Cards.logScrollPane.add("________________________")

	# Java: startOfTurnCheck(player); (line 76)
	start_of_turn_check(player)

	var pi: Player = player.get_player_info()
	var oi: Player = opponent.get_player_info()

	# Java: if (summonedCardImage != null) { (line 81)
	if summoned_card_image != null:
		# Java: summonedCardImage.getCreature().onSummoned(); (line 84)
		if summoned_card_image.get_creature():
			summoned_card_image.get_creature().onSummoned()

	# Java: else if (spellCardImage != null) { (line 94)
	elif spell_card_image != null:

		# Java: Spell spell = SpellFactory.getSpellClass(...); spell.onCast(); (lines 97-100)
		var spell = SpellFactory.get_spell_class(
			spell_card_image.get_card().getName(),
			game,
			spell_card_image.get_card(),
			spell_card_image,
			player,
			opponent
		)
		spell.set_targeted(targeted_card_image)
		spell.set_target_slot(targeted_slot)
		spell.onCast()

	# Java: for (int index = 0; index<6; index++) { (line 120)
	# Attack with all player creatures (except just-summoned one)
	for index in range(6):
		var attacker: CardImage = player.get_slot_cards()[index]
		if attacker == null:
			continue

		# Java: if (summonedCardImage != null && index == summonedSlot) continue; (line 123)
		if summoned_card_image != null and index == summoned_slot:
			continue

		# Java: if (isTriplicateSummon(summonedCardImage, attacker)) continue; (line 126)
		if is_triplicate_summon(summoned_card_image, attacker):
			continue

		# Java: attacker.getCreature().onAttack(); (line 129)
		if attacker.get_creature():
			attacker.get_creature().onAttack()

	# AI TURN
	# Java: startOfTurnCheck(opponent); (line 155)
	start_of_turn_check(opponent)

	# Java: CardImage opptSummons = null; SlotImage si = getOpponentSlot(); (lines 158-160)
	var oppt_summons: CardImage = null
	var si: SlotImage = get_opponent_slot()

	if si != null:

		# Java: do { opptPick = oi.pickRandomEnabledCard(); } while (opptPick == null); (lines 165-168)
		# Keep trying until we get a valid card (matching Java do-while loop)
		var oppt_pick: CardImage = null
		while oppt_pick == null:
			oppt_pick = oi.pickRandomEnabledCard()

		if oppt_pick != null:
			if not oppt_pick.get_card().is_spell():
				# Java: opptSummons = opptPick.clone(); (line 173)
				oppt_summons = oppt_pick.clone_card()

				# Java: game.stage.addActor(opptSummons); (line 175)
				game.stage.add_child(oppt_summons)
				oppt_summons.z_index = game.CREATURE_Z_INDEX

				# Connect hover listeners
				oppt_summons.card_hovered.connect(game._on_card_hovered)
				oppt_summons.card_unhovered.connect(game._on_card_unhovered)

				# Java: CardImage[] imgs = opponent.getSlotCards(); imgs[si.getIndex()] = opptSummons; (lines 180-181)
				var oppt_slot_index: int = si.get_slot_index()
				opponent.get_slot_cards()[oppt_slot_index] = oppt_summons

				# Connect battlefield card click listener for spell targeting
				oppt_summons.card_clicked.connect(func(card_vis: CardImage): game._on_battlefield_card_clicked(card_vis, opponent.get_player_info().get_id(), oppt_slot_index))

				# Java: SlotImage[] slots = opponent.getSlots(); slots[si.getIndex()].setOccupied(true); (lines 183-184)
				opponent.get_slots()[oppt_slot_index].set_occupied(true)

				# Java: Creature summonedCreature = CreatureFactory.getCreatureClass(...); (line 186)
				var summoned_creature = CreatureFactory.get_creature_class(
					oppt_summons.get_card().getName(),
					game,
					oppt_summons.get_card(),
					oppt_summons,
					si.get_slot_index(),
					opponent,
					player
				)
				oppt_summons.set_creature(summoned_creature)

				# Java: Sounds.play(Sound.SUMMONED); (line 189)
				if SoundManager:
					SoundManager.play_sound(SoundTypes.Sound.SUMMONED)

				# Java: opptSummons.addAction(sequence(moveTo(si.getX() + 5, si.getY() + 26, 1.0f), ...)); (line 195)
				# Animate to slot
				oppt_summons.position = oppt_pick.position
				var tween: Tween = game.create_tween()
				tween.set_meta("bound_node", oppt_summons)
				tween.tween_property(
					oppt_summons,
					"position",
					Vector2(si.position.x + 5, si.position.y + 26),
					1.0
				)

				# Wait for animation to complete
				await tween.finished

				# Java: summonedCreature.onSummoned(); (line 206)
				summoned_creature.onSummoned()

			else:
				# Java: Spell opptSpell = SpellFactory.getSpellClass(...); opptSpell.onCast(); (lines 213-214)
				var oppt_spell = SpellFactory.get_spell_class(
					oppt_pick.get_card().getName(),
					game,
					oppt_pick.get_card(),
					oppt_pick,
					opponent,
					player
				)
				oppt_spell.onCast()

	# Java: for (CardImage attacker : opponent.getSlotCards()) { (line 226)
	# AI creatures attack
	var j: int = -1
	for attacker in opponent.get_slot_cards():
		j += 1

		if oppt_summons != null and j == si.get_slot_index():
			continue
		if attacker == null:
			continue
		if is_triplicate_summon(oppt_summons, attacker):
			continue

		# Java: attacker.getCreature().onAttack(); (line 233)
		if attacker.get_creature():
			attacker.get_creature().onAttack()

	# Java: oi.incrementStrengthAll(1); pi.incrementStrengthAll(1); (lines 236-237)
	# GROWTH RATE: Both players gain +1 to all elemental strengths
	oi.incrementStrengthAll(1)
	pi.incrementStrengthAll(1)

	# Java: endOfTurnCheck(opponent); (line 239)
	end_of_turn_check(opponent)

	# Java: for (CardType type : Player.TYPES) { pi.enableDisableCards(type); oi.enableDisableCards(type); } (lines 245-248)
	for type in Player.TYPES:
		pi.enableDisableCards(type)
		oi.enableDisableCards(type)

	# Java: endOfTurnCheck(player); (line 250)
	end_of_turn_check(player)

	# Java: game.finishTurn(); (line 257)
	game.finishTurn()

	print("[BattleRound] COMPLETE")

## Java: private boolean isTriplicateSummon(CardImage summoned, CardImage attacker) (line 263)
func is_triplicate_summon(summoned: CardImage, attacker: CardImage) -> bool:
	if summoned == null or attacker == null:
		return false

	var summoned_name: String = summoned.get_card().getName().to_lower()
	var attacker_name: String = attacker.get_card().getName().to_lower()

	# Java: lines 267-274
	if summoned_name == "giantspider" and attacker_name == "forestspider":
		return true
	if summoned_name == "vampireelder" and attacker_name == "initiate":
		return true
	if summoned_name == "goblinraider" and attacker_name == "goblinraider":
		return true

	return false

## Java: private void startOfTurnCheck(PlayerImage player) (line 280)
func start_of_turn_check(player_img: PlayerImage) -> void:
	var cards: Array = player_img.get_slot_cards()

	for index in range(6):
		var ci: CardImage = cards[index]
		if ci == null:
			continue

		# Don't invoke on the current summoned slot
		if index == summoned_slot:
			continue

		var bc: BaseCreature = ci.get_creature() as BaseCreature
		if bc == null:
			continue

		# Java: if (player.getPlayerInfo().getPlayerClass() == Specializations.VampireLord) { (line 293)
		if player_img.get_player_info().get_player_class() == Specializations.VAMPIRE_LORD:
			player_img.increment_life(1, game)
			var died: bool = ci.decrement_life(bc, 1, game)
			if Cards.logScrollPane:
				Cards.logScrollPane.add("Vampire Lord drains 1 life from " + ci.get_card().getName())
			if died:
				bc.dispose_card_image(player_img, index)

		# Java: for (int index2 = 0; index2 < 6; index2++) { (line 302)
		for index2 in range(6):
			var ci2: CardImage = player_img.get_slot_cards()[index2]
			if ci2 == null:
				continue
			if ci2.get_card().getName().to_lower() == "monumenttorage":
				# Card gets an extra attack this round
				# Java: Utils.attackWithNetworkEvent(ci.getCreature(), player.getPlayerInfo(), index); (line 307)
				Utils.attack_with_network_event(ci.get_creature(), player_img.get_player_info(), index)

		# Java: ci.getCreature().startOfTurnCheck(); (line 313)
		ci.get_creature().startOfTurnCheck()

## Java: private void endOfTurnCheck(PlayerImage player) (line 325)
func end_of_turn_check(player_img: PlayerImage) -> void:
	var cards: Array = []
	for index in range(6):
		var ci: CardImage = player_img.get_slot_cards()[index]
		if ci == null:
			continue
		cards.append(ci)

	# Java: for (CardImage ci : cards) { ci.getCreature().endOfTurnCheck(); } (lines 334-336)
	for ci in cards:
		if ci.get_creature():
			ci.get_creature().endOfTurnCheck()

## Java: public SlotImage getOpponentSlot() (line 348)
func get_opponent_slot() -> SlotImage:
	var slots: Array = opponent.get_slots()

	# Check if there are any open slots
	var has_open_slot: bool = false
	for slot in slots:
		if not slot.is_occupied():
			has_open_slot = true
			break

	if not has_open_slot:
		return null

	# Pick a random open slot
	# Java: lines 360-366
	var slot_index: int = randi() % 6
	var attempts: int = 0
	while slots[slot_index].is_occupied() and attempts < 20:
		slot_index = randi() % 6
		attempts += 1

	if slots[slot_index].is_occupied():
		return null

	return slots[slot_index]
