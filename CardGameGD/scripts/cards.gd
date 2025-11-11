class_name Cards
extends SimpleGame

## ============================================================================
## Cards.gd - EXACT translation of Cards.java
## ============================================================================
## Main game class extending SimpleGame.
## Manages all game logic, UI, player interactions, and battle system.
##
## Original: src/main/java/org/antinori/cards/Cards.java (970 lines)
## Translation: scripts/cards.gd
##
## ONLY CHANGES FROM JAVA:
## - package → class_name
## - extends SimpleGame (same in Godot)
## - Java threading → Godot signals/coroutines
## - LibGDX Actions → Godot Tweens
## - InputListener → Godot signals
## - AtomicBoolean → bool with await
## ============================================================================

# ============================================================================
# STATIC FIELDS (Java: public static fields, lines 46-73)
# ============================================================================

## Java: public static NetworkGame NET_GAME;
static var NET_GAME = null

## Java: public static TextureAtlas smallCardAtlas; (and others)
static var smallCardAtlas = null
static var smallTGACardAtlas = null
static var largeCardAtlas = null
static var largeTGACardAtlas = null
static var faceCardAtlas = null

## Java: public static Texture ramka; spellramka; etc.
static var ramka: Texture2D = null
static var spellramka: Texture2D = null
static var portraitramka: Texture2D = null
static var ramkabig: Texture2D = null
static var ramkabigspell: Texture2D = null
static var slotTexture: Texture2D = null
static var endTurnButtonTexture: Texture2D = null

## Java: public static BitmapFont defaultFont; etc.
static var defaultFont: Font = null
static var greenfont: Font = null
static var customFont: Font = null

## Java: public static Label.LabelStyle whiteStyle; etc.
static var whiteStyle = null  # Label theme
static var redStyle = null
static var greenStyle = null

## Java: public static int SCREEN_WIDTH = 1024; SCREEN_HEIGHT = 768;
static var SCREEN_WIDTH: int = 1024
static var SCREEN_HEIGHT: int = 768

# ============================================================================
# UI LAYOUT CONFIGURATION - Adjust these constants to fine-tune positioning
# ============================================================================
#
# COORDINATE SYSTEM:
#   - Origin (0, 0) is TOP-LEFT corner of screen
#   - X increases RIGHT, Y increases DOWN
#   - Screen size: 1024×768 (SCREEN_WIDTH × SCREEN_HEIGHT)
#   - position property sets the TOP-LEFT CORNER of each element
#
# HOW TO ADJUST:
#   1. Find the element you want to move below
#   2. Change its X or Y constant value
#   3. Test in-game to verify positioning
#   4. Refer to SAFE RANGES to avoid elements going off-screen
#
# Z-INDEX LAYERING (higher = in front):
#   -10 = Background
#     1 = Play slots
#     2 = Player portraits
#     3 = Card description panel
#     4 = Game log
#     5 = Hand cards (topmost, interactive)
#
# ============================================================================

# ─────────────────────────────────────────────────────────────────────────────
# OPPONENT ELEMENTS (Top area of screen)
# ─────────────────────────────────────────────────────────────────────────────

# Opponent portrait (large character face - UPPER LEFT)
# INDIVIDUAL SIZE: 132×132 pixels (portraitramka.png frame)
# TOTAL FRAME SIZE: 132×132 pixels (single portrait)
# SAFE RANGES: X: 0-892, Y: 0-636
# Java: ydown(125) = 643 in LibGDX (bottom-left origin)
# Godot: 768 - 643 - 132 = -7 ≈ 0-10 (top-left origin)
const OPPONENT_PORTRAIT_X: int = 80     # Opponent portrait X
const OPPONENT_PORTRAIT_Y: int = 10     # Opponent portrait Y (user verified)
const PORTRAIT_SPRITE_OFFSET_X: int = 6      # Sprite X offset inside portrait frame (centers 120×120 sprite in 132×132 frame)
const PORTRAIT_SPRITE_OFFSET_Y: int = 6      # Sprite Y offset inside portrait frame (centers 120×120 sprite in 132×132 frame)
const PORTRAIT_FRAME_OFFSET_X: int = 0       # Frame X offset (frame fills 132×132 Control at position 0, 0)
const PORTRAIT_FRAME_OFFSET_Y: int = 0       # Frame Y offset (frame fills 132×132 Control at position 0, 0)

# Opponent play slots (6 card slots in a row - TOP RIGHT)
# INDIVIDUAL SIZE: 92×132 pixels per slot (slot.png)
# TOTAL FRAME SIZE: ~570×132 pixels (6 slots × ~95px spacing = ~570px wide)
# SAFE RANGES: X: 0-454, Y: 0-636
# Java: ydown(170) = 598 in LibGDX (bottom-left origin)
# Godot: 768 - 598 - 132 + 12(Actor offset) = 50 (top-left origin)
const OPPONENT_SLOTS_X: int = 330       # Opponent slots X
const OPPONENT_SLOTS_Y: int = 50        # Opponent slots Y (converted +12 offset)
const SLOT_SPACING_X: int = 95          # Horizontal spacing between play slots

# Opponent resource stats (Fire: X, Air: X, Water: X, Earth: X, Special: X - TOP)
# INDIVIDUAL SIZE: ~50×20 pixels per label
# TOTAL FRAME SIZE: ~515×20 pixels (5 labels × 103px spacing = ~515px wide)
# SAFE RANGES: X: 0-509, Y: 0-748
const OPPONENT_STATS_Y: int = 25        # Opponent's stats Y (Java: ydown(25) → use 25, top area)

# ─────────────────────────────────────────────────────────────────────────────
# PLAYER ELEMENTS (Bottom area of screen)
# ─────────────────────────────────────────────────────────────────────────────

# Player portrait (large character face - LOWER LEFT)
# INDIVIDUAL SIZE: 132×132 pixels (portraitramka.png frame)
# TOTAL FRAME SIZE: 132×132 pixels (single portrait)
# SAFE RANGES: X: 0-892, Y: 0-636
# Java: ydown(300) = 468 in LibGDX (bottom-left origin)
# Godot: 768 - 468 - 132 + 12(Actor offset) = 180 (top-left origin)
const PLAYER_PORTRAIT_X: int = 80       # Player portrait X
const PLAYER_PORTRAIT_Y: int = 180      # Player portrait Y (converted +12 offset)

# Player play slots (6 card slots in a row - MIDDLE RIGHT)
# INDIVIDUAL SIZE: 92×132 pixels per slot (slot.png)
# TOTAL FRAME SIZE: ~570×132 pixels (6 slots × ~95px spacing = ~570px wide)
# SAFE RANGES: X: 0-454, Y: 0-636
# Java: ydown(290) = 478 in LibGDX (bottom-left origin)
# Godot: 768 - 478 - 132 + 12(Actor offset) = 170 (top-left origin)
const PLAYER_SLOTS_X: int = 330         # Player slots X
const PLAYER_SLOTS_Y: int = 170         # Player slots Y (converted +12 offset)

# Player hand cards (5×4 grid of small cards - BOTTOM RIGHT)
# INDIVIDUAL SIZE: 90×100 pixels per card (ramka.png frame)
# TOTAL FRAME SIZE: ~520×400 pixels (5 cols × 104px spacing = ~520px wide, 4 rows × 100px = 400px tall)
# SAFE RANGES: X: 0-504, Y: 0-368
# WARNING: Constants are NAMED backwards due to coordinate bug!
# HAND_START_X actually controls VERTICAL position (despite the name!)
# HAND_START_Y actually controls HORIZONTAL position (despite the name!)
# This is swapped in initializePlayerCards() to correct it
# Java: ydown(328) = 440 in LibGDX (bottom-left origin)
# Godot: 768 - 440 - 111 + 12(Actor offset) = 229 (top-left origin)
# FIXED: Frame height is 111px, not 100px (was 240, corrected to 229)
const HAND_START_X: int = 229           # Actually VERTICAL! (converted +12 offset, frame height corrected)
const HAND_START_Y: int = 405           # Actually HORIZONTAL! (from Java x=405)
const HAND_SPACING_X: int = 104         # Horizontal spacing between card columns (center-to-center)
const HAND_CARD_GAP_Y: int = 6          # Vertical gap between cards (excluding card height)
										# Note: Total Y movement per card = GAP_Y + card_height (~106px)
const HAND_CARD_PORTRAIT_OFFSET_X: int = 0   # Portrait X offset inside card frame
const HAND_CARD_PORTRAIT_OFFSET_Y: int = 0   # Portrait Y offset inside card frame
const HAND_CARD_FRAME_OFFSET_X: int = -3     # Frame X offset relative to portrait
const HAND_CARD_FRAME_OFFSET_Y: int = -12    # Frame Y offset relative to portrait

# Player resource stats (Fire: X, Air: X, Water: X, Earth: X, Special: X - BOTTOM)
# INDIVIDUAL SIZE: ~50×20 pixels per label
# TOTAL FRAME SIZE: ~515×20 pixels (5 labels × 103px spacing = ~515px wide)
# SAFE RANGES: X: 0-509, Y: 0-748
const PLAYER_STATS_Y: int = 337         # Player's stats Y (Java: ydown(337) → use 337, above hand)

# ─────────────────────────────────────────────────────────────────────────────
# SHARED ELEMENTS (Used by both players)
# ─────────────────────────────────────────────────────────────────────────────

# Shared: Play slots z-index
const SLOTS_Z_INDEX: int = 1

# Shared: Portrait z-index (both player and opponent)
const PORTRAIT_Z_INDEX: int = 2

# Shared: Creature z-index (summoned creatures on battlefield)
const CREATURE_Z_INDEX: int = 2

