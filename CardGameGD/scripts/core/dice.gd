extends RefCounted
class_name Dice

var num: int
var sides: int

func _init(number: int = 1, num_sides: int = 6) -> void:
	num = number
	sides = num_sides

func roll() -> int:
	var sum: int = 0
	for i in range(num):
		sum += randi_range(1, sides)
	return sum
