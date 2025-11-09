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
	# Initialize Specializations static data before accessing any specializations
	Specializations._ensure_initialized()

	# Java: cs = new CardSetup(); cs.parseCards(); (lines 120-121)
	# CardSetup is an autoload singleton, access directly
	cs = CardSetup
	CardSetup.parse_cards()

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
	# TODO: Create sprite from background

	# Java: player = new PlayerImage(...); opponent = new PlayerImage(...); (lines 144-145)
	player = PlayerImage.new(null, portraitramka, greenfont, Player.new(), 80, ydown(300))
	opponent = PlayerImage.new(null, portraitramka, greenfont, Player.new(), 80, ydown(125))

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
	playerInfoLabel.position = Vector2(80 + 10 + 120, ydown(300))

	opptInfoLabel = Label.new()
	opptInfoLabel.text = Specializations.CLERIC.get_title()
	opptInfoLabel.position = Vector2(80 + 10 + 120, ydown(30))

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
	var x: int = 420
	var y: int = ydown(337)
	var incr: int = 103
	for i in range(5):
		var label := Label.new()
		label.text = getPlayerStrength(player.get_player_info(), CardType.Type.OTHER)
		x += incr
		label.position = Vector2(x, y)
		stage.add_child(label)
		bottomStrengthLabels.append(label)

	# Java: x = 420; y = ydown(25); (lines 230-236)
	x = 420
	y = ydown(25)
	for i in range(5):
		var label := Label.new()
		label.text = getPlayerStrength(opponent.get_player_info(), CardType.Type.OTHER)
		x += incr
		label.position = Vector2(x, y)
		stage.add_child(label)
		topStrengthLabels.append(label)

	# Java: cdi = new CardDescriptionImage(20, ydown(512)); (lines 238-239)
	cdi = CardDescriptionImage.new(null, null, greenfont, null, 20, ydown(512))
	cdi.setFont(greenfont)

	# Java: logScrollPane = new LogScrollPane(skin); (lines 241-242)
	# Java: logScrollPane.setBounds(24, 36, 451, 173);
	logScrollPane = LogScrollPane.new()
	logScrollPane.position = Vector2(24, 36)
	logScrollPane.custom_minimum_size = Vector2(451, 173)

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
	addSlotImages(opponent, 330, ydown(170), false)
	addSlotImages(player, 330, ydown(290), true)

	# Java: chooser = new SingleDuelChooser(); chooser.init(this); (lines 258-259)
	chooser = SingleDuelChooser.new()
	chooser.init(self)

	# Java: Sounds.startBackGroundMusic(); (line 261)
	if SoundManager:
		SoundManager.start_background_music()

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
func draw(delta: float) -> void:
	# Java: if (chooser != null) { (line 272)
	if chooser != null:
		# Java: if (!chooser.done.get()) { (line 274)
		if not chooser.done:
			# Java: chooser.draw(delta); (line 275)
			chooser.draw(delta)
		else:
			# Java: Thread t = new Thread(new InitializeGameThread()); t.start(); (lines 278-279)
			_initialize_game_thread()

			# Java: Gdx.input.setInputProcessor(new InputMultiplexer(this, stage)); (line 281)
			# TODO: Set input processor

	else:
		# Java: batch.begin(); sprBg.draw(batch); (lines 286-287)
		# TODO: Draw background sprite

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
	# Java: synchronized (this) { (line 335)
	# Java: if (chooser == null) { return; } (lines 337-339)
	if chooser == null:
		return

	# Java: for (int index = 0; index < 6; index++) { (line 341)
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
	player.set_img(chooser.pi.get_img())
	player.set_player_info(chooser.pi.get_player_info())
	player.get_player_info().init()

	# Java: opponent.set_img(chooser.oi.get_img()); (lines 359-361)
	opponent.set_img(chooser.oi.get_img())
	opponent.set_player_info(chooser.oi.get_player_info())
	opponent.get_player_info().init()

	# Java: chooser = null; gameOver = false; Cards.logScrollPane.clear(); (lines 363-365)
	chooser = null
	gameOver = false
	if logScrollPane:
		logScrollPane.clear()

	# Java: initializePlayerCards(player.get_player_info(), true); (lines 369-370)
	initializePlayerCards(player.get_player_info(), true)
	initializePlayerCards(opponent.get_player_info(), false)

	# Java: if (NET_GAME != null) { (lines 372-381)
	if NET_GAME != null:
		# TODO: Network handshake
		pass

	# Java: for (CardType type : Player.TYPES) { (lines 384-387)
	for type in Player.TYPES:
		player.get_player_info().enable_disable_cards(type)
		opponent.get_player_info().enable_disable_cards(type)

