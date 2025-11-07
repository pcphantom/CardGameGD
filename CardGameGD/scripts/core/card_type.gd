extends RefCounted
class_name CardType

enum Type {
	FIRE,
	WATER,
	AIR,
	EARTH,
	DEATH,
	HOLY,
	MECHANICAL,
	ILLUSION,
	CONTROL,
	CHAOS,
	DEMONIC,
	SORCERY,
	BEAST,
	BEASTS_ABILITIES,
	GOBLINS,
	FOREST,
	TIME,
	SPIRIT,
	VAMPIRIC,
	CULT,
	GOLEM,
	OTHER
}

const TITLES: Dictionary = {
	Type.FIRE: "Fire",
	Type.WATER: "Water",
	Type.AIR: "Air",
	Type.EARTH: "Earth",
	Type.DEATH: "Death",
	Type.HOLY: "Holy",
	Type.MECHANICAL: "Mechanical",
	Type.ILLUSION: "Illusion",
	Type.CONTROL: "Control",
	Type.CHAOS: "Chaos",
	Type.DEMONIC: "Demonic",
	Type.SORCERY: "Sorcery",
	Type.BEAST: "Beast",
	Type.BEASTS_ABILITIES: "Beasts Abilities",
	Type.GOBLINS: "Goblins",
	Type.FOREST: "Forest",
	Type.TIME: "Time",
	Type.SPIRIT: "Spirit",
	Type.VAMPIRIC: "Blood",
	Type.CULT: "Cult",
	Type.GOLEM: "Golem",
	Type.OTHER: "Other"
}

static func get_title(card_type: Type) -> String:
	return TITLES.get(card_type, "")

static func get_type_name(card_type: Type) -> String:
	return TITLES.get(card_type, "Unknown")

static func from_string(text: String) -> int:
	if text == null or text.is_empty():
		return -1

	var text_upper: String = text.to_upper()

	for type_value in Type.values():
		var type_name: String = Type.keys()[type_value]
		if type_name == text_upper:
			return type_value

	return -1
