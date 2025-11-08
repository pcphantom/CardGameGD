class_name OpponentCardWindow
extends Window

## ============================================================================
## OpponentCardWindow.gd - EXACT translation of OpponentCardWindow.java
## ============================================================================
## Window displaying opponent's card collection in a grid layout.
## Shows all cards organized by type (FIRE, AIR, WATER, EARTH, OTHER) in columns,
## with 4 rows of cards per type. Displays strength labels at the top.
##
## Original: src/main/java/org/antinori/cards/OpponentCardWindow.java
## Translation: scripts/ui/opponent_card_window.gd
##
## ONLY CHANGES FROM JAVA:
## - package → class_name
## - extends Window (LibGDX) → extends Window (Godot)
## - Table layout → GridContainer for card grid
## - Pixmap/Texture → Image/ImageTexture
## - Import paths updated to match CardGameGD structure
## ============================================================================

# ============================================================================
# IMPORTS (Java: import statements)
# ============================================================================

## Java: import java.util.List;
## GDScript: Arrays are built-in

## Java: import com.badlogic.gdx.graphics.Color;
## GDScript: Color is built-in

## Java: import com.badlogic.gdx.graphics.Pixmap;
## Java: import com.badlogic.gdx.graphics.Texture;
## GDScript: Image and ImageTexture

## Java: import com.badlogic.gdx.scenes.scene2d.Actor;
## Java: import com.badlogic.gdx.scenes.scene2d.ui.Image;
## Java: import com.badlogic.gdx.scenes.scene2d.ui.Label;
## Java: import com.badlogic.gdx.scenes.scene2d.ui.Skin;
## Java: import com.badlogic.gdx.scenes.scene2d.ui.Window;
## GDScript: Control, Label, TextureRect nodes

# ============================================================================
# FIELDS (Java: Cards game; Player opponent;)
# ============================================================================

## Java: Cards game;
var game = null  # Reference to main Cards/GameController

## Java: Player opponent;
var opponent: Player = null  # The opponent player

# UI container for the grid
var grid_container: GridContainer = null

# ============================================================================
# CONSTRUCTOR (Java: public OpponentCardWindow(...))
# ============================================================================

## Java: public OpponentCardWindow(String title, Player opponent, Cards game, Skin skin)
## Constructor to create the opponent card window
## @param p_title Window title text
## @param p_opponent The opponent player whose cards to display
## @param p_game Reference to the main game controller
## @param p_skin The UI skin (not used in Godot, kept for compatibility)
func _init(p_title: String = "", p_opponent: Player = null, p_game = null, p_skin = null) -> void:
	# Java: super(title, skin); (line 20)
	title = p_title

	# Java: this.game = game; (line 21)
	game = p_game

	# Java: this.opponent = opponent; (line 22)
	opponent = p_opponent

func _ready() -> void:
	# Java: defaults().padTop(2); defaults().padBottom(2); etc. (lines 24-27)
	# Set default padding for the window content
	# In Godot, we'll use a MarginContainer
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_bottom", 2)
	margin.add_theme_constant_override("margin_left", 2)
	margin.add_theme_constant_override("margin_right", 2)
	add_child(margin)

	# Create vertical box for layout
	var vbox := VBoxContainer.new()
	margin.add_child(vbox)

	# Java: try { (line 30)
	# Build the window content
	_build_window_content(vbox)

	# Java: pack(); (line 68)
	# Size window to fit content
	reset_size()

# ============================================================================
# BUILD WINDOW CONTENT (Java: lines 30-72 in constructor)
# ============================================================================

