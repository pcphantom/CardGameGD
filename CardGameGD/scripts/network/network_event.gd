class_name NetworkEvent

# NetworkEvent class for network communication
# Replaces NetworkEvent.java from the original libGDX implementation
# Uses Dictionary serialization instead of Java Serializable

# Event types enum matching Event.java
enum EventType {
	REMOTE_PLAYER_INFO_INIT,
	PLAYER_INCR_STRENGTH_ALL,
	CARD_SUMMONED,
	CARD_START_TURN_CHECK,
	CARD_ATTACK,
	CARD_END_TURN_CHECK,
	SPELL_CAST,
	GAME_OVER
}

# Network event properties
var event_id: String
var event_type: EventType
var slot: int = 0
var life: int = 0
var life_incr: int = 0
var life_decr: int = 0
var attack: int = 0
var spell_name: String = ""
var caster: String = ""
var spell_target_card_name: String = ""
var targeted_card_owner_id: String = ""
var damage_via_spell: bool = false
var card_name: String = ""
var player_id: String = ""
var player_icon: String = ""
var player_class: String = ""
var type_strength_affected: int = -1  # CardType enum value
var strength_affected: int = 0
var player_data: Dictionary = {}

# Constructor matching Java constructors
func _init(p_event_type: EventType = EventType.CARD_SUMMONED, p_player_id: String = ""):
	event_id = _generate_uuid()
	event_type = p_event_type
	player_id = p_player_id

# Initialize with slot and card name (matching Java constructor)
static func create_with_slot(p_event_type: EventType, p_slot: int, p_card_name: String, p_player_id: String) -> NetworkEvent:
	var event := NetworkEvent.new(p_event_type, p_player_id)
	event.slot = p_slot
	event.card_name = p_card_name
	return event

# Initialize with player data (matching Java constructor)
static func create_with_player(p_event_type: EventType, player: Dictionary) -> NetworkEvent:
	var event := NetworkEvent.new(p_event_type, player.get("id", ""))
	event.player_data = player
	event.player_icon = player.get("img_name", "")
	event.player_class = player.get("player_class", "")
	return event

# Generate UUID for event tracking
func _generate_uuid() -> String:
	var uuid := ""

	# Generate UUID in format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
	# where x is any hexadecimal digit and y is one of 8, 9, A, or B
	randomize()

	for i in range(36):
		if i == 8 or i == 13 or i == 18 or i == 23:
			uuid += "-"
		elif i == 14:
			uuid += "4"  # Version 4 UUID
		elif i == 19:
			uuid += ["8", "9", "a", "b"][randi() % 4]  # Variant
		else:
			uuid += "0123456789abcdef"[randi() % 16]

	return uuid

# Serialize to Dictionary for network transmission
func to_dict() -> Dictionary:
	var data := {
		"event_id": event_id,
		"event_type": event_type,
		"slot": slot,
		"life": life,
		"life_incr": life_incr,
		"life_decr": life_decr,
		"attack": attack,
		"spell_name": spell_name,
		"caster": caster,
		"spell_target_card_name": spell_target_card_name,
		"targeted_card_owner_id": targeted_card_owner_id,
		"damage_via_spell": damage_via_spell,
		"card_name": card_name,
		"player_id": player_id,
		"player_icon": player_icon,
		"player_class": player_class,
		"type_strength_affected": type_strength_affected,
		"strength_affected": strength_affected,
		"player_data": player_data
	}

	return data

# Deserialize from Dictionary received from network
static func from_dict(data: Dictionary) -> NetworkEvent:
	if data.is_empty():
		push_warning("NetworkEvent: Cannot deserialize empty dictionary")
		return null

	var event_type: EventType = data.get("event_type", EventType.CARD_SUMMONED)
	var event := NetworkEvent.new(event_type, data.get("player_id", ""))

	# Restore all properties
	event.event_id = data.get("event_id", event.event_id)
	event.slot = data.get("slot", 0)
	event.life = data.get("life", 0)
	event.life_incr = data.get("life_incr", 0)
	event.life_decr = data.get("life_decr", 0)
	event.attack = data.get("attack", 0)
	event.spell_name = data.get("spell_name", "")
	event.caster = data.get("caster", "")
	event.spell_target_card_name = data.get("spell_target_card_name", "")
	event.targeted_card_owner_id = data.get("targeted_card_owner_id", "")
	event.damage_via_spell = data.get("damage_via_spell", false)
	event.card_name = data.get("card_name", "")
	event.player_icon = data.get("player_icon", "")
	event.player_class = data.get("player_class", "")
	event.type_strength_affected = data.get("type_strength_affected", -1)
	event.strength_affected = data.get("strength_affected", 0)
	event.player_data = data.get("player_data", {})

	return event

