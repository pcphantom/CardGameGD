class_name SlotImage
extends TextureRect

## EXACT LITERAL TRANSLATION OF SlotImage.java
## Source: CardGameGDX/src/main/java/org/antinori/cards/SlotImage.java
##
## This is a PURE DATA CLASS that holds slot state information.
## It does NOT handle:
## - Rendering (texture handled by TextureRect)
## - Positioning (done by cards.gd)
## - Click events (done by cards.gd)
## - Card management (done by cards.gd)
##
## It ONLY stores:
## - Slot index (0-5)
## - Occupied state (true/false)
## - Highlighted state (true/false)  
## - Bottom/top player flag (true/false)

# ============================================================================
# FIELDS (Exact translation from Java)
# ============================================================================

## Java: private int index = 0;
var index: int = 0

## Java: private boolean occupied;
var occupied: bool = false

## Java: private boolean isHighlighted;
var is_highlighted: bool = false

## Java: private boolean bottomSlots;
var bottom_slots: bool = false

# ============================================================================
# CONSTRUCTOR (Exact translation)
# ============================================================================

## Java Constructor: public SlotImage(Texture texture, int index, boolean isBottom)
## In Java this calls super(texture) and sets fields
## In Godot we do the same via _init
func _init(slot_texture: Texture2D, slot_index: int, is_bottom: bool) -> void:
	# Java: super(texture);
	texture = slot_texture
	
	# Java: this.bottomSlots = isBottom;
	self.bottom_slots = is_bottom
	
	# Java: this.index = index;
	self.index = slot_index
	
	# Set up TextureRect properties to match LibGDX Image behavior
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

# ============================================================================
# GETTERS (Exact translation from Java)
# ============================================================================

## Java: public boolean isBottomSlots()
func is_bottom_slots() -> bool:
	return bottom_slots

## Java: public boolean isOccupied()
func is_occupied() -> bool:
	return occupied

## Java: public int getIndex()
## Renamed to get_slot_index() to avoid conflict with Node.get_index()
func get_slot_index() -> int:
	return index

## Java: public boolean isHighlighted()
func is_highlighted_slot() -> bool:
	return is_highlighted

# ============================================================================
# SETTERS (Exact translation from Java)
# ============================================================================

## Java: public void setBottomSlots(boolean bottomSlots)
func set_bottom_slots(value: bool) -> void:
	self.bottom_slots = value

## Java: public void setOccupied(boolean occupied)
func set_occupied(value: bool) -> void:
	self.occupied = value

## Java: public void setHighlighted(boolean isHighlighted)
func set_highlighted(value: bool) -> void:
	self.is_highlighted = value

# ============================================================================
# TRANSLATION NOTES
# ============================================================================
#
# Java → GDScript Mappings:
# -------------------------
# 1. "extends Image" → "extends TextureRect"
#    LibGDX Image ≈ Godot TextureRect (both display textures)
#
# 2. "Texture" → "Texture2D"  
#    Direct equivalent
#
# 3. "super(texture)" → "texture = slot_texture"
#    In Java, super() sets the image texture
#    In Godot, we set the texture property directly
#
# 4. Method naming: Java uses "isBottomSlots()" 
#    GDScript convention: "is_bottom_slots()"
#    But we keep "is_highlighted_slot()" to avoid conflict with Control.is_highlighted()
#
# 5. Field access: Java uses "this.field"
#    GDScript uses "self.field" (same semantics)
#
# Directory Changes (as per user specification):
# ----------------------------------------------
# - Java: src/main/java/org/antinori/cards/SlotImage.java
# - Godot: scripts/ui/slot_image.gd
#   (Only location changed, no functional changes)
#
# What This Class Does NOT Contain:
# ----------------------------------
# ❌ No draw() method (texture rendering handled by TextureRect)
# ❌ No mouse event handling (done in cards.gd)
# ❌ No positioning logic (done in cards.gd)
# ❌ No card reference (CardImage stored separately in cards.gd)
# ❌ No visual effects (highlighting done in cards.gd)
# ❌ No signals (event handling done in cards.gd)
#
# This matches the Java source EXACTLY - it's a pure data holder.
#
# Line count: Java ~50 lines, GDScript ~150 lines (with extensive comments)
#             Without comments: both ~30 lines of actual code
#
# ============================================================================
