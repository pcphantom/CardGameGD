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
const OPPONENT_PORTRAIT_X: int = 10     # Opponent portrait X (left edge)
const OPPONENT_PORTRAIT_Y: int = 50     # Opponent portrait Y (TOP area)
const PORTRAIT_SPRITE_OFFSET_X: int = 0      # Sprite X offset inside portrait frame
const PORTRAIT_SPRITE_OFFSET_Y: int = 0      # Sprite Y offset inside portrait frame
const PORTRAIT_FRAME_OFFSET_X: int = -6      # Frame X offset relative to sprite
const PORTRAIT_FRAME_OFFSET_Y: int = -6      # Frame Y offset relative to sprite

# Opponent play slots (6 card slots in a row - TOP RIGHT)
# INDIVIDUAL SIZE: 92×132 pixels per slot (slot.png)
# TOTAL FRAME SIZE: ~570×132 pixels (6 slots × ~95px spacing = ~570px wide)
# SAFE RANGES: X: 0-454, Y: 0-636
const OPPONENT_SLOTS_Y: int = 50        # Opponent's slot row Y (TOP area)
const SLOT_SPACING_X: int = 95          # Horizontal spacing between play slots

# Opponent resource stats (Fire: X, Air: X, Water: X, Earth: X, Special: X - TOP)
# INDIVIDUAL SIZE: ~50×20 pixels per label
# TOTAL FRAME SIZE: ~515×20 pixels (5 labels × 103px spacing = ~515px wide)
# SAFE RANGES: X: 0-509, Y: 0-748
const OPPONENT_STATS_Y: int = 25        # Opponent's stats Y (ABOVE play slots)

# ─────────────────────────────────────────────────────────────────────────────
# PLAYER ELEMENTS (Bottom area of screen)
# ─────────────────────────────────────────────────────────────────────────────

# Player portrait (large character face - LOWER LEFT)
# INDIVIDUAL SIZE: 132×132 pixels (portraitramka.png frame)
# TOTAL FRAME SIZE: 132×132 pixels (single portrait)
# SAFE RANGES: X: 0-892, Y: 0-636
const PLAYER_PORTRAIT_X: int = 10       # Player portrait X (left edge)
const PLAYER_PORTRAIT_Y: int = 300      # Player portrait Y (BOTTOM area)

# Player play slots (6 card slots in a row - MIDDLE RIGHT)
# INDIVIDUAL SIZE: 92×132 pixels per slot (slot.png)
# TOTAL FRAME SIZE: ~570×132 pixels (6 slots × ~95px spacing = ~570px wide)
# SAFE RANGES: X: 0-454, Y: 0-636
const PLAYER_SLOTS_Y: int = 170         # Player's slot row Y (BELOW opponent)

# Player hand cards (5×4 grid of small cards - BOTTOM RIGHT)
# INDIVIDUAL SIZE: 90×100 pixels per card (ramka.png frame)
# TOTAL FRAME SIZE: ~520×400 pixels (5 cols × 104px spacing = ~520px wide, 4 rows × 100px = 400px tall)
# SAFE RANGES: X: 0-504, Y: 0-368
# WARNING: Y > 368 will push bottom cards off-screen!
const HAND_START_X: int = 260           # Hand cards start X (right side)
const HAND_START_Y: int = 340           # Hand cards start Y (BOTTOM area)
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
const PLAYER_STATS_Y: int = 340         # Player's stats Y (ABOVE player hand)

# ─────────────────────────────────────────────────────────────────────────────
# SHARED ELEMENTS (Used by both players)
# ─────────────────────────────────────────────────────────────────────────────

# Shared: Play slots horizontal positioning (both player and opponent use same X)
const PLAY_SLOTS_X: int = 260           # Play slots start X (right side, for both rows)
const SLOTS_Z_INDEX: int = 1

# Shared: Portrait z-index (both player and opponent)
const PORTRAIT_Z_INDEX: int = 2

