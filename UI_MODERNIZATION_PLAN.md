# UI Modernization Plan
## Dynamic Scaling & Node Reduction for Elemental Aces

**Status:** Planning Phase - No Implementation Yet
**Date:** 2025-11-15

---

## OVERVIEW

This document outlines the plan to modernize the game's UI system by:
1. **Eliminating 72 UI nodes** (stat labels) by baking stats into card images
2. **Implementing dynamic scaling** similar to Roblox's percentage-based system
3. **Supporting multiple resolutions** with aspect ratio maintenance
4. **Standardizing around 1080p** with optional Ultra HD support

---

## CURRENT STATE ANALYSIS

### Current Resolution & Scaling

**File:** `project.godot` (lines 27-30)
```ini
[display]
window/size/viewport_width=1024
window/size/viewport_height=768
```

**Issues:**
- ❌ Hardcoded 1024×768 resolution (4:3 aspect ratio)
- ❌ No viewport stretch mode configured
- ❌ Won't scale to different screen sizes
- ❌ All UI uses absolute pixel positioning
- ❌ No anchor system implemented
- ❌ No container nodes for layout

### Current UI Node Count

**Card Stat Labels:**
- **Hand cards:** 20 cards × 3 labels each (cost, attack, life) = **60 labels**
- **Battlefield:** 12 slots × 3 labels each (cost, attack, life) = **36 labels** (when occupied)
- **Total:** **96 stat labels**

**Other UI Elements:**
- Portrait images: 2 (player + opponent)
- Slot backgrounds: 12 (6 per player)
- Resource stat labels: 10 (5 per player: Fire, Air, Water, Earth, Special)
- Card images: 20 in hand + up to 12 on battlefield = 32
- **Total UI nodes: ~250+**

### Current Card Layout

**Hand (Bottom Right):**
```gdscript
HAND_START_Y: int = 405     # Horizontal position (confusing naming!)
HAND_START_X: int = 229     # Vertical position
HAND_SPACING_X: int = 104   # Spacing between columns
HAND_CARD_GAP_Y: int = 6    # Gap between rows

Layout: 5 columns × 4 rows = 20 cards
Size: 90×100 pixels per card (small size)
```

**Battlefield (Middle):**
```gdscript
PLAYER_SLOTS_X: int = 330
PLAYER_SLOTS_Y: int = 170
OPPONENT_SLOTS_X: int = 330
OPPONENT_SLOTS_Y: int = 50
SLOT_SPACING_X: int = 95

Layout: 6 slots per player (horizontal row)
Size: 92×132 pixels per slot
```

### CardImage Label Creation

**File:** `scripts/ui/card_image.gd` (lines 145-166)

```gdscript
func _create_visual_elements():
    # Cost label (top)
    cost_label = Label.new()
    cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    cost_label.z_index = 10
    add_child(cost_label)

    # Attack label (bottom left)
    attack_label = Label.new()
    attack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    attack_label.z_index = 10
    add_child(attack_label)

    # Life label (bottom right)
    life_label = Label.new()
    life_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    life_label.z_index = 10
    add_child(life_label)
```

**Updated every frame** (lines 74-95):
```gdscript
func _process(_delta: float) -> void:
    update_stats_display()

func update_stats_display() -> void:
    if attack_label:
        attack_label.text = str(card.get_attack())
    if cost_label:
        cost_label.text = str(card.get_cost())
    if life_label:
        life_label.text = str(card.get_life())
```

---

## GODOT'S RESPONSIVE UI SYSTEM

### 1. Viewport Stretch Modes

**Available in:** `Project Settings → Display → Window → Stretch`

**Stretch Modes:**
```ini
# Mode options:
disabled    # No scaling (default - current state)
canvas_items # Scale 2D content, maintain aspect ratio
viewport    # Scale viewport, may cause blur

# Aspect options:
ignore      # Stretch to fill (distorts)
keep        # Maintain aspect, add black bars
keep_width  # Maintain aspect, fit width
keep_height # Maintain aspect, fit height
expand      # Maintain aspect, show more content (RECOMMENDED)
```

**Recommended Configuration:**
```ini
[display]
window/size/viewport_width=1920      # 1080p base resolution
window/size/viewport_height=1080
window/size/resizable=true           # Allow window resizing
window/size/borderless=false         # Optional fullscreen
window/stretch/mode="canvas_items"   # Scale UI cleanly
window/stretch/aspect="expand"       # Show more on wider screens
```

