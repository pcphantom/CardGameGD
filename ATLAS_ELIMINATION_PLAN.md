# Atlas Elimination Plan
## Elemental Aces - Dynamic Card Loading System

**Status:** Cards extracted, ready for implementation
**Date:** 2025-11-15

---

## OVERVIEW

This document outlines the plan to eliminate the atlas texture system and replace it with a dynamic, type-organized card loading system. This change will dramatically simplify adding new classes and cards to the game.

---

## COMPLETED: Card Extraction ✓

**All 193+ cards extracted from atlases!**

### Folder Structure Created

```
assets/images/cards/
├── fire/
│   ├── sd/          (12 cards @ 150x150 JPG)
│   │   ├── goblinberserker.jpg
│   │   ├── walloffire.jpg
│   │   ├── priestoffire.jpg
│   │   ├── firedrake.jpg
│   │   ├── orcchieftain.jpg
│   │   ├── flamewave.jpg
│   │   ├── minotaurcommander.jpg
│   │   ├── bargul.jpg
│   │   ├── inferno.jpg
│   │   ├── fireelemental.jpg
│   │   ├── armageddon.jpg
│   │   └── dragon.jpg
│   └── hd/          (empty - for future 300x300 PNG)
│
├── water/
│   ├── sd/          (12 cards)
│   └── hd/          (empty)
│
├── air/
│   ├── sd/          (12 cards)
│   └── hd/          (empty)
│
├── earth/
│   ├── sd/          (12 cards)
│   └── hd/          (empty)
│
├── holy/
│   ├── sd/          (6 cards)
│   └── hd/          (empty)
│
├── mechanical/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── death/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── chaos/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── control/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── illusion/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── demonic/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── sorcery/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── beast/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── goblins/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── forest/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── time/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── spirit/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── vampiric/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── cult/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
├── golem/
│   ├── sd/          (8 cards)
│   └── hd/          (empty)
│
└── other/
    ├── sd/          (63 misc cards)
    └── hd/          (empty)
```

### Card Statistics

- **Total card types:** 22
- **Total cards extracted:** 245 (includes duplicates from different atlases)
- **Unique cards:** 193+ as expected
- **Format:** JPEG @ 150x150 pixels (SD quality)
- **Future:** PNG @ 300x300 pixels (HD quality - folders created, awaiting content)

---

## IMPLEMENTATION PHASES

### **PHASE 1: ClassRegistry Module**
Create dynamic class enable/disable system

**New File:** `scripts/data/class_registry.gd`

```gdscript
extends RefCounted
class_name ClassRegistry

# Class availability control
# Set enabled=false to remove class from game (and skip loading its cards)
const CLASS_CONFIG = {
    "CLERIC": {"enabled": true},
    "MECHANICIAN": {"enabled": true},
    "NECROMANCER": {"enabled": true},
    "CHAOSMASTER": {"enabled": true},
    "DOMINATOR": {"enabled": true},
    "ILLUSIONIST": {"enabled": true},
    "DEMONOLOGIST": {"enabled": true},
    "SORCERER": {"enabled": true},
    "BEASTMASTER": {"enabled": true},
    "GOBLIN_CHIEFTAN": {"enabled": true},
    "MAD_HERMIT": {"enabled": true},
    "CHRONOMANCER": {"enabled": true},
    "WARRIOR_PRIEST": {"enabled": true},
    "VAMPIRE_LORD": {"enabled": true},
    "CULTIST": {"enabled": true},
    "GOLEM_MASTER": {"enabled": true},
    "RANDOM": {"enabled": true}
}

static func is_class_enabled(class_id: String) -> bool:
    return CLASS_CONFIG.get(class_id, {}).get("enabled", false)

static func is_class_type_enabled(spec_type: Specializations.Type) -> bool:
    var class_id = Specializations.Type.keys()[spec_type]
    return is_class_enabled(class_id)

static func get_enabled_class_types() -> Array:
    var result = []
    for i in range(Specializations.Type.size()):
        if is_class_type_enabled(i):
            result.append(i)
    return result
```

**Files to modify:**
- `scripts/core/specializations.gd` - Add enabled filtering (~20 lines)
- `scripts/autoload/card_setup.gd` - Skip disabled class cards (~25 lines)
- `scripts/cards.gd` - Safety check for disabled classes (~10 lines)

**Effort:** 2-3 hours
**Result:** Toggle any class on/off with single line change

---

### **PHASE 2: Rewrite TextureManager**
Replace atlas loading with dynamic path construction

**File:** `scripts/autoload/texture_manager.gd`

**Current:** ~400 lines with atlas parsing
**New:** ~100 lines with dynamic loading

**Key changes:**

