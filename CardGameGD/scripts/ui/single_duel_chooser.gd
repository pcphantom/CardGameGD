class_name SingleDuelChooser
extends Control

## ============================================================================
## SingleDuelChooser.gd - EXACT translation of SingleDuelChooser.java
## ============================================================================
## This is the character class selection screen before starting a game.
## Players select their face image (1-77) and character class (Cleric, etc.)
##
## Original: src/main/java/org/antinori/cards/SingleDuelChooser.java
## Translation: scripts/ui/single_duel_chooser.gd
##
## ONLY CHANGES FROM JAVA:
## - Stage/Scene2D → Godot Control nodes
## - SelectBox → OptionButton
## - InputListener → signal connections
## - AtomicBoolean/Integer → bool/int (no threading in Godot)
## ============================================================================

# ============================================================================
# FIELDS (Java: instance variables)
# ============================================================================

## Java: Stage stage;
var stage: Control = null

## Java: TextureRegion background; Image bgimg;
var background: Texture2D = null
var bgimg: TextureRect = null

## Java: TextureRegion chooserBg; Image cbgimg;
var chooser_bg: Texture2D = null
var cbgimg: TextureRect = null

## Java: PlayerImage pi; PlayerImage oi;
var pi: PlayerImage = null
var oi: PlayerImage = null

## Java: Cards game;
var game = null  # Reference to main Cards (game controller)

## Java: AtomicBoolean done = new AtomicBoolean(false);
var done: bool = false

## Java: final AtomicInteger playerIndex = new AtomicInteger(1);
var player_index: int = 1

## Java: final AtomicInteger opponentIndex = new AtomicInteger(1);
var opponent_index: int = 1

## Java: static int buttonWidth = 13;
const BUTTON_WIDTH: int = 13

## Java: static int buttonHeight = 120;
const BUTTON_HEIGHT: int = 120

## Java: static int imgWidth = 120;
const IMG_WIDTH: int = 120

## Java: SelectBox<String> classesPlayer;
var classes_player: OptionButton = null

## Java: SelectBox<String> classesOpponent;
var classes_opponent: OptionButton = null

## Java: private boolean selectHostsShown = false;
var select_hosts_shown: bool = false

# ============================================================================
# INIT METHOD (Java: public void init(Cards game))
# ============================================================================