**Why "expand" mode:**
- Maintains aspect ratio ✓
- Shows more content on wider screens ✓
- Centers content ✓
- No black bars ✓
- Perfect for card game UI ✓

---

### 2. Control Node Anchors (Godot's "Percentage-Based" System)

**This is Godot's equivalent to Roblox's percentage scaling!**

Every Control node has **4 anchor points** (0.0 to 1.0):
- `anchor_left`: 0.0 = left edge, 1.0 = right edge
- `anchor_right`: 0.0 = left edge, 1.0 = right edge
- `anchor_top`: 0.0 = top edge, 1.0 = bottom edge
- `anchor_bottom`: 0.0 = top edge, 1.0 = bottom edge

**Offset properties** (pixel adjustments from anchors):
- `offset_left`, `offset_right`, `offset_top`, `offset_bottom`

**How it works:**
```gdscript
# Example: Bottom-right anchored hand
var hand_container = Control.new()

# Anchor to bottom-right corner
hand_container.anchor_left = 0.6    # 60% from left
hand_container.anchor_right = 1.0   # 100% from left (right edge)
hand_container.anchor_top = 0.7     # 70% from top
hand_container.anchor_bottom = 1.0  # 100% from top (bottom edge)

# Fine-tune with offsets (negative = move inward)
hand_container.offset_left = 0
hand_container.offset_right = -20   # 20px padding from right
hand_container.offset_top = 0
hand_container.offset_bottom = -20  # 20px padding from bottom

# Result: Scales with screen, always bottom-right, maintains padding
```

**Anchor Presets** (shortcuts for common patterns):
```gdscript
# Full screen
set_anchors_preset(Control.PRESET_FULL_RECT)  # 0,0,1,1

# Center
set_anchors_preset(Control.PRESET_CENTER)      # 0.5,0.5,0.5,0.5

# Bottom right
set_anchors_preset(Control.PRESET_BOTTOM_RIGHT) # 1.0,1.0,1.0,1.0

# Top stretch (full width, fixed height)
set_anchors_preset(Control.PRESET_TOP_WIDE)    # 0,1,0,0
```

---

### 3. Container Nodes (Auto-Layout)

**Container types:**

**HBoxContainer** (horizontal layout):
```gdscript
# Battlefield slots - 6 cards in a row
var battlefield_row = HBoxContainer.new()
battlefield_row.add_theme_constant_override("separation", 5)  # 5px gap

for i in range(6):
    var slot = CardSlot.new()
    battlefield_row.add_child(slot)
    # Cards auto-arrange horizontally!
```

**VBoxContainer** (vertical layout):
```gdscript
# Hand columns - 4 cards stacked vertically
var hand_column = VBoxContainer.new()
hand_column.add_theme_constant_override("separation", 6)  # 6px gap

for i in range(4):
    var card = CardImage.new()
    hand_column.add_child(card)
    # Cards auto-stack vertically!
```

**GridContainer** (grid layout):
```gdscript
# Hand - 5×4 grid
var hand_grid = GridContainer.new()
hand_grid.columns = 5  # 5 columns

for i in range(20):  # 20 cards total
    var card = CardImage.new()
    hand_grid.add_child(card)
    # Auto-arranges in 5×4 grid!
```

**MarginContainer** (padding):
```gdscript
# Add padding around any container
var margin = MarginContainer.new()
margin.add_theme_constant_override("margin_left", 20)
margin.add_theme_constant_override("margin_right", 20)
margin.add_theme_constant_override("margin_top", 20)
margin.add_theme_constant_override("margin_bottom", 20)

margin.add_child(hand_grid)  # Wrap existing container
# Now hand_grid has 20px padding on all sides!
```

**CenterContainer** (center children):
```gdscript
# Center the battlefield
var center = CenterContainer.new()
center.add_child(battlefield_row)
# battlefield_row always centered!
```

---

### 4. AspectRatioContainer (Maintain Proportions)

**Critical for card images!**

