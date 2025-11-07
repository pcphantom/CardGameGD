extends Node

# CardDatabase Autoload Singleton
#
# Manages all card data and replaces CardSetup.java.
# Loads card definitions from JSON/XML and provides query methods.
#
# Accessible globally via: CardDatabase.method_name()

# Card storage
var all_cards: Dictionary = {}
var creature_cards: Array = []
var spell_cards: Array = []
var cards_by_type: Dictionary = {}
var cards_by_specialization: Dictionary = {}

# Load status
var is_loaded: bool = false

# Sample JSON structure for cards.json (Phase 5):
# {
#   "cards": [
#     {
#       "name": "GoblinBerserker",
#       "cardname": "Goblin Berserker",
#       "desc": "A fierce goblin warrior",
#       "type": "FIRE",
#       "attack": 3,
#       "life": 2,
#       "summoningCost": 2,
#       "spell": false,
#       "targetable": false,
#       "targetableOnEmptySlot": false,
#       "target": "OWNER",
#       "selfInflictingDamage": 0,
#       "wall": false,
#       "mustBeSummoneOnCard": ""
#     },
#     {
#       "name": "HellFire",
#       "cardname": "Hell Fire",
#       "desc": "Deal 13 damage to all enemy creatures",
#       "type": "FIRE",
#       "attack": 0,
#       "life": 0,
#       "castingCost": 5,
#       "spell": true,
#       "targetable": false,
#       "targetableOnEmptySlot": false,
#       "target": "OPPONENT",
#       "selfInflictingDamage": 0,
#       "wall": false,
#       "mustBeSummoneOnCard": ""
#     }
#   ]
# }

func _ready() -> void:
	print("CardDatabase: Initializing autoload singleton")
	load_cards()

func load_cards() -> void:
	if is_loaded:
		print("CardDatabase: Cards already loaded")
		return

	all_cards.clear()
	creature_cards.clear()
	spell_cards.clear()
	cards_by_type.clear()
	cards_by_specialization.clear()

	var json_path: String = "res://data/cards.json"
	var xml_path: String = "res://data/cards.xml"

	if ResourceLoader.exists(json_path):
		load_from_json(json_path)
	elif ResourceLoader.exists(xml_path):
		load_from_xml(xml_path)
	else:
		push_warning("CardDatabase: No card data found at %s or %s" % [json_path, xml_path])
		push_warning("CardDatabase: Creating sample test cards for development")
		create_sample_cards()

	organize_cards()
	is_loaded = true
	print("CardDatabase: Loaded %d cards (%d creatures, %d spells)" % [
		all_cards.size(),
		creature_cards.size(),
		spell_cards.size()
	])

func load_from_json(file_path: String) -> void:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("CardDatabase: Failed to open JSON file: %s" % file_path)
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: int = json.parse(json_text)

	if parse_result != OK:
		push_error("CardDatabase: JSON parse error at line %d: %s" % [
			json.get_error_line(),
			json.get_error_message()
		])
		return

	var data: Dictionary = json.get_data()
	if data.has("cards"):
		parse_card_data(data["cards"])
	else:
		push_error("CardDatabase: JSON file missing 'cards' array")

func load_from_xml(file_path: String) -> void:
	push_warning("CardDatabase: XML parsing not yet implemented")
	push_warning("CardDatabase: Please convert cards.xml to cards.json or implement XMLParser")

func parse_card_data(cards_array: Array) -> void:
	for card_dict in cards_array:
		if not card_dict is Dictionary:
			continue

		var card: Card = create_card_from_dict(card_dict)
		if card != null:
			all_cards[card.get_name().to_lower()] = card

