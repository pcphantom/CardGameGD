extends BaseSpell
class_name Weakness

## ============================================================================
## Weakness.gd - EXACT translation of Weakness.java
## ============================================================================
## Weakness spell that:
## - Decrements all opponent elemental strengths by 1 (FIRE, AIR, EARTH, WATER, OTHER)
## - Deals 3 damage to opponent player (adjusted)
##
## Original: src/main/java/org/antinori/cards/spells/Weakness.java
## Translation: scripts/spells/weakness.gd
##
## ONLY CHANGES FROM JAVA:
## - package → class_name
## - extends BaseSpell (same)
## - Constructor → _init
## - throws GameOverException → removed (GDScript doesn't use checked exceptions)
## - onCast → on_cast (snake_case)
## - decrementStrength → decrement_strength (snake_case)
## - opposingPlayer → opposing_player (snake_case)
## - adjustDamage → adjust_damage (snake_case)
## - damageOpponent → damage_opponent (snake_case)
## ============================================================================

# ============================================================================
# CONSTRUCTOR (Java: public Weakness(...))
# ============================================================================

## Java: public Weakness(Cards game, Card card, CardImage cardImage, PlayerImage owner, PlayerImage opponent)
## Constructor to create a Weakness spell
## @param game_ref Reference to main game controller
## @param card_ref The card data
## @param card_image_ref The visual card image
## @param owner_ref Owner player
## @param opponent_ref Opponent player
func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	# Java: super(game, card, cardImage, owner, opponent); (line 13)
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

# ============================================================================
# ON CAST METHOD (Java: public void onCast() throws GameOverException)
# ============================================================================

## Java: public void onCast() throws GameOverException
## Called when spell is cast
## Decrements all opponent strengths by 1 and deals 3 damage to opponent
func on_cast() -> void:
	# Java: super.onCast(); (line 17)
	super.on_cast()

	# Java: opposingPlayer.decrementStrength(CardType.FIRE, 1); (line 19)
	opposing_player.decrement_strength(CardType.Type.FIRE, 1)

	# Java: opposingPlayer.decrementStrength(CardType.AIR, 1); (line 20)
	opposing_player.decrement_strength(CardType.Type.AIR, 1)

	# Java: opposingPlayer.decrementStrength(CardType.EARTH, 1); (line 21)
	opposing_player.decrement_strength(CardType.Type.EARTH, 1)

	# Java: opposingPlayer.decrementStrength(CardType.WATER, 1); (line 22)
	opposing_player.decrement_strength(CardType.Type.WATER, 1)

	# Java: opposingPlayer.decrementStrength(CardType.OTHER, 1); (line 23)
	opposing_player.decrement_strength(CardType.Type.OTHER, 1)

	# Java: damageOpponent(adjustDamage(3)); (line 25)
	damage_opponent(adjust_damage(3))
