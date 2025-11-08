extends BaseCreature
class_name Initiate

## ============================================================================
## Initiate.gd - EXACT translation of Initiate.java
## ============================================================================
## Vampire initiate creature with special ability:
## - Takes no damage when attacked if VampireElder is in adjacent slot (left or right)
##
## Original: src/main/java/org/antinori/cards/characters/Initiate.java
## Translation: scripts/creatures/initiate.gd
##
## ONLY CHANGES FROM JAVA:
## - package → class_name
## - extends BaseCreature (same)
## - Constructor → _init
## - throws GameOverException → removed (GDScript doesn't use checked exceptions)
## - String.equalsIgnoreCase → String.to_lower() ==
## ============================================================================

# ============================================================================
# CONSTRUCTOR (Java: public Initiate(...))
# ============================================================================

## Java: public Initiate(Cards game, Card card, CardImage cardImage, int slotIndex, PlayerImage owner, PlayerImage opponent)
## Constructor to create an Initiate creature
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
# ON SUMMONED METHOD (Java: public void onSummoned() throws GameOverException)
# ============================================================================

## Java: public void onSummoned() throws GameOverException
## Called when creature is summoned to the battlefield
func on_summoned() -> void:
	# Java: super.onSummoned(); (line 17)
	super.on_summoned()

# ============================================================================
# ON ATTACK METHOD (Java: public void onAttack() throws GameOverException)
# ============================================================================

## Java: public void onAttack() throws GameOverException
## Called when creature attacks
func on_attack() -> void:
	# Java: super.onAttack(); (line 21)
	super.on_attack()

# ============================================================================
# ON ATTACKED METHOD (Java: public int onAttacked(BaseFunctions attacker, int damage))
# ============================================================================

## Java: public int onAttacked(BaseFunctions attacker, int damage) throws GameOverException
## Called when creature is attacked
## Takes no damage if VampireElder is in adjacent slot (left or right)
## @param attacker The attacking entity
## @param damage Amount of damage
## @return Actual damage taken (0 if protected by VampireElder)
func on_attacked(attacker, damage: int) -> int:
	# Java: int nl = slotIndex - 1; (line 26)
	var nl: int = slot_index - 1

	# Java: int nr = slotIndex + 1; (line 27)
	var nr: int = slot_index + 1

	# Java: boolean isVampireElderStillAlve = false; (line 28)
	var isVampireElderStillAlve: bool = false

	# Java: if (nl >= 0 && owner.getSlotCards()[nl] != null) { (line 30)
	if nl >= 0 and owner_cards[nl] != null:
		# Java: String n = owner.getSlotCards()[nl].getCard().getName(); (line 31)
		var n: String = owner_cards[nl].getCard().getName()

		# Java: if (n.equalsIgnoreCase("vampireelder")) { (line 32)
		if n.to_lower() == "vampireelder":
			# Java: isVampireElderStillAlve = true; (line 33)
			isVampireElderStillAlve = true

	# Java: if (nr <= 5 && owner.getSlotCards()[nr] != null) { (line 37)
	if nr <= 5 and owner_cards[nr] != null:
		# Java: String n = owner.getSlotCards()[nr].getCard().getName(); (line 38)
		var n: String = owner_cards[nr].getCard().getName()

		# Java: if (n.equalsIgnoreCase("vampireelder")) { (line 39)
		if n.to_lower() == "vampireelder":
			# Java: isVampireElderStillAlve = true; (line 40)
			isVampireElderStillAlve = true

	# Java: if (isVampireElderStillAlve) { (line 44)
	if isVampireElderStillAlve:
		# Java: return 0; (line 45)
		return 0
	else:
		# Java: return super.onAttacked(attacker, damage); (line 47)
		return super.on_attacked(attacker, damage)
