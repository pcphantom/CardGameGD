extends BaseCreature
class_name Mindstealer

## ============================================================================
## Mindstealer.gd - EXACT translation of Mindstealer.java
## ============================================================================
## Mindstealer creature with special ability:
## - When attacked, damages the attacker instead of taking damage itself
## - If the attacker dies from the reflected damage, dispose of it
##
## Original: src/main/java/org/antinori/cards/characters/Mindstealer.java
## Translation: scripts/creatures/mindstealer.gd
##
## ONLY CHANGES FROM JAVA:
## - package → class_name
## - extends BaseCreature (same)
## - Constructor → _init
## - throws GameOverException → removed (GDScript doesn't use checked exceptions)
## ============================================================================

# ============================================================================
# CONSTRUCTOR (Java: public Mindstealer(...))
# ============================================================================

## Java: public Mindstealer(Cards game, Card card, CardImage cardImage, int slotIndex, PlayerImage owner, PlayerImage opponent)
## Constructor to create a Mindstealer creature
## @param p_game_state Reference to main game controller
## @param p_card The card data
## @param p_card_image The visual card image
## @param p_slot_index The slot index (0-5)
## @param p_owner Owner player
## @param p_opponent Opponent player
func _init(p_game_state, p_card: Card, p_card_image, p_slot_index: int, p_owner, p_opponent):
	# Java: super(game, card, cardImage, slotIndex, owner, opponent); (line 12)
	super(p_game_state, p_card, p_card_image, p_slot_index, p_owner, p_opponent)

# ============================================================================
# ON ATTACKED METHOD (Java: public int onAttacked(BaseFunctions attacker, int damage))
# ============================================================================

## Java: public int onAttacked(BaseFunctions attacker, int damage) throws GameOverException
## Called when creature is attacked
## Reflects damage to the attacker instead of taking damage
## @param attacker The attacking entity
## @param damage Amount of damage
## @return 0 (always, as Mindstealer doesn't take damage)
func on_attacked(attacker, damage: int) -> int:
	# Java: boolean died = attacker.cardImage.decrementLife(this, damage, game); (line 17)
	var died: bool = attacker.cardImage.decrementLife(self, damage, game)

	# Java: if (died) { (line 18)
	if died:
		# Java: disposeCardImage(opponent, slotIndex); (line 19)
		disposeCardImage(opponent, slot_index)

	# Java: return 0; (line 21)
	return 0
