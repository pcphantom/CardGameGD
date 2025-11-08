class_name CardType
extends RefCounted

## ============================================================================
## CardType.gd - EXACT translation of CardType.java from CardGameGDX
## ============================================================================
## This is a LITERAL translation with ZERO creative additions.
## Every enum value, method, and line of logic matches the Java source exactly.
## 
## Original: src/main/java/org/antinori/cards/CardType.java
## Translation: scripts/core/card_type.gd
##
## ONLY CHANGES FROM JAVA:
## - Package path: org.antinori.cards → scripts/core (Godot project structure)
## - Java enum → GDScript enum Type (GDScript convention)
## - String[] → Array (GDScript type)
## - null → null (same)
## ============================================================================

# ============================================================================
# ENUM TYPE (Java: public enum CardType)
# ============================================================================
# In Java, CardType itself IS the enum
# In GDScript, we create an enum Type inside the class
# This maintains the same usage pattern: CardType.FIRE, CardType.WATER, etc.

enum Type {
	FIRE = 0,           # Java: FIRE ("Fire")
	WATER = 1,          # Java: WATER("Water")
	AIR = 2,            # Java: AIR("Air")
	EARTH = 3,          # Java: EARTH("Earth")
	DEATH = 4,          # Java: DEATH("Death")
	HOLY = 5,           # Java: HOLY("Holy")
	MECHANICAL = 6,     # Java: MECHANICAL("Mechanical")
	ILLUSION = 7,       # Java: ILLUSION("Illusion")
	CONTROL = 8,        # Java: CONTROL("Control")
	CHAOS = 9,          # Java: CHAOS("Chaos")
	DEMONIC = 10,       # Java: DEMONIC("Demonic")
	SORCERY = 11,       # Java: SORCERY("Sorcery")
	BEAST = 12,         # Java: BEAST("Beast")
	BEASTS_ABILITIES = 13,  # Java: BEASTS_ABILITIES("Beasts Abilities")
	GOBLINS = 14,       # Java: GOBLINS("Goblins")
	FOREST = 15,        # Java: FOREST("Forest")
	TIME = 16,          # Java: TIME("Time")
	SPIRIT = 17,        # Java: SPIRIT("Spirit")
	VAMPIRIC = 18,      # Java: VAMPIRIC("Blood")
	CULT = 19,          # Java: CULT("Cult")
	GOLEM = 20,         # Java: GOLEM("Golem")
	OTHER = 21          # Java: OTHER("Other")
}

# ============================================================================
# TITLE MAPPING (Java: private String title field in enum)
# ============================================================================
# Java stores title as an instance field in each enum value
# GDScript uses a static dictionary to map enum values to titles
# This is EQUIVALENT functionality, different implementation

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

# ============================================================================
# METHOD: getTitle()
# ============================================================================
## Java: public String getTitle() { return this.title; }
## 
## Returns the display title for a given CardType enum value
## 
## @param card_type: The Type enum value (e.g., CardType.Type.FIRE)
## @return: The title string (e.g., "Fire")
##
## EXACT TRANSLATION:
## - Java instance method → GDScript static function (enums are different)
## - Same return type (String)
## - Same functionality (returns title string)
static func get_title(card_type: Type) -> String:
	# Java: return this.title;
	# GDScript: return TITLES[card_type]
	if TITLES.has(card_type):
		return TITLES[card_type]
	return "Unknown"  # Defensive fallback (Java wouldn't reach here)

# ============================================================================
# METHOD: fromString(String text)
# ============================================================================
## Java: public static CardType fromString(String text)
##
## Converts a string to a CardType enum value (case-insensitive)
## 
## @param text: The string to convert (e.g., "fire", "FIRE", "Fire")
## @return: The matching Type enum value, or null if not found
##
## EXACT TRANSLATION:
## - Java: checks text != null, iterates CardType.values()
## - GDScript: checks text != null, iterates Type.values()
## - Both use case-insensitive comparison
## - Both return null if no match
##
## Java code:
## ```java
## public static CardType fromString(String text) {
##     if (text != null) {
##         for (CardType c : CardType.values()) {
##             if (c.toString().equalsIgnoreCase(text)) {
##                 return c;
##             }
##         }
##     }
##     return null;
## }
## ```
static func from_string(text: String) -> Variant:  # Returns Type or null
	# Java: if (text != null)
	if text == null or text.is_empty():
		return null
	
	# Java: for (CardType c : CardType.values())
	# GDScript: iterate through all enum values
	for card_type in Type.values():
		# Java: c.toString().equalsIgnoreCase(text)
		# GDScript: compare enum name (uppercase) to uppercase text
		var enum_name: String = Type.keys()[card_type]
		if enum_name.to_upper() == text.to_upper():
			return card_type
	
	# Java: return null;
	return null

# ============================================================================
# HELPER METHOD: type_to_string(Type)
# ============================================================================
## ADDITIONAL HELPER (not in Java, but useful for GDScript)
## Converts Type enum value to its string name
## 
## @param card_type: The Type enum value
## @return: The enum name as string (e.g., "FIRE")
##
## This matches Java's implicit toString() on enum values
static func type_to_string(card_type: Type) -> String:
	return Type.keys()[card_type]

# ============================================================================
# HELPER METHOD: get_all_types()
# ============================================================================
## ADDITIONAL HELPER (not in Java, but matches CardType.values())
## Returns array of all Type enum values
## 
## @return: Array of all Type enum values
##
## This matches Java's CardType.values() method
static func get_all_types() -> Array:
	return Type.values()
