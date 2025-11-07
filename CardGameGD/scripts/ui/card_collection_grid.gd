class_name CardCollectionGrid
extends ScrollContainer

# EXACT grid specifications from original game
const GRID_COLS: int = 5
const CARD_WIDTH: int = 89
const CARD_HEIGHT: int = 100
const CARD_SPACING_X: int = 8
const CARD_SPACING_Y: int = 8
const GRID_PADDING: int = 5
const GRID_PANEL_WIDTH: int = 490
const GRID_PANEL_HEIGHT: int = 400

var card_visuals: Array[CardImage] = []
var grid_container: GridContainer = null

func _ready() -> void:
	# EXACT scroll container setup
	custom_minimum_size = Vector2(GRID_PANEL_WIDTH, GRID_PANEL_HEIGHT)
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

	# Create grid container with EXACT spacing
	grid_container = GridContainer.new()
	grid_container.columns = GRID_COLS
	grid_container.add_theme_constant_override("h_separation", CARD_SPACING_X)
	grid_container.add_theme_constant_override("v_separation", CARD_SPACING_Y)
	add_child(grid_container)

func populate_cards(player_cards: Array) -> void:
	# Clear existing
	for card_visual in card_visuals:
		card_visual.queue_free()
	card_visuals.clear()

	# Group by element type
	var fire_cards: Array = []
	var water_cards: Array = []
	var air_cards: Array = []
	var earth_cards: Array = []
	var other_cards: Array = []

	for card in player_cards:
		match card.get_type():
			CardType.Type.FIRE:
				fire_cards.append(card)
			CardType.Type.WATER:
				water_cards.append(card)
			CardType.Type.AIR:
				air_cards.append(card)
			CardType.Type.EARTH:
				earth_cards.append(card)
			CardType.Type.OTHER:
				other_cards.append(card)

	# Add sections with EXACT colors
	_add_card_section("FIRE", fire_cards, Color(1.0, 0.3, 0.3))
	_add_card_section("WATER", water_cards, Color(0.3, 0.5, 1.0))
	_add_card_section("AIR", air_cards, Color(0.9, 0.9, 0.5))
	_add_card_section("EARTH", earth_cards, Color(0.6, 0.4, 0.2))
	_add_card_section("OTHER", other_cards, Color(0.7, 0.7, 0.7))

func _add_card_section(section_name: String, cards: Array, color: Color) -> void:
	if cards.is_empty():
		return

	# Section header with EXACT formatting
	var header := Label.new()
	header.text = section_name
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", color)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grid_container.add_child(header)

	# Fill rest of row with spacers
	for i in range(GRID_COLS - 1):
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(CARD_WIDTH, 20)
		grid_container.add_child(spacer)

	# Add cards with EXACT size
	for card in cards:
		var card_visual := CardImage.new()
		card_visual.setup_card(card, "small")
		card_visual.custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
		card_visual.card_clicked.connect(_on_card_clicked)
		grid_container.add_child(card_visual)
		card_visuals.append(card_visual)

func _on_card_clicked(card_visual: CardImage) -> void:
	# Emit signal or handle card selection
	pass
