class_name CardImage
extends Control

## Visual representation of a card on screen
## Direct translation of CardImage.java from CardGameGDX
## Maintains exact same logic, methods, and rendering behavior

# =============================================================================
# CONSTANTS
# =============================================================================

# Card sizes from Java
const SMALL_CARD_WIDTH: int = 80
const SMALL_CARD_HEIGHT: int = 80  
const LARGE_CARD_WIDTH: int = 150
const LARGE_CARD_HEIGHT: int = 207

# =============================================================================
# SIGNALS
# =============================================================================

signal card_clicked(card_visual: CardImage)
signal card_hovered(card_visual: CardImage)
signal card_unhovered(card_visual: CardImage)

# =============================================================================
# MEMBER VARIABLES (Direct translation of Java fields)
# =============================================================================

# Instance variables
var img: Sprite2D = null  # Java: Sprite img
var frame: Texture2D = null  # Java: Texture frame
var card: Card = null  # Java: Card card
var font: Font = null  # Java: BitmapFont font (not used in Godot, kept for compatibility)
var enabled: bool = true  # Java: boolean enabled
var is_highlighted: bool = false  # Java: boolean isHighlighted
var creature = null  # Java: Creature creature (BaseCreature type)

# Static variables (shared across all instances)
static var stunned_texture: Texture2D = null  # Java: static Texture stunned
static var health_box_texture: Texture2D = null  # Java: static Texture healthBox
var health_bar_rect: Rect2 = Rect2(0, 0, 63, 4)  # Java: TextureRegion healthBar

# Visual elements for Godot rendering
var portrait: TextureRect = null
var frame_rect: TextureRect = null
var stunned_indicator: TextureRect = null
var health_bar_display: ColorRect = null

# Stat labels
var cost_label: Label = null
var attack_label: Label = null
var life_label: Label = null

# =============================================================================
# INITIALIZATION (Java: constructors and initTextures)
# =============================================================================

func _init() -> void:
	# Java: public CardImage()
	mouse_filter = Control.MOUSE_FILTER_STOP

func _ready() -> void:
	_init_static_textures()
	_create_visual_elements()

	# Connect mouse signals for hover tooltips
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)

## Java: CardImage.draw() reads card stats every frame (lines 81-93)
## In Godot, we need to update labels when card stats change
## This matches Java's behavior where draw() continuously updates display
func _process(_delta: float) -> void:
	update_stats_display()

## Update card stats labels to match current card values
## Called every frame to match Java's draw() behavior
func update_stats_display() -> void:
	if card == null:
		return

	var at: int = card.get_attack()
	var co: int = card.get_cost()
	var li: int = card.get_life()

	# Update attack label
	if attack_label and attack_label.visible:
		attack_label.text = str(at)

	# Update cost label
	if cost_label and cost_label.visible:
		cost_label.text = str(co)

	# Update life label
	if life_label and life_label.visible:
		life_label.text = str(li)

# Java: private static void initTextures()
static func _init_static_textures() -> void:
	if health_box_texture != null:
		return
	
	# Create health box texture (Java: Pixmap p = new Pixmap(63, 4...))
	var img_data := Image.create(63, 4, false, Image.FORMAT_RGBA8)
	img_data.fill(Color("105410"))  # Java: p.setColor(Color.valueOf("105410"))
	health_box_texture = ImageTexture.create_from_image(img_data)
	
	# Load stunned texture (Java: stunned = new Texture(Gdx.files.classpath("images/stunned.png")))
	if TextureManager and TextureManager.is_loaded:
		stunned_texture = TextureManager.stunned

# Create visual child elements
func _create_visual_elements() -> void:
	# Portrait (card artwork) - z_index 1 (behind frame)
	portrait = TextureRect.new()
	portrait.z_index = 1
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)

	# Frame (border) - z_index 2 (on top of portrait)
	frame_rect = TextureRect.new()
	frame_rect.z_index = 2
	frame_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame_rect)
	
	# Stunned indicator - z_index 3 (on top of frame)
	stunned_indicator = TextureRect.new()
	stunned_indicator.z_index = 3
	stunned_indicator.visible = false
	stunned_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stunned_indicator)

	# Health bar - z_index 4 (on top of everything)
	health_bar_display = ColorRect.new()
	health_bar_display.color = Color("105410")
	health_bar_display.z_index = 4
	health_bar_display.visible = false
	health_bar_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(health_bar_display)
	
	# Stat labels - z_index 10 (always on top)
	cost_label = Label.new()
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_label.z_index = 10
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cost_label)
	
	attack_label = Label.new()
	attack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	attack_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	attack_label.z_index = 10
	attack_label.visible = false
	attack_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(attack_label)
	
	life_label = Label.new()
	life_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	life_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	life_label.z_index = 10
	life_label.visible = false
	life_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(life_label)

