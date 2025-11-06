extends RefCounted
class_name Specializations

enum Type {
	CLERIC,
	MECHANICIAN,
	NECROMANCER,
	CHAOSMASTER,
	DOMINATOR,
	ILLUSIONIST,
	DEMONOLOGIST,
	SORCERER,
	BEASTMASTER,
	GOBLIN_CHIEFTAN,
	MAD_HERMIT,
	CHRONOMANCER,
	WARRIOR_PRIEST,
	VAMPIRE_LORD,
	CULTIST,
	GOLEM_MASTER,
	RANDOM
}

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

const CLERIC: Specialization = Specialization.new(0, "Cleric", CardType.Type.HOLY)
const MECHANICIAN: Specialization = Specialization.new(1, "Mechanician", CardType.Type.MECHANICAL)
const NECROMANCER: Specialization = Specialization.new(2, "Necromancer", CardType.Type.DEATH)
const CHAOSMASTER: Specialization = Specialization.new(3, "Chaosmaster", CardType.Type.CHAOS)
const DOMINATOR: Specialization = Specialization.new(4, "Dominator", CardType.Type.CONTROL)
const ILLUSIONIST: Specialization = Specialization.new(5, "Illusionist", CardType.Type.ILLUSION)
const DEMONOLOGIST: Specialization = Specialization.new(6, "Demonologist", CardType.Type.DEMONIC)
const SORCERER: Specialization = Specialization.new(7, "Sorcerer", CardType.Type.SORCERY)
const BEASTMASTER: Specialization = Specialization.new(8, "Beastmaster", CardType.Type.BEAST)
const GOBLIN_CHIEFTAN: Specialization = Specialization.new(9, "Goblin Chieftan", CardType.Type.GOBLINS)
const MAD_HERMIT: Specialization = Specialization.new(10, "Mad Hermit", CardType.Type.FOREST)
const CHRONOMANCER: Specialization = Specialization.new(11, "Chronomancer", CardType.Type.TIME)
const WARRIOR_PRIEST: Specialization = Specialization.new(12, "Warrior Priest", CardType.Type.SPIRIT)
const VAMPIRE_LORD: Specialization = Specialization.new(13, "Vampire Lord", CardType.Type.VAMPIRIC)
const CULTIST: Specialization = Specialization.new(14, "Cultist", CardType.Type.CULT)
const GOLEM_MASTER: Specialization = Specialization.new(15, "Golem Master", CardType.Type.GOLEM)
const RANDOM: Specialization = Specialization.new(16, "Random", CardType.Type.HOLY)

static var ALL_SPECIALIZATIONS: Array = [
	CLERIC,
	MECHANICIAN,
	NECROMANCER,
	CHAOSMASTER,
	DOMINATOR,
	ILLUSIONIST,
	DEMONOLOGIST,
	SORCERER,
	BEASTMASTER,
	GOBLIN_CHIEFTAN,
	MAD_HERMIT,
	CHRONOMANCER,
	WARRIOR_PRIEST,
	VAMPIRE_LORD,
	CULTIST,
	GOLEM_MASTER,
	RANDOM
]

static func get_by_id(spec_id: int) -> Specialization:
	if spec_id < 0 or spec_id >= ALL_SPECIALIZATIONS.size():
		return null
	return ALL_SPECIALIZATIONS[spec_id]

static func get_by_title(title: String) -> Specialization:
	if title == null or title.is_empty():
		return null

	var title_lower: String = title.to_lower()

	for spec in ALL_SPECIALIZATIONS:
		if spec.title.to_lower() == title_lower:
			return spec

	return null

static func get_titles() -> Array:
	var titles: Array = []
	for spec in ALL_SPECIALIZATIONS:
		titles.append(spec.title)
	return titles

static func from_type(spec_type: Type) -> Specialization:
	if spec_type < 0 or spec_type >= Type.size():
		return null
	return ALL_SPECIALIZATIONS[spec_type]