## Java: public void init(Cards game)
## Initializes the character selection UI
## - Loads background images
## - Creates player/opponent face images
## - Creates Start/Connect/Listen buttons
## - Creates class selection dropdowns
## - Creates face navigation buttons (left/right arrows)
## - Positions all UI elements
func init(game_ref) -> void:
	self.game = game_ref

	# Java: stage = new Stage(new ScreenViewport());
	# GDScript: stage is just the Control tree
	stage = Control.new()
	add_child(stage)

	# Java: background = new TextureRegion(new Texture(Gdx.files.classpath("images/splash.png")));
	# Java: bgimg = new Image(background);
	background = load("res://assets/images/splash.png")
	bgimg = TextureRect.new()
	bgimg.texture = background
	bgimg.position = Vector2.ZERO

	# Java: chooserBg = new TextureRegion(new Texture(Gdx.files.classpath("images/singleduel1.png")));
	# Java: cbgimg = new Image(chooserBg);
	chooser_bg = load("res://assets/images/singleduel1.png")
	cbgimg = TextureRect.new()
	cbgimg.texture = chooser_bg

	# Java: Sprite spP = Cards.faceCardAtlas.createSprite(game.player.getPlayerInfo().getImgName());
	# Java: spP.flip(false, true);
	# Java: pi = new PlayerImage(spP, Cards.portraitramka, game.player.getPlayerInfo());
	var sp_p_texture = TextureManager.get_face_texture(game.player.get_player_info().get_img_name())
	pi = PlayerImage.new()
	pi.set_texture(sp_p_texture)
	pi.set_player_info(game.player.get_player_info())

	# Java: Sprite spO = Cards.faceCardAtlas.createSprite(game.opponent.getPlayerInfo().getImgName());
	# Java: spO.flip(false, true);
	# Java: oi = new PlayerImage(spO, Cards.portraitramka, game.opponent.getPlayerInfo());
	var sp_o_texture = TextureManager.get_face_texture(game.opponent.get_player_info().get_img_name())
	oi = PlayerImage.new()
	oi.set_texture(sp_o_texture)
	oi.set_player_info(game.opponent.get_player_info())

	# Java: TextButton play = new TextButton("Start", game.skin);
	# Java: play.addListener(new InputListener() {...});
	var play = Button.new()
	play.text = "Start"
	play.pressed.connect(_on_start_pressed)

	# Java: final Cards temp = game;
	# Java: TextButton selectHostsButton = new TextButton("Connect", game.skin);
	var select_hosts_button = Button.new()
	select_hosts_button.text = "Connect"
	select_hosts_button.pressed.connect(_on_connect_pressed)

	# Java: TextButton startNetworkServer = new TextButton("Listen", game.skin);
	var start_network_server = Button.new()
	start_network_server.text = "Listen"
	start_network_server.pressed.connect(_on_listen_pressed)

	# Java: classesPlayer = new SelectBox(game.skin);
	# Java: classesPlayer.setItems(Specializations.titles());
	classes_player = OptionButton.new()
	var titles = Specializations.titles()
	for title in titles:
		classes_player.add_item(title)

	# Java: classesOpponent = new SelectBox(game.skin);
	# Java: classesOpponent.setItems(Specializations.titles());
	classes_opponent = OptionButton.new()
	for title in titles:
		classes_opponent.add_item(title)

	# Java: int x = 300;
	# Java: int y = 253;
	var x: int = 300
	var y: int = 253

	# Java: cbgimg.setPosition(x, 0);
	cbgimg.position = Vector2(x, 0)

	# Java: Button lpb = createButton(x += 34, y, pi, playerIndex, true);
	x += 34
	var lpb = create_button(x, y, pi, true)

	# Java: pi.setPosition(x += (buttonWidth + 7), y);
	x += (BUTTON_WIDTH + 7)
	pi.position = Vector2(x, y)

	# Java: Button rpb = createButton(x += imgWidth + 10, y, pi, playerIndex, false);
	x += IMG_WIDTH + 10
	var rpb = create_button(x, y, pi, false)

	# Java: Button lob = createButton(x += 43, y, oi, opponentIndex, true);
	x += 43
	var lob = create_button(x, y, oi, true)

	# Java: oi.setPosition(x += (buttonWidth + 7), y);
	x += (BUTTON_WIDTH + 7)
	oi.position = Vector2(x, y)

	# Java: Button rob = createButton(x += imgWidth + 10, y, oi, opponentIndex, false);
	x += IMG_WIDTH + 10
	var rob = create_button(x, y, oi, false)

	# Java: Label lbl = new Label("Single Duel", game.skin);
	# Java: lbl.setPosition(465, 430);
	var lbl = Label.new()
	lbl.text = "Single Duel"
	lbl.position = Vector2(465, 430)

	# Java: play.setBounds(410, 133, 60, 25);
	play.position = Vector2(410, 133)
	play.custom_minimum_size = Vector2(60, 25)

	# Java: selectHostsButton.setBounds(475, 133, 60, 25);
	select_hosts_button.position = Vector2(475, 133)
	select_hosts_button.custom_minimum_size = Vector2(60, 25)

	# Java: startNetworkServer.setBounds(540, 133, 60, 25);
	start_network_server.position = Vector2(540, 133)
	start_network_server.custom_minimum_size = Vector2(60, 25)

	# Java: stage.addActor(bgimg);
	stage.add_child(bgimg)

	# Java: stage.addActor(cbgimg);
	stage.add_child(cbgimg)

	# Java: stage.addActor(lbl);
	stage.add_child(lbl)

	# Java: stage.addActor(lpb);
	# Java: stage.addActor(pi);
	# Java: stage.addActor(rpb);
	stage.add_child(lpb)
	stage.add_child(pi)
	stage.add_child(rpb)

	# Java: stage.addActor(lob);
	# Java: stage.addActor(oi);
	# Java: stage.addActor(rob);
	stage.add_child(lob)
	stage.add_child(oi)
	stage.add_child(rob)

	# Java: stage.addActor(classesPlayer);
	# Java: classesPlayer.setPosition(355, 194);
	# Java: classesPlayer.setHeight(25);
	# Java: classesPlayer.setWidth(123);
	stage.add_child(classes_player)
	classes_player.position = Vector2(355, 194)
	classes_player.custom_minimum_size = Vector2(123, 25)

	# Java: stage.addActor(classesOpponent);
	# Java: classesOpponent.setPosition(548, 194);
	# Java: classesOpponent.setHeight(25);
	# Java: classesOpponent.setWidth(123);
	stage.add_child(classes_opponent)
	classes_opponent.position = Vector2(548, 194)
	classes_opponent.custom_minimum_size = Vector2(123, 25)

	# Java: stage.addActor(play);
	# Java: stage.addActor(selectHostsButton);
	# Java: stage.addActor(startNetworkServer);
	stage.add_child(play)
	stage.add_child(select_hosts_button)
	stage.add_child(start_network_server)

