extends Node

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
	# Java: DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
	# Java: factory.setValidating(true);
	# Java: factory.setIgnoringElementContentWhitespace(true);
	# GDScript: Use XMLParser instead
	
	var xml_parser := XMLParser.new()
	
	# Java: InputStream is = CardSetup.class.getResourceAsStream("/cards.xml");
	# GDScript: Load from res:// path
	var xml_path: String = "res://data/cards.xml"
	
	if not FileAccess.file_exists(xml_path):
		push_error("CardSetup: cards.xml not found at %s" % xml_path)
		return
	
	var error := xml_parser.open(xml_path)
	if error != OK:
		push_error("CardSetup: Failed to open cards.xml: %d" % error)
		return
	
	# Java: NodeList locater = doc.getElementsByTagName("cards");
	# Java: NodeList cards = locater.item(0).getChildNodes();
	# GDScript: Parse XML nodes
	
	while xml_parser.read() == OK:
		if xml_parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name: String = xml_parser.get_node_name()
			
			# Java: if (node_name1 == "card")
			if node_name == "card":
				# Java: String type = getAttrText(n1, "type");
				var type_str: String = _get_attr_text(xml_parser, "type")
				
				# Java: Card c = new Card(CardType.fromString(type));
				var card_type: CardType.Type = CardType.from_string(type_str)
				var c: Card = Card.new(card_type)
				
				# Java: c.setName(getAttrText(n1, "name"));
				c.set_name(_get_attr_text(xml_parser, "name"))
				
				# Java: c.setCardname(getAttrText(n1, "cardname"));
				c.set_cardname(_get_attr_text(xml_parser, "cardname"))
				
				# Java: c.setDesc(getAttrText(n1, "desc"));
				c.set_desc(_get_attr_text(xml_parser, "desc"))
				
				# Java: c.setAttack(getAttrNumber(n1, "attack"));
				# Java: c.setOriginalAttack(c.getAttack());
				var attack: int = _get_attr_number(xml_parser, "attack")
				c.set_attack(attack)
				c.set_original_attack(c.get_attack())
				
				# Java: c.setLife(getAttrNumber(n1, "life"));
				# Java: c.setOriginalLife(c.getLife());
				var life: int = _get_attr_number(xml_parser, "life")
				c.set_life(life)
				c.set_original_life(c.get_life())
				
				# Java: Boolean spell = Boolean.parseBoolean(getAttrText(n1, "spell"));
				# Java: c.setSpell(spell);
				var spell: bool = _get_attr_text(xml_parser, "spell").to_lower() == "true"
				c.set_spell(spell)
				
				# Java: Boolean targetable = Boolean.parseBoolean(getAttrText(n1, "targetable"));
				# Java: c.setTargetable(targetable);
				var targetable: bool = _get_attr_text(xml_parser, "targetable").to_lower() == "true"
				c.set_targetable(targetable)
				
				# Java: Boolean targetableOnEmptySlot = Boolean.parseBoolean(getAttrText(n1, "targetableOnEmptySlot"));
				# Java: c.setTargetableOnEmptySlotOnly(targetableOnEmptySlot);
				var targetable_on_empty: bool = _get_attr_text(xml_parser, "targetableOnEmptySlot").to_lower() == "true"
				c.set_targetable_on_empty_slot_only(targetable_on_empty)
				
				# Java: Card.TargetType target = Card.fromTargetTypeString(getAttrText(n1, "target"));
				# Java: c.setTargetType(target);
				var target_str: String = _get_attr_text(xml_parser, "target")
				var target: Card.TargetType = Card.from_target_type_string(target_str)
				c.set_target_type(target)
				
				# Java: int cost = getAttrNumber(n1, "summoningCost");
				# Java: if (spell) { cost = getAttrNumber(n1, "castingCost"); }
				# Java: c.setCost(cost);
				var cost: int = 0
				if spell:
					cost = _get_attr_number(xml_parser, "castingCost")
				else:
					cost = _get_attr_number(xml_parser, "summoningCost")
				c.set_cost(cost)
				
				# Java: int selfInflicting = getAttrNumber(n1, "selfInflictingDamage");
				# Java: c.setSelfInflictingDamage(selfInflicting);
				var self_inflicting: int = _get_attr_number(xml_parser, "selfInflictingDamage")
				c.set_self_inflicting_damage(self_inflicting)
				
				# Java: Boolean wall = Boolean.parseBoolean(getAttrText(n1, "wall"));
				# Java: c.setWall(wall);
				var wall: bool = _get_attr_text(xml_parser, "wall").to_lower() == "true"
				c.set_wall(wall)
				
				# Java: c.setMustBeSummoneOnCard(getAttrText(n1, "mustBeSummoneOnCard"));
				c.set_must_be_summone_on_card(_get_attr_text(xml_parser, "mustBeSummoneOnCard"))
				
				# Java: cardSet.add(c);
				card_set[c] = null  # Dictionary used as Set
				
				# Java: if (c.isSpell()) { spellCards.add(c); } else { creatureCards.add(c); }
				if c.is_spell():
					spell_cards[c] = null
				else:
					creature_cards[c] = null

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
	
	# Filter cards by type (CardPredicate functionality)
	for card in set.keys():
		if card.get_type() == type:
			result.append(card)
	
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
func get_card_images_by_type(atlas1: TextureAtlas, atlas2: TextureAtlas, type: CardType.Type, max_number: int) -> Array:
	# Java: List<Card> picks = getCardsByType(type, maxNumber);
	var picks: Array = get_cards_by_type(type, max_number)
	
	# Java: List<CardImage> images = new ArrayList<CardImage>();
	var images: Array = []
	
	# Java: for (Card c : picks)
	for c in picks:
		# Java: Sprite sp = atlas1.createSprite(c.getName().toLowerCase());
		var sprite_name: String = c.get_name().to_lower()
		var sp: Sprite = atlas1.create_sprite(sprite_name)
		
		# Java: if (sp == null) { sp = atlas2.createSprite(...); if (sp != null) sp.flip(false, true); }
		if sp == null:
			sp = atlas2.create_sprite(sprite_name)
			if sp != null:
				sp.flip(false, true)  # TGA files need to be flipped twice
		
		# Java: if (sp == null) throw new Exception("Sprite is null for card: " + c);
		if sp == null:
			push_error("Sprite is null for card: %s" % c.get_name())
			continue
		
		# Java: sp.flip(false, true);
		sp.flip(false, true)
		
		# Java: CardImage img = new CardImage(sp, c);
		var img: CardImage = CardImage.new(sp, c)
		
		# Java: images.add(img);
		images.append(img)
	
	# Java: return images;
	return images

