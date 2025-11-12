extends RefCounted
class_name CreatureFactory

## ============================================================================
## CreatureFactory.gd - EXACT translation of CreatureFactory.java
## ============================================================================
## Dynamically loads creature classes by name, falling back to BaseCreature
## if specific implementation doesn't exist.
##
## Original: src/main/java/org/antinori/cards/CreatureFactory.java
## Translation: scripts/factories/creature_factory.gd
##
## Java uses reflection: Class.forName(packageName + className)
## Godot uses load(): load("res://scripts/creatures/" + class_name + ".gd")
## ============================================================================

const CREATURE_PATH: String = "res://scripts/creatures/"

## Java: public static Creature getCreatureClass(String className, ...)
static func get_creature_class(
	creature_class_name: String,
	game,  # Cards (main game controller)
	card: Card,
	card_image: CardImage,
	slot_index: int,
	owner: PlayerImage,
	opponent: PlayerImage
) -> BaseCreature:

	var creature: BaseCreature = null

	# Java: try { constructor = Class.forName(packageName + className).getConstructor(...); }
	# Convert to snake_case for Godot file naming (e.g., "FireDrake" -> "fire_drake.gd")
	var creature_script_path: String = CREATURE_PATH + _to_snake_case(creature_class_name) + ".gd"

	# Attempt to load specific creature class
	if ResourceLoader.exists(creature_script_path):
		var CreatureClass = load(creature_script_path)
		if CreatureClass != null:
			# Java: creature = (Creature) constructor.newInstance(game, card, cardImage, slotIndex, owner, opponent);
			creature = CreatureClass.new(game, card, card_image, slot_index, owner, opponent)
			return creature

	# Java: catch (Exception e) { constructor = Class.forName(packageName + "BaseCreature").getConstructor(...); }
	# Fallback to BaseCreature if specific class not found
	creature = BaseCreature.new(game, card, card_image, slot_index, owner, opponent)

	return creature

## Helper to convert PascalCase to snake_case for file naming
static func _to_snake_case(pascal_case: String) -> String:
	var result := ""
	for i in range(pascal_case.length()):
		var c := pascal_case[i]
		if c == c.to_upper() and i > 0:
			result += "_"
		result += c.to_lower()
	return result

static func creature_exists(creature_class_name: String) -> bool:
	var creature_script_path: String = CREATURE_PATH + _to_snake_case(creature_class_name) + ".gd"
	return ResourceLoader.exists(creature_script_path)
