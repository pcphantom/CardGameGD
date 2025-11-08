class_name CardPredicate
extends RefCounted

## ============================================================================
## CardPredicate.gd - EXACT translation of CardPredicate.java
## ============================================================================
## Predicate class for filtering/matching cards based on criteria.
## Implements the Predicate pattern to evaluate cards by name, type, or spell status.
##
## Original: src/main/java/org/antinori/cards/CardPredicate.java
## Translation: scripts/ai/card_predicate.gd
##
## ONLY CHANGES FROM JAVA:
## - package → class_name
## - implements Predicate → extends RefCounted (no Predicate interface in Godot)
## - Three constructors → One _init() with optional parameters
## - Object o → Variant o (GDScript typing)
## - Import paths updated to match CardGameGD structure
## ============================================================================

# ============================================================================
# IMPORTS (Java: import statements)
# ============================================================================

## Java: import org.apache.commons.collections.Predicate;
## GDScript: No Predicate interface needed, using duck typing

# ============================================================================
# FIELDS (Java: private String name; private CardType type; private Boolean isSpell;)
# ============================================================================

## Java: private String name;
## The card name to match (case insensitive)
var name: String = ""

## Java: private CardType type;
## The card type to match (FIRE, AIR, WATER, EARTH, OTHER)
var type: CardType.Type = -1

## Java: private Boolean isSpell;
## Whether to match spell cards (true) or creature cards (false)
var isSpell: bool = false

# Internal flags to track which predicate type is set
var _has_name: bool = false
var _has_type: bool = false
var _has_is_spell: bool = false

# ============================================================================
# CONSTRUCTORS (Java: Three overloaded constructors)
# ============================================================================

## Java: public CardPredicate(String name)
## Java: public CardPredicate(CardType type)
## Java: public CardPredicate(Boolean isSpell)
##
## GDScript combines all three constructors into one with optional parameters
## @param p_name Optional card name to match
## @param p_type Optional card type to match
## @param p_is_spell Optional spell status to match
func _init(p_name: String = "", p_type: CardType.Type = -1, p_is_spell: bool = false) -> void:
	# Java: super();
	# GDScript: Implicit call to RefCounted._init()

	# Determine which constructor was used based on parameters
	if p_name != "":
		# Java: this.name = name; (from constructor 1, lines 10-13)
		name = p_name
		_has_name = true
	elif p_type != -1:
		# Java: this.type = type; (from constructor 2, lines 14-17)
		type = p_type
		_has_type = true
	else:
		# Java: this.isSpell = isSpell; (from constructor 3, lines 18-21)
		isSpell = p_is_spell
		_has_is_spell = true

# ============================================================================
# EVALUATE METHOD (Java: public boolean evaluate(Object o))
# ============================================================================

## Java: public boolean evaluate(Object o)
## Evaluates whether a card matches this predicate's criteria
## @param o The object to evaluate (must be a Card)
## @return true if the card matches the predicate, false otherwise
func evaluate(o: Variant) -> bool:
	# Java: Card c = (Card) o; (line 24)
	var c: Card = o as Card

	# Java: if (this.name != null) return c.getName().equalsIgnoreCase(this.name); (lines 25-26)
	if _has_name:
		return c.getName().to_lower() == name.to_lower()

	# Java: if (this.type != null) return c.getType().equals(this.type); (lines 27-28)
	if _has_type:
		return c.getType() == type

	# Java: if (this.isSpell != null) return c.isSpell() == this.isSpell; (lines 29-30)
	if _has_is_spell:
		return c.isSpell() == isSpell

	# Java: return false; (line 31)
	return false
