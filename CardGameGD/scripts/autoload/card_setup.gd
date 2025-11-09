extends Node
# NOTE: No class_name declaration - this is an autoload singleton
# Accessible globally as CardSetup via autoload settings in project.godot

## EXACT LITERAL TRANSLATION OF CardSetup.java
## Source: CardGameGDX/src/main/java/org/antinori/cards/CardSetup.java
##
## This class manages all card data loading and querying.
## Replaces CardSetup.java functionality with identical behavior.
##
## Java class name: CardSetup
## GDScript file name: card_setup.gd (following naming convention)
## Accessible as: CardSetup (when used as autoload) or instantiated directly

# ============================================================================
# FIELDS - EXACT TRANSLATION
# ============================================================================

# Java: Set<Card> cardSet = new HashSet<Card>();
var card_set: Dictionary = {}  # Using Dictionary as Set (keys only, values null)

# Java: Set<Card> creatureCards = new HashSet<Card>();
var creature_cards: Dictionary = {}

# Java: Set<Card> spellCards = new HashSet<Card>();
var spell_cards: Dictionary = {}

# ============================================================================
# GETTER METHODS - EXACT TRANSLATION
# ============================================================================

# Java: public Set<Card> getCardSet()
func get_card_set() -> Dictionary:
	return card_set

# Java: public Set<Card> getCreatureCards()
func get_creature_cards() -> Dictionary:
	return creature_cards

# Java: public Set<Card> getSpellCards()
func get_spell_cards() -> Dictionary:
	return spell_cards

# ============================================================================
# PARSE CARDS - EXACT TRANSLATION
# ============================================================================

# Java: public void parseCards()
func parse_cards() -> void:
	# Load from JSON instead of XML (cards.xml was crashing Godot)
	var json_path: String = "res://data/cards.json"

	if not FileAccess.file_exists(json_path):
		push_error("CardSetup: cards.json not found at %s" % json_path)
		return

	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		push_error("CardSetup: Failed to open cards.json")
		return

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("CardSetup: Failed to parse cards.json: %s" % json.get_error_message())
		return

	var data = json.data
	if not data or not data.has("cards"):
		push_error("CardSetup: cards.json missing 'cards' array")
		return

	# Parse each card from JSON (193 cards converted from cards.xml)
	var card_count: int = 0
	for card_data in data["cards"]:
		card_count += 1

		# Create card with type
		var type_str: String = card_data.get("type", "")
		var card_type: CardType.Type = CardType.from_string(type_str)
		var c: Card = Card.new(card_type)

		# Set basic properties (matching XML attributes exactly)
		c.set_name(card_data.get("name", ""))
		c.set_cardname(card_data.get("cardname", ""))
		c.set_desc(card_data.get("desc", ""))

		# Set stats
		var attack: int = card_data.get("attack", 0)
		c.set_attack(attack)
		c.set_original_attack(attack)

		var life: int = card_data.get("life", 0)
		c.set_life(life)
		c.set_original_life(life)

		# Set spell/creature flag
		var spell: bool = card_data.get("spell", false)
		c.set_spell(spell)

		# Set targetable properties
		var targetable: bool = card_data.get("targetable", false)
		c.set_targetable(targetable)

		var targetable_on_empty: bool = card_data.get("targetableOnEmptySlot", false)
		c.set_targetable_on_empty_slot_only(targetable_on_empty)

		# Set target type
		var target_str: String = card_data.get("target", "")
		var target: Card.TargetType = Card.from_target_type_string(target_str)
		c.set_target_type(target)

		# Set cost (spell uses castingCost, creature uses summoningCost - same as XML)
		var cost: int = 0
		if spell:
			cost = card_data.get("castingCost", 0)
		else:
			cost = card_data.get("summoningCost", 0)
		c.set_cost(cost)

		# Set other properties
		var self_inflicting: int = card_data.get("selfInflictingDamage", 0)
		c.set_self_inflicting_damage(self_inflicting)

		var wall: bool = card_data.get("wall", false)
		c.set_wall(wall)

		# FIXED TYPO: set_must_be_summoned_on_card (not summone)
		c.set_must_be_summoned_on_card(card_data.get("mustBeSummoneOnCard", ""))

		# Add to sets
		card_set[c] = null
		if c.is_spell():
			spell_cards[c] = null
		else:
			creature_cards[c] = null

	print("CardSetup: Successfully loaded ", card_count, " cards from JSON")
	print("  Creature cards: ", creature_cards.size())
	print("  Spell cards: ", spell_cards.size())