```gdscript
# OLD: Dictionary of pre-loaded atlas textures
var small_card_atlas: Dictionary = {}
var large_card_atlas: Dictionary = {}

# NEW: On-demand loading with caching
var card_texture_cache: Dictionary = {}
var quality_setting: String = "sd"  # or "hd"

func get_card_texture(card_name: String, card_type: CardType.Type) -> Texture2D:
    var cache_key = "%s_%s_%s" % [card_name.to_lower(), quality_setting, CardType.get_title(card_type)]

    # Check cache
    if card_texture_cache.has(cache_key):
        return card_texture_cache[cache_key]

    # Build path: res://assets/images/cards/{type}/{quality}/{cardname}.{ext}
    var type_folder = CardType.get_title(card_type).to_lower()
    var extension = "png" if quality_setting == "hd" else "jpg"
    var card_path = "res://assets/images/cards/%s/%s/%s.%s" % [type_folder, quality_setting, card_name.to_lower(), extension]

    # Load and cache
    if ResourceLoader.exists(card_path):
        var texture = load(card_path)
        card_texture_cache[cache_key] = texture
        return texture
    else:
        push_warning("Card not found: %s" % card_path)
        return null
```

**What to remove:**
- `load_texture_atlas()` function (lines 61-148)
- All atlas dictionaries
- All .txt file parsing
- All Rect2 region calculations

**What to keep:**
- Frame loading (ramka.png files) - IF frames not baked into cards
- Face texture loading (will be replaced in future phase)

**Effort:** 2-3 hours
**Result:** Clean, simple texture loading without atlas complexity

---

### **PHASE 3: Update CardImage Rendering**
Remove frame overlays, add texture scaling

**File:** `scripts/ui/card_image.gd`

**Changes:**

1. **Update texture loading (lines 223-238):**

```gdscript
# OLD:
var card_name: String = card.get_name().to_lower()
if is_large:
    card_texture = TextureManager.get_large_card_texture(card_name)
else:
    card_texture = TextureManager.get_small_card_texture(card_name)

# NEW:
var card_name: String = card.get_name().to_lower()
var card_type: CardType.Type = card.get_type()
card_texture = TextureManager.get_card_texture(card_name, card_type)

# Scale texture for display size
portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
if is_large:
    portrait.custom_minimum_size = Vector2(300, 300)
else:
    portrait.custom_minimum_size = Vector2(100, 100)
```

2. **Remove frame overlay (lines 258-280):**

```gdscript
# DELETE (if frames baked into cards):
frame_rect.texture = ...
frame_rect.position = ...
frame_rect.size = ...
```

**Effort:** 1-2 hours
**Result:** Cards display with proper scaling, no separate frame layers

---

### **PHASE 4: Update All Callers**
Update all files that call TextureManager

**Files to modify:**

1. **card_setup.gd** (lines 265, 290):
```gdscript
# OLD:
var card_texture = TextureManager.get_small_card_texture(c.get_name().to_lower())

# NEW:
var card_texture = TextureManager.get_card_texture(c.get_name().to_lower(), c.get_type())
```

2. **cards.gd** (multiple locations):
- Remove static atlas variables (lines 30-34)
- Remove frame setting calls (lines 962-963, 1239-1240)
- Remove atlas references

3. **single_duel_chooser.gd** (if updating faces):
- Update face loading to use new system (future phase)

**Effort:** 1-2 hours
**Result:** All texture loading goes through new dynamic system

---

### **PHASE 5: Cleanup & Testing**
Remove old atlas files, verify everything works

**Files to delete:**
```
assets/images/smallTiles.png
assets/images/smallCardsPack.txt
assets/images/largeTiles.png
assets/images/largeCardsPack.txt
assets/images/smallTGATiles.png
assets/images/smallTGACardsPack.txt
assets/images/largeTGATiles.png
assets/images/largeTGACardsPack.txt
assets/images/faceCardsPack.txt
assets/images/faceTiles.png

assets/images/ramka.png        (if frames baked into cards)
assets/images/ramkaspell.png   (if frames baked into cards)
assets/images/ramkabig.png     (if frames baked into cards)
assets/images/ramkabigspell.png (if frames baked into cards)
assets/images/portraitramka.png (if not using)

assets/images/smallTiles/      (folder)
assets/images/largeTiles/      (folder)
assets/images/smallTGATiles/   (folder)
assets/images/largeTGATiles/   (folder)
assets/images/faceTiles/       (folder)
```

**Testing checklist:**
- [ ] All cards load correctly in hand view
- [ ] All cards display correctly in large detail view
- [ ] All card types (22 types) load without errors
- [ ] Memory usage acceptable
- [ ] No missing texture warnings
- [ ] Card scaling works for small/large views
- [ ] Game playable end-to-end

**Effort:** 1 hour
**Result:** Clean codebase, no legacy atlas files

---