# Shared: Resource stats horizontal positioning (both player and opponent use same X)
const STATS_START_X: int = 420          # Stat labels start X (Java: x=420, offset right from slots)
const STATS_SPACING_X: int = 103        # Horizontal spacing between stat labels (Java: incr=103)

# Shared: Player hand z-index
const HAND_Z_INDEX: int = 5

# Shared: Card description panel (large card detail display - LEFT CENTER)
# INDIVIDUAL SIZE: ~200×250 pixels (estimated)
# TOTAL FRAME SIZE: ~200×250 pixels (single panel)
# SAFE RANGES: X: 0-824, Y: 0-518
const CARD_DESC_X: int = 20             # Card description X (left side)
const CARD_DESC_Y: int = 256            # Card description Y (middle-left)
const CARD_DESC_Z_INDEX: int = 3

# Shared: Game log panel (scrolling text log - LEFT BOTTOM)
# INDIVIDUAL SIZE: 451×173 pixels (fixed size)
# TOTAL FRAME SIZE: 451×173 pixels (single panel)
# SAFE RANGES: X: 0-573, Y: 0-595
const GAME_LOG_X: int = 24              # Game log X (left side)
const GAME_LOG_Y: int = 559             # Game log Y (bottom area)
const GAME_LOG_WIDTH: int = 451         # Game log width (RESTORED from 220 - was incorrectly shortened)
const GAME_LOG_HEIGHT: int = 173        # Game log height
const GAME_LOG_Z_INDEX: int = 4

# ═════════════════════════════════════════════════════════════════════════════
# UI FINE-TUNING CONTROLS - ADJUST THESE TO FINE-TUNE THE UI
# ═════════════════════════════════════════════════════════════════════════════

# ALL PLAYER HAND CARD IMAGES - MOVES ALL THE CARD ARTWORK IN YOUR HAND
const HAND_CARD_IMAGE_ADJUST_X: int = 0      # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT
const HAND_CARD_IMAGE_ADJUST_Y: int = 12      # POSITIVE MOVES DOWN, NEGATIVE MOVES UP

# ALL PLAYER HAND CARD FRAMES - MOVES ALL THE FRAMES AROUND CARDS IN YOUR HAND
const HAND_CARD_FRAME_ADJUST_X: int = 0      # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT
const HAND_CARD_FRAME_ADJUST_Y: int = 16      # POSITIVE MOVES DOWN, NEGATIVE MOVES UP

# BOTH HANDS FOR PLAY AREA - MOVES BOTH PLAYER AND OPPONENT PLAY SLOTS TOGETHER
const PLAY_SLOTS_ADJUST_X: int = 0           # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT
const PLAY_SLOTS_ADJUST_Y: int = 0           # POSITIVE MOVES DOWN, NEGATIVE MOVES UP

# SKIP TURN BUTTON - MOVES THE SKIP TURN BUTTON AND ITS FRAME
const SKIP_TURN_BUTTON_ADJUST_X: int = 0     # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT
const SKIP_TURN_BUTTON_ADJUST_Y: int = 0     # POSITIVE MOVES DOWN, NEGATIVE MOVES UP

# PLAYER'S ELEMENTAL POWERS TEXT - MOVES ALL PLAYER POWER LABELS (FIRE, AIR, WATER, EARTH, OTHER)
const PLAYER_POWERS_ADJUST_X: int = 0        # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT
const PLAYER_POWERS_ADJUST_Y: int = -4        # POSITIVE MOVES DOWN, NEGATIVE MOVES UP
const POWERS_LABEL_FONT_SIZE: int = 18       # FONT SIZE FOR PLAYER'S ELEMENTAL POWERS TEXT

# OPPONENT'S ELEMENTAL POWERS TEXT - MOVES ALL OPPONENT POWER LABELS
const OPPONENT_POWERS_ADJUST_X: int = 0      # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT
const OPPONENT_POWERS_ADJUST_Y: int = 0      # POSITIVE MOVES DOWN, NEGATIVE MOVES UP

# VALUES FOR PLAYER'S CARD STATS - MOVES ALL CARD NUMBERS (ATTACK/COST/LIFE)
const HAND_CARD_STATS_ADJUST_X: int = -2     # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT
const HAND_CARD_STATS_ADJUST_Y: int = 25     # POSITIVE MOVES DOWN, NEGATIVE MOVES UP
const CARD_STATS_FONT_SIZE_SMALL: int = 16   # FONT SIZE FOR CARD STATS ON SMALL CARDS
const CARD_STATS_FONT_SIZE_LARGE: int = 20   # FONT SIZE FOR CARD STATS ON LARGE CARDS
const CARD_STATS_ATTACK_COLOR: Color = Color(1.0, 0.0, 0.0, 1.0)  # FONT COLOR FOR ATTACK (R, G, B, A) - DEFAULT RED
const CARD_STATS_COST_COLOR: Color = Color(1.0, 1.0, 0.0, 1.0)    # FONT COLOR FOR COST (R, G, B, A) - DEFAULT YELLOW
const CARD_STATS_LIFE_COLOR: Color = Color(0.0, 1.0, 0.0, 1.0)    # FONT COLOR FOR LIFE (R, G, B, A) - DEFAULT GREEN
const CARD_STATS_BOLD: bool = false          # MAKE CARD STATS BOLD (true) OR NORMAL (false)

# PLAYER'S PORTRAIT FRAME - MOVES THE ENTIRE PLAYER PORTRAIT (SPRITE + FRAME TOGETHER)
const PLAYER_PORTRAIT_FRAME_ADJUST_X: int = 0      # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT
const PLAYER_PORTRAIT_FRAME_ADJUST_Y: int = 0      # POSITIVE MOVES DOWN, NEGATIVE MOVES UP

# OPPONENT'S PORTRAIT FRAME - MOVES THE ENTIRE OPPONENT PORTRAIT (SPRITE + FRAME TOGETHER)
const OPPONENT_PORTRAIT_FRAME_ADJUST_X: int = 0    # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT
const OPPONENT_PORTRAIT_FRAME_ADJUST_Y: int = 0    # POSITIVE MOVES DOWN, NEGATIVE MOVES UP

# PLAYER PORTRAIT SPRITE INSIDE FRAME - FINE-TUNES WHERE PLAYER PORTRAIT IMAGE SITS INSIDE ITS FRAME
const PLAYER_PORTRAIT_SPRITE_ADJUST_X: int = 0      # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT (ADDS TO BASE 6)
const PLAYER_PORTRAIT_SPRITE_ADJUST_Y: int = 0      # POSITIVE MOVES DOWN, NEGATIVE MOVES UP (ADDS TO BASE 6)

# OPPONENT PORTRAIT SPRITE INSIDE FRAME - FINE-TUNES WHERE OPPONENT PORTRAIT IMAGE SITS INSIDE ITS FRAME
const OPPONENT_PORTRAIT_SPRITE_ADJUST_X: int = 0    # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT (ADDS TO BASE 6)
const OPPONENT_PORTRAIT_SPRITE_ADJUST_Y: int = 0    # POSITIVE MOVES DOWN, NEGATIVE MOVES UP (ADDS TO BASE 6)

# PLAYER PORTRAIT FRAME BORDER - FINE-TUNES WHERE PLAYER FRAME BORDER DRAWS AROUND PORTRAIT
const PLAYER_PORTRAIT_FRAME_BORDER_ADJUST_X: int = 0       # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT (ADDS TO BASE 0)
const PLAYER_PORTRAIT_FRAME_BORDER_ADJUST_Y: int = 0       # POSITIVE MOVES DOWN, NEGATIVE MOVES UP (ADDS TO BASE 0)

# OPPONENT PORTRAIT FRAME BORDER - FINE-TUNES WHERE OPPONENT FRAME BORDER DRAWS AROUND PORTRAIT
const OPPONENT_PORTRAIT_FRAME_BORDER_ADJUST_X: int = 0     # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT (ADDS TO BASE 0)
const OPPONENT_PORTRAIT_FRAME_BORDER_ADJUST_Y: int = 0     # POSITIVE MOVES DOWN, NEGATIVE MOVES UP (ADDS TO BASE 0)

# PLAYER'S CLASS & HP LABEL - MOVES THE "CLERIC LIFE: 60" TEXT
const PLAYER_INFO_LABEL_ADJUST_X: int = 0    # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT
const PLAYER_INFO_LABEL_ADJUST_Y: int = 0    # POSITIVE MOVES DOWN, NEGATIVE MOVES UP

# OPPONENT'S CLASS & HP LABEL - MOVES THE OPPONENT'S CLASS AND LIFE TEXT
const OPPONENT_INFO_LABEL_ADJUST_X: int = 0  # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT
const OPPONENT_INFO_LABEL_ADJUST_Y: int = 0  # POSITIVE MOVES DOWN, NEGATIVE MOVES UP

# FONT SIZE FOR CLASS & HP LABELS - CONTROLS THE SIZE OF "CLERIC LIFE: 60" TEXT
const INFO_LABEL_FONT_SIZE: int = 24

# OTHER BUTTONS - MOVES SHOW CARDS AND SHUFFLE CARDS BUTTONS
const SIDE_BUTTONS_ADJUST_X: int = 0         # POSITIVE MOVES RIGHT, NEGATIVE MOVES LEFT
const SIDE_BUTTONS_ADJUST_Y: int = 0         # POSITIVE MOVES DOWN, NEGATIVE MOVES UP

# ═════════════════════════════════════════════════════════════════════════════

# Background (full-screen battlefield image)
const BACKGROUND_Z_INDEX: int = -10     # Behind everything else