```gdscript
# Card with fixed aspect ratio (e.g., 3:4 for standard card)
var aspect_container = AspectRatioContainer.new()
aspect_container.ratio = 3.0 / 4.0  # Width:Height
aspect_container.stretch_mode = AspectRatioContainer.STRETCH_FIT

var card_image = TextureRect.new()
card_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
aspect_container.add_child(card_image)

# Result: Card always maintains 3:4 ratio, scales to fit container
```

**Stretch modes:**
```gdscript
STRETCH_WIDTH_CONTROLS_HEIGHT  # Width fixed, height scales
STRETCH_HEIGHT_CONTROLS_WIDTH  # Height fixed, width scales
STRETCH_FIT                    # Fit inside container
STRETCH_COVER                  # Fill container (may crop)
```

---

## IMPLEMENTATION PLAN

### Phase 1: Bake Stats Into Card Images

**What to bake:**
- ✓ Cost (top center)
- ✓ Base Attack (bottom left)
- ✓ Base HP (bottom right)
- ✓ Card frame (creature vs spell)

**Process:**
1. Artist adds text overlays to all 245 cards (both HD and SD)
2. Export with frames baked in
3. Cards become complete visual units

**Benefits:**
- Eliminates 60 labels from hand
- Eliminates 12 labels from battlefield (cost)
- Simpler rendering
- Fewer scene tree nodes

---

### Phase 2: Remove Labels From CardImage

**File to modify:** `scripts/ui/card_image.gd`

**Changes:**

**A. Remove hand card labels entirely:**
```gdscript
# OLD (lines 51-53):
var cost_label: Label = null
var attack_label: Label = null
var life_label: Label = null

# NEW:
# REMOVED - Stats baked into card images for hand cards
# Only battlefield cards need dynamic attack/life labels
var attack_label: Label = null  # Only for battlefield
var life_label: Label = null    # Only for battlefield
```

**B. Conditional label creation:**
```gdscript
# OLD (lines 145-166):
func _create_visual_elements():
    cost_label = Label.new()
    add_child(cost_label)

    attack_label = Label.new()
    add_child(attack_label)

    life_label = Label.new()
    add_child(life_label)

# NEW:
func _create_visual_elements(create_stat_labels: bool = false):
    # Only create labels for battlefield cards
    if create_stat_labels:
        attack_label = Label.new()
        attack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        attack_label.z_index = 10
        add_child(attack_label)

        life_label = Label.new()
        life_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        life_label.z_index = 10
        add_child(life_label)

    # Cost label never created - baked into image
```

**C. Update stats display:**
```gdscript
# OLD (lines 79-95):
func update_stats_display() -> void:
    if attack_label:
        attack_label.text = str(card.get_attack())
    if cost_label:
        cost_label.text = str(card.get_cost())
    if life_label:
        life_label.text = str(card.get_life())

# NEW:
func update_stats_display() -> void:
    # Only update battlefield card stats (attack/life change during gameplay)
    if attack_label:
        attack_label.text = str(card.get_attack())
    if life_label:
        life_label.text = str(card.get_life())

    # Cost removed - never changes, baked into image
```

**Node reduction:**
- Hand: 20 cards × 3 labels removed = **-60 nodes**
- Battlefield: 12 slots × 1 label removed (cost) = **-12 nodes**
- **Total: -72 nodes eliminated** ✓

---

### Phase 3: Update Cards.gd Battlefield Card Creation

**File to modify:** `scripts/cards.gd`

**When summoning creatures, enable stat labels:**

```gdscript
# OLD (around line 1290):
var clone = card_img.duplicate()
clone.z_index = CREATURE_Z_INDEX
add_child(clone)

# NEW:
var clone = card_img.duplicate()
clone.z_index = CREATURE_Z_INDEX

# Enable dynamic stat labels for battlefield cards
clone._create_visual_elements(true)  # true = create attack/life labels
clone.update_stats_display()  # Initialize label values

add_child(clone)
```

**Battlefield frame overlays:**
- Create new frame textures that cover the static stats area
- Position attack/life labels in visible areas (outside covered region)
- Labels show current values that change during combat

---

### Phase 4: Enable Viewport Scaling

**File to modify:** `project.godot`

**Replace current display settings:**

```ini
# OLD:
[display]
window/size/viewport_width=1024
window/size/viewport_height=768

# NEW (1080p base, dynamic scaling):
[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/size/resizable=true
window/size/borderless=false
window/size/mode=2                       # 0=windowed, 2=maximized, 3=fullscreen
window/stretch/mode="canvas_items"       # Scale 2D content smoothly
window/stretch/aspect="expand"           # Maintain aspect, show more on wider
window/stretch/scale=1.0                 # Base scale factor
```