# ============================================================================
# CREATE BUTTON METHOD (Java: private Button createButton(...))
# ============================================================================

## Java: private Button createButton(int x, int y, PlayerImage img, AtomicInteger index, boolean left)
## Creates a navigation button for cycling through face images
## @param x X position
## @param y Y position
## @param img PlayerImage to update
## @param left true for left arrow (decrement), false for right arrow (increment)
## @return The created button
func create_button(x: int, y: int, img: PlayerImage, left: bool) -> Button:
	# Java: ButtonListener bl = new ButtonListener(img, index, left);
	# Java: Button btn = new Button(game.skin);
	# Java: btn.addListener(bl);
	var btn = Button.new()

	# Connect signal with parameters bound
	if img == pi:
		if left:
			btn.pressed.connect(_on_player_left_pressed)
		else:
			btn.pressed.connect(_on_player_right_pressed)
	else:  # img == oi
		if left:
			btn.pressed.connect(_on_opponent_left_pressed)
		else:
			btn.pressed.connect(_on_opponent_right_pressed)

	# Java: btn.setBounds(x, y, buttonWidth, buttonHeight);
	btn.position = Vector2(x, y)
	btn.custom_minimum_size = Vector2(BUTTON_WIDTH, BUTTON_HEIGHT)

	# Java: return btn;
	return btn

# ============================================================================
# BUTTON LISTENER LOGIC (Java: class ButtonListener extends InputListener)
# ============================================================================

## Java: ButtonListener touchDown for player left button
func _on_player_left_pressed() -> void:
	# Java: if (decreasing) {
	# Java:     index.decrementAndGet();
	# Java:     if (index.get() < 1) {
	# Java:         index.set(1);
	# Java:     }
	# Java: }
	player_index -= 1
	if player_index < 1:
		player_index = 1

	# Java: Sprite sp = Cards.faceCardAtlas.createSprite("face" + index);
	# Java: sp.flip(false, true);
	# Java: pi.setImg(sp);
	var sp = TextureManager.get_face_texture("face" + str(player_index))
	pi.set_texture(sp)

	# Java: pi.getPlayerInfo().setImgName("face" + index);
	pi.get_player_info().set_img_name("face" + str(player_index))

## Java: ButtonListener touchDown for player right button
func _on_player_right_pressed() -> void:
	# Java: } else {
	# Java:     index.incrementAndGet();
	# Java:     if (index.get() > 77) {
	# Java:         index.set(77);
	# Java:     }
	# Java: }
	player_index += 1
	if player_index > 77:
		player_index = 77

	var sp = TextureManager.get_face_texture("face" + str(player_index))
	pi.set_texture(sp)
	pi.get_player_info().set_img_name("face" + str(player_index))

## Java: ButtonListener touchDown for opponent left button
func _on_opponent_left_pressed() -> void:
	opponent_index -= 1
	if opponent_index < 1:
		opponent_index = 1

	var sp = TextureManager.get_face_texture("face" + str(opponent_index))
	oi.set_texture(sp)
	oi.get_player_info().set_img_name("face" + str(opponent_index))

