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
	# Use custom conversion to handle cases like "CalltoThunder" -> "call_to_thunder"
	var snake_case_name := _to_snake_case(spell_class_name)
	var spell_script_path: String = SPELL_PATH + snake_case_name + ".gd"

	print("[SPELL FACTORY] Looking for spell: '%s'" % spell_class_name)
	print("[SPELL FACTORY] Converted to: '%s'" % snake_case_name)
	print("[SPELL FACTORY] Path: '%s'" % spell_script_path)
	print("[SPELL FACTORY] Exists: %s" % ResourceLoader.exists(spell_script_path))

	# Try to load the specific spell class
	if ResourceLoader.exists(spell_script_path):
		var SpellClass = load(spell_script_path)
		if SpellClass != null:
			print("[SPELL FACTORY] Successfully loaded spell class: %s" % spell_class_name)
			spell = SpellClass.new(game, card, card_image, owner, opponent)
			return spell
		else:
			print("[SPELL FACTORY ERROR] Failed to load spell script even though it exists!")

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

## Helper to convert PascalCase to snake_case for file naming
## Handles cases like "CalltoThunder" -> "call_to_thunder"
static func _to_snake_case(pascal_case: String) -> String:
	# Common prepositions that should have underscores added
	const PREPOSITIONS := ["of", "to", "the", "in", "on", "at", "by", "for", "with", "from"]

	var result := ""
	var i := 0
	while i < pascal_case.length():
		var c := pascal_case[i]

		# Check if we're at a preposition
		var found_prep := false
		for prep in PREPOSITIONS:
			var prep_len: int = prep.length()
			if i + prep_len <= pascal_case.length():
				var substring := pascal_case.substr(i, prep_len).to_lower()
				if substring == prep:
					# Check it's not at start and followed by capital or end
					if i > 0 and (i + prep_len >= pascal_case.length() or pascal_case[i + prep_len] == pascal_case[i + prep_len].to_upper()):
						if result != "":
							result += "_"
						result += prep
						if i + prep_len < pascal_case.length():
							result += "_"
						i += prep_len
						found_prep = true
						break

		if found_prep:
			continue

		# Normal capital letter handling
		if c == c.to_upper() and i > 0:
			result += "_"
		result += c.to_lower()
		i += 1

	return result

static func spell_exists(spell_class_name: String) -> bool:
	var spell_script_path: String = SPELL_PATH + _to_snake_case(spell_class_name) + ".gd"
	return ResourceLoader.exists(spell_script_path)
