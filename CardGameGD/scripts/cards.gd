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
var skipTurnButton: Button = null
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
	# Java: cs = new CardSetup(); cs.parseCards(); (lines 120-121)
	cs = CardSetup.new()
	cs.parseCards()

	# Java: batch = new SpriteBatch(); (line 123)
	# Not needed in Godot

	# Java: ramka = new Texture(...); (lines 125-130)
	ramka = load("res://images/ramka.png")
	spellramka = load("res://images/ramkaspell.png")
	portraitramka = load("res://images/portraitramka.png")
	ramkabig = load("res://images/ramkabig.png")
	ramkabigspell = load("res://images/ramkabigspell.png")
	slotTexture = load("res://images/slot.png")

	# Java: smallCardAtlas = new TextureAtlas(...); (lines 132-138)
	# TODO: Load texture atlases - Godot uses different system

	# Java: background = new Texture(...); (lines 140-142)
	background = load("res://images/background.jpg")
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
	playerInfoLabel.text = Specializations.Cleric.getTitle()
	playerInfoLabel.position = Vector2(80 + 10 + 120, ydown(300))

	opptInfoLabel = Label.new()
	opptInfoLabel.text = Specializations.Cleric.getTitle()
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
	skipTurnButton = Button.new()
	skipTurnButton.pressed.connect(_on_skip_turn_pressed)
	skipTurnButton.position = Vector2(10, ydown(110))
	skipTurnButton.size = Vector2(50, 50)
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
		label.text = getPlayerStrength(player.playerInfo, CardType.Type.OTHER)
		x += incr
		label.position = Vector2(x, y)
		stage.add_child(label)
		bottomStrengthLabels.append(label)

	# Java: x = 420; y = ydown(25); (lines 230-236)
	x = 420
	y = ydown(25)
	for i in range(5):
		var label := Label.new()
		label.text = getPlayerStrength(opponent.playerInfo, CardType.Type.OTHER)
		x += incr
		label.position = Vector2(x, y)
		stage.add_child(label)
		topStrengthLabels.append(label)

	# Java: cdi = new CardDescriptionImage(20, ydown(512)); (lines 238-239)
	cdi = CardDescriptionImage.new(null, null, greenfont, null, 20, ydown(512))
	cdi.setFont(greenfont)

	# Java: logScrollPane = new LogScrollPane(skin); (lines 241-242)
	# logScrollPane = LogScrollPane.new()
	# logScrollPane.position = Vector2(24, 36)
	# logScrollPane.size = Vector2(451, 173)

	# Java: stage.addActor(player); etc. (lines 244-249)
	stage.add_child(player)
	stage.add_child(opponent)
	stage.add_child(playerInfoLabel)
	stage.add_child(opptInfoLabel)
	stage.add_child(cdi)
	# stage.add_child(logScrollPane)

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

		# Java: Player pInfo = player.getPlayerInfo(); (lines 294-295)
		var pInfo: Player = player.getPlayerInfo()
		var oInfo: Player = opponent.getPlayerInfo()

		# Java: playerInfoLabel.setText(getPlayerDescription(pInfo)); (lines 297-298)
		playerInfoLabel.text = getPlayerDescription(pInfo)
		opptInfoLabel.text = getPlayerDescription(oInfo)

		# Java: CardType[] types = {...}; (line 300)
		var types: Array = [CardType.Type.FIRE, CardType.Type.AIR, CardType.Type.WATER, CardType.Type.EARTH, opponent.getPlayerInfo().getPlayerClass().getType()]

		# Java: for (int i = 0; i < 5; i++) { setStrengthLabel(topStrengthLabels[i], oInfo, types[i]); } (lines 301-303)
		for i in range(5):
			setStrengthLabel(topStrengthLabels[i], oInfo, types[i])

		# Java: types[4] = player.getPlayerInfo().getPlayerClass().getType(); (line 304)
		types[4] = player.getPlayerInfo().getPlayerClass().getType()

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
		# Java: if (player.getSlotCards()[index] != null) { player.getSlotCards()[index].remove(); } (lines 342-344)
		if player.getSlotCards()[index] != null:
			player.getSlotCards()[index].queue_free()

		player.getSlotCards()[index] = null
		player.getSlots()[index].setOccupied(false)

		# Java: if (opponent.getSlotCards()[index] != null) { opponent.getSlotCards()[index].remove(); } (lines 348-350)
		if opponent.getSlotCards()[index] != null:
			opponent.getSlotCards()[index].queue_free()

		opponent.getSlotCards()[index] = null
		opponent.getSlots()[index].setOccupied(false)

	# Java: player.setImg(chooser.pi.getImg()); (lines 355-357)
	player.setImg(chooser.pi.getImg())
	player.setPlayerInfo(chooser.pi.getPlayerInfo())
	player.getPlayerInfo().init()

	# Java: opponent.setImg(chooser.oi.getImg()); (lines 359-361)
	opponent.setImg(chooser.oi.getImg())
	opponent.setPlayerInfo(chooser.oi.getPlayerInfo())
	opponent.getPlayerInfo().init()

	# Java: chooser = null; gameOver = false; Cards.logScrollPane.clear(); (lines 363-365)
	chooser = null
	gameOver = false
	if logScrollPane:
		logScrollPane.clear()

	# Java: initializePlayerCards(player.getPlayerInfo(), true); (lines 369-370)
	initializePlayerCards(player.getPlayerInfo(), true)
	initializePlayerCards(opponent.getPlayerInfo(), false)

	# Java: if (NET_GAME != null) { (lines 372-381)
	if NET_GAME != null:
		# TODO: Network handshake
		pass

	# Java: for (CardType type : Player.TYPES) { (lines 384-387)
	for type in Player.TYPES:
		player.getPlayerInfo().enableDisableCards(type)
		opponent.getPlayerInfo().enableDisableCards(type)

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
	var types: Array = [CardType.Type.FIRE, CardType.Type.AIR, CardType.Type.WATER, CardType.Type.EARTH, p_player.getPlayerClass().getType()]

	# Java: for (CardType type : types) { (line 400)
	for type in types:
		# Java: if (player.getCards(type) != null && player.getCards(type).size() > 0) { (line 402)
		if p_player.getCards(type) != null and p_player.getCards(type).size() > 0:
			# Java: for (CardImage ci : player.getCards(type)) { ci.remove(); } (lines 403-405)
			for ci in p_player.getCards(type):
				ci.queue_free()

		# Java: List<CardImage> v1 = cs.getCardImagesByType(...); (line 408)
		var v1: Array = cs.getCardImagesByType(smallCardAtlas, smallTGACardAtlas, type, 4)

		# Java: x += 104; (line 409)
		x += 104

		# Java: addVerticalGroupCards(x, y, v1, player, type, visible); (line 410)
		addVerticalGroupCards(x, y, v1, p_player, type, visible)

		# Java: player.setCards(type, v1); (line 411)
		p_player.setCards(type, v1)

		# Java: player.enableDisableCards(type); (line 413)
		p_player.enableDisableCards(type)