# =============================================================================
# SETUP METHOD (Called from outside to initialize card)
# =============================================================================

# Java: public CardImage(Sprite img, Card info)
func setup_card(card_data: Card, size_type: String = "small") -> void:
	card = card_data

	if card == null:
		push_warning("CardImage: setup_card called with null card")
		return

	# CRITICAL: Ensure visual elements exist before _render_card() tries to use them
	# _ready() only runs when node is added to tree, but setup_card() is called before that
	if portrait == null:
		_init_static_textures()
		_create_visual_elements()

	set_name(card.get_name())

	# Render the card
	_render_card(size_type)

# =============================================================================
# RENDERING (Java: draw method)
# =============================================================================

# Java: public void draw(Batch batch, float parentAlpha)
func _render_card(size_type: String) -> void:
	if card == null:
		return
	
	_init_static_textures()
	
	# Determine card size
	var is_large: bool = (size_type == "large")
	var card_width: int = LARGE_CARD_WIDTH if is_large else SMALL_CARD_WIDTH
	var card_height: int = LARGE_CARD_HEIGHT if is_large else SMALL_CARD_HEIGHT
	var frame_width: int = 172 if is_large else 100
	var frame_height: int = 231 if is_large else 111
	
	# Set overall size
	custom_minimum_size = Vector2(frame_width, frame_height)
	size = Vector2(frame_width, frame_height)
	
	# Java: batch.draw(img, x, y)
	# Position and set card artwork
	# Use configurable offset from Cards config (default 0,0)
	var portrait_offset_x = (Cards.HAND_CARD_PORTRAIT_OFFSET_X if Cards else 0) + (Cards.HAND_CARD_IMAGE_ADJUST_X if Cards else 0)
	var portrait_offset_y = (Cards.HAND_CARD_PORTRAIT_OFFSET_Y if Cards else 0) + (Cards.HAND_CARD_IMAGE_ADJUST_Y if Cards else 0)
	portrait.position = Vector2(portrait_offset_x, portrait_offset_y)
	portrait.size = Vector2(card_width, card_height)
	portrait.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP
	
	# Load card artwork from texture atlas
	if TextureManager and TextureManager.is_loaded:
		var card_name: String = card.get_name().to_lower()
		var card_texture: Texture2D = null
		
		if is_large:
			card_texture = TextureManager.get_large_card_texture(card_name)
		else:
			card_texture = TextureManager.get_small_card_texture(card_name)
		
		if card_texture != null:
			portrait.texture = card_texture
		else:
			push_warning("CardImage: Missing texture for card: %s" % card_name)
	
	# Java: if (creature != null && creature.mustSkipNextAttack()) batch.draw(stunned, x, y)
	if creature != null:
		stunned_indicator.visible = creature.must_skip_next_attack() if creature.has_method("must_skip_next_attack") else false
		if stunned_indicator.visible and stunned_texture:
			stunned_indicator.texture = stunned_texture
			stunned_indicator.position = Vector2(0, 0)
			stunned_indicator.size = Vector2(card_width, card_height)
	
	# Java: batch.draw(frame, x - 3, y - 12)
	# Use configurable offset from Cards config (default -3,-12 from Java)
	var frame_offset_x = (Cards.HAND_CARD_FRAME_OFFSET_X if Cards else -3) + (Cards.HAND_CARD_FRAME_ADJUST_X if Cards else 0)
	var frame_offset_y = (Cards.HAND_CARD_FRAME_OFFSET_Y if Cards else -12) + (Cards.HAND_CARD_FRAME_ADJUST_Y if Cards else 0)
	frame_rect.position = Vector2(frame_offset_x, frame_offset_y)
	frame_rect.size = Vector2(frame_width, frame_height)
	frame_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	frame_rect.stretch_mode = TextureRect.STRETCH_KEEP
	
	# Load correct frame based on card type
	if TextureManager and TextureManager.is_loaded:
		if card.is_spell():
			frame_rect.texture = TextureManager.ramka_big_spell if is_large else TextureManager.spell_ramka
		else:
			frame_rect.texture = TextureManager.ramka_big if is_large else TextureManager.ramka
	
	# Get stat values
	var at: int = card.get_attack()
	var co: int = card.get_cost()
	var li: int = card.get_life()
	
	# Java: font.draw(batch, "" + at, (at > 9 ? x : x + 3), y + 5);
	# Render stats based on card type
	# COORDINATE CONVERSION: libGDX uses bottom-origin (y=0 at bottom), Godot uses top-origin (y=0 at top)
	# libGDX "y + 5" (5px from bottom) → Godot "card_height - 5" (5px from bottom)
	# libGDX "y + 85" (85px from bottom, 5px from top of 80px card) → Godot "card_height - 85" (5px from top)
	if not card.is_spell():
		# Creature card - show attack, cost, life
		if li > 0:
			# Attack (bottom-left corner)
			# Java: (at > 9 ? x : x + 3), y + 5
			# Single digit: x+3, Double digit: x+0
			# LibGDX font.draw() positions text from BASELINE, Godot Label from TOP-LEFT
			# Must subtract label height (font 16 ≈ 20px) to position correctly
			var attack_x: float = 3.0 if at < 10 else 0.0
			var attack_y: float = card_height - 5.0 - 20  # FIXED: Subtract label height (20px)
			if is_large:
				attack_x = 5.0 if at < 10 else 2.0
				attack_y = LARGE_CARD_HEIGHT - 5.0 - 24  # FIXED: Subtract label height for large (24px)
			var stats_adjust_x = Cards.HAND_CARD_STATS_ADJUST_X if Cards else 0
			var stats_adjust_y = Cards.HAND_CARD_STATS_ADJUST_Y if Cards else 0
			attack_label.position = Vector2(attack_x + stats_adjust_x, attack_y + stats_adjust_y)
			attack_label.size = Vector2(15, 15) if not is_large else Vector2(18, 18)
			var attack_font_size = Cards.CARD_STATS_FONT_SIZE_LARGE if is_large else Cards.CARD_STATS_FONT_SIZE_SMALL
			attack_label.add_theme_font_size_override("font_size", attack_font_size)
			var attack_color = Cards.CARD_STATS_ATTACK_COLOR if Cards else Color(1.0, 0.0, 0.0)
			attack_label.add_theme_color_override("font_color", attack_color)
			var card_stats_bold = Cards.CARD_STATS_BOLD if Cards else false
			if card_stats_bold:
				attack_label.add_theme_constant_override("outline_size", 1)
				attack_label.add_theme_color_override("font_outline_color", attack_color)
			else:
				attack_label.add_theme_constant_override("outline_size", 0)
			attack_label.text = str(at)
			attack_label.visible = true

			# Cost (top-right corner, extends into frame area above card)
			# Java: (co > 9 ? x + 66 : x + 69), y + 85
			# Single digit: x+69, Double digit: x+66
			# LibGDX font.draw() positions text from BASELINE, Godot Label from TOP-LEFT
			# Must subtract label height (font 16 ≈ 20px) to position correctly
			var cost_x: float = 69.0 if co < 10 else 66.0
			var cost_y: float = card_height - 85.0 - 20  # FIXED: Subtract label height (20px)
			if is_large:
				cost_x = 132.0 if co < 10 else 130.0
				cost_y = LARGE_CARD_HEIGHT - 150.0 - 24  # FIXED: Subtract label height for large (24px)
			cost_label.position = Vector2(cost_x + stats_adjust_x, cost_y + stats_adjust_y)
			cost_label.size = Vector2(15, 15) if not is_large else Vector2(18, 18)
			var cost_font_size = Cards.CARD_STATS_FONT_SIZE_LARGE if is_large else Cards.CARD_STATS_FONT_SIZE_SMALL
			cost_label.add_theme_font_size_override("font_size", cost_font_size)
			var cost_color = Cards.CARD_STATS_COST_COLOR if Cards else Color(1.0, 1.0, 0.0)
			cost_label.add_theme_color_override("font_color", cost_color)
			if card_stats_bold:
				cost_label.add_theme_constant_override("outline_size", 1)
				cost_label.add_theme_color_override("font_outline_color", cost_color)
			else:
				cost_label.add_theme_constant_override("outline_size", 0)
			cost_label.text = str(co)
			cost_label.visible = true

			# Life (bottom-right corner)
			# Java: (li > 9 ? x + 66 : x + 69), y + 5
			# Single digit: x+69, Double digit: x+66
			# LibGDX font.draw() positions text from BASELINE, Godot Label from TOP-LEFT
			# Must subtract label height (font 16 ≈ 20px) to position correctly
			var life_x: float = 69.0 if li < 10 else 66.0
			var life_y: float = card_height - 5.0 - 20  # FIXED: Subtract label height (20px)
			if is_large:
				life_x = 134.0 if li < 10 else 131.0
				life_y = LARGE_CARD_HEIGHT - 5.0 - 24  # FIXED: Subtract label height for large (24px)
			life_label.position = Vector2(life_x + stats_adjust_x, life_y + stats_adjust_y)
			life_label.size = Vector2(15, 15) if not is_large else Vector2(18, 18)
			var life_font_size = Cards.CARD_STATS_FONT_SIZE_LARGE if is_large else Cards.CARD_STATS_FONT_SIZE_SMALL
			life_label.add_theme_font_size_override("font_size", life_font_size)
			var life_color = Cards.CARD_STATS_LIFE_COLOR if Cards else Color(0.0, 1.0, 0.0)
			life_label.add_theme_color_override("font_color", life_color)
			if card_stats_bold:
				life_label.add_theme_constant_override("outline_size", 1)
				life_label.add_theme_color_override("font_outline_color", life_color)
			else:
				life_label.add_theme_constant_override("outline_size", 0)
			life_label.text = str(li)
			life_label.visible = true
	else:
		# Spell card - only show cost
		# Java: font.draw(batch, "" + co, (co > 9 ? x + 66 : x + 69), y + 77);
		# Single digit: x+69, Double digit: x+66
		# LibGDX font.draw() positions text from BASELINE, Godot Label from TOP-LEFT
		# Must subtract label height (font 16 ≈ 20px) to position correctly
		var cost_x: float = 69.0 if co < 10 else 66.0
		var cost_y: float = card_height - 77.0 - 20  # FIXED: Subtract label height (20px)
		if is_large:
			cost_x = 132.0 if co < 10 else 130.0
			cost_y = LARGE_CARD_HEIGHT - 192.0 - 24  # FIXED: Subtract label height for large (24px)
		var spell_stats_adjust_x = Cards.HAND_CARD_STATS_ADJUST_X if Cards else 0
		var spell_stats_adjust_y = Cards.HAND_CARD_STATS_ADJUST_Y if Cards else 0
		cost_label.position = Vector2(cost_x + spell_stats_adjust_x, cost_y + spell_stats_adjust_y)
		cost_label.size = Vector2(15, 15) if not is_large else Vector2(18, 18)
		var spell_cost_font_size = Cards.CARD_STATS_FONT_SIZE_LARGE if is_large else Cards.CARD_STATS_FONT_SIZE_SMALL
		cost_label.add_theme_font_size_override("font_size", spell_cost_font_size)
		var spell_cost_color = Cards.CARD_STATS_COST_COLOR if Cards else Color(1.0, 1.0, 0.0)
		cost_label.add_theme_color_override("font_color", spell_cost_color)
		var spell_card_stats_bold = Cards.CARD_STATS_BOLD if Cards else false
		if spell_card_stats_bold:
			cost_label.add_theme_constant_override("outline_size", 1)
			cost_label.add_theme_color_override("font_outline_color", spell_cost_color)
		else:
			cost_label.add_theme_constant_override("outline_size", 0)
		cost_label.text = str(co)
		cost_label.visible = true

		attack_label.visible = false
		life_label.visible = false
	
	# Java: if (creature != null) batch.draw(healthBar, x, y + 82);
	if creature != null:
		health_bar_display.position = Vector2(0, 82)
		health_bar_display.size = Vector2(health_bar_rect.size.x, health_bar_rect.size.y)
		health_bar_display.visible = true
	else:
		health_bar_display.visible = false
	
	# Ensure card is visible (critical fix for invisible cards)
	visible = true
	modulate.a = 1.0

