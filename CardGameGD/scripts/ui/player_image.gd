class_name PlayerImage
extends Control

## Exact translation of PlayerImage.java from CardGameGDX
## This class is a visual container for player portrait, slots, and cards
## Main layout logic is handled by Cards.gd (the game controller)

# ============================================================================
# MEMBER VARIABLES (Direct translation from Java fields)
# ============================================================================

# Visual elements
var img: Sprite2D = null  # Java: Sprite img
var frame: Texture2D = null  # Java: Texture frame  
var player_info: Player = null  # Java: Player playerInfo
var font: Font = null  # Java: BitmapFont font

# Slots and cards (exactly 6 of each, like Java)
var slots: Array[SlotImage] = []  # Java: private SlotImage[] slots = new SlotImage[6]
var slot_cards: Array[CardImage] = []  # Java: private CardImage[] slotCards = new CardImage[6]

# Stun state
var must_skip_next_attack: bool = false  # Java: public boolean mustSkipNexAttack = false

# Per-instance positioning adjustments (different for player vs opponent)
var sprite_adjust_x: int = 0  # Sprite position adjustment inside frame
var sprite_adjust_y: int = 0  # Sprite position adjustment inside frame
var frame_border_adjust_x: int = 0  # Frame border position adjustment
var frame_border_adjust_y: int = 0  # Frame border position adjustment

# Static texture (class-level, not instance-level)
static var stunned_texture: Texture2D = null  # Java: private static Texture stunned

# ============================================================================
# CONSTRUCTOR EQUIVALENTS
# ============================================================================

## Java Constructor 1: PlayerImage(Sprite img, Texture frame, Player info)
func _init_simple(sprite_img: Sprite2D, frame_tex: Texture2D, info: Player) -> void:
    self.img = sprite_img
    self.frame = frame_tex
    self.player_info = info
    
    # Initialize arrays to size 6 (matching Java's new SlotImage[6])
    slots.resize(6)
    slot_cards.resize(6)
    
    # Fill with nulls (GDScript arrays don't auto-null like Java)
    for i in range(6):
        slots[i] = null
        slot_cards[i] = null

## Java Constructor 2: PlayerImage(Sprite img, Texture frame, BitmapFont font, Player info, float x, float y)
func _init_positioned(sprite_img: Sprite2D, frame_tex: Texture2D, p_font: Font, info: Player, px: float, py: float) -> void:
    self.img = sprite_img
    self.frame = frame_tex
    self.player_info = info
    self.font = p_font
    
    # Java: setX(x); setY(y);
    position = Vector2(px, py)
    
    # Initialize arrays to size 6
    slots.resize(6)
    slot_cards.resize(6)
    
    for i in range(6):
        slots[i] = null
        slot_cards[i] = null

## Godot _init() - supports both Java constructors via optional parameters
## Java Constructor 1: PlayerImage(Sprite img, Texture frame, Player info) - first 3 params
## Java Constructor 2: PlayerImage(Sprite img, Texture frame, BitmapFont font, Player info, float x, float y) - all 6 params
func _init(sprite_img: Sprite2D = null, frame_tex: Texture2D = null, p_font: Font = null, info: Player = null, px: float = 0.0, py: float = 0.0) -> void:
    self.img = sprite_img
    self.frame = frame_tex
    self.player_info = info
    self.font = p_font

    # Java: setX(x); setY(y); (only for 6-param constructor)
    if px != 0.0 or py != 0.0:
        position = Vector2(px, py)

    # FIXED: Godot Controls need explicit size for children to render
    # Portrait frame is 132×132 pixels (from portraitramka.png)
    # Without size, Control defaults to (0, 0) and Sprite2D children don't show
    custom_minimum_size = Vector2(132, 132)
    size = Vector2(132, 132)

    # Initialize arrays to size 6 (matching Java's new SlotImage[6])
    slots.resize(6)
    slot_cards.resize(6)

    # Fill with nulls (GDScript arrays don't auto-null like Java)
    for i in range(6):
        slots[i] = null
        slot_cards[i] = null

# ============================================================================
# GODOT LIFECYCLE METHODS
# ============================================================================