# Get event type as string (for debugging)
func get_event_type_string() -> String:
	match event_type:
		EventType.REMOTE_PLAYER_INFO_INIT:
			return "REMOTE_PLAYER_INFO_INIT"
		EventType.PLAYER_INCR_STRENGTH_ALL:
			return "PLAYER_INCR_STRENGTH_ALL"
		EventType.CARD_SUMMONED:
			return "CARD_SUMMONED"
		EventType.CARD_START_TURN_CHECK:
			return "CARD_START_TURN_CHECK"
		EventType.CARD_ATTACK:
			return "CARD_ATTACK"
		EventType.CARD_END_TURN_CHECK:
			return "CARD_END_TURN_CHECK"
		EventType.SPELL_CAST:
			return "SPELL_CAST"
		EventType.GAME_OVER:
			return "GAME_OVER"
		_:
			return "UNKNOWN"

# String representation matching Java toString()
func _to_string() -> String:
	return "NetworkEvent %s (%s) slot=%d, life=%d, life_incr=%d, life_decr=%d, attack=%d, spell_name=%s, card_name=%s, damage_via_spell=%s, player_id=%s, player_icon=%s, player_class=%s, type_strength_affected=%d, strength_affected=%d, player_data=%s" % [
		get_event_type_string(),
		event_id,
		slot,
		life,
		life_incr,
		life_decr,
		attack,
		spell_name,
		card_name,
		damage_via_spell,
		player_id,
		player_icon,
		player_class,
		type_strength_affected,
		strength_affected,
		str(player_data)
	]

# Getters matching Java implementation
func get_event_type() -> EventType:
	return event_type

func get_slot() -> int:
	return slot

func get_spell_name() -> String:
	return spell_name

func get_card_name() -> String:
	return card_name

func get_life() -> int:
	return life

func get_life_incr() -> int:
	return life_incr

func get_life_decr() -> int:
	return life_decr

func get_attack() -> int:
	return attack

func is_damage_via_spell() -> bool:
	return damage_via_spell

func get_type_strength_affected() -> int:
	return type_strength_affected

func get_strength_affected() -> int:
	return strength_affected

func get_player_id() -> String:
	return player_id

func get_player_icon() -> String:
	return player_icon

func get_player_class() -> String:
	return player_class

func get_player_data() -> Dictionary:
	return player_data

func get_spell_target_card_name() -> String:
	return spell_target_card_name

func get_caster() -> String:
	return caster

func get_targeted_card_owner_id() -> String:
	return targeted_card_owner_id

# Setters matching Java implementation
func set_event_type(value: EventType) -> void:
	event_type = value

func set_slot(value: int) -> void:
	slot = value

func set_spell_name(value: String) -> void:
	spell_name = value

func set_card_name(value: String) -> void:
	card_name = value

func set_life(value: int) -> void:
	life = value

func set_life_incr(value: int) -> void:
	life_incr = value

func set_life_decr(value: int) -> void:
	life_decr = value

func set_attack(value: int) -> void:
	attack = value

func set_damage_via_spell(value: bool) -> void:
	damage_via_spell = value

func set_type_strength_affected(value: int) -> void:
	type_strength_affected = value

func set_strength_affected(value: int) -> void:
	strength_affected = value

func set_player_id(value: String) -> void:
	player_id = value

func set_player_icon(value: String) -> void:
	player_icon = value

func set_player_class(value: String) -> void:
	player_class = value

func set_player_data(value: Dictionary) -> void:
	player_data = value

func set_spell_target_card_name(value: String) -> void:
	spell_target_card_name = value

func set_caster(value: String) -> void:
	caster = value

func set_targeted_card_owner_id(value: String) -> void:
	targeted_card_owner_id = value