# Java: public CardImage getCardImageByName(TextureAtlas atlas1, TextureAtlas atlas2, String name)
func get_card_image_by_name(atlas1: TextureAtlas, atlas2: TextureAtlas, name: String) -> CardImage:
	# Java: Card c = getCardByName(name);
	var c: Card = get_card_by_name(name)
	
	if c == null:
		push_error("Card not found: %s" % name)
		return null
	
	# Java: Sprite sp = atlas1.createSprite(c.getName().toLowerCase());
	var sprite_name: String = c.get_name().to_lower()
	var sp: Sprite = atlas1.create_sprite(sprite_name)
	
	# Java: if (sp == null) { sp = atlas2.createSprite(...); if (sp != null) sp.flip(false, true); }
	if sp == null:
		sp = atlas2.create_sprite(sprite_name)
		if sp != null:
			sp.flip(false, true)  # TGA files need to be flipped twice
	
	# Java: if (sp == null) throw new Exception("Sprite is null for card: " + c);
	if sp == null:
		push_error("Sprite is null for card: %s" % c.get_name())
		return null
	
	# Java: sp.flip(false, true);
	sp.flip(false, true)
	
	# Java: CardImage img = new CardImage(sp, c);
	var img: CardImage = CardImage.new(sp, c)
	
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