## Java: static Texture background; Sprite sprBg;
static var background: Texture2D = null
static var sprBg = null

# ============================================================================
# INSTANCE FIELDS (Java: public/private fields, lines 75-106)
# ============================================================================

## Java: public PlayerImage player; opponent;
var player: PlayerImage = null
var opponent: PlayerImage = null

## Java: Label playerInfoLabel; opptInfoLabel;
var playerInfoLabel: Label = null
var opptInfoLabel: Label = null

## Java: Button shuffleCardsButton; ImageButton skipTurnButton; Button showOpptCardsButton;
var shuffleCardsButton: Button = null
var skipTurnButton: TextureButton = null
var showOpptCardsButton: Button = null

## Java: public static LogScrollPane logScrollPane;
static var logScrollPane = null

## Java: Label[] topStrengthLabels = new Label[5]; bottomStrengthLabels = new Label[5];
var topStrengthLabels: Array = []  # 5 Labels
var bottomStrengthLabels: Array = []  # 5 Labels

## Java: public CardSetup cs;
var cs = null  # CardSetup instance

## Java: CardDescriptionImage cdi;
var cdi = null

## Java: SpriteBatch batch;
var batch = null  # Not needed in Godot, but kept for reference

## Java: public MouseOverCardListener li; ShowDescriptionListener sdl; SlotListener sl;
var li = null  # MouseOverCardListener
var sdl = null  # ShowDescriptionListener
var sl = null  # SlotListener

## Java: public SingleDuelChooser chooser;
var chooser = null

## Java: private CardImage selectedCard;
var selectedCard: CardImage = null

## Java: private boolean activeTurn = false;
var activeTurn: bool = false

## Java: private boolean gameOver = false;
var gameOver: bool = false

## Java: private boolean opptCardsShown = false;
var opptCardsShown: bool = false

## Java: private static int damageOffsetter = 0;
static var damageOffsetter: int = 0

# ============================================================================
# MAIN METHOD (Java: public static void main, lines 108-115)
# ============================================================================

## Java: public static void main(String[] args)
## In Godot, entry point is handled by project settings
## This would be called from main scene's _ready()

# ============================================================================
# INIT METHOD (Java: public void init(), lines 117-263)
# ============================================================================

## Java: @Override public void init()
## Initialize all game resources: textures, fonts, UI, player images
func init() -> void:
	print("Cards.init() START")

	# Initialize Specializations static data before accessing any specializations
	Specializations._ensure_initialized()

	# Java: cs = new CardSetup(); cs.parseCards(); (lines 120-121)
	# CardSetup is an autoload singleton, access directly
	cs = CardSetup
	CardSetup.parse_cards()
	print("Cards.init() - Parsed cards")

	# Java: batch = new SpriteBatch(); (line 123)
	# Not needed in Godot

	# Java: ramka = new Texture(...); (lines 125-130)
	ramka = load("res://assets/images/ramka.png")
	spellramka = load("res://assets/images/ramkaspell.png")
	portraitramka = load("res://assets/images/portraitramka.png")
	ramkabig = load("res://assets/images/ramkabig.png")
	ramkabigspell = load("res://assets/images/ramkabigspell.png")
	slotTexture = load("res://assets/images/slot.png")
	endTurnButtonTexture = load("res://assets/images/endturnbutton.png")

	# Java: smallCardAtlas = new TextureAtlas(...); (lines 132-138)
	# TODO: Load texture atlases - Godot uses different system

	# Java: background = new Texture(...); (lines 140-142)
	background = load("res://assets/images/background.jpg")
	# Java: sprBg = new Sprite(background); (creates sprite from background texture)
	# In Godot, use TextureRect to display background image
	sprBg = TextureRect.new()
	sprBg.texture = background
	sprBg.position = Vector2.ZERO
	sprBg.z_index = BACKGROUND_Z_INDEX
	sprBg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprBg.custom_minimum_size = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)
	sprBg.size = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)
	sprBg.stretch_mode = TextureRect.STRETCH_SCALE
	stage.add_child(sprBg)

	# Java: player = new PlayerImage(...); opponent = new PlayerImage(...); (lines 144-145)
	# CRITICAL FIX: Load portrait textures from faceCardAtlas and set them on PlayerImage objects
	var player_data = Player.new()
	var opponent_data = Player.new()

	player = PlayerImage.new(null, portraitramka, greenfont, player_data,
		PLAYER_PORTRAIT_X + PLAYER_PORTRAIT_FRAME_ADJUST_X,
		PLAYER_PORTRAIT_Y + PLAYER_PORTRAIT_FRAME_ADJUST_Y)
	player.z_index = PORTRAIT_Z_INDEX
	player.visible = false  # Hide until battle starts (prevent showing in class select)
	# Set per-instance portrait adjustments (player portraits offset differently than opponent)
	player.sprite_adjust_x = PLAYER_PORTRAIT_SPRITE_ADJUST_X
	player.sprite_adjust_y = PLAYER_PORTRAIT_SPRITE_ADJUST_Y
	player.frame_border_adjust_x = PLAYER_PORTRAIT_FRAME_BORDER_ADJUST_X
	player.frame_border_adjust_y = PLAYER_PORTRAIT_FRAME_BORDER_ADJUST_Y

	# Load and set player portrait texture from imgName
	var player_portrait_texture = TextureManager.get_face_texture(player_data.get_img_name())
	if player_portrait_texture:
		player.set_texture(player_portrait_texture)
		print("Cards.init(): Set player portrait texture from imgName: ", player_data.get_img_name())
	else:
		push_warning("Cards.init(): Failed to load player portrait texture for: ", player_data.get_img_name())

	opponent = PlayerImage.new(null, portraitramka, greenfont, opponent_data,
		OPPONENT_PORTRAIT_X + OPPONENT_PORTRAIT_FRAME_ADJUST_X,
		OPPONENT_PORTRAIT_Y + OPPONENT_PORTRAIT_FRAME_ADJUST_Y)
	opponent.z_index = PORTRAIT_Z_INDEX
	opponent.visible = false  # Hide until battle starts (prevent showing in class select)
	# Set per-instance portrait adjustments (opponent portraits offset differently than player)
	opponent.sprite_adjust_x = OPPONENT_PORTRAIT_SPRITE_ADJUST_X
	opponent.sprite_adjust_y = OPPONENT_PORTRAIT_SPRITE_ADJUST_Y
	opponent.frame_border_adjust_x = OPPONENT_PORTRAIT_FRAME_BORDER_ADJUST_X
	opponent.frame_border_adjust_y = OPPONENT_PORTRAIT_FRAME_BORDER_ADJUST_Y

	# Load and set opponent portrait texture from imgName
	var opponent_portrait_texture = TextureManager.get_face_texture(opponent_data.get_img_name())
	if opponent_portrait_texture:
		opponent.set_texture(opponent_portrait_texture)
		print("Cards.init(): Set opponent portrait texture from imgName: ", opponent_data.get_img_name())
	else:
		push_warning("Cards.init(): Failed to load opponent portrait texture for: ", opponent_data.get_img_name())

	# Java: defaultFont = new BitmapFont(); (lines 147-151)
	# TODO: Load fonts properly
	defaultFont = ThemeDB.fallback_font
	# greenfont = load font
	# customFont = load font

	# Java: whiteStyle = new Label.LabelStyle(defaultFont, Color.WHITE); (lines 153-155)
	# TODO: Create label styles

	# Java: playerInfoLabel = new Label(...); (lines 157-160)
	# Java: playerInfoLabel.setPosition(80 + 10 + 120, ydown(300));
	# LibGDX setPosition() sets BOTTOM-LEFT, Godot position sets TOP-LEFT
	# ydown(300) = 468 is the BOTTOM of the label in LibGDX
	# Godot Y = 768 - 468 - label_height = 768 - 468 - 28 = 272
	playerInfoLabel = Label.new()
	playerInfoLabel.text = Specializations.CLERIC.get_title()
	playerInfoLabel.position = Vector2(
		210 + PLAYER_INFO_LABEL_ADJUST_X,
		272 + PLAYER_INFO_LABEL_ADJUST_Y)
	playerInfoLabel.add_theme_font_size_override("font_size", INFO_LABEL_FONT_SIZE)
	playerInfoLabel.add_theme_color_override("font_color", Color.WHITE)
	playerInfoLabel.custom_minimum_size = Vector2(150, 20)

	# Java: opptInfoLabel.setPosition(80 + 10 + 120, ydown(30));
	# LibGDX setPosition() sets BOTTOM-LEFT, Godot position sets TOP-LEFT
	# ydown(30) = 738 is the BOTTOM of the label in LibGDX
	# Godot Y = 768 - 738 - label_height = 768 - 738 - 28 = 2
	opptInfoLabel = Label.new()
	opptInfoLabel.text = Specializations.CLERIC.get_title()
	opptInfoLabel.position = Vector2(
		210 + OPPONENT_INFO_LABEL_ADJUST_X,
		2 + OPPONENT_INFO_LABEL_ADJUST_Y)
	opptInfoLabel.add_theme_font_size_override("font_size", INFO_LABEL_FONT_SIZE)
	opptInfoLabel.add_theme_color_override("font_color", Color.WHITE)
	opptInfoLabel.custom_minimum_size = Vector2(150, 20)

	# Java: ImageButtonStyle style = ... (lines 162-165)
	# TODO: Create button styles

	# Java: showOpptCardsButton = new Button(skin); (lines 167-192)
	# Java: setBounds(10, ydown(50), 50, 50) where ydown(50) = 768-50 = 718
	# For widgets, use the original Y value (50), not the ydown result
	showOpptCardsButton = Button.new()
	showOpptCardsButton.pressed.connect(_on_show_oppt_cards_pressed)
	showOpptCardsButton.position = Vector2(
		10 + SIDE_BUTTONS_ADJUST_X,
		50 + SIDE_BUTTONS_ADJUST_Y)
	showOpptCardsButton.size = Vector2(50, 50)
	stage.add_child(showOpptCardsButton)

	# Java: skipTurnButton = new ImageButton(style); (lines 194-206)
	# Java: style uses endturnbutton.png texture (line 163)
	# Java: setBounds(10, ydown(110), 50, 50) where ydown(110) = 768-110 = 658
	# For widgets, use the original Y value (110), not the ydown result
	skipTurnButton = TextureButton.new()
	if endTurnButtonTexture:
		skipTurnButton.texture_normal = endTurnButtonTexture
	skipTurnButton.pressed.connect(_on_skip_turn_pressed)
	skipTurnButton.position = Vector2(
		10 + SKIP_TURN_BUTTON_ADJUST_X,
		110 + SKIP_TURN_BUTTON_ADJUST_Y)
	skipTurnButton.custom_minimum_size = Vector2(50, 50)
	skipTurnButton.ignore_texture_size = true
	skipTurnButton.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	stage.add_child(skipTurnButton)

	# Java: shuffleCardsButton = new Button(skin); (lines 208-220)
	# Java: setBounds(10, ydown(170), 50, 50) where ydown(170) = 768-170 = 598
	# For widgets, use the original Y value (170), not the ydown result
	shuffleCardsButton = Button.new()
	shuffleCardsButton.pressed.connect(_on_shuffle_cards_pressed)
	shuffleCardsButton.position = Vector2(
		10 + SIDE_BUTTONS_ADJUST_X,
		170 + SIDE_BUTTONS_ADJUST_Y)
	shuffleCardsButton.size = Vector2(50, 50)
	stage.add_child(shuffleCardsButton)

	# Java: int x = 420; int y = ydown(337); int incr = 103; (lines 222-228)
	# Player strength labels (bottom)
	# LibGDX setPosition() sets BOTTOM-LEFT, Godot position sets TOP-LEFT
	# ydown(337) = 431, Godot Y = 768 - 431 - label_height = 768 - 431 - 22 = 315
	var x: int = STATS_START_X
	var y: int = PLAYER_STATS_Y - 22  # FIXED: Subtract label height (font 18 ≈ 22px)
	for i in range(5):
		var label := Label.new()
		label.text = getPlayerStrength(player.get_player_info(), CardType.Type.OTHER)
		x += STATS_SPACING_X
		label.position = Vector2(
			x + PLAYER_POWERS_ADJUST_X,
			y + PLAYER_POWERS_ADJUST_Y)
		# Add styling to make labels visible
		label.add_theme_font_size_override("font_size", POWERS_LABEL_FONT_SIZE)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.custom_minimum_size = Vector2(90, 20)
		stage.add_child(label)
		bottomStrengthLabels.append(label)

	# Java: x = 420; y = ydown(25); (lines 230-236)
	# Opponent strength labels (top)
	# LibGDX setPosition() sets BOTTOM-LEFT, Godot position sets TOP-LEFT
	# ydown(25) = 743, Godot Y = 768 - 743 - label_height = 768 - 743 - 22 = 3
	x = STATS_START_X
	y = OPPONENT_STATS_Y - 22  # FIXED: Subtract label height (font 18 ≈ 22px)
	for i in range(5):
		var label := Label.new()
		label.text = getPlayerStrength(opponent.get_player_info(), CardType.Type.OTHER)
		x += STATS_SPACING_X
		label.position = Vector2(
			x + OPPONENT_POWERS_ADJUST_X,
			y + OPPONENT_POWERS_ADJUST_Y)
		# Add styling to make labels visible
		label.add_theme_font_size_override("font_size", POWERS_LABEL_FONT_SIZE)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.custom_minimum_size = Vector2(90, 20)
		stage.add_child(label)
		topStrengthLabels.append(label)

	# Java: cdi = new CardDescriptionImage(20, ydown(512)); (lines 238-239)
	cdi = CardDescriptionImage.new(null, null, greenfont, null, CARD_DESC_X, CARD_DESC_Y)
	cdi.setFont(greenfont)
	cdi.z_index = CARD_DESC_Z_INDEX

	# Java: logScrollPane = new LogScrollPane(skin); (lines 241-242)
	logScrollPane = LogScrollPane.new()
	logScrollPane.position = Vector2(GAME_LOG_X, GAME_LOG_Y)
	logScrollPane.custom_minimum_size = Vector2(GAME_LOG_WIDTH, GAME_LOG_HEIGHT)
	logScrollPane.z_index = GAME_LOG_Z_INDEX
	logScrollPane.visible = false  # Hide initially, show after chooser is done

	# Java: stage.addActor(player); etc. (lines 244-249)
	stage.add_child(player)
	stage.add_child(opponent)
	stage.add_child(playerInfoLabel)
	stage.add_child(opptInfoLabel)
	stage.add_child(cdi)
	stage.add_child(logScrollPane)

	# Java: sl = new SlotListener(); li = new MouseOverCardListener(); sdl = new ShowDescriptionListener(); (lines 251-253)
	# TODO: Create listener instances

	# Java: addSlotImages(opponent, 330, ydown(170), false); (lines 255-256)
	# Java: addSlotImages(player, 330, ydown(290), true);
	addSlotImages(opponent, OPPONENT_SLOTS_X, OPPONENT_SLOTS_Y, false)   # Opponent slots at top
	addSlotImages(player, PLAYER_SLOTS_X, PLAYER_SLOTS_Y, true)         # Player slots below opponent

	# Java: chooser = new SingleDuelChooser(); chooser.init(this); (lines 258-259)
	chooser = SingleDuelChooser.new()
	chooser.init(self)
	stage.add_child(chooser)
	print("Cards.init() - Created and added chooser to stage")
	print("  stage children: ", stage.get_child_count())
	print("  chooser position: ", chooser.position)
	print("  chooser size: ", chooser.size)

	# Java: Sounds.startBackGroundMusic(); (line 261)
	if SoundManager:
		SoundManager.start_background_music()

	print("Cards.init() END - Battle UI created, chooser active")