# =============================================================================
# CLONING (Java: clone method)
# =============================================================================

# Java: public CardImage clone()
func clone_card() -> CardImage:
	var ci := CardImage.new()

	# CRITICAL FIX: Must call setup_card() to create visual elements and render
	# Without this, the clone has no portrait/frame/label children and is invisible!
	# Java's clone() works because LibGDX's Image copies the drawable automatically
	# In Godot, we must explicitly set up all the TextureRect/Label child nodes
	if card != null:
		ci.setup_card(card.clone(), "small")  # Creates visual elements and renders

	# Copy remaining properties (setup_card already sets card, img, frame, font internally via _render_card)
	ci.set_enabled(true)
	ci.position = position
	ci.size = size

	# Copy creature reference if exists
	if creature != null:
		ci.set_creature(creature)

	return ci

# =============================================================================
# LIFE/HEALTH MANAGEMENT (Java: decrementLife, incrementLife)
# =============================================================================

# Java: public boolean decrementLife(BaseFunctions attacker, int value, Cards game)
func decrement_life(attacker, value: int, _game) -> bool:
	if creature and creature.has_method("on_attacked"):
		creature.on_attacked(attacker, value)
	
	var remaining_life: int = card.get_life()
	var died: bool = (remaining_life < 1)
	
	# Update health bar (Java: double percent = (double) remainingLife / (double) card.getOriginalLife())
	var percent: float = float(remaining_life) / float(card.get_original_life())
	var bar: float = percent * 63.0
	if remaining_life < 0:
		bar = 0.0
	if bar > 63:
		bar = 63.0
	
	# Java: healthBar.setRegion(0, 0, (int) bar, 4)
	health_bar_rect.size.x = bar
	if health_bar_display:
		health_bar_display.size = Vector2(bar, 4)
	
	return died