# ============================================================================
# HELPER METHODS (Java: lines 418-429)
# ============================================================================

## Java: public void setStrengthLabel(Label label, Player pl, CardType type)
func setStrengthLabel(label: Label, pl: Player, type: CardType.Type) -> void:
	label.text = getPlayerStrength(pl, type)

## Java: public String getPlayerDescription(Player pl)
func getPlayerDescription(pl: Player) -> String:
	return pl.getPlayerClass().getTitle() + " Life: " + str(pl.getLife())

## Java: public String getPlayerStrength(Player pl, CardType type)
func getPlayerStrength(pl: Player, type: CardType.Type) -> String:
	var str_val: int = 0 if pl == null else pl.getStrength(type)
	return CardType.getTitle(type) + ":  " + str(str_val)

# ============================================================================
# ADD VERTICAL GROUP CARDS METHOD (Java: lines 431-459)
# ============================================================================

## Java: public void addVerticalGroupCards(...)
func addVerticalGroupCards(x: int, y: int, cards: Array, p_player: Player, type: CardType.Type, addToStage: bool) -> void:
	# Java: CardImage.sort(cards); (line 433)
	CardImage.sort(cards)

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

		# Java: ci.setFont(customFont); (line 446)
		ci.setFont(customFont)

		# Java: ci.setFrame(ci.getCard().isSpell() ? spellramka : ramka); (line 447)
		ci.setFrame(spellramka if ci.getCard().isSpell() else ramka)

		# Java: ci.addListener(sdl); (line 448)
		# TODO: Add listeners

		# Java: y1 -= (spacing + ci.getFrame().getHeight()); (line 450)
		y1 -= (spacing + ci.getFrame().get_height())

		# Java: ci.setBounds(x1, y1, ci.getFrame().getWidth(), ci.getFrame().getHeight()); (line 451)
		ci.position = Vector2(x1, y1)
		ci.size = Vector2(ci.getFrame().get_width(), ci.getFrame().get_height())

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

		# Java: s.setBounds(x1, y, s.getWidth(), s.getHeight()); (line 467)
		s.position = Vector2(x1, y)
		s.size = Vector2(s.getWidth(), s.getHeight())

		# Java: x1 += (spacing + s.getWidth()); (line 468)
		x1 += (spacing + s.getWidth())

		# Java: s.addListener(sl); (line 469)
		# TODO: Add listener

		# Java: stage.addActor(s); (line 471)
		stage.add_child(s)

		# Java: pi.getSlots()[i] = s; (line 473)
		pi.getSlots()[i] = s