# ============================================================================
# YDOWN METHOD (Java: public static int ydown, lines 265-267)
# ============================================================================

## Java: public static int ydown(int y)
## Convert Y coordinate from top-down to bottom-up
static func ydown(y: int) -> int:
	return SCREEN_HEIGHT - y

# ============================================================================
# DRAW METHOD (Java: public void draw, lines 269-320)
# ============================================================================

## Java: @Override public void draw(float delta)
## Main rendering loop
func draw(_delta: float) -> void:
	# Java: if (chooser != null) { (line 272)
	if chooser != null:
		# Java: if (!chooser.done.get()) { (line 274)
		if not chooser.done:
			# Java: chooser.draw(delta); (line 275)
			# chooser renders automatically via _process()
			pass
		else:
			print("Cards.draw() - Chooser DONE, starting battle initialization")
			# Hide chooser to show battle UI (initialize() will set chooser = null)
			chooser.visible = false

			# Java: Thread t = new Thread(new InitializeGameThread()); t.start(); (lines 278-279)
			_initialize_game_thread()

			# Java: Gdx.input.setInputProcessor(new InputMultiplexer(this, stage)); (line 281)
			# TODO: Set input processor

	else:
		# Battle rendering mode
		# Static flag to print debug once
		if not has_node("_battle_debug_printed"):
			var marker = Node.new()
			marker.name = "_battle_debug_printed"
			add_child(marker)
			print("\n=== BATTLE MODE RENDERING ===")
			print("  Player:")
			print("    Visible:", player.visible, " Pos:", player.position, " Children:", player.get_child_count())
			print("  Opponent:")
			print("    Visible:", opponent.visible, " Pos:", opponent.position, " Children:", opponent.get_child_count())
			print("  PlayerInfoLabel:")
			print("    Visible:", playerInfoLabel.visible, " Pos:", playerInfoLabel.position, " Text:", playerInfoLabel.text)
			print("  OpptInfoLabel:")
			print("    Visible:", opptInfoLabel.visible, " Pos:", opptInfoLabel.position, " Text:", opptInfoLabel.text)
			print("  LogScrollPane:")
			print("    Visible:", logScrollPane.visible, " Pos:", logScrollPane.position)
			print("  SkipTurnButton:")
			print("    Visible:", skipTurnButton.visible, " Pos:", skipTurnButton.position)
			print("  Total stage children:", stage.get_child_count())
			print("==============================\n")

		# Java: batch.begin(); sprBg.draw(batch); (lines 286-287)
		# Background is now a TextureRect child node, drawn automatically by Godot

		# Java: if (NET_GAME != null) { (line 288)
		if NET_GAME != null:
			# TODO: Draw turn indicator and connected host
			pass

		# Java: batch.end(); (line 292)

		# Java: Player pInfo = player.get_player_info(); (lines 294-295)
		var pInfo: Player = player.get_player_info()
		var oInfo: Player = opponent.get_player_info()

		# Java: playerInfoLabel.setText(getPlayerDescription(pInfo)); (lines 297-298)
		playerInfoLabel.text = getPlayerDescription(pInfo)
		opptInfoLabel.text = getPlayerDescription(oInfo)

		# Java: CardType[] types = {...}; (line 300)
		var types: Array = [CardType.Type.FIRE, CardType.Type.AIR, CardType.Type.WATER, CardType.Type.EARTH, opponent.get_player_info().get_player_class().get_type()]

		# Java: for (int i = 0; i < 5; i++) { setStrengthLabel(topStrengthLabels[i], oInfo, types[i]); } (lines 301-303)
		for i in range(5):
			setStrengthLabel(topStrengthLabels[i], oInfo, types[i])

		# Java: types[4] = player.get_player_info().get_player_class().get_type(); (line 304)
		types[4] = player.get_player_info().get_player_class().get_type()

		# Java: for (int i = 0; i < 5; i++) { setStrengthLabel(bottomStrengthLabels[i], pInfo, types[i]); } (lines 305-307)
		for i in range(5):
			setStrengthLabel(bottomStrengthLabels[i], pInfo, types[i])

		# Java: stage.act(Gdx.graphics.getDeltaTime()); stage.draw(); (lines 309-310)
		# TODO: Stage act and draw

	# Java: batch.begin(); ... draw cursor ... batch.end(); (lines 314-318)
	# TODO: Draw custom cursor

