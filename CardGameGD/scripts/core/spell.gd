extends RefCounted
class_name Spell

# Spell Interface
#
# This class defines the contract that all spell implementations must follow.
# Since GDScript does not support formal interfaces, this serves as a base class
# that documents the required methods for spell cards.
#
# All concrete spell classes should extend BaseSpell, which implements
# this interface and provides default behavior for all methods.
#
# Core Spell Method:
# - on_cast() : Called when the spell is cast. This is where spell-specific
#               logic is implemented (damage, healing, buffs, etc.)
#
# Targeting Methods:
# - set_targeted(target) : Sets the target card/card image for targetable spells
# - set_target_slot(index) : Sets the target slot index (0-5) for positional spells
#
# Spell Execution Flow:
# 1. Player selects spell from hand
# 2. If spell is targetable, player selects target (card or slot)
# 3. cast() method is called on BaseSpell:
#    a. Deducts mana cost from player
#    b. Applies self-inflicting damage if any
#    c. Checks for spell prevention (Reaver creature)
#    d. Calls on_cast() - implemented by specific spell
# 4. Spell effects are applied to target(s)
# 5. Spell card is removed from hand

func on_cast() -> void:
	push_error("Spell.on_cast() must be implemented by subclass")

func set_targeted(target) -> void:
	push_error("Spell.set_targeted() must be implemented by subclass")

func set_target_slot(index: int) -> void:
	push_error("Spell.set_target_slot() must be implemented by subclass")