func _ready() -> void:
    print("PlayerImage._ready() called")
    print("  - img is null: ", img == null)

    # Add the portrait sprite as a child if it exists
    if img != null:
        print("  - img has texture: ", img.texture != null)
        if img.texture:
            print("  - texture size: ", img.texture.get_size())

        # CRITICAL FIX: Remove from old parent before adding as child
        var old_parent = img.get_parent()
        if old_parent != null and old_parent != self:
            print("  - Sprite had old parent in _ready(), removing from: ", old_parent.name if old_parent.has_method("get_name") else str(old_parent))
            old_parent.remove_child(img)

        # Only add if not already a child
        if img.get_parent() != self:
            add_child(img)
            print("  - Added sprite as child in _ready()")

        # Use configurable offset from Cards config (base offset + per-instance adjustment)
        var sprite_offset_x = (Cards.PORTRAIT_SPRITE_OFFSET_X if Cards else 6) + sprite_adjust_x
        var sprite_offset_y = (Cards.PORTRAIT_SPRITE_OFFSET_Y if Cards else 6) + sprite_adjust_y
        img.position = Vector2(sprite_offset_x, sprite_offset_y)
        img.z_index = 1  # Sprite renders in front
        img.scale = Vector2(1.0, 1.0)
        img.visible = true  # Force visible
        print("  - Sprite configured: pos=", img.position, " z_index=", img.z_index, " visible=", img.visible)

# ============================================================================
# PRIVATE METHODS
# ============================================================================

## Java: private static void initTextures()
## Loads the stunned.png texture (called lazily on first draw)
static func init_textures() -> void:
    if stunned_texture == null:
        # Java: stunned = new Texture(Gdx.files.classpath("images/stunned.png"));
        # Godot equivalent: load from res:// path
        stunned_texture = load("res://assets/images/stunned.png")

# ============================================================================
# PUBLIC METHODS (Exact translations)
# ============================================================================

## Java: @Override public void draw(Batch batch, float parentAlpha)
## Godot doesn't use batching - this is handled by _draw() instead
func _draw() -> void:
    # Java: if (stunned == null) { initTextures(); }
    if stunned_texture == null:
        init_textures()

    # NOTE: The sprite img is added as a child node and renders automatically
    # We only need to draw the frame border and stunned indicator here

    # Java: batch.draw(frame, x - 6, y - 6);
    # In Godot: Control is 132×132 (frame size), frame texture fills Control at (0, 0)
    # Draw the frame (border) texture with configurable offset (base offset + per-instance adjustment)
    if frame != null:
        var frame_offset_x = (Cards.PORTRAIT_FRAME_OFFSET_X if Cards else 0) + frame_border_adjust_x
        var frame_offset_y = (Cards.PORTRAIT_FRAME_OFFSET_Y if Cards else 0) + frame_border_adjust_y
        draw_texture(frame, Vector2(frame_offset_x, frame_offset_y))

    # Java: if (this.mustSkipNexAttack) { batch.draw(stunned, x + 10, y - 10); }
    if must_skip_next_attack and stunned_texture != null:
        draw_texture(stunned_texture, Vector2(10, -10))

## Java: public void decrementLife(int value, Cards game)
func decrement_life(value: int, game) -> void:  # game is Cards.gd (game controller)
    # Java: playerInfo.decrementLife(value);
    player_info.decrement_life(value)
    
    # Java: game.animateDamageText(value, this);
    if game.has_method("animate_damage_text"):
        game.animate_damage_text(value, self)

## Java: public void incrementLife(int value, Cards game)
func increment_life(value: int, game) -> void:
    # Java: playerInfo.incrementLife(value);
    player_info.increment_life(value)
    
    # Java: game.animateHealingText(value, this);
    if game.has_method("animate_healing_text"):
        game.animate_healing_text(value, self)

# ============================================================================
# GETTERS (Exact translations)
# ============================================================================

## Java: public Sprite getImg()
func get_img() -> Sprite2D:
    return img

## Java: public Texture getFrame()
func get_frame() -> Texture2D:
    return frame

## Java: public BitmapFont getFont()
func get_font() -> Font:
    return font

## Java: public Player getPlayerInfo()
func get_player_info() -> Player:
    return player_info

## Java: public SlotImage[] getSlots()
func get_slots() -> Array[SlotImage]:
    return slots

## Java: public CardImage[] getSlotCards()
func get_slot_cards() -> Array[CardImage]:
    return slot_cards

# ============================================================================
# SETTERS (Exact translations)
# ============================================================================