# ============================================================================
# INNER CLASS: InitializeGameThread (Java: lines 322-331)
# ============================================================================

func _initialize_game_thread() -> void:
	# Java: public void run() { try { initialize(); } catch (Exception e) { e.printStackTrace(); } }
	await get_tree().process_frame
	initialize()

# ============================================================================
# INITIALIZE METHOD (Java: public void initialize, lines 333-389)
# ============================================================================

## Java: public void initialize() throws Exception
## Initialize game state for new game
func initialize() -> void:
	print("Cards.initialize() START")
	# Java: synchronized (this) { (line 335)
	# Java: if (chooser == null) { return; } (lines 337-339)
	if chooser == null:
		print("  ERROR: chooser is null, aborting")
		return
	print("  chooser exists, proceeding with init")

	# Java: for (int index = 0; index < 6; index++) { (line 341)
	print("  Clearing slots...")
	for index in range(6):
		# Java: if (player.get_slot_cards()[index] != null) { player.get_slot_cards()[index].remove(); } (lines 342-344)
		if player.get_slot_cards()[index] != null:
			player.get_slot_cards()[index].queue_free()

		player.get_slot_cards()[index] = null
		player.get_slots()[index].set_occupied(false)

		# Java: if (opponent.get_slot_cards()[index] != null) { opponent.get_slot_cards()[index].remove(); } (lines 348-350)
		if opponent.get_slot_cards()[index] != null:
			opponent.get_slot_cards()[index].queue_free()

		opponent.get_slot_cards()[index] = null
		opponent.get_slots()[index].set_occupied(false)

	# Java: player.set_img(chooser.pi.get_img()); (lines 355-357)
	print("  Setting player images and info from chooser...")
	print("    chooser.pi.img:", chooser.pi.img)
	print("    chooser.oi.img:", chooser.oi.img)
	player.set_img(chooser.pi.get_img())
	player.set_player_info(chooser.pi.get_player_info())
	player.get_player_info().init()
	print("    Player class:", player.get_player_info().get_player_class().get_title())

	# Java: opponent.set_img(chooser.oi.get_img()); (lines 359-361)
	opponent.set_img(chooser.oi.get_img())
	opponent.set_player_info(chooser.oi.get_player_info())
	opponent.get_player_info().init()
	print("    Opponent class:", opponent.get_player_info().get_player_class().get_title())

	# Java: chooser = null; gameOver = false; Cards.logScrollPane.clear(); (lines 363-365)
	# Free chooser after copying data from it
	print("  Freeing chooser...")
	var temp_chooser = chooser
	chooser = null
	if temp_chooser:
		stage.remove_child(temp_chooser)
		temp_chooser.queue_free()

	gameOver = false
	if logScrollPane:
		logScrollPane.clear()
		logScrollPane.visible = true  # Show log panel now that we're in battle
		print("    Game log cleared and shown")

	# Show portraits now that battle has started (were hidden during class select)
	if player:
		player.visible = true
	if opponent:
		opponent.visible = true

	# Show play slots now that battle has started (were hidden during class select)
	for i in range(6):
		if player and player.get_slots()[i]:
			player.get_slots()[i].visible = true
		if opponent and opponent.get_slots()[i]:
			opponent.get_slots()[i].visible = true
	print("    Portraits and slots are now visible")

	# Java: initializePlayerCards(player.get_player_info(), true); (lines 369-370)
	print("  Initializing player cards (visible=true)...")
	initializePlayerCards(player.get_player_info(), true)
	print("  Initializing opponent cards (visible=false)...")
	initializePlayerCards(opponent.get_player_info(), false)

	# Java: if (NET_GAME != null) { (lines 372-381)
	if NET_GAME != null:
		# TODO: Network handshake
		pass

	# Java: for (CardType type : Player.TYPES) { (lines 384-387)
	print("  Enabling/disabling cards by type...")
	for type in Player.TYPES:
		player.get_player_info().enable_disable_cards(type)
		opponent.get_player_info().enable_disable_cards(type)

	print("Cards.initialize() COMPLETE - Battle should be ready")

	# Debug: Print complete scene tree
	debug_scene_tree()

# ============================================================================
# DEBUG SCENE TREE
# ============================================================================

func debug_scene_tree() -> void:
	print("\n=== COMPLETE SCENE TREE ===")
	for i in range(stage.get_child_count()):
		var child = stage.get_child(i)
		print("Child %d: %s" % [i, child.name if child.name else "<unnamed>"])
		print("  Type: %s" % child.get_class())
		if child is Node2D or child is Control:
			print("  Position: %s" % str(child.position))
		if child is CanvasItem:
			print("  Z-Index: %s" % child.z_index)
			print("  Visible: %s" % child.visible)
		if child is Control:
			print("  Size: %s" % str(child.size))
		if child is TextureRect:
			print("  Has Texture: %s" % (child.texture != null))
			if child.texture:
				print("  Texture Size: %s" % str(child.texture.get_size()))
	print("=== END SCENE TREE ===\n")

# ============================================================================
# INITIALIZE PLAYER CARDS METHOD (Java: lines 391-416)
# ============================================================================

## Java: public void initializePlayerCards(Player player, boolean visible) throws Exception
func initializePlayerCards(p_player: Player, show_cards: bool) -> void:
	print("    initializePlayerCards: visible=", show_cards)
	# Java: selectedCard = null; (line 393)
	selectedCard = null

	# Java: int x = 405; int y = ydown(328); (lines 395-396)
	# CRITICAL FIX: Based on user testing, the variable assignments are SWAPPED!
	# User set HAND_START_X=400 (expecting horizontal) but it controlled VERTICAL
	# User set HAND_START_Y=790 (expecting vertical) but it controlled HORIZONTAL
	# This means the constant NAMES don't match their actual usage!
	var x: int = HAND_START_Y  # SWAPPED: x should be horizontal, comes from _Y constant!
	var y: int = HAND_START_X  # SWAPPED: y should be vertical, comes from _X constant!
	print("      Starting position: x=", x, " y=", y)

	# Java: CardType[] types = {...}; (line 398)
	var types: Array = [CardType.Type.FIRE, CardType.Type.AIR, CardType.Type.WATER, CardType.Type.EARTH, p_player.get_player_class().get_type()]

	# Java: for (CardType type : types) { (line 400)
	for type in types:
		# Java: if (player.get_cards(type) != null && player.get_cards(type).size() > 0) { (line 402)
		if p_player.get_cards(type) != null and p_player.get_cards(type).size() > 0:
			# Java: for (CardImage ci : player.get_cards(type)) { ci.remove(); } (lines 403-405)
			for ci in p_player.get_cards(type):
				ci.queue_free()

		# Java: List<CardImage> v1 = cs.getCardImagesByType(...); (line 408)
		# Godot: TextureManager handles atlases internally, no atlas parameters needed
		var v1: Array = cs.get_card_images_by_type(type, 4)
		print("      Type ", CardType.get_title(type), ": created ", v1.size(), " cards")

		# Java: x += 104; (line 409)
		# Use configurable horizontal spacing from constants
		x += HAND_SPACING_X

		# Java: addVerticalGroupCards(x, y, v1, player, type, visible); (line 410)
		print("      Adding vertical group at x=", x, " y=", y, " visible=", show_cards)
		addVerticalGroupCards(x, y, v1, p_player, type, show_cards)

		# Java: player.set_cards(type, v1); (line 411)
		p_player.set_cards(type, v1)

		# Java: player.enable_disable_cards(type); (line 413)
		p_player.enable_disable_cards(type)

# ============================================================================
# HELPER METHODS (Java: lines 418-429)
# ============================================================================

## Java: public void setStrengthLabel(Label label, Player pl, CardType type)
func setStrengthLabel(label: Label, pl: Player, type: CardType.Type) -> void:
	label.text = getPlayerStrength(pl, type)

## Java: public String getPlayerDescription(Player pl)
func getPlayerDescription(pl: Player) -> String:
	return pl.get_player_class().get_title() + " Life: " + str(pl.get_life())

## Java: public String getPlayerStrength(Player pl, CardType type)
func getPlayerStrength(pl: Player, type: CardType.Type) -> String:
	var str_val: int = 0 if pl == null else pl.get_strength(type)
	return CardType.get_title(type) + ":  " + str(str_val)

# ============================================================================
# ADD VERTICAL GROUP CARDS METHOD (Java: lines 431-459)
# ============================================================================

