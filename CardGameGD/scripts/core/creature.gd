extends RefCounted
class_name Creature

# Creature Interface
#
# This class defines the contract that all creature implementations must follow.
# Since GDScript does not support formal interfaces, this serves as a base class
# that documents the required methods for creature cards.
#
# All concrete creature classes should extend BaseCreature, which implements
# this interface and provides default behavior for all methods.
#
# Lifecycle Methods:
# - on_summoned() : Called when creature enters the battlefield
# - on_attack() : Called when creature performs an attack
# - on_attacked(attacker, damage) : Called when creature takes damage, returns actual damage taken
# - on_dying() : Called when creature dies and is removed from board
# - start_of_turn_check() : Called at the beginning of each turn
# - end_of_turn_check() : Called at the end of each turn
#
# State Management Methods:
# - get_index() : Returns the slot index (0-5) where creature is positioned
# - set_index(index) : Sets the slot index for this creature
# - must_skip_next_attack_check() : Returns true if creature must skip its next attack
# - set_skip_next_attack(flag) : Sets whether creature must skip next attack (stun/freeze)

# Lifecycle Methods

func on_summoned() -> void:
	push_error("Creature.on_summoned() must be implemented by subclass")

func on_attack() -> void:
	push_error("Creature.on_attack() must be implemented by subclass")

func on_attacked(attacker, damage: int) -> int:
	push_error("Creature.on_attacked() must be implemented by subclass")
	return 0

func on_dying() -> void:
	push_error("Creature.on_dying() must be implemented by subclass")

func start_of_turn_check() -> void:
	push_error("Creature.start_of_turn_check() must be implemented by subclass")

func end_of_turn_check() -> void:
	push_error("Creature.end_of_turn_check() must be implemented by subclass")

# State Management Methods

func get_index() -> int:
	push_error("Creature.get_index() must be implemented by subclass")
	return -1

func set_index(index: int) -> void:
	push_error("Creature.set_index() must be implemented by subclass")

func must_skip_next_attack_check() -> bool:
	push_error("Creature.must_skip_next_attack_check() must be implemented by subclass")
	return false

func set_skip_next_attack(flag: bool) -> void:
	push_error("Creature.set_skip_next_attack() must be implemented by subclass")
