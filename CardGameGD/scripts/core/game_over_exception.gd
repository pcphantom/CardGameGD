extends RefCounted
class_name GameOverException

var died_player_id: String = ""
var message: String = ""

func _init(player_id: String = "", error_message: String = "") -> void:
	died_player_id = player_id
	if error_message.is_empty():
		message = "Game Over: Player %s has died" % player_id
	else:
		message = error_message

func get_died_player_id() -> String:
	return died_player_id

func set_died_player_id(player_id: String) -> void:
	died_player_id = player_id

func get_message() -> String:
	return message

func set_message(error_message: String) -> void:
	message = error_message

func _to_string() -> String:
	return message