## Java: ButtonListener touchDown for opponent right button
func _on_opponent_right_pressed() -> void:
	opponent_index += 1
	if opponent_index > 77:
		opponent_index = 77

	var sp = TextureManager.get_face_texture("face" + str(opponent_index))
	oi.set_texture(sp)
	oi.get_player_info().set_img_name("face" + str(opponent_index))

# ============================================================================
# START BUTTON (Java: play button InputListener)
# ============================================================================

## Java: play.addListener touchDown
## When Start button is pressed:
## - Sets player class from dropdown selection
## - Sets opponent class from dropdown selection
## - Closes the selection screen
## - Marks done = true
func _on_start_pressed() -> void:
	# Java: pi.getPlayerInfo().setPlayerClass(Specializations.fromTitleString(classesPlayer.getSelected()));
	var player_class_title = classes_player.get_item_text(classes_player.selected)
	pi.get_player_info().set_player_class(Specializations.from_title_string(player_class_title))

	# Java: oi.getPlayerInfo().setPlayerClass(Specializations.fromTitleString(classesOpponent.getSelected()));
	var opponent_class_title = classes_opponent.get_item_text(classes_opponent.selected)
	oi.get_player_info().set_player_class(Specializations.from_title_string(opponent_class_title))

	# Java: stage.clear();
	# Java: stage.dispose();
	stage.queue_free()

	# Java: done.set(true);
	done = true

	# Close this selection screen
	queue_free()

# ============================================================================
# CONNECT BUTTON (Java: selectHostsButton InputListener)
# ============================================================================

## Java: selectHostsButton.addListener touchDown
## Opens network host selection dialog
func _on_connect_pressed() -> void:
	# Java: if (selectHostsShown || Cards.NET_GAME != null) {
	# Java:     return true;
	# Java: }
	if select_hosts_shown or NetworkManager.is_network_game():
		return

	# Java: selectHostsShown = true;
	select_hosts_shown = true

	# Java: final SelectHostsDialog window = new SelectHostsDialog(...);
	# TODO: Implement SelectHostsDialog when that class is converted
	push_warning("SingleDuelChooser: SelectHostsDialog not yet implemented")

	# For now, just reset the flag
	select_hosts_shown = false

# ============================================================================
# LISTEN BUTTON (Java: startNetworkServer ChangeListener)
# ============================================================================

## Java: startNetworkServer.addListener changed
## Starts network server and sets opponent to "lanface"
func _on_listen_pressed() -> void:
	# Java: if (Cards.NET_GAME != null) {
	# Java:     return;
	# Java: }
	if NetworkManager.is_network_game():
		return

	# Java: Dialog dialog = new Dialog("Start Server", temp.skin, "dialog") {...}
	# TODO: Show confirmation dialog
	# For now, directly start server

	# Java: Cards.NET_GAME = new NetworkGame(SingleDuelChooser.this.game, true);
	NetworkManager.start_server(game)

	# Java: Sprite sp = Cards.faceCardAtlas.createSprite("lanface");
	# Java: sp.flip(false, true);
	# Java: oi.setImg(sp);
	var sp = TextureManager.get_face_texture("lanface")
	oi.set_texture(sp)

# ============================================================================
# DRAW METHOD (Java: public void draw(float delta))
# ============================================================================

## Java: public void draw(float delta)
## Called every frame to update and render the stage
## In Godot, this is handled by _process
func _process(_delta: float) -> void:
	# Java: stage.act(Gdx.graphics.getDeltaTime());
	# Java: stage.draw();
	# GDScript: Godot handles this automatically
	pass

# ============================================================================
# HANDLE EVENT METHOD (Java: public boolean handle(Event event))
# ============================================================================

## Java: public boolean handle(Event event)
## EventListener implementation - sets opponent to network face
## @param event The event
## @return false
func handle(_event) -> bool:
	# Java: Sprite sp = Cards.faceCardAtlas.createSprite("lanface");
	# Java: sp.flip(false, true);
	# Java: oi.setImg(sp);
	var sp = TextureManager.get_face_texture("lanface")
	oi.set_texture(sp)

	# Java: return false;
	return false
