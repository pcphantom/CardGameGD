class_name SimpleGame
extends Node2D

## ============================================================================
## SimpleGame.gd - EXACT translation of SimpleGame.java
## ============================================================================
## Abstract base class for the game application.
## Manages camera, stage, cursor, and skin initialization.
## Subclasses must implement init() and draw() methods.
##
## Original: src/main/java/org/antinori/cards/SimpleGame.java
## Translation: scripts/simple_game.gd
##
## ONLY CHANGES FROM JAVA:
## - package → class_name
## - extends InputAdapter implements ApplicationListener → extends Node2D
## - OrthographicCamera → Camera2D
## - Stage → Control node
## - Skin → Theme
## - LWJGL cursor management → Godot Input.set_custom_mouse_cursor()
## - Import paths updated to match CardGameGD structure
## ============================================================================

# ============================================================================
# IMPORTS (Java: import statements)
# ============================================================================

## Java: import org.lwjgl.input.Mouse;
## Java: import com.badlogic.gdx.graphics.OrthographicCamera;
## Java: import com.badlogic.gdx.scenes.scene2d.Stage;
## Java: import com.badlogic.gdx.scenes.scene2d.ui.Skin;
## GDScript: Camera2D, Control, Theme are built-in

# ============================================================================
# FIELDS (Java: public/static fields)
# ============================================================================

## Java: public OrthographicCamera camera;
var camera: Camera2D = null

## Java: public Stage stage;
var stage: Control = null

## Java: public Skin skin;
var skin = null  # Godot uses Theme, but keeping name for compatibility

## Java: static org.lwjgl.input.Cursor emptyCursor;
static var emptyCursor = null  # Not used in Godot

## Java: Texture cursor;
var cursor: Texture2D = null

## Java: int xHotspot, yHotspot;
var xHotspot: int = 0
var yHotspot: int = 0

# ============================================================================
# CONSTRUCTOR (Java: public SimpleGame())
# ============================================================================

## Java: public SimpleGame()
## Constructor - empty in Java, empty in GDScript
func _init() -> void:
	# Java: empty constructor (lines 32-33)
	pass

# ============================================================================
# ABSTRACT METHODS (Java: public abstract void init/draw)
# ============================================================================

## Java: public abstract void init();
## Initialize game-specific content. Must be overridden by subclasses.
func init() -> void:
	# Abstract method - subclasses must override
	push_error("SimpleGame.init() must be overridden by subclass")

## Java: public abstract void draw(float delta);
## Render game content. Must be overridden by subclasses.
## @param _delta Time elapsed since last frame in seconds
func draw(_delta: float) -> void:
	# Abstract method - subclasses must override
	push_error("SimpleGame.draw() must be overridden by subclass")

# ============================================================================
# GODOT LIFECYCLE METHODS (Bridge to LibGDX lifecycle)
# ============================================================================

## Godot: func _ready()
## Called when node enters scene tree - bridges to LibGDX create()
func _ready() -> void:
	create()

## Godot: func _process(delta: float)
## Called every frame - bridges to LibGDX render()
func _process(_delta: float) -> void:
	render()

# ============================================================================
# CREATE METHOD (Java: public void create())
# ============================================================================

## Java: public void create()
## Initialize the game application (camera, stage, cursor, skin)
func create() -> void:
	# Java: camera = new OrthographicCamera(); (line 41)
	# Java: camera.setToOrtho(false); (line 42)
	camera = Camera2D.new()
	add_child(camera)

	# Java: stage = new Stage(new ScreenViewport(camera)); (line 44)
	# In Godot, Control nodes in a CanvasLayer render in screen-space, independent of Camera2D
	# This matches libGDX Stage behavior which renders UI in screen space
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

	stage = Control.new()
	stage.position = Vector2.ZERO
	stage.size = Vector2(1024, 768)
	stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(stage)

	# Java: cursor = new Texture(Gdx.files.classpath("images/cursor.png")); (line 46)
	# Java: xHotspot = 0; (line 47)
	# Java: yHotspot = cursor.getHeight(); (line 48)
	if ResourceLoader.exists("res://assets/images/cursor.png"):
		cursor = load("res://assets/images/cursor.png")
		xHotspot = 0
		yHotspot = cursor.get_height() if cursor else 0

	# Java: skin = new Skin(Gdx.files.classpath("skin/uiskin.json")); (line 50)
	# Godot uses Theme instead of Skin
	if ResourceLoader.exists("res://assets/skin/uiskin.theme"):
		skin = load("res://assets/skin/uiskin.theme")

	# Java: init(); (line 52)
	init()

