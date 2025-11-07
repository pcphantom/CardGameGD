extends RefCounted
class_name Specializations

## Specializations / Mage Classes
## Replaces Specializations.java from the original game
## Uses compile-time enum constants and runtime data dictionary

# Specialization IDs (compile-time constants via enum)
enum Type {
	CLERIC = 0,
	MECHANICIAN = 1,
	NECROMANCER = 2,
	CHAOSMASTER = 3,
	DOMINATOR = 4,
	ILLUSIONIST = 5,
	DEMONOLOGIST = 6,
	SORCERER = 7,
	BEASTMASTER = 8,
	GOBLIN_CHIEFTAN = 9,
	MAD_HERMIT = 10,
	CHRONOMANCER = 11,
	WARRIOR_PRIEST = 12,
	VAMPIRE_LORD = 13,
	CULTIST = 14,
	GOLEM_MASTER = 15,
	RANDOM = 16
}

# Specialization data (runtime dictionary - NOT const)
# Maps specialization ID to its properties
static var data: Dictionary = {
	Type.CLERIC: {
		"name": "Cleric",
		"color": Color(1.0, 1.0, 0.8),
		"card_type": CardType.Type.HOLY
	},
	Type.MECHANICIAN: {
		"name": "Mechanician",
		"color": Color(0.6, 0.6, 0.6),
		"card_type": CardType.Type.MECHANICAL
	},
	Type.NECROMANCER: {
		"name": "Necromancer",
		"color": Color(0.3, 0.0, 0.3),
		"card_type": CardType.Type.DEATH
	},
	Type.CHAOSMASTER: {
		"name": "Chaosmaster",
		"color": Color(1.0, 0.0, 0.0),
		"card_type": CardType.Type.CHAOS
	},
	Type.DOMINATOR: {
		"name": "Dominator",
		"color": Color(0.0, 0.3, 0.7),
		"card_type": CardType.Type.CONTROL
	},
	Type.ILLUSIONIST: {
		"name": "Illusionist",
		"color": Color(0.8, 0.8, 1.0),
		"card_type": CardType.Type.ILLUSION
	},
	Type.DEMONOLOGIST: {
		"name": "Demonologist",
		"color": Color(0.5, 0.0, 0.0),
		"card_type": CardType.Type.DEMONIC
	},
	Type.SORCERER: {
		"name": "Sorcerer",
		"color": Color(0.3, 0.0, 0.6),
		"card_type": CardType.Type.SORCERY
	},
	Type.BEASTMASTER: {
		"name": "Beastmaster",
		"color": Color(0.0, 0.6, 0.0),
		"card_type": CardType.Type.BEAST
	},
	Type.GOBLIN_CHIEFTAN: {
		"name": "Goblin Chieftan",
		"color": Color(0.6, 0.3, 0.0),
		"card_type": CardType.Type.GOBLINS
	},
	Type.MAD_HERMIT: {
		"name": "Mad Hermit",
		"color": Color(0.5, 0.5, 0.3),
		"card_type": CardType.Type.FOREST
	},
	Type.CHRONOMANCER: {
		"name": "Chronomancer",
		"color": Color(0.7, 0.7, 0.9),
		"card_type": CardType.Type.TIME
	},
	Type.WARRIOR_PRIEST: {
		"name": "Warrior Priest",
		"color": Color(0.9, 0.9, 0.7),
		"card_type": CardType.Type.SPIRIT
	},
	Type.VAMPIRE_LORD: {
		"name": "Vampire Lord",
		"color": Color(0.4, 0.0, 0.2),
		"card_type": CardType.Type.VAMPIRIC
	},
	Type.CULTIST: {
		"name": "Cultist",
		"color": Color(0.3, 0.0, 0.4),
		"card_type": CardType.Type.CULT
	},
	Type.GOLEM_MASTER: {
		"name": "Golem Master",
		"color": Color(0.4, 0.4, 0.4),
		"card_type": CardType.Type.GOLEM
	},
	Type.RANDOM: {
		"name": "Random",
		"color": Color(0.5, 0.5, 0.5),
		"card_type": CardType.Type.HOLY
	}
}

# Specialization class for backward compatibility
class Specialization extends RefCounted:
	var id: int
	var title: String
	var card_type: CardType.Type

	func _init(spec_id: int, spec_title: String, spec_card_type: CardType.Type) -> void:
		id = spec_id
		title = spec_title
		card_type = spec_card_type

	func get_id() -> int:
		return id

	func get_title() -> String:
		return title

	func get_type() -> CardType.Type:
		return card_type

# Static accessor variables (initialized at runtime, not compile-time)
static var CLERIC: Specialization
static var MECHANICIAN: Specialization
static var NECROMANCER: Specialization
static var CHAOSMASTER: Specialization
static var DOMINATOR: Specialization
static var ILLUSIONIST: Specialization
static var DEMONOLOGIST: Specialization
static var SORCERER: Specialization
static var BEASTMASTER: Specialization
static var GOBLIN_CHIEFTAN: Specialization
static var MAD_HERMIT: Specialization
static var CHRONOMANCER: Specialization
static var WARRIOR_PRIEST: Specialization
static var VAMPIRE_LORD: Specialization
static var CULTIST: Specialization
static var GOLEM_MASTER: Specialization
static var RANDOM: Specialization