# Java: public void incrementLife(int value, Cards game)
func increment_life(value: int, game) -> void:
	card.increment_life(value)
	if game and game.has_method("animate_healing_text"):
		game.animate_healing_text(value, self)

# =============================================================================
# GETTERS AND SETTERS (Direct translations from Java)
# =============================================================================

# Java: public Sprite getImg()
func get_img() -> Sprite2D:
	return img

# Java: public void setImg(Sprite img)
func set_img(new_img: Sprite2D) -> void:
	img = new_img

# Java: public Texture getFrame()
func get_frame() -> Texture2D:
	return frame

# Java: public void setFrame(Texture frame)
func set_frame(new_frame: Texture2D) -> void:
	frame = new_frame

# Java: public Card getCard()
func get_card() -> Card:
	return card

# Java: public void setCard(Card card)
func set_card(new_card: Card) -> void:
	card = new_card

# Java: public BitmapFont getFont()
func get_font() -> Font:
	return font

# Java: public void setFont(BitmapFont font)
func set_font(new_font: Font) -> void:
	font = new_font

# Java: public boolean isEnabled()
func is_enabled() -> bool:
	return enabled

# Java: public void setEnabled(boolean enabled)
func set_enabled(new_enabled: bool) -> void:
	enabled = new_enabled
	# Java applies color change: enabled ? WHITE : DARK_GRAY
	if not enabled:
		modulate = Color(0.3, 0.3, 0.3, 1.0)  # DARK_GRAY
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)  # WHITE