**For mobile support:**
```ini
[display]
window/handheld/orientation=0            # 0=landscape, 1=portrait
window/size/window_width_override=1920   # Desktop override
window/size/window_height_override=1080  # Desktop override
```

**Test resolutions:**
- 1920×1080 (1080p - base)
- 2560×1440 (1440p - HD)
- 3840×2160 (4K - Ultra HD)
- 1280×720 (720p - mobile/low-end)
- 800×480 (mobile vertical)

---

### Phase 5: Convert Hand to Container Layout

**Current:** Hardcoded grid positioning (lines 882-912 in cards.gd)

**New:** Container-based layout

**Create hand container structure:**

```gdscript
# Create main hand container (anchored to bottom-right)
var hand_container = MarginContainer.new()
hand_container.anchor_left = 0.4
hand_container.anchor_right = 1.0
hand_container.anchor_top = 0.65
hand_container.anchor_bottom = 1.0
hand_container.add_theme_constant_override("margin_right", 20)
hand_container.add_theme_constant_override("margin_bottom", 20)

# Create grid for 5×4 card layout
var hand_grid = GridContainer.new()
hand_grid.columns = 5
hand_grid.add_theme_constant_override("h_separation", 4)  # Horizontal gap
hand_grid.add_theme_constant_override("v_separation", 6)  # Vertical gap

hand_container.add_child(hand_grid)
add_child(hand_container)

# Add cards to grid
for card in player_cards:
    # Wrap each card in AspectRatioContainer to maintain proportions
    var aspect = AspectRatioContainer.new()
    aspect.ratio = 90.0 / 100.0  # Card aspect ratio
    aspect.stretch_mode = AspectRatioContainer.STRETCH_FIT

    aspect.add_child(card)
    hand_grid.add_child(aspect)

# Result: Hand auto-scales to screen size, maintains card aspect ratios!
```

**Benefits:**
- ✓ Auto-scales to any resolution
- ✓ Maintains card proportions
- ✓ Consistent spacing at all sizes
- ✓ Easy to adjust layout (change columns, spacing, etc.)
- ✓ No hardcoded pixel positions

---

### Phase 6: Convert Battlefield to Container Layout

**Current:** Hardcoded slot positioning (lines 619-620 in cards.gd)

**New:** Container-based battlefield

```gdscript
# Create battlefield container (centered horizontally)
var battlefield_container = CenterContainer.new()
battlefield_container.anchor_left = 0.0
battlefield_container.anchor_right = 1.0
battlefield_container.anchor_top = 0.05
battlefield_container.anchor_bottom = 0.35

# Vertical stack: opponent row, then player row
var battlefield_vbox = VBoxContainer.new()
battlefield_vbox.add_theme_constant_override("separation", 30)  # Gap between rows
battlefield_container.add_child(battlefield_vbox)

# Opponent slot row
var opponent_row = HBoxContainer.new()
opponent_row.add_theme_constant_override("separation", 5)
for i in range(6):
    var slot = create_battlefield_slot(opponent, i)
    opponent_row.add_child(slot)

battlefield_vbox.add_child(opponent_row)

# Player slot row
var player_row = HBoxContainer.new()
player_row.add_theme_constant_override("separation", 5)
for i in range(6):
    var slot = create_battlefield_slot(player, i)
    player_row.add_child(slot)

battlefield_vbox.add_child(player_row)
add_child(battlefield_container)

# Result: Battlefield centered, scales to any screen width!
```

---

### Phase 7: Portrait & UI Elements

**Portraits:**
```gdscript
# Player portrait (bottom-left anchor)
var player_portrait = TextureRect.new()
player_portrait.anchor_left = 0.0
player_portrait.anchor_right = 0.15   # 15% of screen width
player_portrait.anchor_top = 0.7
player_portrait.anchor_bottom = 0.95
player_portrait.offset_left = 20
player_portrait.offset_top = 20
player_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL

# Opponent portrait (top-left anchor)
var opponent_portrait = TextureRect.new()
opponent_portrait.anchor_left = 0.0
opponent_portrait.anchor_right = 0.15
opponent_portrait.anchor_top = 0.05
opponent_portrait.anchor_bottom = 0.30
opponent_portrait.offset_left = 20
opponent_portrait.offset_top = 20
opponent_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
```

