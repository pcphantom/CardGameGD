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

    # Initialize arrays to size 6 (matching Java's new SlotImage[6])
    slots.resize(6)
    slot_cards.resize(6)

    # Fill with nulls (GDScript arrays don't auto-null like Java)
    for i in range(6):
        slots[i] = null
        slot_cards[i] = null

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
    
    # Java: Color color = getColor();
    # Java: batch.setColor(color.r, color.g, color.b, color.a * parentAlpha);
    # Godot: modulate handles color/alpha automatically
    
    # Java: float x = getX(); float y = getY();
    var x: float = position.x
    var y: float = position.y
    
    # Java: batch.draw(img, x, y);
    if img != null and img.texture != null:
        draw_texture(img.texture, Vector2(x, y))
    
    # Java: if (this.mustSkipNexAttack) { batch.draw(stunned, x + 10, y - 10); }
    if must_skip_next_attack and stunned_texture != null:
        draw_texture(stunned_texture, Vector2(x + 10, y - 10))
    
    # Java: batch.draw(frame, x - 6, y - 6);
    if frame != null:
        draw_texture(frame, Vector2(x - 6, y - 6))

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
    self.img = sprite_img

## Java: public void setFrame(Texture frame)
func set_frame(frame_tex: Texture2D) -> void:
    self.frame = frame_tex

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
