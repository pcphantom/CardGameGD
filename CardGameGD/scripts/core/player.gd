extends RefCounted
class_name Player

const STARTING_LIFE: int = 60
const MAX_STRENGTH: int = 99
const TYPES: Array = [
	CardType.Type.FIRE,
	CardType.Type.AIR,
	CardType.Type.WATER,
	CardType.Type.EARTH,
	CardType.Type.OTHER
]

var id: String = ""
var img_name: String = "face1"
var player_class: Specializations.Specialization = null
var life: int = STARTING_LIFE
var name: String = ""

var strength: Dictionary = {
	CardType.Type.FIRE: 0,
	CardType.Type.AIR: 0,
	CardType.Type.WATER: 0,
	CardType.Type.EARTH: 0,
	CardType.Type.OTHER: 0
}

# Growth rate tracking - cards can modify these while in play
# Base growth rate is +1 per turn, cards add/subtract from this
var growth_rate: Dictionary = {
	CardType.Type.FIRE: 1,
	CardType.Type.AIR: 1,
	CardType.Type.WATER: 1,
	CardType.Type.EARTH: 1,
	CardType.Type.OTHER: 1
}

var fire_cards: Array = []
var air_cards: Array = []
var water_cards: Array = []
var earth_cards: Array = []
var special_cards: Array = []

func _init() -> void:
	id = generate_uuid()
	player_class = Specializations.CLERIC
	init()

func init() -> void:
	var dice: Dice = Dice.new(1, 6)
	strength[CardType.Type.FIRE] = dice.roll()
	strength[CardType.Type.AIR] = dice.roll()
	strength[CardType.Type.WATER] = dice.roll()
	strength[CardType.Type.EARTH] = dice.roll()
	strength[CardType.Type.OTHER] = dice.roll()
	life = STARTING_LIFE

func generate_uuid() -> String:
	var uuid: String = ""
	for i in range(32):
		var n: int = randi() % 16
		if i == 8 or i == 12 or i == 16 or i == 20:
			uuid += "-"
		uuid += "0123456789abcdef"[n]
	return uuid

func get_id() -> String:
	return id

func set_id(player_id: String) -> void:
	id = player_id

func get_name() -> String:
	return name

func set_name(player_name: String) -> void:
	name = player_name

func get_img_name() -> String:
	return img_name

func set_img_name(image_name: String) -> void:
	img_name = image_name

func get_player_class() -> Specializations.Specialization:
	return player_class

func set_player_class(spec: Specializations.Specialization) -> void:
	player_class = spec

func get_life() -> int:
	return life

func set_life(amount: int) -> void:
	life = amount

func modify_life(amount: int) -> void:
	life += amount

func increment_life(inc: int) -> void:
	life += inc

func decrement_life(dec: int) -> void:
	life -= dec

func get_strength(type: CardType.Type) -> int:
	if strength.has(type):
		return strength[type]
	return strength[CardType.Type.OTHER]

func set_strength(type: CardType.Type, amount: int) -> void:
	var clamped_amount: int = clampi(amount, 0, MAX_STRENGTH)
	if strength.has(type):
		strength[type] = clamped_amount
	else:
		strength[CardType.Type.OTHER] = clamped_amount

func increment_strength(type: CardType.Type, amount: int) -> void:
	var current: int = get_strength(type)
	set_strength(type, current + amount)

func decrement_strength(type: CardType.Type, amount: int) -> void:
	var current: int = get_strength(type)
	set_strength(type, current - amount)

func increment_strength_all(incr: int) -> void:
	for type in TYPES:
		increment_strength(type, incr)

## Apply growth rates to strengths - called each turn
func apply_growth_rates() -> void:
	print("[GROWTH RATE] Player %s applying growth rates:" % name)
	for type in TYPES:
		var rate: int = growth_rate[type]
		if rate != 0:
			var type_name := CardType.get_title(type)
			var old_str := get_strength(type)
			increment_strength(type, rate)
			var new_str := get_strength(type)
			print("  %s: %d (rate: %+d) -> %d" % [type_name, old_str, rate, new_str])

## Modify growth rate for a type - cards call this when summoned/dying
func increment_growth_rate(type: CardType.Type, amount: int) -> void:
	if growth_rate.has(type):
		growth_rate[type] += amount
		print("[GROWTH RATE] Player %s %s growth rate: %+d (now %+d/turn)" % [name, CardType.get_title(type), amount, growth_rate[type]])

func decrement_growth_rate(type: CardType.Type, amount: int) -> void:
	increment_growth_rate(type, -amount)

func increment_growth_rate_all(amount: int) -> void:
	for type in TYPES:
		increment_growth_rate(type, amount)

func decrement_growth_rate_all(amount: int) -> void:
	increment_growth_rate_all(-amount)

func reset_strengths() -> void:
	for type in TYPES:
		set_strength(type, 0)

func get_strength_fire() -> int:
	return get_strength(CardType.Type.FIRE)

func get_strength_air() -> int:
	return get_strength(CardType.Type.AIR)

func get_strength_water() -> int:
	return get_strength(CardType.Type.WATER)

func get_strength_earth() -> int:
	return get_strength(CardType.Type.EARTH)

func get_strength_special() -> int:
	return get_strength(CardType.Type.OTHER)

func set_strength_fire(value: int) -> void:
	set_strength(CardType.Type.FIRE, value)

func set_strength_air(value: int) -> void:
	set_strength(CardType.Type.AIR, value)