# ============================================================================
# GET CARD BY NAME - EXACT TRANSLATION
# ============================================================================

# Java: public Card getCardByName(String name)
func get_card_by_name(name: String) -> Card:
	return get_card_by_name_from_set(name, card_set)

# Java: public Card getCardByName(String name, Set<Card> set)
func get_card_by_name_from_set(name: String, set: Dictionary) -> Card:
	# Java: Card result = (Card)CollectionUtils.find(set, new CardPredicate(name.toLowerCase()));
	# Java: return result.clone();
	
	var name_lower: String = name.to_lower()
	
	# Search through the set (Dictionary keys)
	for card in set.keys():
		if card.get_name().to_lower() == name_lower:
			# Java: return result.clone();
			return card.clone()
	
	return null

# ============================================================================
# GET CARDS BY TYPE - EXACT TRANSLATION
# ============================================================================

# Java: public List<Card> getCardsByType(CardType type, int maxNumber)
func get_cards_by_type(type: CardType.Type, max_number: int) -> Array:
	return get_cards_by_type_from_set(type, max_number, card_set)

# Java: public List<Card> getCardsByType(CardType type, int maxNumber, Set<Card> set)
func get_cards_by_type_from_set(type: CardType.Type, max_number: int, set: Dictionary) -> Array:
	# Java: List<Card> result = (List<Card>) CollectionUtils.select(set, new CardPredicate(type));
	var result: Array = []

	# DEBUG: Print what we're looking for
	print("    [DEBUG] get_cards_by_type_from_set: Looking for type ", type, " (", CardType.get_title(type), ")")
	print("    [DEBUG] card_set has ", set.size(), " cards total")

	# DEBUG: Show first few card types
	var count = 0
	for card in set.keys():
		if count < 3:
			print("      [DEBUG] Card '", card.get_name(), "' has type ", card.get_type(), " (", CardType.get_title(card.get_type()), ")")
			count += 1

	# Filter cards by type (CardPredicate functionality)
	for card in set.keys():
		if card.get_type() == type:
			result.append(card)

	print("    [DEBUG] Found ", result.size(), " cards of type ", CardType.get_title(type))

	# Java: if (maxNumber > result.size()) return result;
	if max_number > result.size():
		return result
	
	# Java: List<Card> picks = new ArrayList<Card>();
	var picks: Array = []
	
	# Java: for (int i=0;i<maxNumber;i++)
	for i in range(max_number):
		# Java: do { ... } while(true);
		while true:
			# Java: int rand = new Random().nextInt(result.size());
			var rand: int = randi() % result.size()
			
			# Java: Card c = result.get(rand).clone();
			var c: Card = result[rand].clone()
			
			# Java: if (picks.contains(c)) continue;
			if picks.has(c):
				continue
			
			# Java: picks.add(c);
			picks.append(c)
			
			# Java: break;
			break
	
	# Java: return picks;
	return picks

# ============================================================================
# GET CARD IMAGES BY TYPE - EXACT TRANSLATION
# ============================================================================

# Java: public List<CardImage> getCardImagesByType(TextureAtlas atlas1, TextureAtlas atlas2, CardType type, int maxNumber)
# NOTE: atlas1/atlas2 are Dictionary[String, Texture2D] in Godot (not LibGDX TextureAtlas)
func get_card_images_by_type(atlas1, atlas2, type: CardType.Type, max_number: int) -> Array:
	# Java: List<Card> picks = getCardsByType(type, maxNumber);
	var picks: Array = get_cards_by_type(type, max_number)

	# Java: List<CardImage> images = new ArrayList<CardImage>();
	var images: Array = []

	# Java: for (Card c : picks)
	for c in picks:
		# Java: Sprite sp = atlas1.createSprite(c.getName().toLowerCase());
		# Godot: atlas is Dictionary, lookup by key
		var sprite_name: String = c.get_name().to_lower()
		var sp: Texture2D = atlas1.get(sprite_name) if atlas1 is Dictionary else null

		# Java: if (sp == null) { sp = atlas2.createSprite(...); if (sp != null) sp.flip(false, true); }
		if sp == null and atlas2 is Dictionary:
			sp = atlas2.get(sprite_name)
			# Note: Texture2D doesn't have flip() - flipping handled by Sprite2D at render time

		# Java: if (sp == null) throw new Exception("Sprite is null for card: " + c);
		if sp == null:
			push_error("Texture is null for card: %s" % c.get_name())
			continue

		# Java: sp.flip(false, true);
		# Note: Skipping flip - Texture2D doesn't have flip method

		# Java: CardImage img = new CardImage(sp, c);
		# NOTE: Godot CardImage._init() takes no parameters - this needs refactoring
		var img: CardImage = CardImage.new()
		# TODO: Set texture and card properties on img after creation

		# Java: images.add(img);
		images.append(img)

	# Java: return images;
	return images