static var ALL_SPECIALIZATIONS: Array[Specialization] = []
static var _initialized: bool = false

# Initialize all specializations (called automatically on first access)
static func _ensure_initialized() -> void:
	if _initialized:
		return

	_initialized = true

	# Create Specialization objects from data
	CLERIC = Specialization.new(Type.CLERIC, get_name(Type.CLERIC), get_card_type(Type.CLERIC))
	MECHANICIAN = Specialization.new(Type.MECHANICIAN, get_name(Type.MECHANICIAN), get_card_type(Type.MECHANICIAN))
	NECROMANCER = Specialization.new(Type.NECROMANCER, get_name(Type.NECROMANCER), get_card_type(Type.NECROMANCER))
	CHAOSMASTER = Specialization.new(Type.CHAOSMASTER, get_name(Type.CHAOSMASTER), get_card_type(Type.CHAOSMASTER))
	DOMINATOR = Specialization.new(Type.DOMINATOR, get_name(Type.DOMINATOR), get_card_type(Type.DOMINATOR))
	ILLUSIONIST = Specialization.new(Type.ILLUSIONIST, get_name(Type.ILLUSIONIST), get_card_type(Type.ILLUSIONIST))
	DEMONOLOGIST = Specialization.new(Type.DEMONOLOGIST, get_name(Type.DEMONOLOGIST), get_card_type(Type.DEMONOLOGIST))
	SORCERER = Specialization.new(Type.SORCERER, get_name(Type.SORCERER), get_card_type(Type.SORCERER))
	BEASTMASTER = Specialization.new(Type.BEASTMASTER, get_name(Type.BEASTMASTER), get_card_type(Type.BEASTMASTER))
	GOBLIN_CHIEFTAN = Specialization.new(Type.GOBLIN_CHIEFTAN, get_name(Type.GOBLIN_CHIEFTAN), get_card_type(Type.GOBLIN_CHIEFTAN))
	MAD_HERMIT = Specialization.new(Type.MAD_HERMIT, get_name(Type.MAD_HERMIT), get_card_type(Type.MAD_HERMIT))
	CHRONOMANCER = Specialization.new(Type.CHRONOMANCER, get_name(Type.CHRONOMANCER), get_card_type(Type.CHRONOMANCER))
	WARRIOR_PRIEST = Specialization.new(Type.WARRIOR_PRIEST, get_name(Type.WARRIOR_PRIEST), get_card_type(Type.WARRIOR_PRIEST))
	VAMPIRE_LORD = Specialization.new(Type.VAMPIRE_LORD, get_name(Type.VAMPIRE_LORD), get_card_type(Type.VAMPIRE_LORD))
	CULTIST = Specialization.new(Type.CULTIST, get_name(Type.CULTIST), get_card_type(Type.CULTIST))
	GOLEM_MASTER = Specialization.new(Type.GOLEM_MASTER, get_name(Type.GOLEM_MASTER), get_card_type(Type.GOLEM_MASTER))
	RANDOM = Specialization.new(Type.RANDOM, get_name(Type.RANDOM), get_card_type(Type.RANDOM))

	ALL_SPECIALIZATIONS = [
		CLERIC, MECHANICIAN, NECROMANCER, CHAOSMASTER,
		DOMINATOR, ILLUSIONIST, DEMONOLOGIST, SORCERER,
		BEASTMASTER, GOBLIN_CHIEFTAN, MAD_HERMIT, CHRONOMANCER,
		WARRIOR_PRIEST, VAMPIRE_LORD, CULTIST, GOLEM_MASTER,
		RANDOM
	]

# Helper functions to access specialization data
static func get_name(spec_id: int) -> String:
	return data.get(spec_id, {}).get("name", "Unknown")

static func get_color(spec_id: int) -> Color:
	return data.get(spec_id, {}).get("color", Color.WHITE)

static func get_card_type(spec_id: int) -> CardType.Type:
	return data.get(spec_id, {}).get("card_type", CardType.Type.HOLY)

static func get_by_id(spec_id: int) -> Specialization:
	_ensure_initialized()
	if spec_id < 0 or spec_id >= ALL_SPECIALIZATIONS.size():
		return null
	return ALL_SPECIALIZATIONS[spec_id]

static func get_by_title(title: String) -> Specialization:
	_ensure_initialized()
	if title == null or title.is_empty():
		return null

	var title_lower: String = title.to_lower()

	for spec in ALL_SPECIALIZATIONS:
		if spec.title.to_lower() == title_lower:
			return spec

	return null

static func get_titles() -> Array:
	_ensure_initialized()
	var titles: Array = []
	for spec in ALL_SPECIALIZATIONS:
		titles.append(spec.title)
	return titles

static func from_type(spec_type: Type) -> Specialization:
	_ensure_initialized()
	if spec_type < 0 or spec_type >= Type.size():
		return null
	return ALL_SPECIALIZATIONS[spec_type]

static func get_all_specializations() -> Array[Specialization]:
	_ensure_initialized()
	return ALL_SPECIALIZATIONS.duplicate()