**Resource stats:**
```gdscript
# Stats row (bottom, above hand)
var stats_container = HBoxContainer.new()
stats_container.anchor_left = 0.4
stats_container.anchor_right = 1.0
stats_container.anchor_top = 0.6
stats_container.anchor_bottom = 0.65
stats_container.add_theme_constant_override("separation", 20)

for stat_name in ["Fire", "Air", "Water", "Earth", "Special"]:
    var stat_label = Label.new()
    stat_label.text = "%s: 0" % stat_name
    stats_container.add_child(stat_label)
```

---

## RESOLUTION TARGETS

### Standard Resolutions (16:9 aspect ratio recommended)

**Base:** 1920×1080 (1080p)
- Default for PC
- Clean scaling for UI elements
- Base textures designed for this

**Mobile:** 1280×720 (720p)
- SD textures recommended
- Reduced UI scale if needed
- Performance optimized

**HD:** 2560×1440 (1440p)
- HD textures recommended
- Sharper visuals
- Same layout, higher fidelity

**Ultra HD:** 3840×2160 (4K)
- Ultra HD textures (future)
- Maximum quality
- Same layout, maximum fidelity

### Aspect Ratio Support

**Primary:** 16:9 (most common)
- 1920×1080, 1280×720, 2560×1440, 3840×2160

**Secondary:** 16:10 (some laptops)
- 1920×1200, 1680×1050

**Fallback:** 4:3 (legacy)
- 1024×768 (current base)
- Shows extra vertical space with "expand" mode

**Ultra-wide:** 21:9, 32:9 (gaming monitors)
- Shows extra horizontal space
- UI stays centered
- Extra background visible on sides

---

## TEXTURE LOADING STRATEGY

### Dynamic Quality Selection

**Settings menu option:**
```
Graphics Quality:
[ ] Auto (detect device capability)
[ ] SD (150×150 JPG, fast)
[ ] HD (300×300 PNG, sharp)
[ ] Ultra HD (600×600 PNG, future)
```

**Auto-detection logic:**
```gdscript
func detect_graphics_quality() -> String:
    var screen_size = DisplayServer.screen_get_size()
    var screen_width = screen_size.x

    # Mobile or low-end
    if OS.has_feature("mobile") or screen_width < 1280:
        return "sd"

    # HD capable
    elif screen_width >= 1920 and screen_width < 2560:
        return "hd"

    # Ultra HD capable
    elif screen_width >= 2560:
        return "ultra_hd"  # Future

    # Default
    else:
        return "sd"
```

**TextureManager update:**
```gdscript
# In texture_manager.gd
var quality_setting: String = "sd"  # or "hd"

func get_card_texture(card_name: String, card_type: CardType.Type) -> Texture2D:
    var type_folder = CardType.get_title(card_type).to_lower()
    var extension = "png" if quality_setting == "hd" else "jpg"

    # Dynamic path based on quality
    var card_path = "res://assets/images/cards/%s/%s/%s.%s" % [
        type_folder,
        quality_setting,  # sd or hd folder
        card_name.to_lower(),
        extension
    ]

    return load(card_path)
```

**Key insight:** TextureRect's `expand_mode` handles scaling automatically!
- Load 150×150 JPG → TextureRect scales it up for display
- Load 300×300 PNG → TextureRect scales it down for display
- No additional code needed!

---

## MIGRATION STRATEGY

### Order of Operations

**Phase 1: Planning (Current)**
- Document current UI structure ✓
- Plan container-based layout ✓
- Design anchor system ✓

**Phase 2: Preparation**
- Artist bakes stats into all 245 cards (HD + SD)
- Create battlefield frame overlays (cover static stats)
- Test sample cards with baked stats

**Phase 3: Implementation (Code Changes)**
1. Enable viewport scaling in project.godot
2. Remove labels from CardImage class
3. Update battlefield card creation logic
4. Convert hand to container layout
5. Convert battlefield to container layout
6. Update portrait/stats positioning
7. Test at multiple resolutions

**Phase 4: Testing**
- Test 1080p (base)
- Test 720p (mobile sim)
- Test 1440p (HD)
- Test 4K (if available)
- Test window resizing
- Test fullscreen mode
- Verify all UI scales correctly