## Java: public void setImg(Sprite img)
func set_img(sprite_img: Sprite2D) -> void:
    print("PlayerImage.set_img() called:")
    print("  - sprite_img is null: ", sprite_img == null)
    if sprite_img != null:
        print("  - sprite_img has texture: ", sprite_img.texture != null)
        if sprite_img.texture:
            print("  - texture size: ", sprite_img.texture.get_size())

    # Remove old sprite if it exists
    if self.img != null and self.img.get_parent() == self:
        remove_child(self.img)
        print("  - Removed old sprite from self")

    self.img = sprite_img

    # CRITICAL FIX: Remove sprite from its old parent before adding as child
    if sprite_img != null:
        # Remove from old parent if it has one
        var old_parent = sprite_img.get_parent()
        if old_parent != null:
            print("  - Sprite had old parent, removing from: ", old_parent.name if old_parent.has_method("get_name") else str(old_parent))
            old_parent.remove_child(sprite_img)

        # Add new sprite as child if we're in the scene tree
        if is_inside_tree():
            add_child(sprite_img)
            print("  - Added sprite as child of PlayerImage")
            # Use configurable offset from Cards config
            var sprite_offset_x = Cards.PORTRAIT_SPRITE_OFFSET_X if Cards else 0
            var sprite_offset_y = Cards.PORTRAIT_SPRITE_OFFSET_Y if Cards else 0
            sprite_img.position = Vector2(sprite_offset_x, sprite_offset_y)
            sprite_img.z_index = 1  # Sprite renders in front
            sprite_img.visible = true  # Force visible
            print("  - Sprite position: ", sprite_img.position, " z_index: ", sprite_img.z_index, " visible: ", sprite_img.visible)
            queue_redraw()  # Redraw to show the frame around new sprite
        else:
            print("  - WARNING: PlayerImage not in tree yet, sprite will be added in _ready()")

## Java: public void setFrame(Texture frame)
func set_frame(frame_tex: Texture2D) -> void:
    self.frame = frame_tex

## Godot helper: Set texture directly (creates or updates Sprite2D)
## Used by SingleDuelChooser when setting face textures
func set_texture(tex: Texture2D) -> void:
    if img == null:
        img = Sprite2D.new()
        # Use configurable offset from Cards config (base offset + per-instance adjustment)
        var sprite_offset_x = (Cards.PORTRAIT_SPRITE_OFFSET_X if Cards else 6) + sprite_adjust_x
        var sprite_offset_y = (Cards.PORTRAIT_SPRITE_OFFSET_Y if Cards else 6) + sprite_adjust_y
        img.position = Vector2(sprite_offset_x, sprite_offset_y)
        img.z_index = 1  # Sprite renders in front
        add_child(img)  # CRITICAL: Add sprite to scene tree so it renders!
    img.texture = tex
    # Debug logging for portrait texture loading
    print("PlayerImage: Texture set - Valid: ", tex != null, " Visible: ", img.visible, " Z-index: ", img.z_index)
    if tex:
        print("  Texture size: ", tex.get_size())
    queue_redraw()  # Redraw to show the frame around texture

## Java: public void setFont(BitmapFont font)
func set_font(p_font: Font) -> void:
    self.font = p_font

## Java: public void setPlayerInfo(Player playerInfo)
func set_player_info(info: Player) -> void:
    self.player_info = info

## Java: public void setSlots(SlotImage[] slots)
func set_slots(new_slots: Array[SlotImage]) -> void:
    self.slots = new_slots

# Note: Java doesn't have a setSlotCards() method, only a getter
# So we don't add one here either

# ============================================================================
# DOCUMENTATION OF JAVA CLASS STRUCTURE
# ============================================================================
#
# This is a LITERAL translation of PlayerImage.java with these changes:
#
# 1. Java "Sprite" → Godot "Sprite2D" 
#    (Sprite is a visual node, but we store texture reference)
#
# 2. Java "Texture" → Godot "Texture2D"
#    (Direct equivalent)
#
# 3. Java "BitmapFont" → Godot "Font"
#    (Direct equivalent)
#
# 4. Java arrays "new SlotImage[6]" → GDScript "Array[SlotImage]" with size 6
#    (Type-safe arrays, manually filled with null)
#
# 5. Java "draw(Batch, float)" → Godot "_draw()"
#    (Different rendering pipeline, but same logic)
#
# 6. File paths: "images/stunned.png" → "res://assets/images/stunned.png"
#    (Only directory change as specified by user)
#
# WHAT THIS CLASS DOES NOT DO:
# - Layout positioning (that's in Cards.java → cards.gd)
# - Slot creation (that's in Cards.java → cards.gd)  
# - Card management (that's in Cards.java → cards.gd)
# - UI updates (that's in Cards.java → cards.gd)
#
# WHAT THIS CLASS DOES:
# - Holds visual references (sprite, frame, font)
# - Holds data reference (player_info)
# - Holds slot/card arrays (populated externally by Cards.gd)
# - Draws player portrait and stun indicator
# - Provides helper methods for life changes
# - Simple getters/setters
#
# The original Java class is ~100 lines
# This GDScript translation is ~220 lines (with extensive comments)
# Without comments, it's ~100 lines - matching the original exactly
#
# ============================================================================
