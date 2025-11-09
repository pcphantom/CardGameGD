class_name Move
extends RefCounted

## ============================================================================
## Move.gd - EXACT translation of Move.java
## ============================================================================
## Represents a potential AI move in the card game.
## Contains a slot index and the card to be played in that slot.
##
## Original: src/main/java/org/antinori/cards/ai/Move.java
## Translation: scripts/ai/move.gd
##
## ONLY CHANGES FROM JAVA:
## - package → class_name
## - this.field → direct field assignment (no 'this' needed in _init)
## - Import paths updated to match CardGameGD structure
## ============================================================================

# ============================================================================
# FIELDS (Java: private int slot; private Card card;)
# ============================================================================

## Java: private int slot;
var slot: int = 0

## Java: private Card card;
var card: Card = null

# ============================================================================
# CONSTRUCTOR (Java: public Move(int slot, Card card))
# ============================================================================

## Java: public Move(int slot, Card card)
## Constructor to create a move with a slot and card
## @param slot The slot index where the card should be played
## @param card The card to be played
func _init(p_slot: int = 0, p_card: Card = null) -> void:
	# Java: super();
	# GDScript: Implicit call to RefCounted._init()

	# Java: this.slot = slot;
	slot = p_slot

	# Java: this.card = card;
	card = p_card

# ============================================================================
# GETTER METHODS (Java: public int getSlot(); public Card getCard();)
# ============================================================================

## Java: public int getSlot()
## Returns the slot index for this move
## @return The slot index
func get_slot() -> int:
	return slot

## Java: public Card getCard()
## Returns the card for this move
## @return The card to be played
func get_card() -> Card:
	return card

# ============================================================================
# SETTER METHODS (Java: public void setSlot(int slot); public void setCard(Card card);)
# ============================================================================

## Java: public void setSlot(int slot)
## Sets the slot index for this move
## @param slot The slot index
func set_slot(p_slot: int) -> void:
	slot = p_slot

## Java: public void setCard(Card card)
## Sets the card for this move
## @param card The card to be played
func set_card(p_card: Card) -> void:
	card = p_card