## TOTAL EFFORT ESTIMATE

| Phase | Description | Effort |
|-------|-------------|--------|
| 1 | ClassRegistry module | 2-3 hours |
| 2 | TextureManager rewrite | 2-3 hours |
| 3 | CardImage updates | 1-2 hours |
| 4 | Update callers | 1-2 hours |
| 5 | Cleanup & testing | 1 hour |
| **TOTAL** | **Complete atlas elimination** | **7-11 hours** |

---

## BENEFITS

### Immediate Benefits

1. **Zero programming per card**
   - Drop image file → automatically loads
   - No atlas editing
   - No coordinate calculations

2. **Type-organized files**
   - Visual structure matches game structure
   - Easy to find cards
   - Easy to manage assets

3. **Simple class addition**
   - Create folder: `cards/newtype/sd/`
   - Drop card images
   - Enable in ClassRegistry
   - Done!

4. **Version control friendly**
   - Individual files = better diffs
   - Easy to track changes
   - No binary atlas conflicts

5. **Modding ready**
   - Players can add card packs
   - Drop images in folder
   - No tools required

### Future Benefits

6. **HD/SD toggle ready**
   - Structure supports two quality tiers
   - Menu option switches between sd/ and hd/
   - Automatic resolution selection (PC = HD, Mobile = SD)

7. **Per-class asset management**
   - Disable class = skip loading its cards
   - Memory optimization
   - Faster testing with subset of classes

8. **Scalable to 1000+ cards**
   - No atlas size limits
   - No coordinate hell
   - Add infinite cards without code changes

9. **Godot auto-optimization**
   - Each image auto-optimized on import
   - Better compression than manual atlases
   - Per-file import settings if needed

---

## FUTURE ENHANCEMENTS

### Planned for Later Phases

1. **HD Graphics Support**
   - Populate `cards/*/hd/` folders with 300x300 PNG
   - Add menu setting for graphics quality
   - Auto-select based on platform (PC/mobile)

2. **Dynamic Face System**
   - Faces organized by class: `faces/{classname}/portrait.png`
   - Auto-load face when class selected
   - Difficulty variants: `faces/{classname}/difficulty_{1-5}.png`

3. **Separate Card Data Files**
   - Move from single `cards.json` to per-type files
   - `data/cards/fire.json`, `data/cards/holy.json`, etc.
   - Only load data for enabled classes

4. **Script Auto-Discovery**
   - Convention: `scripts/creatures/{cardname}.gd`
   - Auto-load script if file exists
   - No manual registration needed

5. **Class Metadata System**
   - Descriptions, lore, difficulty ratings
   - Unlock requirements
   - Custom properties per class

---

## NEXT STEPS

1. **Review this plan** - Confirm approach is correct
2. **Implement Phase 1** - Create ClassRegistry module
3. **Implement Phase 2** - Rewrite TextureManager
4. **Implement Phase 3** - Update CardImage rendering
5. **Implement Phase 4** - Update all callers
6. **Implement Phase 5** - Cleanup and test
7. **Commit changes** - Incremental commits per phase

---

## QUESTIONS TO RESOLVE

Before starting implementation:

1. **Frame system:** Are frames baked into your 150x150 card images?
   - If YES: Delete ramka*.png files, remove frame overlay code
   - If NO: Keep ramka*.png files, keep frame overlay code

2. **Card naming:** Verify all card names in cards.json match extracted filenames
   - Example: JSON has "GoblinBerserker", file is "goblinberserker.jpg"
   - Code does `card.get_name().to_lower()` to match

3. **Quality setting:** How should users select SD vs HD?
   - Menu option: Settings → Graphics Quality → [SD / HD]
   - Auto-detect: PC defaults HD, Mobile defaults SD
   - Both?

4. **Memory management:** Should we cache all textures or load/unload as needed?
   - Current plan: Cache loaded textures, clear between matches
   - Alternative: Keep all in memory (faster but more RAM)

---

## RESOURCES

### Scripts Created

- `extract_cards.py` - Python script to extract all cards from atlases ✓ COMPLETED
- `extract_cards_from_atlas.gd` - GDScript version (requires Godot CLI)

### Files To Create

- `scripts/data/class_registry.gd` - Class enable/disable control

### Files To Modify

- `scripts/autoload/texture_manager.gd` - Complete rewrite
- `scripts/ui/card_image.gd` - Update texture loading
- `scripts/autoload/card_setup.gd` - Update texture calls
- `scripts/cards.gd` - Remove atlas references
- `scripts/core/specializations.gd` - Add enabled filtering

### Files To Delete (After Migration)

- All atlas .png and .txt files
- Ramka files (if frames baked into cards)
- Atlas extraction folders

---

**Ready to proceed with implementation!**

All cards extracted and organized. Structure ready for HD content when available.