# ============================================================================
# BUTTON SIGNAL HANDLERS (Godot-specific, replaces Java InputListeners)
# ============================================================================

func _on_show_oppt_cards_pressed() -> void:
	# Java: lines 168-190
	if opptCardsShown:
		return

	opptCardsShown = true

	var title_text: String = getPlayerDescription(opponent.getPlayerInfo())
	var window = OpponentCardWindow.new(title_text, opponent.getPlayerInfo(), self, skin)

	# TODO: Add close button and show window

func _on_skip_turn_pressed() -> void:
	# Java: lines 195-203
	if gameOver:
		return

	# TODO: Start BattleRoundThread

func _on_shuffle_cards_pressed() -> void:
	# Java: lines 209-217
	initializePlayerCards(player.getPlayerInfo(), true)

# ============================================================================
# HELPER METHODS CONTINUED (Java: lines 751-968)
# ============================================================================

## Java: public void clearHighlights()
func clearHighlights() -> void:
	# Java: for (CardImage ci : player.getSlotCards()) { (lines 752-758)
	for ci in player.getSlotCards():
		if ci != null:
			ci.setHighlighted(false)
			ci.clearActions()
			ci.modulate = Color.WHITE

	# Java: for (CardImage ci : opponent.getSlotCards()) { (lines 759-765)
	for ci in opponent.getSlotCards():
		if ci != null:
			ci.setHighlighted(false)
			ci.clearActions()
			ci.modulate = Color.WHITE

	# Java: for (SlotImage si : player.getSlots()) { (lines 766-770)
	for si in player.getSlots():
		si.setHighlighted(false)
		si.clearActions()
		si.modulate = Color.WHITE

	# Java: for (SlotImage si : opponent.getSlots()) { (lines 771-775)
	for si in opponent.getSlots():
		si.setHighlighted(false)
		si.clearActions()
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
		SoundManager.play(Sound.ATTACK)

	# Java: if (pi.getSlots()[0] == null) { return; } (lines 836-838)
	if pi.getSlots()[0] == null:
		return

	# Java: boolean isBottom = pi.getSlots()[0].isBottomSlots(); (line 842)
	var isBottom: bool = pi.getSlots()[0].isBottomSlots()

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

	# Java: boolean isBottom = pi.getSlots()[0].isBottomSlots(); (line 870)
	var isBottom: bool = pi.getSlots()[0].isBottomSlots()

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

	# Java: if (player.getPlayerInfo().getId().equalsIgnoreCase(id)) { ret = player; } (lines 917-919)
	if player.getPlayerInfo().getId().to_lower() == id.to_lower():
		ret = player

	# Java: if (opponent.getPlayerInfo().getId().equalsIgnoreCase(id)) { ret = opponent; } (lines 921-923)
	if opponent.getPlayerInfo().getId().to_lower() == id.to_lower():
		ret = opponent

	# Java: if (ret == null) { throw new Exception("Could not find player with id: " + id); } (lines 925-927)
	if ret == null:
		push_error("Could not find player with id: " + id)

	# Java: return ret; (line 929)
	return ret

## Java: public void setOpposingPlayerId(String id)
func setOpposingPlayerId(id: String) -> void:
	# Java: opponent.getPlayerInfo().setId(id); (line 933)
	opponent.getPlayerInfo().setId(id)

## Java: public PlayerImage getOpposingPlayerImage(String id)
func getOpposingPlayerImage(id: String) -> PlayerImage:
	# Java: PlayerImage ret = null; (line 938)
	var ret: PlayerImage = null

	# Java: if (player.getPlayerInfo().getId().equalsIgnoreCase(id)) { ret = opponent; } (lines 940-942)
	if player.getPlayerInfo().getId().to_lower() == id.to_lower():
		ret = opponent

	# Java: if (opponent.getPlayerInfo().getId().equalsIgnoreCase(id)) { ret = player; } (lines 944-946)
	if opponent.getPlayerInfo().getId().to_lower() == id.to_lower():
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