# Java: public Creature getCreature()
func get_creature():
	return creature

# Java: public void setCreature(Creature creature)
func set_creature(new_creature) -> void:
	creature = new_creature

# Java: public boolean isHighlighted()
func get_is_highlighted() -> bool:
	return is_highlighted

# Java: public void setHighlighted(boolean isHighlighted)
func set_highlighted(new_highlighted: bool) -> void:
	is_highlighted = new_highlighted
	# Can add visual highlight effect here if needed

# Java: public Color getColor()
func get_color() -> Color:
	return modulate

# Java: public void setColor(Color color)
func set_color(color: Color) -> void:
	modulate = color

# =============================================================================
# STATIC SORT METHOD (Java: static void sort)
# =============================================================================

# Java: public static void sort(List<CardImage> cards)
static func sort_cards(cards: Array) -> void:
	cards.sort_custom(func(a: CardImage, b: CardImage) -> bool:
		var cost1: int = a.get_card().get_cost() if a and a.get_card() else 0
		var cost2: int = b.get_card().get_cost() if b and b.get_card() else 0
		return cost1 < cost2
	)

# =============================================================================
# INPUT HANDLING
# =============================================================================

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			card_clicked.emit(self)
			accept_event()

func _mouse_entered() -> void:
	card_hovered.emit(self)

func _mouse_exited() -> void:
	card_unhovered.emit(self)

## Clears any active animations/actions on this card
## Called from cards.gd clearHighlights() method
## Equivalent to Java's Actor.clearActions() called in Cards.java line 754
func clear_actions() -> void:
	# Stop any tweens running on this card
	var tweens = get_tree().get_processed_tweens()
	for tween in tweens:
		if tween and is_instance_valid(tween):
			# Check if this tween is animating this node
			var bound_node = tween.get_meta("bound_node", null)
			if bound_node == self:
				tween.kill()

# =============================================================================
# DEBUG/UTILITY (Java: toString)
# =============================================================================

# Java: public String toString()
func _to_string() -> String:
	if card != null:
		return "CardImage(%s, enabled=%s, highlighted=%s)" % [card.get_name(), enabled, is_highlighted]
	return "CardImage(empty)"
