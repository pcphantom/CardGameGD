extends RefCounted
class_name Card

enum TargetType {
	OWNER,
	OPPONENT,
	ANY
}

var name: String = ""
var cardname: String = ""
var desc: String = ""
var type: CardType.Type = CardType.Type.FIRE
var cost: int = 0
var attack: int = 0
var original_attack: int = 0
var life: int = 0
var original_life: int = 0
var self_inflicting_damage: int = 0
var spell: bool = false
var targetable: bool = false
var targetable_on_empty_slot_only: bool = false
var wall: bool = false
var target_type: TargetType = TargetType.OWNER
var must_be_summoned_on_card: String = ""

func _init(card_type: CardType.Type = CardType.Type.FIRE) -> void:
	type = card_type

func clone() -> Card:
	var c: Card = Card.new(type)
	c.name = name
	c.attack = attack
	c.life = life
	c.original_life = original_life
	c.original_attack = original_attack
	c.self_inflicting_damage = self_inflicting_damage
	c.cardname = cardname
	c.cost = cost
	c.desc = desc
	c.spell = spell
	c.wall = wall
	c.targetable = targetable
	c.targetable_on_empty_slot_only = targetable_on_empty_slot_only
	c.target_type = target_type
	c.must_be_summoned_on_card = must_be_summoned_on_card
	return c

func get_name() -> String:
	return name

func set_name(value: String) -> void:
	name = value

func get_attack() -> int:
	return attack

func set_attack(value: int) -> void:
	attack = value

func increment_attack(inc: int) -> void:
	if wall:
		return
	attack += inc

func decrement_attack(dec: int) -> void:
	if wall:
		return
	attack -= dec

func get_life() -> int:
	return life

func set_life(value: int) -> void:
	life = value

func increment_life(inc: int) -> void:
	life += inc

func decrement_life(dec: int) -> void:
	life -= dec

func get_cardname() -> String:
	return cardname

func set_cardname(value: String) -> void:
	cardname = value

func get_type() -> CardType.Type:
	return type

func set_type(value: CardType.Type) -> void:
	type = value

func get_cost() -> int:
	return cost

func set_cost(value: int) -> void:
	cost = value

func is_spell() -> bool:
	return spell

func set_spell(value: bool) -> void:
	spell = value

func get_desc() -> String:
	return desc

func set_desc(value: String) -> void:
	desc = value

func is_targetable() -> bool:
	return targetable

func set_targetable(value: bool) -> void:
	targetable = value

func is_wall() -> bool:
	return wall

func set_wall(value: bool) -> void:
	wall = value

func get_original_life() -> int:
	return original_life

func set_original_life(value: int) -> void:
	original_life = value

func get_original_attack() -> int:
	return original_attack

func set_original_attack(value: int) -> void:
	original_attack = value

func get_self_inflicting_damage() -> int:
	return self_inflicting_damage

func set_self_inflicting_damage(value: int) -> void:
	self_inflicting_damage = value

func get_must_be_summoned_on_card() -> String:
	return must_be_summoned_on_card

func set_must_be_summoned_on_card(value: String) -> void:
	must_be_summoned_on_card = value

func is_targetable_on_empty_slot_only() -> bool:
	return targetable_on_empty_slot_only

func set_targetable_on_empty_slot_only(value: bool) -> void:
	targetable_on_empty_slot_only = value

func get_target_type() -> TargetType:
	return target_type

func set_target_type(value: TargetType) -> void:
	target_type = value

static func from_target_type_string(text: String) -> TargetType:
	if text == null or text.is_empty():
		return TargetType.OWNER

	var text_upper: String = text.to_upper()

	for target_value in TargetType.values():
		var target_name: String = TargetType.keys()[target_value]
		if target_name == text_upper:
			return target_value

	return TargetType.OWNER

func _to_string() -> String:
	return "%s\t\t\t%s\tattack=%d\tlife=%d\tcost=%d\tspell=%s" % [
		cardname,
		CardType.get_title(type),
		attack,
		life,
		cost,
		spell
	]

func hash() -> int:
	if name.is_empty():
		return 0
	return name.hash()

func equals(other: Card) -> bool:
	if other == null:
		return false
	if name.is_empty() and not other.name.is_empty():
		return false
	if not name.is_empty() and other.name.is_empty():
		return false
	return name == other.name