## Java: public void addVerticalGroupCards(...)
func addVerticalGroupCards(x: int, y: int, cards: Array, _p_player: Player, _type: CardType.Type, addToStage: bool) -> void:
	# Java: CardImage.sort(cards); (line 433)
	CardImage.sort_cards(cards)

	# Java: float x1 = x; float y1 = y; int spacing = 6; (lines 435-437)
	var x1: float = x
	var y1: float = y
	# Use configurable vertical gap from constants
	var spacing: int = HAND_CARD_GAP_Y

	# Java: for (CardImage ci : cards) { (line 439)
	for ci in cards:
		# Java: if (!addToStage) { x1 = 0; y1 = ydown(0); } (lines 441-444)
		if not addToStage:
			x1 = 0
			y1 = ydown(0)

		# Java: ci.set_font(customFont); (line 446)
		ci.set_font(customFont)

		# Java: ci.set_frame(ci.get_card().is_spell() ? spellramka : ramka); (line 447)
		ci.set_frame(spellramka if ci.get_card().is_spell() else ramka)

		# Java: ci.addListener(sdl); (line 448)
		# Connect hover signals for card description (ShowDescriptionListener equivalent)
		ci.card_hovered.connect(_on_card_hovered)
		ci.card_unhovered.connect(_on_card_unhovered)

		# Java: y1 -= (spacing + ci.get_frame().getHeight()); (line 450)
		# CRITICAL FIX: Java LibGDX had Y=0 at BOTTOM, so subtracting moved UP
		# Godot has Y=0 at TOP, so we ADD to move DOWN (stack cards downward)
		y1 += (spacing + ci.get_frame().get_height())

		# Java: ci.setBounds(x1, y1, ci.get_frame().getWidth(), ci.get_frame().getHeight()); (line 451)
		# Vector2(x, y) where x=horizontal, y=vertical (standard Godot)
		# The swap is done earlier in initializePlayerCards() variable assignment
		ci.position = Vector2(x1, y1)
		ci.size = Vector2(ci.get_frame().get_width(), ci.get_frame().get_height())

		# Java: if (addToStage) { ci.addListener(li); stage.addActor(ci); } (lines 453-456)
		if addToStage:
			# Connect click signal for card interaction (MouseOverCardListener equivalent)
			ci.card_clicked.connect(_on_card_clicked)
			ci.z_index = HAND_Z_INDEX  # Hand cards above most UI elements
			stage.add_child(ci)

# ============================================================================
# ADD SLOT IMAGES METHOD (Java: lines 461-476)
# ============================================================================

## Java: public void addSlotImages(PlayerImage pi, int x, int y, boolean bottom)
func addSlotImages(pi: PlayerImage, x: int, y: int, bottom: bool) -> void:
	# Java: float x1 = x; int spacing = 5; (lines 462-463)
	var x1: float = x
	# NOTE: SLOT_SPACING_X is the center-to-center distance (~95px)
	# Java used spacing=5 + texture width, we calculate from SLOT_SPACING_X

	# Java: for (int i = 0; i < 6; i++) { (line 464)
	for i in range(6):
		# Java: SlotImage s = new SlotImage(slotTexture, i, bottom); (line 466)
		var s := SlotImage.new(slotTexture, i, bottom)

		# Java: s.setBounds(x1, y, s.texture.get_width(), s.texture.get_height()); (line 467)
		s.position = Vector2(x1, y)
		s.size = Vector2(s.texture.get_width(), s.texture.get_height())
		s.z_index = SLOTS_Z_INDEX  # Above background, below everything else
		s.visible = false  # Hide until battle starts (prevent showing in class select)

		# Java: x1 += (spacing + s.texture.get_width()); (line 468)
		# Use configurable spacing from constants
		x1 += SLOT_SPACING_X

		# Java: s.addListener(sl); (line 469)
		# Connect slot click signal (SlotListener equivalent)
		s.slot_clicked.connect(_on_slot_clicked)

		# Java: stage.addActor(s); (line 471)
		stage.add_child(s)

		# Java: pi.get_slots()[i] = s; (line 473)
		pi.get_slots()[i] = s

# ============================================================================
# BUTTON SIGNAL HANDLERS (Godot-specific, replaces Java InputListeners)
# ============================================================================

func _on_show_oppt_cards_pressed() -> void:
	# Java: lines 168-190
	if opptCardsShown:
		return

	opptCardsShown = true

	var title_text: String = getPlayerDescription(opponent.get_player_info())
	var _window = OpponentCardWindow.new(title_text, opponent.get_player_info(), self, skin)

	# TODO: Add close button and show window

func _on_skip_turn_pressed() -> void:
	# Java: lines 195-203
	# Java: if (gameOver) { return true; } (lines 197-199)
	print("=== SKIP TURN PRESSED ===")
	if gameOver:
		print("  -> Game is over, cannot skip turn")
		return

	# Java: BattleRoundThread t = new BattleRoundThread(Cards.this, player, opponent); (line 200)
	# Java: t.start(); (line 201)
	print("  -> Starting battle round (opponent's turn)")

	# Clear any selections
	selectedCard = null
	clearHighlights()

	# Java: BattleRoundThread t = new BattleRoundThread(Cards.this, player, opponent); (line 200)
	# Java: t.start(); (line 201)
	# This constructor variant means no creature summoned and no spell cast
	# Just process attacks and AI turn
	var battle_thread := BattleRoundThread.new(self, player, opponent)
	battle_thread.execute()

	print("=== SKIP TURN COMPLETE ===")

func _on_shuffle_cards_pressed() -> void:
	# Java: lines 209-217
	initializePlayerCards(player.get_player_info(), true)

# ============================================================================
# CARD/SLOT SIGNAL HANDLERS (Converted from Java InputListeners)
# ============================================================================

## Card click handler - MouseOverCardListener.touchDown() equivalent
## Java source: Cards.java lines 480-577 (MouseOverCardListener.touchDown)
## Handles clicking cards in the player's hand
func _on_card_clicked(card_visual: CardImage) -> void:
	print("=== CARD CLICKED ===")
	print("Card: ", card_visual.get_card().name if card_visual.get_card() else "null")
	print("Game over: ", gameOver, " Can start turn: ", canStartMyTurn())

	# Java: if (gameOver || !canStartMyTurn()) { return true; } (lines 482-484)
	if gameOver or not canStartMyTurn():
		print("  -> Cannot interact: gameOver or not my turn")
		return

	# Java: selectedCard = (CardImage) actor; (line 489)
	selectedCard = card_visual
	print("  -> Selected card set to: ", selectedCard.get_card().name if selectedCard.get_card() else "null")

	# Java: clearHighlights(); (line 491)
	clearHighlights()

	# Java: if (canStartMyTurn() && selectedCard.isEnabled()) { (line 493)
	if not canStartMyTurn() or not selectedCard.is_enabled():
		print("  -> Card not enabled or can't start turn")
		return

	var card_data: Card = selectedCard.get_card()

	# Java: if (selectedCard.getCard().isSpell()) { (line 495)
	if card_data.is_spell():
		print("  -> Card is a SPELL")

		# Java: if (selectedCard.getCard().isTargetable()) { (line 497)
		if card_data.is_targetable():
			print("    -> Spell is TARGETABLE")
			var target_type := card_data.get_target_type()
			print("    -> Target type: ", target_type)

			# Java: switch (selectedCard.getCard().getTargetType()) { (line 500)
			match target_type:
				Card.TargetType.OWNER:
					# Java: case OWNER: (lines 501-509)
					print("      -> Highlighting OWNER (player) cards")
					var cards: Array[CardImage] = player.get_slot_cards()
					for ci in cards:
						if ci != null:
							ci.set_highlighted(true)
							# Java: ci.addAction(forever(sequence(color(Color.GREEN, .75f), color(Color.WHITE, .75f)))); (line 506)
							add_color_pulse(ci)

				Card.TargetType.OPPONENT:
					# Java: case OPPONENT: (lines 510-518)
					print("      -> Highlighting OPPONENT cards")
					var cards: Array[CardImage] = opponent.get_slot_cards()
					for ci in cards:
						if ci != null:
							ci.set_highlighted(true)
							# Java: ci.addAction(forever(sequence(color(Color.GREEN, .75f), color(Color.WHITE, .75f)))); (line 515)
							add_color_pulse(ci)

				Card.TargetType.ANY:
					# Java: case ANY: (lines 519-534)
					print("      -> Highlighting ANY (both player and opponent) cards")
					# Highlight player's creatures
					var player_cards: Array[CardImage] = player.get_slot_cards()
					for ci in player_cards:
						if ci != null:
							ci.set_highlighted(true)
							add_color_pulse(ci)
					# Highlight opponent's creatures
					var opponent_cards: Array[CardImage] = opponent.get_slot_cards()
					for ci in opponent_cards:
						if ci != null:
							ci.set_highlighted(true)
							add_color_pulse(ci)

		# Java: else if (selectedCard.getCard().isTargetableOnEmptySlotOnly()) { (line 537)
		elif card_data.is_targetable_on_empty_slot_only():
			print("    -> Spell targetable on EMPTY SLOT only")
			# Java: for (SlotImage si : player.getSlots()) { (line 540)
			for si in player.get_slots():
				if not si.is_occupied():
					si.set_highlighted(true)
					# Java: si.addAction(forever(sequence(color(Color.GREEN, .75f), color(Color.WHITE, .75f)))); (line 543)
					add_color_pulse(si)

		# Java: else { //cast the spell (line 547)
		else:
			print("    -> Spell is NON-TARGETABLE, casting immediately")
			# Java: BattleRoundThread t = new BattleRoundThread(Cards.this, player, opponent, selectedCard); (line 549)
			# Java: t.start(); (line 550)
			startTurn()
			var battle_thread := BattleRoundThread.new(self, player, opponent, selectedCard)
			battle_thread.execute()

	# Java: else if (selectedCard.getCard().getMustBeSummoneOnCard() != null) { (line 553)
	elif card_data.get_must_be_summoned_on_card() != null and card_data.get_must_be_summoned_on_card() != "":
		print("  -> Card must be summoned on specific card")
		# Java: String requiredTarget = selectedCard.getCard().getMustBeSummoneOnCard(); (line 556)
		var required_target: String = card_data.get_must_be_summoned_on_card()
		print("    -> Required target: ", required_target)

		# Java: for (CardImage ci : player.getSlotCards()) { (line 559)
		for ci in player.get_slot_cards():
			if ci != null:
				var target_name: String = ci.get_card().name if ci.get_card() else ""
				# Java: if (ci != null && (ci.getCard().getName().equalsIgnoreCase(requiredTarget) || requiredTarget.equals("any"))) { (line 560)
				if target_name.to_lower() == required_target.to_lower() or required_target.to_lower() == "any":
					print("      -> Highlighting valid target: ", target_name)
					ci.set_highlighted(true)
					# Java: ci.addAction(forever(sequence(color(Color.GREEN, .75f), color(Color.WHITE, .75f)))); (line 562)
					add_color_pulse(ci)

	# Regular creature - highlight available slots
	else:
		print("  -> Regular CREATURE card, highlighting player slots")
		# Highlight player's slots for summoning
		for si in player.get_slots():
			if not si.is_occupied():
				si.set_highlighted(true)
				add_color_pulse(si)

	print("=== CARD CLICKED COMPLETE ===")

