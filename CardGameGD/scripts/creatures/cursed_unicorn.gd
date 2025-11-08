extends BaseCreature
class_name CursedUnicorn

## ============================================================================
## CursedUnicorn.gd - EXACT translation of CursedUnicorn.java
## ============================================================================
## Cursed unicorn with special abilities:
## - When attacked by a spell, reflects damage to opposing slot creature
## - At start of turn, takes 5 damage if opposing slot has a creature
##
## Original: src/main/java/org/antinori/cards/characters/CursedUnicorn.java
## Translation: scripts/creatures/cursed_unicorn.gd
##
## ONLY CHANGES FROM JAVA:
## - package → class_name
## - extends BaseCreature (same)
## - Constructor → _init
## - throws GameOverException → removed (GDScript doesn't use checked exceptions)
## ============================================================================

# ============================================================================
# CONSTRUCTOR (Java: public CursedUnicorn(...))
# ============================================================================

## Java: public CursedUnicorn(Cards game, Card card, CardImage cardImage, int slotIndex, PlayerImage owner, PlayerImage opponent)
## Constructor to create a CursedUnicorn creature
## @param p_game_state Reference to main game controller
## @param p_card The card data
## @param p_card_image The visual card image
## @param p_slot_index The slot index (0-5)
## @param p_owner Owner player
## @param p_opponent Opponent player
func _init(p_game_state, p_card: Card, p_card_image, p_slot_index: int, p_owner, p_opponent):
	# Java: super(game, card, cardImage, slotIndex, owner, opponent); (line 13)
	super(p_game_state, p_card, p_card_image, p_slot_index, p_owner, p_opponent)

# ============================================================================
# ON ATTACKED METHOD (Java: public int onAttacked(BaseFunctions attacker, int damage))
# ============================================================================

## Java: public int onAttacked(BaseFunctions attacker, int damage) throws GameOverException
## Called when creature is attacked
## If attacked by a spell, reflects damage to opposing slot creature
## @param attacker The attacking entity
## @param damage Amount of damage
## @return Actual damage taken
func on_attacked(attacker, damage: int) -> int:
	# Java: if (opponent.getSlotCards()[slotIndex] != null && attacker.isSpell) { (line 18)
	if opponent_cards[slot_index] != null and attacker.isSpell:
		# Java: damageSlot(opponent.getSlotCards()[slotIndex], slotIndex, opponent, damage); (line 19)
		damageSlot(opponent_cards[slot_index], slot_index, opponent, damage)

		# Java: return damage; (line 20)
		return damage
	else:
		# Java: return super.onAttacked(attacker, damage); (line 22)
		return super.on_attacked(attacker, damage)

# ============================================================================
# START OF TURN CHECK METHOD (Java: public void startOfTurnCheck())
# ============================================================================

## Java: public void startOfTurnCheck() throws GameOverException
## Called at start of turn
## Takes 5 damage if opposing slot has a creature
func start_of_turn_check() -> void:
	# Java: if (opponent.getSlotCards()[slotIndex] != null) { (line 27)
	if opponent_cards[slot_index] != null:
		# Java: cardImage.decrementLife(this, 5, game); (line 28)
		card_image.decrementLife(self, 5, game)