# ============================================================================
# INITIALIZE PLAYER CARDS METHOD (Java: lines 391-416)
# ============================================================================

## Java: public void initializePlayerCards(Player player, boolean visible) throws Exception
func initializePlayerCards(p_player: Player, visible: bool) -> void:
	# Java: selectedCard = null; (line 393)
	selectedCard = null

	# Java: int x = 405; int y = ydown(328); (lines 395-396)
	var x: int = 405
	var y: int = ydown(328)

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
		var v1: Array = cs.get_card_images_by_type(smallCardAtlas, smallTGACardAtlas, type, 4)

		# Java: x += 104; (line 409)
		x += 104

		# Java: addVerticalGroupCards(x, y, v1, player, type, visible); (line 410)
		addVerticalGroupCards(x, y, v1, p_player, type, visible)

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
	return pl.get_player_class().getTitle() + " Life: " + str(pl.get_life())

## Java: public String getPlayerStrength(Player pl, CardType type)
func getPlayerStrength(pl: Player, type: CardType.Type) -> String:
	var str_val: int = 0 if pl == null else pl.get_strength(type)
	return CardType.get_title(type) + ":  " + str(str_val)

# ============================================================================
# ADD VERTICAL GROUP CARDS METHOD (Java: lines 431-459)
# ============================================================================

## Java: public void addVerticalGroupCards(...)
func addVerticalGroupCards(x: int, y: int, cards: Array, p_player: Player, type: CardType.Type, addToStage: bool) -> void:
	# Java: CardImage.sort(cards); (line 433)
	CardImage.sort_cards(cards)

	# Java: float x1 = x; float y1 = y; int spacing = 6; (lines 435-437)
	var x1: float = x
	var y1: float = y
	var spacing: int = 6

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
		y1 -= (spacing + ci.get_frame().get_height())

		# Java: ci.setBounds(x1, y1, ci.get_frame().getWidth(), ci.get_frame().getHeight()); (line 451)
		ci.position = Vector2(x1, y1)
		ci.size = Vector2(ci.get_frame().get_width(), ci.get_frame().get_height())

		# Java: if (addToStage) { ci.addListener(li); stage.addActor(ci); } (lines 453-456)
		if addToStage:
			# TODO: Add listener
			stage.add_child(ci)

# ============================================================================
# ADD SLOT IMAGES METHOD (Java: lines 461-476)
# ============================================================================

## Java: public void addSlotImages(PlayerImage pi, int x, int y, boolean bottom)
func addSlotImages(pi: PlayerImage, x: int, y: int, bottom: bool) -> void:
	# Java: float x1 = x; int spacing = 5; (lines 462-463)
	var x1: float = x
	var spacing: int = 5

	# Java: for (int i = 0; i < 6; i++) { (line 464)
	for i in range(6):
		# Java: SlotImage s = new SlotImage(slotTexture, i, bottom); (line 466)
		var s := SlotImage.new(slotTexture, i, bottom)

		# Java: s.setBounds(x1, y, s.texture.get_width(), s.texture.get_height()); (line 467)
		s.position = Vector2(x1, y)
		s.size = Vector2(s.texture.get_width(), s.texture.get_height())

		# Java: x1 += (spacing + s.texture.get_width()); (line 468)
		x1 += (spacing + s.texture.get_width())

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
	var window = OpponentCardWindow.new(title_text, opponent.get_player_info(), self, skin)

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
func _animateDamageTextImpl(value: int, sx: float, sy: float, dx: float, dy: float) -> void:
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
func _animateHealingTextImpl(value: int, sx: float, sy: float, dx: float, dy: float) -> void:
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