func create_card_from_dict(data: Dictionary) -> Card:
	var type_str: String = data.get("type", "FIRE")
	var card_type: CardType.Type = CardType.from_string(type_str)

	var card: Card = Card.new(card_type)

	card.set_name(data.get("name", ""))
	card.set_cardname(data.get("cardname", ""))
	card.set_desc(data.get("desc", ""))

	var attack: int = data.get("attack", 0)
	card.set_attack(attack)
	card.set_original_attack(attack)

	var life: int = data.get("life", 0)
	card.set_life(life)
	card.set_original_life(life)

	var is_spell: bool = data.get("spell", false)
	card.set_spell(is_spell)

	var cost: int = 0
	if is_spell:
		cost = data.get("castingCost", 0)
	else:
		cost = data.get("summoningCost", 0)
	card.set_cost(cost)

	card.set_targetable(data.get("targetable", false))
	card.set_targetable_on_empty_slot_only(data.get("targetableOnEmptySlot", false))

	var target_str: String = data.get("target", "OWNER")
	var target_type: Card.TargetType = Card.from_target_type_string(target_str)
	card.set_target_type(target_type)

	card.set_self_inflicting_damage(data.get("selfInflictingDamage", 0))
	card.set_wall(data.get("wall", false))
	card.set_must_be_summoned_on_card(data.get("mustBeSummoneOnCard", ""))

	return card

func organize_cards() -> void:
	for card_name in all_cards.keys():
		var card: Card = all_cards[card_name]

		if card.is_spell():
			spell_cards.append(card)
		else:
			creature_cards.append(card)

		var card_type: CardType.Type = card.get_type()
		if not cards_by_type.has(card_type):
			cards_by_type[card_type] = []
		cards_by_type[card_type].append(card)

func create_sample_cards() -> void:
	var sample_creature: Card = Card.new(CardType.Type.FIRE)
	sample_creature.set_name("SampleCreature")
	sample_creature.set_cardname("Sample Creature")
	sample_creature.set_desc("A test creature for development")
	sample_creature.set_attack(3)
	sample_creature.set_original_attack(3)
	sample_creature.set_life(4)
	sample_creature.set_original_life(4)
	sample_creature.set_cost(2)
	sample_creature.set_spell(false)
	all_cards["samplecreature"] = sample_creature

	var sample_spell: Card = Card.new(CardType.Type.FIRE)
	sample_spell.set_name("SampleSpell")
	sample_spell.set_cardname("Sample Spell")
	sample_spell.set_desc("A test spell for development")
	sample_spell.set_cost(3)
	sample_spell.set_spell(true)
	all_cards["samplespell"] = sample_spell

func get_card_by_name(name: String) -> Card:
	var key: String = name.to_lower()
	if all_cards.has(key):
		return all_cards[key].clone()
	return null

func get_creature_cards() -> Array:
	return creature_cards.duplicate()

func get_spell_cards() -> Array:
	return spell_cards.duplicate()

func get_cards_for_specialization(spec: Specializations.Specialization) -> Array:
	if spec == null:
		return []

	if cards_by_specialization.has(spec.get_id()):
		return cards_by_specialization[spec.get_id()].duplicate()

	var card_type: CardType.Type = spec.get_type()
	return filter_cards_by_type(card_type)

func get_enabled_cards(player: Player) -> Array:
	if player == null:
		return []

	var enabled: Array = []

	for card in all_cards.values():
		if can_afford_card(player, card):
			enabled.append(card)

	return enabled

func can_afford_card(player: Player, card: Card) -> bool:
	if player == null or card == null:
		return false

	var card_type: CardType.Type = card.get_type()
	var card_cost: int = card.get_cost()
	var player_strength: int = player.get_strength(card_type)

	return player_strength >= card_cost

func filter_cards_by_type(type: CardType.Type) -> Array:
	if cards_by_type.has(type):
		return cards_by_type[type].duplicate()
	return []

func get_cards_by_type(type: CardType.Type, max_number: int) -> Array:
	var type_cards: Array = filter_cards_by_type(type)

	if max_number >= type_cards.size():
		return type_cards

	type_cards.shuffle()
	var selected: Array = []
	for i in range(max_number):
		if i < type_cards.size():
			selected.append(type_cards[i].clone())

	return selected

func get_random_cards(max_number: int) -> Array:
	var all_cards_array: Array = all_cards.values()
	all_cards_array.shuffle()

	var selected: Array = []
	for i in range(min(max_number, all_cards_array.size())):
		selected.append(all_cards_array[i].clone())

	return selected

func get_all_card_names() -> Array:
	return all_cards.keys()

func get_card_count() -> int:
	return all_cards.size()

func has_card(name: String) -> bool:
	return all_cards.has(name.to_lower())

func reload_cards() -> void:
	is_loaded = false
	load_cards()