## Card hover handler - ShowDescriptionListener.enter() equivalent
## Java source: Cards.java lines 715-744 (ShowDescriptionListener.enter)
## Shows large card preview when hovering
func _on_card_hovered(card_visual: CardImage) -> void:
	print("Card hovered: ", card_visual.get_card().name if card_visual.get_card() else "null")

	# Java: if (actor == null) { return; } (lines 718-720)
	if card_visual == null or card_visual.get_card() == null:
		return

	var card_data: Card = card_visual.get_card()

	# Java: Sprite sp = largeCardAtlas.createSprite(card.getName().toLowerCase()); (line 726)
	# Godot: TextureManager returns Texture2D directly, not Sprite2D
	var card_name_lower: String = card_data.name.to_lower()
	var card_texture: Texture2D = null

	# Try to get large card texture from TextureManager
	card_texture = TextureManager.get_large_card_texture(card_name_lower)

	# Java: if (sp == null) { cdi.setImg(null); return; } (lines 733-736)
	if card_texture == null:
		print("  -> No texture found for: ", card_name_lower)
		cdi.setImg(null)
		return

	# Java: cdi.setImg(sp); (line 740)
	# Godot: setImg() expects Texture2D (no sprite flipping needed)
	cdi.setImg(card_texture)

	# Java: cdi.setFrame(ci.getCard().isSpell() ? ramkabigspell : ramkabig); (line 741)
	var frame_texture: Texture2D = ramkabigspell if card_data.is_spell() else ramkabig
	cdi.setFrame(frame_texture)

	# Java: cdi.setCard(card); (line 742)
	cdi.setCard(card_data)

## Card unhover handler - ShowDescriptionListener.exit() equivalent
## Java source: Cards.java lines 746-748 (ShowDescriptionListener.exit)
## Hides large card preview when mouse leaves
func _on_card_unhovered(card_visual: CardImage) -> void:
	print("Card unhovered: ", card_visual.get_card().name if card_visual.get_card() else "null")
	# Java: cdi.setImg(null); (line 747)
	cdi.setImg(null)

## Slot click handler - SlotListener.touchDown() equivalent
## Java source: Cards.java lines 658-711 (SlotListener.touchDown)
## Handles clicking slots to place cards or cast spells
func _on_slot_clicked(slot: SlotImage) -> void:
	print("=== SLOT CLICKED ===")
	print("Slot index: ", slot.get_slot_index(), " Bottom: ", slot.is_bottom_slots(), " Occupied: ", slot.is_occupied())
	print("Game over: ", gameOver, " Can start turn: ", canStartMyTurn())
	print("Selected card: ", selectedCard.get_card().name if selectedCard and selectedCard.get_card() else "null")

	# Java: if (gameOver) { return true; } (lines 660-662)
	if gameOver:
		print("  -> Game is over, ignoring click")
		return

	# Java: if (canStartMyTurn() && selectedCard != null && selectedCard.isEnabled() && si.isBottomSlots()) { (line 669)
	if not canStartMyTurn() or selectedCard == null or not selectedCard.is_enabled():
		print("  -> Cannot act: can't start turn, no card selected, or card not enabled")
		return

	if not slot.is_bottom_slots():
		print("  -> Cannot click opponent's slots")
		return

	var card_data: Card = selectedCard.get_card()

	# Java: if (!selectedCard.getCard().isSpell() && selectedCard.getCard().getMustBeSummoneOnCard() == null) { (line 671)
	if not card_data.is_spell() and (card_data.get_must_be_summoned_on_card() == null or card_data.get_must_be_summoned_on_card() == ""):
		print("  -> Summoning creature to slot ", slot.get_slot_index())

		# Java: startTurn(); (line 672)
		startTurn()

		# Java: final CardImage clone = selectedCard.clone(); (line 674)
		var clone: CardImage = selectedCard.clone_card()

		# Java: stage.addActor(clone); (line 676)
		stage.add_child(clone)
		clone.z_index = CREATURE_Z_INDEX  # Creatures on battlefield

		# Java: CardImage[] imgs = player.getSlotCards(); imgs[si.getIndex()] = clone; (lines 680-681)
		var slot_index: int = slot.get_slot_index()

		# Java: clone.addListener(new TargetedCardListener(player.getPlayerInfo().getId(), si.getIndex())); (line 677)
		clone.card_clicked.connect(func(card_vis: CardImage): _on_battlefield_card_clicked(card_vis, player.get_player_info().get_id(), slot_index))

		# Java: clone.addListener(sdl); (line 678)
		# Connect hover signals for the cloned card
		clone.card_hovered.connect(_on_card_hovered)
		clone.card_unhovered.connect(_on_card_unhovered)
		player.get_slot_cards()[slot_index] = clone

		# Java: SlotImage[] slots = player.getSlots(); slots[si.getIndex()].setOccupied(true); (lines 683-684)
		player.get_slots()[slot_index].set_occupied(true)

		# Java: Creature summonedCreature = CreatureFactory.getCreatureClass(...); (line 686)
		var summoned_creature = CreatureFactory.get_creature_class(
			clone.get_card().name,
			self,  # Cards reference
			clone.get_card(),
			clone,
			slot_index,
			player,
			opponent
		)
		clone.set_creature(summoned_creature)

		# Java: Sounds.play(Sound.SUMMONED); (line 689)
		if SoundManager:
			SoundManager.play_sound(SoundTypes.Sound.SUMMONED)

		# Java: clone.addAction(sequence(moveTo(si.getX() + 5, si.getY() + 26, 1.0f), new Action() {...})); (lines 691-697)
		# Animate card from hand to slot
		clone.position = selectedCard.position

		var tween := create_tween()
		tween.set_meta("bound_node", clone)  # Tag tween with the node it's animating
		tween.tween_property(
			clone,
			"position",
			Vector2(slot.position.x + 5, slot.position.y + 26),
			1.0
		)
		tween.tween_callback(func():
			print("    -> Animation complete, executing battle round")
			# Java: BattleRoundThread t = new BattleRoundThread(Cards.this, player, opponent, clone, si.getIndex()); (line 693)
			# Java: t.start(); (line 694)
			var battle_thread := BattleRoundThread.new(self, player, opponent, clone, slot_index)
			battle_thread.execute()
		)

	# Java: else if (selectedCard.getCard().isSpell() && si.isHighlighted()) { (line 699)
	elif card_data.is_spell() and slot.is_highlighted_slot():
		print("  -> Casting SPELL on empty slot ", slot.get_slot_index())

		# Java: startTurn(); (line 700)
		startTurn()

		# Java: clearHighlights(); (line 701)
		clearHighlights()

		# Java: BattleRoundThread t = new BattleRoundThread(Cards.this, player, opponent, selectedCard, null, player.getPlayerInfo().getId(), si.getIndex()); (line 704)
		# Java: t.start(); (line 705)
		var battle_thread := BattleRoundThread.new(self, player, opponent, selectedCard, slot.get_slot_index(), player.get_player_info().getId())
		battle_thread.execute()

	else:
		print("  -> No action taken (conditions not met)")

	print("=== SLOT CLICKED COMPLETE ===")

# ============================================================================
# HELPER METHODS CONTINUED (Java: lines 751-968)
# ============================================================================

## Java: public void clearHighlights()
func clearHighlights() -> void:
	# Java: for (CardImage ci : player.get_slot_cards()) { (lines 752-758)
	for ci in player.get_slot_cards():
		if ci != null:
			ci.set_highlighted(false)
			ci.clear_actions()
			ci.modulate = Color.WHITE

	# Java: for (CardImage ci : opponent.get_slot_cards()) { (lines 759-765)
	for ci in opponent.get_slot_cards():
		if ci != null:
			ci.set_highlighted(false)
			ci.clear_actions()
			ci.modulate = Color.WHITE

	# Java: for (SlotImage si : player.get_slots()) { (lines 766-770)
	for si in player.get_slots():
		si.set_highlighted(false)
		si.clear_actions()
		si.modulate = Color.WHITE

	# Java: for (SlotImage si : opponent.get_slots()) { (lines 771-775)
	for si in opponent.get_slots():
		si.set_highlighted(false)
		si.clear_actions()
		si.modulate = Color.WHITE

