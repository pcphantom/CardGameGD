extends BaseCreature
class_name DarkSculptor

## ============================================================================
## DarkSculptor.gd - EXACT translation of DarkSculptor.java
## ============================================================================
## Basic dark sculptor creature with no special abilities.
## Simply calls parent implementations for all methods.
##
## Original: src/main/java/org/antinori/cards/characters/DarkSculptor.java
## Translation: scripts/creatures/dark_sculptor.gd
##
## ONLY CHANGES FROM JAVA:
## - package → class_name
## - extends BaseCreature (same)
## - Constructor → _init
## - throws GameOverException → removed (GDScript doesn't use checked exceptions)
## ============================================================================

# ============================================================================
# CONSTRUCTOR (Java: public DarkSculptor(...))
# ============================================================================

## Java: public DarkSculptor(Cards game, Card card, CardImage cardImage, int slotIndex, PlayerImage owner, PlayerImage opponent)
## Constructor to create a DarkSculptor creature
## @param p_game_state Reference to main game controller
## @param p_card The card data
## @param p_card_image The visual card image
## @param p_slot_index The slot index (0-5)
## @param p_owner Owner player
## @param p_opponent Opponent player
func _init(p_game_state, p_card: Card, p_card_image, p_slot_index: int, p_owner, p_opponent):
	# Java: super(game, card, cardImage, slotIndex, owner, opponent); (line 10)
	super(p_game_state, p_card, p_card_image, p_slot_index, p_owner, p_opponent)

# ============================================================================
# ON SUMMONED METHOD (Java: public void onSummoned() throws GameOverException)
# ============================================================================

## Java: public void onSummoned() throws GameOverException
## Called when creature is summoned to the battlefield
func on_summoned() -> void:
	# Java: super.onSummoned(); (line 13)
	super.on_summoned()

# ============================================================================
# ON ATTACK METHOD (Java: public void onAttack() throws GameOverException)
# ============================================================================

## Java: public void onAttack() throws GameOverException
## Called when creature attacks
func on_attack() -> void:
	# Java: super.onAttack(); (line 16)
	super.on_attack()
