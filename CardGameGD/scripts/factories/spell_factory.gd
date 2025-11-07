extends RefCounted
class_name SpellFactory

# Spell Factory
#
# This factory creates spell instances by name using dynamic class loading.
# The Java version uses reflection to load spell classes at runtime.
#
# Current Implementation (Phase 3):
# - Returns BaseSpell for all spell names
# - Logs a warning indicating specific implementation is pending
#
# Future Implementation (Phase 6):
# - Will load specific spell classes (HellFire, HealingSpray, Fireball, etc.)
# - Uses GDScript's load() to dynamically load spell scripts
# - Falls back to BaseSpell if specific class not found
#
# Usage:
#   var spell = SpellFactory.get_spell_class(
#       "HellFire", game, card, card_image, owner, opponent
#   )

const SPELL_PATH: String = "res://scripts/spells/"

static func get_spell_class(
	class_name: String,
	game,
	card: Card,
	card_image,
	owner,
	opponent
) -> BaseSpell:

	# Phase 3 Stub: Always return BaseSpell
	# In Phase 6, this will attempt to load specific spell classes

	var spell: BaseSpell = null

	# Attempt to load specific spell class (will be implemented in Phase 6)
	var spell_script_path: String = SPELL_PATH + class_name.to_lower() + ".gd"

	# For now, we don't have specific spell implementations
	# Always use BaseSpell
	if game != null and game.has_method("log_message"):
		game.log_message("SpellFactory: Using base spell for %s - specific implementation pending" % class_name)
	else:
		print("SpellFactory: Using base spell for %s - specific implementation pending" % class_name)

	# Create BaseSpell instance
	spell = BaseSpell.new(
		game,
		card,
		card_image,
		owner,
		opponent
	)

	# Future Phase 6 implementation will look like:
	#
	# if ResourceLoader.exists(spell_script_path):
	#     var SpellClass = load(spell_script_path)
	#     if SpellClass != null:
	#         spell = SpellClass.new(game, card, card_image, owner, opponent)
	#         return spell
	#
	# # Fallback to BaseSpell if specific class not found
	# spell = BaseSpell.new(game, card, card_image, owner, opponent)

	return spell

static func spell_exists(class_name: String) -> bool:
	var spell_script_path: String = SPELL_PATH + class_name.to_lower() + ".gd"
	return ResourceLoader.exists(spell_script_path)