**Phase 5: Optimization**
- Profile node count reduction
- Measure performance improvement
- Verify memory usage
- Optimize texture loading

---

## EXPECTED BENEFITS

### Performance

**Node reduction:**
- Before: ~250 UI nodes
- After: ~178 UI nodes (-72 labels)
- **28% fewer nodes** ✓

**Frame budget savings:**
- 72 fewer `_process()` calls per frame
- 72 fewer text updates per frame
- Simpler scene tree traversal
- Reduced CPU overhead

### Maintainability

**Code simplification:**
- No manual stat label positioning
- No per-frame stat updates for hand cards
- Container auto-layout (no hardcoded positions)
- Easy to adjust spacing/layout

### Scalability

**Resolution independence:**
- Works at any resolution automatically
- Maintains aspect ratios
- Scales smoothly
- No distortion

### User Experience

**Platform support:**
- PC: Windowed, fullscreen, resizable
- Mobile: Full screen, landscape/portrait
- Tablets: Auto-scales to screen
- Ultra-wide monitors: Shows more background

---

## TECHNICAL NOTES

### Godot vs Roblox UI Comparison

| Feature | Roblox | Godot Equivalent |
|---------|--------|------------------|
| Percentage sizing | `Size = UDim2.new(0.5, 0, 0.5, 0)` | `anchor_left/right/top/bottom = 0.5` |
| Pixel offsets | `Position = UDim2.new(0, 10, 0, 10)` | `offset_left/right/top/bottom = 10` |
| Auto-layout | `UIListLayout`, `UIGridLayout` | `VBoxContainer`, `HBoxContainer`, `GridContainer` |
| Aspect ratio | `UIAspectRatioConstraint` | `AspectRatioContainer` |
| Padding | `UIPadding` | `MarginContainer` |
| Scaling | `UIScale` | Viewport stretch mode |

**Godot is MORE powerful:**
- Built-in stretch modes (no custom code needed)
- Better container system (more layout options)
- Cleaner API (anchors + offsets)
- Better performance (native C++ containers)

### Important Gotchas

**1. Anchor + Offset interaction:**
```gdscript
# Anchors define PERCENTAGE position
anchor_left = 0.5   # 50% from left

# Offsets define PIXEL adjustment FROM anchor
offset_left = -50   # 50px left of anchor point

# Result: Element centered horizontally with 50px offset
```

**2. Container sizing:**
- Containers ignore `custom_minimum_size` of children
- Use `set_custom_minimum_size()` to control container children
- AspectRatioContainer needs explicit ratio setting

**3. Viewport stretch order:**
```
1. Render at base resolution (1920×1080)
2. Scale to window size (maintain aspect)
3. Add letterboxing/pillarboxing if needed (or expand)
4. Display final image
```

**4. TextureRect expand modes:**
```gdscript
# Best for card images:
TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL  # Scales to fit, maintains aspect
TextureRect.EXPAND_IGNORE_SIZE             # Uses texture size
TextureRect.EXPAND_FIT_HEIGHT              # Fits height
```

---

## QUESTIONS TO RESOLVE

Before implementation:

1. **Battlefield frame overlay design:**
   - Where exactly do we position attack/life labels?
   - What size/color for battlefield frames?
   - Should frames differ from hand card frames?

2. **Mobile orientation:**
   - Landscape only (current)?
   - Support portrait mode?
   - Tablet-specific layout?

3. **Ultra HD support:**
   - Generate 600×600 card images?
   - When to add this tier?
   - Worth the asset size increase?

4. **Settings persistence:**
   - Save graphics quality preference?
   - Auto-detect on first launch?
   - Allow manual override?

5. **Fallback behavior:**
   - What if HD texture missing?
   - Gracefully fall back to SD?
   - Show warning or silent fallback?

---

## NEXT STEPS

**Ready for:**
1. Artist to bake stats into card images
2. Plan discussion/refinement
3. Prototyping container layouts
4. Testing viewport scaling

**When ready to implement:**
1. Create backup branch
2. Implement Phase 3 (enable scaling)
3. Implement Phase 4 (remove labels)
4. Test thoroughly
5. Iterate based on results

---

**All planning, no implementation yet - awaiting your approval and next discussion phase!**
