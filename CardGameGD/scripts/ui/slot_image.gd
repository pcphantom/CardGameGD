class_name SlotImage
extends TextureRect

## EXACT LITERAL TRANSLATION OF SlotImage.java
## Source: CardGameGDX/src/main/java/org/antinori/cards/SlotImage.java
##
## This is a PURE DATA CLASS that holds slot state information.
## It does NOT handle:
## - Rendering (texture handled by TextureRect)
## - Positioning (done by cards.gd)
## - Card management (done by cards.gd)
##
## It DOES handle:
## - Slot index (0-5)
## - Occupied state (true/false)
## - Highlighted state (true/false)
## - Bottom/top player flag (true/false)
## - Click events (emits slot_clicked signal)

# ============================================================================
# SIGNALS
# ============================================================================

signal slot_clicked(slot: SlotImage)

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

	# Enable input handling for click events
	mouse_filter = Control.MOUSE_FILTER_STOP

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
# INPUT HANDLING (Godot-specific for signal emission)
# ============================================================================

## Handles mouse input and emits slot_clicked signal
## Equivalent to Java's InputListener added in Cards.java line 469
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# DEBUG: print("SlotImage clicked: index=", index, " bottom=", bottom_slots, " occupied=", occupied)
			slot_clicked.emit(self)
			accept_event()

## Clears any active animations/actions on this slot
## Called from cards.gd clearHighlights() method
func clear_actions() -> void:
	# Stop any tweens running on this slot
	var tweens = get_tree().get_processed_tweens()
	for tween in tweens:
		if tween and is_instance_valid(tween):
			# Check if this tween is animating this node
			var bound_node = tween.get_meta("bound_node", null)
			if bound_node == self:
				tween.kill()

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
# ❌ No positioning logic (done in cards.gd)
# ❌ No card reference (CardImage stored separately in cards.gd)
# ❌ No visual effects (highlighting done in cards.gd)
#
# What This Class DOES Contain (Godot additions):
# ------------------------------------------------
# ✅ Mouse event handling (_gui_input emits slot_clicked signal)
# ✅ Signal: slot_clicked(slot: SlotImage)
# ✅ clear_actions() to stop animations
#
# This matches the Java source functionality - in Java the listener was added
# externally in Cards.java line 469, in Godot we emit a signal instead.
#
# Line count: Java ~50 lines, GDScript ~150 lines (with extensive comments)
#             Without comments: both ~30 lines of actual code
#
# ============================================================================
