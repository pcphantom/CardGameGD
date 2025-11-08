extends BaseSpell
class_name PoisonousCloud

## ============================================================================
## PoisonousCloud.gd - EXACT translation of PoisonousCloud.java
## ============================================================================
## Poisonous Cloud spell that:
## - Decrements all opponent elemental strengths by 1 (FIRE, AIR, EARTH, WATER, OTHER)
## - Damages each opponent creature for half its current life (adjusted)
## - Disposes of creatures that die from the damage
##
## Original: src/main/java/org/antinori/cards/spells/PoisonousCloud.java
## Translation: scripts/spells/poisonous_cloud.gd
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
## - decrementLife → decrement_life (snake_case)
## - disposeCardImage → dispose_card_image (snake_case)
## - getSlotCards → get_slot_cards (snake_case)
## ============================================================================

# ============================================================================
# CONSTRUCTOR (Java: public PoisonousCloud(...))
# ============================================================================

## Java: public PoisonousCloud(Cards game, Card card, CardImage cardImage, PlayerImage owner, PlayerImage opponent)
## Constructor to create a PoisonousCloud spell
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
## Decrements all opponent strengths by 1, then damages all creatures for half their life
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

	# Java: for (int index = 0; index < 6; index++) { (line 26)
	for index in range(6):
		# Java: CardImage ci = opponent.getSlotCards()[index]; (line 27)
		var ci = opponent.get_slot_cards()[index]

		# Java: if (ci == null) continue; (line 28)
		if ci == null:
			continue

		# Java: int attack = ci.getCard().getLife() / 2; (line 30)
		var attack: int = ci.get_card().get_life() / 2

		# Java: boolean died = ci.decrementLife(this, adjustDamage(attack), game); (line 32)
		var died: bool = ci.decrement_life(self, adjust_damage(attack), game)

		# Java: if (died) { (line 34)
		if died:
			# Java: disposeCardImage(opponent, index); (line 35)
			dispose_card_image(opponent, index)