# Shared: Resource stats horizontal positioning (both player and opponent use same X)
const STATS_START_X: int = 260          # Stat labels start X (right side, for both rows)
const STATS_SPACING_X: int = 103        # Horizontal spacing between stat labels

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
	player = PlayerImage.new(null, portraitramka, greenfont, Player.new(), PLAYER_PORTRAIT_X, PLAYER_PORTRAIT_Y)
	player.z_index = PORTRAIT_Z_INDEX
	player.visible = false  # Hide until battle starts (prevent showing in class select)
	opponent = PlayerImage.new(null, portraitramka, greenfont, Player.new(), OPPONENT_PORTRAIT_X, OPPONENT_PORTRAIT_Y)
	opponent.z_index = PORTRAIT_Z_INDEX
	opponent.visible = false  # Hide until battle starts (prevent showing in class select)

	# Java: defaultFont = new BitmapFont(); (lines 147-151)
	# TODO: Load fonts properly
	defaultFont = ThemeDB.fallback_font
	# greenfont = load font
	# customFont = load font

	# Java: whiteStyle = new Label.LabelStyle(defaultFont, Color.WHITE); (lines 153-155)
	# TODO: Create label styles

	# Java: playerInfoLabel = new Label(...); (lines 157-160)
	playerInfoLabel = Label.new()
	playerInfoLabel.text = Specializations.CLERIC.get_title()
	playerInfoLabel.position = Vector2(PLAYER_PORTRAIT_X + 130, PLAYER_PORTRAIT_Y)

	opptInfoLabel = Label.new()
	opptInfoLabel.text = Specializations.CLERIC.get_title()
	opptInfoLabel.position = Vector2(OPPONENT_PORTRAIT_X + 130, SCREEN_HEIGHT - 30)

	# Java: ImageButtonStyle style = ... (lines 162-165)
	# TODO: Create button styles

	# Java: showOpptCardsButton = new Button(skin); (lines 167-192)
	showOpptCardsButton = Button.new()
	showOpptCardsButton.pressed.connect(_on_show_oppt_cards_pressed)
	showOpptCardsButton.position = Vector2(10, ydown(50))
	showOpptCardsButton.size = Vector2(50, 50)
	stage.add_child(showOpptCardsButton)

	# Java: skipTurnButton = new ImageButton(style); (lines 194-206)
	# Java: style uses endturnbutton.png texture (line 163)
	skipTurnButton = TextureButton.new()
	if endTurnButtonTexture:
		skipTurnButton.texture_normal = endTurnButtonTexture
	skipTurnButton.pressed.connect(_on_skip_turn_pressed)
	skipTurnButton.position = Vector2(10, ydown(110))
	skipTurnButton.custom_minimum_size = Vector2(50, 50)
	skipTurnButton.ignore_texture_size = true
	skipTurnButton.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	stage.add_child(skipTurnButton)

	# Java: shuffleCardsButton = new Button(skin); (lines 208-220)
	shuffleCardsButton = Button.new()
	shuffleCardsButton.pressed.connect(_on_shuffle_cards_pressed)
	shuffleCardsButton.position = Vector2(10, ydown(170))
	shuffleCardsButton.size = Vector2(50, 50)
	stage.add_child(shuffleCardsButton)

	# Java: int x = 420; int y = ydown(337); int incr = 103; (lines 222-228)
	# Player strength labels (bottom)
	var x: int = STATS_START_X
	var y: int = PLAYER_STATS_Y
	for i in range(5):
		var label := Label.new()
		label.text = getPlayerStrength(player.get_player_info(), CardType.Type.OTHER)
		x += STATS_SPACING_X
		label.position = Vector2(x, y)
		stage.add_child(label)
		bottomStrengthLabels.append(label)

	# Java: x = 420; y = ydown(25); (lines 230-236)
	# Opponent strength labels (top)
	x = STATS_START_X
	y = OPPONENT_STATS_Y
	for i in range(5):
		var label := Label.new()
		label.text = getPlayerStrength(opponent.get_player_info(), CardType.Type.OTHER)
		x += STATS_SPACING_X
		label.position = Vector2(x, y)
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
	addSlotImages(opponent, PLAY_SLOTS_X, OPPONENT_SLOTS_Y, false)   # Opponent slots at top
	addSlotImages(player, PLAY_SLOTS_X, PLAYER_SLOTS_Y, true)         # Player slots below opponent

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
	var x: int = HAND_START_X
	var y: int = HAND_START_Y
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
		# TODO: Add listeners

		# Java: y1 -= (spacing + ci.get_frame().getHeight()); (line 450)
		# Total Y movement per card = gap + frame height
		y1 -= (spacing + ci.get_frame().get_height())

		# Java: ci.setBounds(x1, y1, ci.get_frame().getWidth(), ci.get_frame().getHeight()); (line 451)
		ci.position = Vector2(x1, y1)
		ci.size = Vector2(ci.get_frame().get_width(), ci.get_frame().get_height())

		# Java: if (addToStage) { ci.addListener(li); stage.addActor(ci); } (lines 453-456)
		if addToStage:
			# TODO: Add listener
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
		# TODO: Add listener

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
	if gameOver:
		return

	# TODO: Start BattleRoundThread

func _on_shuffle_cards_pressed() -> void:
	# Java: lines 209-217
	initializePlayerCards(player.get_player_info(), true)

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
		SoundManager.play(SoundTypes.Sound.ATTACK)

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