func _build_window_content(container: VBoxContainer) -> void:
	# Java: add().space(3); (line 32)
	# Java: for (int i=0;i<5;i++) { (line 33)
	# Java:     Label l = new Label(game.topStrengthLabels[i].getText(), Cards.whiteStyle); (line 34)
	# Java:     add(l); (line 35)
	# Java: } (line 36)
	# Java: row(); (line 37)

	# Create header row with strength labels
	var header_row := HBoxContainer.new()
	container.add_child(header_row)

	# Add spacing (3 pixels)
	var spacer1 := Control.new()
	spacer1.custom_minimum_size = Vector2(3, 0)
	header_row.add_child(spacer1)

	# Add 5 strength labels (one for each card type)
	for i in range(5):
		var l := Label.new()
		# Java: game.topStrengthLabels[i].getText()
		if game and game.has("topStrengthLabels") and game.topStrengthLabels.size() > i:
			l.text = game.topStrengthLabels[i].text
		# Java: Cards.whiteStyle
		l.add_theme_color_override("font_color", Color.WHITE)
		header_row.add_child(l)

	# Java: List<CardImage> fire = opponent.getCards(CardType.FIRE); (lines 40-44)
	var fire: Array = opponent.getCards(CardType.Type.FIRE)
	var air: Array = opponent.getCards(CardType.Type.AIR)
	var water: Array = opponent.getCards(CardType.Type.WATER)
	var earth: Array = opponent.getCards(CardType.Type.EARTH)
	var special: Array = opponent.getCards(CardType.Type.OTHER)

	# Java: for (int i = 0; i < 4; i++) { (line 46)
	for i in range(4):
		# Java: Actor a1 = getCard(fire,i); (lines 48-52)
		var a1: Control = getCard(fire, i)
		var a2: Control = getCard(air, i)
		var a3: Control = getCard(water, i)
		var a4: Control = getCard(earth, i)
		var a5: Control = getCard(special, i)

		# Create row container
		var row := HBoxContainer.new()
		container.add_child(row)

		# Java: add().space(3); (line 54)
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(3, 0)
		row.add_child(spacer)

		# Java: add(a1); add(a2); add(a3); add(a4); add(a5); (lines 55-59)
		row.add_child(a1)
		row.add_child(a2)
		row.add_child(a3)
		row.add_child(a4)
		row.add_child(a5)

		# Java: row(); (line 61)
		# Implicit - we created a new row container

	# Java: row(); add().space(6); (lines 64-65)
	var spacer_row := Control.new()
	spacer_row.custom_minimum_size = Vector2(0, 6)
	container.add_child(spacer_row)

# ============================================================================
# GET CARD METHOD (Java: private Actor getCard(List<CardImage> cards, int index))
# ============================================================================

## Java: private Actor getCard(List<CardImage> cards, int index)
## Returns a card visual or empty slot image for the given index
## @param cards List of CardImage objects for a specific type
## @param index The row index (0-3)
## @return Control node containing the card or empty slot
func getCard(cards: Array, index: int) -> Control:
	# Java: if (cards == null || cards.size() < index + 1) (line 78)
	# Java:     return getEmptySlotImage(); (line 79)
	if cards == null or cards.size() < index + 1:
		return getEmptySlotImage()

	# Java: CardImage ci = cards.get(index); (line 81)
	var ci: CardImage = cards[index]

	# Java: if (ci == null) { (line 82)
	# Java:     return getEmptySlotImage(); (line 83)
	# Java: } (line 84)
	if ci == null:
		return getEmptySlotImage()

	# Java: CardImage clone = ci.clone(); (line 86)
	var clone: CardImage = ci.clone()

	# Java: clone.setEnabled(cards.get(index).isEnabled()); (line 87)
	clone.setEnabled(cards[index].isEnabled())

	# Java: clone.setColor(cards.get(index).getColor()); (line 88)
	clone.setColor(cards[index].getColor())

	# Java: return clone; (line 89)
	return clone

# ============================================================================
# GET EMPTY SLOT IMAGE METHOD (Java: private Image getEmptySlotImage())
# ============================================================================

## Java: private Image getEmptySlotImage()
## Creates a transparent empty slot image (89x100 pixels)
## @return TextureRect with transparent texture
func getEmptySlotImage() -> TextureRect:
	# Java: Pixmap p = new Pixmap(89, 100, Pixmap.Format.RGBA8888); (line 93)
	# Java: p.setColor(Color.CLEAR); (line 94)
	# Java: p.fill(); (line 95)
	var img_data := Image.create(89, 100, false, Image.FORMAT_RGBA8)
	img_data.fill(Color.TRANSPARENT)

	# Java: Texture texture = new Texture(p); (line 96)
	var texture := ImageTexture.create_from_image(img_data)

	# Java: return new Image(texture); (line 97)
	var img_rect := TextureRect.new()
	img_rect.texture = texture
	img_rect.custom_minimum_size = Vector2(89, 100)
	return img_rect
