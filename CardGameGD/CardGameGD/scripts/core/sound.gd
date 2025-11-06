class_name Sound

# Sound class representing a game sound with its properties
# Replaces Sound.java enum from the original libGDX implementation

# Sound type constants matching the original Sound enum
enum Type {
	BACKGROUND1,
	BACKGROUND2,
	BACKGROUND3,
	POSITIVE_EFFECT,
	NEGATIVE_EFFECT,
	MAGIC,
	ATTACK,
	SUMMON_DROP,
	SUMMONED
}

# Sound properties
var file: String
var looping: bool
var volume: float

func _init(p_file: String = "", p_looping: bool = false, p_volume: float = 0.3):
	file = p_file
	looping = p_looping
	volume = p_volume

# Static sound configurations matching the original Java Sound enum
static func get_sound(sound_type: Type) -> Sound:
	match sound_type:
		Type.BACKGROUND1:
			return Sound.new("res://assets/sounds/combat1.ogg", false, 0.1)
		Type.BACKGROUND2:
			return Sound.new("res://assets/sounds/combat2.ogg", false, 0.1)
		Type.BACKGROUND3:
			return Sound.new("res://assets/sounds/combat3.ogg", false, 0.1)
		Type.POSITIVE_EFFECT:
			return Sound.new("res://assets/sounds/PositiveEffect.ogg", false, 0.3)
		Type.NEGATIVE_EFFECT:
			return Sound.new("res://assets/sounds/NegativeEffect.ogg", false, 0.3)
		Type.MAGIC:
			return Sound.new("res://assets/sounds/magic.ogg", false, 0.3)
		Type.ATTACK:
			return Sound.new("res://assets/sounds/attack.ogg", false, 0.3)
		Type.SUMMON_DROP:
			return Sound.new("res://assets/sounds/summondrop.ogg", false, 0.3)
		Type.SUMMONED:
			return Sound.new("res://assets/sounds/summon1.ogg", false, 0.3)
		_:
			return Sound.new("res://assets/sounds/magic.ogg", false, 0.3)

# Getters matching the original Java implementation
func get_file() -> String:
	return file

func get_looping() -> bool:
	return looping

func get_volume() -> float:
	return volume