# ============================================================================
# RENDER METHOD (Java: public void render())
# ============================================================================

## Java: public void render()
## Main render loop - hides hardware cursor and calls draw()
func render() -> void:
	# Java: try { setHWCursorVisible(false); } catch (LWJGLException e) { throw new GdxRuntimeException(e); } (lines 58-62)
	setHWCursorVisible(false)

	# Java: draw(Gdx.graphics.getDeltaTime()); (line 64)
	draw(get_process_delta_time())

# ============================================================================
# INPUT METHODS (Java: InputAdapter methods)
# ============================================================================

## Java: public boolean keyDown(int keycode)
## Called when a key is pressed
## @param _keycode The key code
## @return true if the event was handled
func keyDown(_keycode: int) -> bool:
	return false

## Java: public boolean keyUp(int keycode)
## Called when a key is released
## @param _keycode The key code
## @return true if the event was handled
func keyUp(_keycode: int) -> bool:
	return false

## Java: public boolean keyTyped(char character)
## Called when a character is typed
## @param _character The character typed
## @return true if the event was handled
func keyTyped(_character: String) -> bool:
	return false

## Java: public boolean touchDown(int x, int y, int pointer, int button)
## Called when screen is touched or mouse button is pressed
## @return true if the event was handled
func touchDown(_x: int, _y: int, _pointer: int, _button: int) -> bool:
	return false

## Java: public boolean touchUp(int x, int y, int pointer, int button)
## Called when screen touch ends or mouse button is released
## @return true if the event was handled
func touchUp(_x: int, _y: int, _pointer: int, _button: int) -> bool:
	return false

## Java: public boolean touchDragged(int x, int y, int pointer)
## Called when screen is dragged
## @return true if the event was handled
func touchDragged(_x: int, _y: int, _pointer: int) -> bool:
	return false

## Java: public boolean mouseMoved(int screenX, int screenY)
## Called when mouse is moved without buttons pressed
## @return true if the event was handled
func mouseMoved(_screenX: int, _screenY: int) -> bool:
	return false

## Java: public boolean scrolled(int amount)
## Called when mouse wheel is scrolled
## @param _amount Scroll amount (positive = up, negative = down)
## @return true if the event was handled
func scrolled(_amount: int) -> bool:
	return false

# ============================================================================
# APPLICATION LIFECYCLE METHODS (Java: ApplicationListener methods)
# ============================================================================

## Java: public void pause()
## Called when application is paused
func pause() -> void:
	# Empty in Java (lines 100-101)
	pass

## Java: public void resume()
## Called when application is resumed
func resume() -> void:
	# Empty in Java (lines 103-104)
	pass

## Java: public void dispose()
## Called when application is disposed
func dispose() -> void:
	# Empty in Java (lines 106-107)
	pass

## Java: public void resize(int width, int height)
## Called when window is resized
## @param _width New window width
## @param _height New window height
func resize(_width: int, _height: int) -> void:
	# Empty in Java (lines 109-111)
	pass

# ============================================================================
# CURSOR VISIBILITY METHOD (Java: public void setHWCursorVisible(boolean visible))
# ============================================================================

## Java: public void setHWCursorVisible(boolean visible) throws LWJGLException
## Sets hardware cursor visibility (LWJGL-specific)
## In Godot, uses Input.set_custom_mouse_cursor()
## @param cursor_visible true to show cursor, false to hide
func setHWCursorVisible(cursor_visible: bool) -> void:
	# Java: if (Gdx.app.getType() != ApplicationType.Desktop && Gdx.app instanceof LwjglApplication) return; (lines 114-115)
	# In Godot, always runs

	# Java: if (emptyCursor == null) { ... create empty cursor ... } (lines 116-124)
	# Godot doesn't need empty cursor creation

	# Java: if (Mouse.isInsideWindow()) Mouse.setNativeCursor(visible ? null : emptyCursor); (lines 125-126)
	if cursor_visible:
		Input.set_custom_mouse_cursor(null)
	else:
		# Hide cursor by setting it to a transparent 1x1 image
		if cursor:
			Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(xHotspot, yHotspot))