## Adds pulsing color animation to a node
## Java: forever(sequence(color(Color.GREEN, .75f), color(Color.WHITE, .75f)))
func add_color_pulse(node: Node2D, color1: Color = Color.GREEN, color2: Color = Color.WHITE, duration: float = 0.75) -> void:
	var tween: Tween = create_tween()
	tween.set_meta("bound_node", node)
	tween.set_loops()
	tween.tween_property(node, "modulate", color1, duration)
	tween.tween_property(node, "modulate", color2, duration)

## Handles clicking on battlefield cards for spell targeting
## Java: TargetedCardListener.touchDown() (Cards.java inner class)
func _on_battlefield_card_clicked(card_visual: CardImage, owner_id: String, slot_index: int) -> void:
	if gameOver or not canStartMyTurn():
		return

	if selectedCard == null or not selectedCard.get_card().is_spell():
		return

	if not card_visual.is_highlighted():
		return

	# Cast the spell targeting this card
	startTurn()
	clearHighlights()

	var battle_thread := BattleRoundThread.new(self, player, opponent, selectedCard, card_visual, owner_id)
	battle_thread.execute()

## Java: public void animateDamageText(int value, CardImage ci)
func animateDamageText(value: int, target) -> void:
	if target is CardImage:
		_animateDamageTextImpl(value, target.position.x + 70, target.position.y + 10, target.position.x + 70, target.position.y + 69)
	elif target is PlayerImage:
		_animateDamageTextImpl(value, target.position.x + 90, target.position.y + 5, target.position.x + 90, target.position.y + 55)

## Java: public void animateHealingText(int value, CardImage ci)
func animateHealingText(value: int, target) -> void:
	if target is CardImage:
		_animateHealingTextImpl(value, target.position.x + 70, target.position.y + 10, target.position.x + 70, target.position.y + 69)
	elif target is PlayerImage:
		_animateHealingTextImpl(value, target.position.x + 90, target.position.y + 5, target.position.x + 90, target.position.y + 55)

## Java: private void animateDamageText(int value, float sx, float sy, float dx, float dy)
func _animateDamageTextImpl(value: int, sx: float, sy: float, _dx: float, _dy: float) -> void:
	# Java: if (redStyle == null) { return; } (lines 796-798)
	if redStyle == null:
		return

	# Java: Label label = new Label("- " + value, redStyle); (line 799)
	var label := Label.new()
	label.text = "- " + str(value)
	# TODO: Apply red style

	# Java: damageOffsetter = damageOffsetter + 5; if (damageOffsetter > 60) { damageOffsetter = 0; } (lines 801-804)
	damageOffsetter = damageOffsetter + 5
	if damageOffsetter > 60:
		damageOffsetter = 0

	# Java: label.setPosition(sx - damageOffsetter, sy); (line 806)
	label.position = Vector2(sx - damageOffsetter, sy)

	# Java: stage.addActor(label); (line 807)
	stage.add_child(label)

	# Java: label.addAction(sequence(moveTo(dx - damageOffsetter, dy, 3), fadeOut(1), removeActor(label))); (line 808)
	# TODO: Create tween for animation

## Java: private void animateHealingText(int value, float sx, float sy, float dx, float dy)
func _animateHealingTextImpl(value: int, sx: float, sy: float, _dx: float, _dy: float) -> void:
	# Java: if (greenStyle == null) { return; } (lines 812-814)
	if greenStyle == null:
		return

	# Java: damageOffsetter = damageOffsetter + 5; if (damageOffsetter > 60) { damageOffsetter = 0; } (lines 816-819)
	damageOffsetter = damageOffsetter + 5
	if damageOffsetter > 60:
		damageOffsetter = 0

	# Java: Label label = new Label("+ " + value, greenStyle); (line 821)
	var label := Label.new()
	label.text = "+ " + str(value)
	# TODO: Apply green style

	# Java: label.setPosition(sx - damageOffsetter, sy); (line 822)
	label.position = Vector2(sx - damageOffsetter, sy)

	# Java: stage.addActor(label); (line 823)
	stage.add_child(label)

	# Java: label.addAction(sequence(moveTo(dx - damageOffsetter, dy, 3), fadeOut(1), removeActor(label))); (line 824)
	# TODO: Create tween for animation

## Java: public void moveCardActorOnBattle(CardImage ci, PlayerImage pi)
func moveCardActorOnBattle(ci: CardImage, pi: PlayerImage) -> void:
	# Java: if (ci == null || pi == null) { System.err.println("moveCardActorOnBattle: null ci or pi"); return; } (lines 829-832)
	if ci == null or pi == null:
		push_error("moveCardActorOnBattle: null ci or pi")
		return

	# Java: Sounds.play(Sound.ATTACK); (line 834)
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.ATTACK)

	# Java: if (pi.get_slots()[0] == null) { return; } (lines 836-838)
	if pi.get_slots()[0] == null:
		return

	# Java: boolean isBottom = pi.get_slots()[0].is_bottom_slots(); (line 842)
	var isBottom: bool = pi.get_slots()[0].is_bottom_slots()

	# Java: ci.addAction(sequence(moveBy(0, isBottom ? 20 : -20, 0.5f), moveBy(0, isBottom ? -20 : 20, 0.5f), ...)); (lines 844-849)
	var tween := create_tween()
	var move_amount: float = 20 if isBottom else -20
	tween.tween_property(ci, "position:y", ci.position.y + move_amount, 0.5)
	tween.tween_property(ci, "position:y", ci.position.y, 0.5)
	await tween.finished

## Java: public void moveCardActorOnMagic(CardImage ci, PlayerImage pi)
func moveCardActorOnMagic(ci: CardImage, pi: PlayerImage) -> void:
	# Java: if (ci == null || pi == null) { System.err.println("moveCardActorOnMagic: null ci or pi"); return; } (lines 863-866)
	if ci == null or pi == null:
		push_error("moveCardActorOnMagic: null ci or pi")
		return

	# Java: boolean isBottom = pi.get_slots()[0].is_bottom_slots(); (line 870)
	var isBottom: bool = pi.get_slots()[0].is_bottom_slots()

	# Java: pi.addAction(sequence(moveBy(0, isBottom ? -20 : 20, 0.5f), moveBy(0, isBottom ? 20 : -20, 0.5f), ...)); (lines 872-877)
	var tween := create_tween()
	var move_amount: float = -20 if isBottom else 20
	tween.tween_property(pi, "position:y", pi.position.y + move_amount, 0.5)
	tween.tween_property(pi, "position:y", pi.position.y, 0.5)
	await tween.finished

## Java: public CardImage getSelectedCard()
func getSelectedCard() -> CardImage:
	return selectedCard

## Java: public void handleGameOver()
func handleGameOver() -> void:
	# Java: gameOver = true; (line 894)
	gameOver = true

	# Java: Cards.logScrollPane.add("Game Over"); (line 896)
	if logScrollPane:
		logScrollPane.add("Game Over")

	# Java: if (Cards.NET_GAME != null) { Cards.NET_GAME.sendYourTurnSignal(); } (lines 898-900)
	if NET_GAME != null:
		NET_GAME.sendYourTurnSignal()

	# Java: Dialog dialog = new Dialog(...).text("Play Again?").button("Yes", true).button("No", false); (lines 902-909)
	# TODO: Show dialog

## Java: public PlayerImage getPlayerImage(String id) throws Exception
func getPlayerImage(id: String) -> PlayerImage:
	# Java: PlayerImage ret = null; (line 916)
	var ret: PlayerImage = null

	# Java: if (player.get_player_info().get_id().equalsIgnoreCase(id)) { ret = player; } (lines 917-919)
	if player.get_player_info().get_id().to_lower() == id.to_lower():
		ret = player

	# Java: if (opponent.get_player_info().get_id().equalsIgnoreCase(id)) { ret = opponent; } (lines 921-923)
	if opponent.get_player_info().get_id().to_lower() == id.to_lower():
		ret = opponent

	# Java: if (ret == null) { throw new Exception("Could not find player with id: " + id); } (lines 925-927)
	if ret == null:
		push_error("Could not find player with id: " + id)

	# Java: return ret; (line 929)
	return ret

## Java: public void setOpposingPlayerId(String id)
func setOpposingPlayerId(id: String) -> void:
	# Java: opponent.get_player_info().set_id(id); (line 933)
	opponent.get_player_info().set_id(id)

## Java: public PlayerImage getOpposingPlayerImage(String id)
func getOpposingPlayerImage(id: String) -> PlayerImage:
	# Java: PlayerImage ret = null; (line 938)
	var ret: PlayerImage = null

	# Java: if (player.get_player_info().get_id().equalsIgnoreCase(id)) { ret = opponent; } (lines 940-942)
	if player.get_player_info().get_id().to_lower() == id.to_lower():
		ret = opponent

	# Java: if (opponent.get_player_info().get_id().equalsIgnoreCase(id)) { ret = player; } (lines 944-946)
	if opponent.get_player_info().get_id().to_lower() == id.to_lower():
		ret = player

	# Java: return ret; (line 948)
	return ret

## Java: public void startTurn()
func startTurn() -> void:
	# Java: activeTurn = true; (line 952)
	activeTurn = true

## Java: public void finishTurn()
func finishTurn() -> void:
	# Java: this.activeTurn = false; this.selectedCard = null; (lines 956-957)
	self.activeTurn = false
	self.selectedCard = null

## Java: public boolean canStartMyTurn()
func canStartMyTurn() -> bool:
	# Java: if (NET_GAME != null && NET_GAME.isConnected()) { return NET_GAME.isMyTurn(); } (lines 962-964)
	if NET_GAME != null and NET_GAME.isConnected():
		return NET_GAME.isMyTurn()

	# Java: return !activeTurn; (line 966)
	return not activeTurn
