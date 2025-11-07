extends RefCounted
class_name SoundTypes

## Centralized sound enum definitions
## Prevents type scoping issues when used across multiple files

enum Sound {
	BACKGROUND1,
	BACKGROUND2,
	BACKGROUND3,
	POSITIVE_EFFECT,
	NEGATIVE_EFFECT,
	MAGIC,
	ATTACK,
	SUMMON_DROP,
	SUMMONED,
	DAMAGED,
	DEATH,
	GAMEOVER,
	CLICK
}