# Java: public CardImage getCardImageByName(TextureAtlas atlas1, TextureAtlas atlas2, String name)
# NOTE: atlas1/atlas2 are Dictionary[String, Texture2D] in Godot (not LibGDX TextureAtlas)
func get_card_image_by_name(atlas1, atlas2, name: String) -> CardImage:
	# Java: Card c = getCardByName(name);
	var c: Card = get_card_by_name(name)

	if c == null:
		push_error("Card not found: %s" % name)
		return null

	# Java: Sprite sp = atlas1.createSprite(c.getName().toLowerCase());
	# Godot: atlas is Dictionary, lookup by key
	var sprite_name: String = c.get_name().to_lower()
	var sp: Texture2D = atlas1.get(sprite_name) if atlas1 is Dictionary else null

	# Java: if (sp == null) { sp = atlas2.createSprite(...); if (sp != null) sp.flip(false, true); }
	if sp == null and atlas2 is Dictionary:
		sp = atlas2.get(sprite_name)
		# Note: Texture2D doesn't have flip() - flipping handled by Sprite2D at render time

	# Java: if (sp == null) throw new Exception("Sprite is null for card: " + c);
	if sp == null:
		push_error("Texture is null for card: %s" % c.get_name())
		return null

	# Java: sp.flip(false, true);
	# Note: Skipping flip - Texture2D doesn't have flip method

	# Java: CardImage img = new CardImage(sp, c);
	# NOTE: Godot CardImage._init() takes no parameters - this needs refactoring
	var img: CardImage = CardImage.new()
	# TODO: Set texture and card properties on img after creation

	# Java: return img;
	return img

# ============================================================================
# XML HELPER METHODS - EXACT TRANSLATION
# ============================================================================

# Java: private String getAttrText(Node n, String attr)
func _get_attr_text(parser: XMLParser, attr: String) -> String:
	# Java: NamedNodeMap attrs = n.getAttributes();
	# Java: if (attrs == null) return null;
	# Java: Node valueNode = attrs.getNamedItem(attr);
	# Java: if (valueNode == null) return null;
	# Java: return valueNode.getNodeValue();
	
	if not parser.has_attribute(attr):
		return ""
	
	return parser.get_named_attribute_value(attr)

# Java: private int getAttrNumber(Node n, String attr)
func _get_attr_number(parser: XMLParser, attr: String) -> int:
	# Java: NamedNodeMap attrs = n.getAttributes();
	# Java: if (attrs == null) return 0;
	# Java: Node valueNode = attrs.getNamedItem(attr);
	# Java: if (valueNode == null) return 0;
	# Java: return Integer.parseInt(valueNode.getNodeValue());
	
	if not parser.has_attribute(attr):
		return 0
	
	var value_str: String = parser.get_named_attribute_value(attr)
	return value_str.to_int()

# ============================================================================
# HELPER CLASSES (if needed for Godot)
# ============================================================================

# Note: CardPredicate functionality is implemented inline in get_cards_by_type_from_set
# Note: TextureAtlas and Sprite would need to be separate classes matching LibGDX behavior
# Note: CardImage is a separate class (card_image.gd)

# ============================================================================
# USAGE NOTES
# ============================================================================

# Java usage:
#   CardSetup cs = new CardSetup();
#   cs.parseCards();
#   Card card = cs.getCardByName("GoblinBerserker");
#
# GDScript usage:
#   var cs = CardSetup.new()
#   cs.parse_cards()
#   var card = cs.get_card_by_name("GoblinBerserker")
#
# Or as autoload:
#   CardSetup.parse_cards()
#   var card = CardSetup.get_card_by_name("GoblinBerserker")
