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
	spell_class_name: String,
	game,  # Cards (main game controller)
	card: Card,
	card_image: CardImage,
	owner: PlayerImage,
	opponent: PlayerImage
) -> BaseSpell:

	# Java: Uses reflection to load "org.antinori.cards.spells." + className
	# Godot: Uses load() to dynamically load spell scripts by name

	var spell: BaseSpell = null

	# Convert class name to snake_case for file name (e.g., "FlameWave" -> "flame_wave")
	var spell_script_path: String = SPELL_PATH + spell_class_name.to_snake_case() + ".gd"

	# Try to load the specific spell class
	if ResourceLoader.exists(spell_script_path):
		var SpellClass = load(spell_script_path)
		if SpellClass != null:
			spell = SpellClass.new(game, card, card_image, owner, opponent)
			print("[SPELL] Loaded specific spell: %s from %s" % [spell_class_name, spell_script_path])
			return spell

	# Fallback to BaseSpell if specific class not found
	if game != null and game.has_method("log_message"):
		game.log_message("SpellFactory: Using base spell for %s - specific class not found at %s" % [spell_class_name, spell_script_path])
	else:
		push_warning("SpellFactory: Using base spell for %s - specific class not found at %s" % [spell_class_name, spell_script_path])

	spell = BaseSpell.new(
		game,
		card,
		card_image,
		owner,
		opponent
	)

	return spell

static func spell_exists(spell_class_name: String) -> bool:
	var spell_script_path: String = SPELL_PATH + spell_class_name.to_snake_case() + ".gd"
	return ResourceLoader.exists(spell_script_path)