func set_strength_water(value: int) -> void:
	set_strength(CardType.Type.WATER, value)

func set_strength_earth(value: int) -> void:
	set_strength(CardType.Type.EARTH, value)

func set_strength_special(value: int) -> void:
	set_strength(CardType.Type.OTHER, value)

func get_cards(type: CardType.Type) -> Array:
	match type:
		CardType.Type.FIRE:
			return fire_cards
		CardType.Type.AIR:
			return air_cards
		CardType.Type.WATER:
			return water_cards
		CardType.Type.EARTH:
			return earth_cards
		_:
			return special_cards

func set_cards(type: CardType.Type, cards: Array) -> void:
	match type:
		CardType.Type.FIRE:
			fire_cards = cards
		CardType.Type.AIR:
			air_cards = cards
		CardType.Type.WATER:
			water_cards = cards
		CardType.Type.EARTH:
			earth_cards = cards
		_:
			special_cards = cards

func get_fire_cards() -> Array:
	return fire_cards

func get_air_cards() -> Array:
	return air_cards

func get_water_cards() -> Array:
	return water_cards

func get_earth_cards() -> Array:
	return earth_cards

func get_special_cards() -> Array:
	return special_cards

func get_all_cards() -> Array:
	# REASON: Card collection grid needs all player cards combined
	# RETURNS: Array of all cards from all element types
	var cards: Array = []
	cards.append_array(fire_cards)
	cards.append_array(air_cards)
	cards.append_array(water_cards)
	cards.append_array(earth_cards)
	cards.append_array(special_cards)
	return cards

func enable_disable_cards(type: CardType.Type) -> void:
	var pstr: int = get_strength(type)
	var cards: Array = get_cards(type)
	for card_image in cards:
		if card_image.get_card().get_cost() <= pstr:
			card_image.set_enabled(true)
			card_image.set_color(Color.WHITE)
		else:
			card_image.set_enabled(false)
			card_image.set_color(Color.DARK_GRAY)

func pick_best_enabled_card():
	var pick = null
	for type in TYPES:
		var c = pick_best_enabled_card_of_type(type)
		if c == null:
			continue
		if pick == null:
			pick = c
		elif c.get_card().get_cost() > pick.get_card().get_cost():
			pick = c
	if pick != null:
		print("Computer opponent picked: ", pick)
	return pick

func pick_best_enabled_card_of_type(type: CardType.Type):
	var card = null
	var cards: Array = get_cards(type)
	var highest_cost: int = 0
	for c in cards:
		if not c.is_enabled():
			continue
		if c.get_card().get_cost() > highest_cost:
			highest_cost = c.get_card().get_cost()
			card = c
	return card

func pick_random_enabled_card():
	var dice: Dice = Dice.new(1, 5)
	var roll: int = dice.roll()
	var type: CardType.Type = TYPES[roll - 1]
	return pick_random_enabled_card_of_type(type)

func pick_random_enabled_card_of_type(type: CardType.Type):
	var ci = null
	var cards: Array = get_cards(type)
	var enabled_count: int = 0

	for card in cards:
		if card.is_enabled():
			enabled_count += 1

	if enabled_count == 0:
		return null

	var dice: Dice = Dice.new(1, 4)
	var attempts: int = 0
	var max_attempts: int = 100

	while attempts < max_attempts:
		var roll: int = dice.roll()
		if roll - 1 < cards.size():
			ci = cards[roll - 1]
			if ci != null and ci.is_enabled():
				break
		attempts += 1

	return ci

func clone_for_evaluation() -> Player:
	var p: Player = Player.new()
	p.life = life
	p.player_class = player_class
	p.id = id
	p.img_name = img_name
	p.name = name

	for type in TYPES:
		p.set_strength(type, get_strength(type))

	return p

func _to_string() -> String:
	return "Player [id=%s, name=%s, imgName=%s, playerClass=%s, life=%d, strengthFire=%d, strengthAir=%d, strengthWater=%d, strengthEarth=%d, strengthSpecial=%d]" % [
		id,
		name,
		img_name,
		player_class.get_title() if player_class != null else "None",
		life,
		get_strength_fire(),
		get_strength_air(),
		get_strength_water(),
		get_strength_earth(),
		get_strength_special()
	]

## Java: public void incrementStrengthAll(int incr) (Player.java line 141)
func incrementStrengthAll(incr: int) -> void:
	strength[CardType.Type.FIRE] += incr
	strength[CardType.Type.AIR] += incr
	strength[CardType.Type.EARTH] += incr
	strength[CardType.Type.WATER] += incr
	strength[CardType.Type.OTHER] += incr

## Java: public void enableDisableCards(CardType type) (Player.java line 169)
func enableDisableCards(type) -> void:
	var pstr: int = get_strength(type)
	var cards: Array = get_cards(type)
	for card in cards:
		if card.get_card().get_cost() <= pstr:
			card.set_enabled(true)
			card.set_color(Color.WHITE)
		else:
			card.set_enabled(false)
			card.set_color(Color.DARK_GRAY)

## Java: public CardImage pickRandomEnabledCard() (Player.java line 235)
func pickRandomEnabledCard() -> CardImage:
	# Try each type until we find an enabled card
	var types_to_try: Array = TYPES.duplicate()
	types_to_try.shuffle()

	for type in types_to_try:
		var card: CardImage = pick_random_enabled_card_of_type(type)
		if card != null:
			return card

	return null
