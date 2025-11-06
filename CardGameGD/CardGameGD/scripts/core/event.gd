extends RefCounted
class_name Event

# Event
#
# Defines network event types for multiplayer game synchronization.
# Matches Event.java from the network package.

enum Type {
	REMOTE_PLAYER_INFO_INIT = 0,
	PLAYER_INCR_STRENGTH_ALL = 1,
	CARD_SUMMONED = 2,
	CARD_START_TURN_CHECK = 3,
	CARD_ATTACK = 4,
	CARD_END_TURN_CHECK = 5,
	SPELL_CAST = 6,
	GAME_OVER = 7
}

static func to_string(event_type: int) -> String:
	match event_type:
		Type.REMOTE_PLAYER_INFO_INIT:
			return "REMOTE_PLAYER_INFO_INIT"
		Type.PLAYER_INCR_STRENGTH_ALL:
			return "PLAYER_INCR_STRENGTH_ALL"
		Type.CARD_SUMMONED:
			return "CARD_SUMMONED"
		Type.CARD_START_TURN_CHECK:
			return "CARD_START_TURN_CHECK"
		Type.CARD_ATTACK:
			return "CARD_ATTACK"
		Type.CARD_END_TURN_CHECK:
			return "CARD_END_TURN_CHECK"
		Type.SPELL_CAST:
			return "SPELL_CAST"
		Type.GAME_OVER:
			return "GAME_OVER"
		_:
			return "UNKNOWN_EVENT_%d" % event_type

static func from_string(event_name: String) -> int:
	var event_name_upper: String = event_name.to_upper()

	match event_name_upper:
		"REMOTE_PLAYER_INFO_INIT":
			return Type.REMOTE_PLAYER_INFO_INIT
		"PLAYER_INCR_STRENGTH_ALL":
			return Type.PLAYER_INCR_STRENGTH_ALL
		"CARD_SUMMONED":
			return Type.CARD_SUMMONED
		"CARD_START_TURN_CHECK":
			return Type.CARD_START_TURN_CHECK
		"CARD_ATTACK":
			return Type.CARD_ATTACK
		"CARD_END_TURN_CHECK":
			return Type.CARD_END_TURN_CHECK
		"SPELL_CAST":
			return Type.SPELL_CAST
		"GAME_OVER":
			return Type.GAME_OVER
		_:
			return -1

static func is_valid(event_type: int) -> bool:
	return event_type >= Type.REMOTE_PLAYER_INFO_INIT and event_type <= Type.GAME_OVER
