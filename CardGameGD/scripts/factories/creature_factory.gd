extends RefCounted
class_name CreatureFactory

# Creature Factory
#
# This factory creates creature instances by name using dynamic class loading.
# The Java version uses reflection to load creature classes at runtime.
#
# Current Implementation (Phase 3):
# - Returns BaseCreature for all creature names
# - Logs a warning indicating specific implementation is pending
#
# Future Implementation (Phase 5):
# - Will load specific creature classes (FireDrake, Minotaur, Dragon, etc.)
# - Uses GDScript's load() to dynamically load creature scripts
# - Falls back to BaseCreature if specific class not found
#
# Usage:
#   var creature = CreatureFactory.get_creature_class(
#       "FireDrake", game, card, card_image, 0, owner, opponent
#   )

const CREATURE_PATH: String = "res://scripts/creatures/"

static func get_creature_class(
	creature_class_name: String,
	game: GameController,
	card: Card,
	card_image: CardImage,
	slot_index: int,
	owner: PlayerImage,
	opponent: PlayerImage
) -> BaseCreature:

	# Phase 3 Stub: Always return BaseCreature
	# In Phase 5, this will attempt to load specific creature classes

	var creature: BaseCreature = null

	# Attempt to load specific creature class (will be implemented in Phase 5)
	var _creature_script_path: String = CREATURE_PATH + creature_class_name.to_lower() + ".gd"

	# For now, we don't have specific creature implementations
	# Always use BaseCreature
	if game != null and game.has_method("log_message"):
		game.log_message("CreatureFactory: Using base creature for %s - specific implementation pending" % creature_class_name)
	else:
		print("CreatureFactory: Using base creature for %s - specific implementation pending" % creature_class_name)

	# Create BaseCreature instance
	creature = BaseCreature.new(
		game,
		card,
		card_image,
		slot_index,
		owner,
		opponent
	)

	# Future Phase 5 implementation will look like:
	#
	# if ResourceLoader.exists(creature_script_path):
	#     var CreatureClass = load(creature_script_path)
	#     if CreatureClass != null:
	#         creature = CreatureClass.new(game, card, card_image, slot_index, owner, opponent)
	#         return creature
	#
	# # Fallback to BaseCreature if specific class not found
	# creature = BaseCreature.new(game, card, card_image, slot_index, owner, opponent)

	return creature

static func creature_exists(creature_class_name: String) -> bool:
	var creature_script_path: String = CREATURE_PATH + creature_class_name.to_lower() + ".gd"
	return ResourceLoader.exists(creature_script_path)
