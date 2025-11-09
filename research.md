# Critical Regression Analysis Framework

**Unable to access your local source files**, but here's a systematic approach to diagnose and fix your CardGameGD regression based on the symptoms you described.

## Understanding the core problem

Your "nuclear rewrite" broke three critical systems: **class selection flow, card rendering, and battle initialization**. Based on LibGDX-to-Godot conversion patterns, these failures typically stem from initialization order issues, missing scene connections, or incorrect signal/event wiring.

## 1. Class Selection Flow: Why SingleDuelChooser is Skipped

### What to Check in Your Java Files

**In SingleDuelChooser.java**, look for:
- **How it's instantiated**: Constructor parameters, what data it receives
- **show() method**: What happens when it becomes the active screen
- **Input setup**: How click/touch listeners are registered on character portraits
- **Screen transition**: How it signals completion and passes selected character data

### What Likely Broke in single_duel_chooser.gd

**Common conversion mistakes:**

**Issue #1: Not Added to Scene Tree**
```gdscript
# WRONG - node created but never added
var chooser = preload("res://single_duel_chooser.tscn").instantiate()
chooser.setup()  # This runs but node never renders!

# RIGHT - must add to tree
var chooser = preload("res://single_duel_chooser.tscn").instantiate()
add_child(chooser)  # NOW it will render and process
```

**Issue #2: Signal Connections Missing**
In LibGDX, you probably had:
```java
characterButton.addListener(new ClickListener() {
    public void clicked(InputEvent event, float x, float y) {
        selectCharacter(characterData);
    }
});
```

In Godot, this MUST become:
```gdscript
character_button.pressed.connect(_on_character_selected.bind(character_data))
```

**If these connections aren't made in _ready(), buttons do nothing.**

**Issue #3: Scene Switching Logic**
Check your main_menu.gd button connection:
```gdscript
# When "Single Player" clicked, does it:
single_player_button.pressed.connect(_on_single_player_pressed)

func _on_single_player_pressed():
    # Option A: Switch to chooser scene (CORRECT)
    get_tree().change_scene_to_file("res://scenes/single_duel_chooser.tscn")
    
    # Option B: Skip directly to battle (YOUR BUG)
    get_tree().change_scene_to_file("res://scenes/cards.tscn")  # Skips selection!
```

**The symptom "clicking Single Player skips class selection" means your button is connecting directly to the battle scene instead of the chooser scene.**

### Fix Priority #1: Trace Single Player Button Flow

1. Open `main_menu.gd`
2. Find the Single Player button signal connection
3. **Check what function it calls**
4. **Verify that function loads single_duel_chooser.tscn, NOT cards.tscn**
5. If it correctly loads the chooser scene, check if SingleDuelChooser scene actually contains visible character portraits

## 2. Card Rendering Regression: Why Nothing Displays

### The Initialization Pipeline in LibGDX

Your Java Cards.java likely follows this pattern:
```java
public class Cards implements Screen {
    // Constructor - create objects
    public Cards(GameData gameData) {
        this.gameData = gameData;
    }
    
    // show() - called when screen becomes active
    public void show() {
        // Load textures HERE (after construction)
        loadTextures();
        
        // Create stage and UI
        stage = new Stage();
        
        // Create players with portraits
        player1 = new PlayerImage(playerData1, textures);
        player2 = new PlayerImage(playerData2, textures);
        
        // Add to stage
        stage.addActor(player1);
        stage.addActor(player2);
        
        // Create cards in hand
        createInitialHand();
        
        // Set input processor
        Gdx.input.setInputProcessor(stage);
    }
    
    public void render(float delta) {
        // Update and draw
        stage.act(delta);
        stage.draw();
    }
}
```

### Critical Godot Conversion Issues

**Issue #1: Initialization Order Inversion**

In LibGDX, `create()` runs once, then `show()` runs when screen activates. In Godot:
- `_init()` = constructor
- `_ready()` = **both create() AND show()** combined

**Your cards.gd must do EVERYTHING in _ready():**
```gdscript
func _ready():
    # Load textures (or use preloaded constants)
    texture_manager.initialize()
    
    # Create player portraits
    _setup_players()
    
    # Deal initial cards
    _create_initial_hand()
    
    # Connect signals
    _connect_ui_signals()
```

**If your rewrite split this into multiple functions but didn't call them all from _ready(), nothing initializes.**

**Issue #2: Children Not Added to Scene Tree**

```gdscript
# WRONG - creates card but it never renders
func create_card(card_data):
    var card = card_image.instantiate()
    card.setup(card_data)
    # Missing: add_child(card) ← THIS IS YOUR BUG

# RIGHT
func create_card(card_data):
    var card = card_image.instantiate()
    card.setup(card_data)
    hand_container.add_child(card)  # Now it renders!
```

**Issue #3: Texture Assignment Timing**

In your card_image.gd:
```gdscript
# WRONG - texture not loaded yet
var card_texture = null

func _ready():
    update_visual()  # Tries to use null texture!

func setup(card_data):
    card_texture = texture_manager.get_texture(card_data.id)  # Loads AFTER _ready()

# RIGHT - use proper initialization order
var card_texture = null

func setup(card_data):
    card_texture = texture_manager.get_texture(card_data.id)
    update_visual()  # NOW texture exists

func update_visual():
    if card_texture == null:
        return  # Guard against null
    $Sprite.texture = card_texture
    visible = true  # Must explicitly set visible
```

**Issue #4: Missing visible = true**

**Godot nodes default to visible=true, BUT if your rewrite explicitly set visible=false somewhere (like during initialization to prevent flicker), you must set it back to true.**

Check every visual node for:
```gdscript
# Ensure this is set after setup completes
visible = true
show()  # Alternative method
```

### Fix Priority #2: Card Rendering Checklist

**In cards.gd (_ready method), verify this EXACT order:**
1. Initialize texture_manager
2. Create player portraits and add them with `add_child()`
3. Create card instances and add them with `add_child()`
4. Call setup() on each card BEFORE adding to tree
5. Verify all sprite nodes have `.visible = true`

**In card_image.gd (or wherever cards are defined):**
1. Don't call `update_visual()` in `_ready()` - textures not loaded yet
2. Call `update_visual()` in `setup()` AFTER assigning texture
3. Add null check in `update_visual()`: `if card_texture == null: return`
4. Explicitly set `visible = true` at end of setup
5. Check if parent nodes are visible (a hidden parent hides all children)

## 3. Battle Screen Initialization: Exact Sequence Documentation

### Reverse-Engineering Your Java Flow

To fix your Godot version, you need to document your Java Cards.java initialization in this format:

**Cards.java Initialization Sequence:**
```
Constructor:
- Store references to game data
- Initialize variables
- DO NOT load assets yet

show():
1. Load textures via TextureManager/AssetManager
2. Create Stage with viewport
3. Create background (if any)
4. Create player1 portrait at position X,Y
5. Create player2 portrait at position X,Y
6. Create hand containers
7. Deal initial cards (3-7 cards typically)
8. Create card collection panel
9. Add all actors to stage
10. Set stage as input processor

render():
- Update stage: stage.act(delta)
- Draw stage: stage.draw()
```

### Mapping to Godot cards.gd

Your `_ready()` must replicate the entire `show()` sequence:

```gdscript
func _ready():
    # Step 1: Textures
    TextureManager.load_all()  # Or use preload constants
    
    # Step 2-3: Background (should be in scene already)
    # If created programmatically:
    var bg = Sprite2D.new()
    bg.texture = preload("res://assets/battle_bg.png")
    bg.z_index = -10  # Behind everything
    add_child(bg)
    
    # Step 4-5: Player portraits
    var player1_portrait = preload("res://scenes/player_image.tscn").instantiate()
    player1_portrait.setup(player1_data)
    player1_portrait.position = Vector2(100, 200)
    add_child(player1_portrait)
    
    var player2_portrait = preload("res://scenes/player_image.tscn").instantiate()
    player2_portrait.setup(player2_data)
    player2_portrait.position = Vector2(700, 200)
    add_child(player2_portrait)
    
    # Step 6-7: Hand
    for i in range(5):
        var card = preload("res://scenes/card_image.tscn").instantiate()
        card.setup(deck.draw())
        card.position = Vector2(100 + i * 120, 500)
        hand_container.add_child(card)
    
    # Step 8: Card collection
    card_collection_panel = preload("res://scenes/collection_panel.tscn").instantiate()
    add_child(card_collection_panel)
```

**CRITICAL: Every instantiate() MUST be followed by add_child() or it won't render.**

## 4. Specific File Comparison Strategy

Since I can't access your files, here's how YOU should compare them:

### For SingleDuelChooser.java vs single_duel_chooser.gd

**Create a comparison document:**

| Java Method | What It Does | GDScript Equivalent | Status |
|------------|--------------|---------------------|---------|
| Constructor | Stores game data | _init() or _ready() | ✓/✗ |
| show() | Makes screen visible, loads assets | _ready() | ✓/✗ |
| setupCharacterButtons() | Creates clickable portraits | _setup_buttons() | ✓/✗ |
| onClick(portrait) | Handles selection | _on_portrait_pressed(portrait) | ✓/✗ |
| switchToBattle(char) | Transitions to battle | get_tree().change_scene_to_file() | ✓/✗ |

**For each row marked ✗, that's a missing feature causing your bug.**

### For Cards.java vs cards.gd

| Java Method | What It Does | GDScript Equivalent | Status |
|------------|--------------|---------------------|---------|
| Constructor | Init variables | _init() | ✓/✗ |
| show() | Full initialization | _ready() | ✓/✗ |
| loadTextures() | Asset loading | TextureManager or preload() | ✓/✗ |
| createPlayers() | Player portraits | _setup_players() | ✓/✗ |
| dealInitialHand() | Create hand cards | _create_hand() | ✓/✗ |
| render(delta) | Update and draw | _process(delta) | ✓/✗ |

### For CardImage.java vs card_image.gd

| Java Method | What It Does | GDScript Equivalent | Status |
|------------|--------------|---------------------|---------|
| Constructor | Create sprite | _init() or _ready() | ✓/✗ |
| setTexture(tex) | Assign artwork | setup() | ✓/✗ |
| setPosition(x,y) | Set location | position = Vector2() | ✓/✗ |
| draw(batch) | Render (automatic in LibGDX Stage) | Automatic in Godot | ✓ |
| addListener() | Click handling | pressed.connect() | ✓/✗ |

## 5. Root Cause Identification: The "Nuclear Rewrite" Problems

Based on the symptoms, here are the likely root causes:

### Root Cause #1: Incomplete _ready() Implementation
**Symptom**: Empty battle screen, no cards
**Cause**: Your rewrite created helper functions but didn't call them all from `_ready()`
**Fix**: Ensure `_ready()` calls every initialization function in correct order

### Root Cause #2: Missing add_child() Calls
**Symptom**: No visual elements at all
**Cause**: Nodes instantiated but never added to scene tree
**Fix**: Add `add_child(node)` after every `instantiate()`

### Root Cause #3: Broken Scene Flow
**Symptom**: Class selection skipped
**Cause**: Main menu button connects to wrong scene
**Fix**: Verify button signal connections in main_menu.gd

### Root Cause #4: Texture Loading Order
**Symptom**: Card frames visible but no artwork
**Cause**: `update_visual()` called before textures loaded
**Fix**: Move `update_visual()` call to after texture assignment in `setup()`

### Root Cause #5: Visibility Flags
**Symptom**: Everything else works but nothing visible
**Cause**: `visible = false` set during init and never reset
**Fix**: Set `visible = true` at end of setup functions

### Root Cause #6: Signal Disconnections
**Symptom**: UI present but non-interactive
**Cause**: Button signals not connected after rewrite
**Fix**: Add `.pressed.connect()` calls in `_ready()`

## 6. Step-by-Step Fix Recommendations (Priority Order)

### Phase 1: Restore Scene Flow (30 minutes)
1. **Open main_menu.gd**
2. **Find Single Player button signal connection**
3. **Change scene path from cards.tscn to single_duel_chooser.tscn**
4. **Open single_duel_chooser.gd**
5. **In _ready(), verify character portraits are created and added with add_child()**
6. **Connect each portrait button to selection handler**
7. **Test**: Single Player should now show character selection

### Phase 2: Fix Card Rendering (1 hour)
1. **Open cards.gd**
2. **In _ready(), add debug prints at each step:**
   ```gdscript
   func _ready():
       print("Cards _ready() START")
       print("Loading textures...")
       TextureManager.initialize()
       print("Creating players...")
       _setup_players()
       print("Creating hand...")
       _create_initial_hand()
       print("Cards _ready() END")
   ```
3. **Run and check console - which prints appear?**
4. **For missing steps, check if function exists and is being called**
5. **Open card_image.gd**
6. **Move update_visual() call from _ready() to end of setup()**
7. **Add visible = true at end of setup()**
8. **Test**: Cards should now appear

### Phase 3: Verify Player Portraits (30 minutes)
1. **Open player_image.gd**
2. **Check _ready() initializes sprite nodes**
3. **Verify setup() assigns textures**
4. **Ensure node is added to parent with add_child()**
5. **Set visible = true**
6. **Test**: Player portraits should appear

### Phase 4: Full Battle Initialization (1 hour)
1. **Compare your Java Cards.java show() method line by line**
2. **For each line that creates or adds something, find equivalent in cards.gd**
3. **Add any missing initialization steps to _ready()**
4. **Verify correct order matches Java**
5. **Test**: Full battle screen should work

## 7. Debugging Commands to Run

**To see what's in your scene tree while game runs:**
```gdscript
# Add to cards.gd _ready():
print_tree_pretty()  # Shows entire scene hierarchy
print("Children count: ", get_child_count())
for child in get_children():
    print("Child: ", child.name, " visible: ", child.visible)
```

**To verify textures loaded:**
```gdscript
# Add to texture_manager.gd or cards.gd:
print("Card texture loaded: ", card_texture != null)
if card_texture:
    print("Texture size: ", card_texture.get_size())
```

**To check signal connections:**
```gdscript
# Add after connecting signals:
print("Button connected: ", button.is_connected("pressed", _on_button_pressed))
```

**To see node positions:**
```gdscript
# Add to any visual node:
print("Node position: ", global_position)
print("In viewport: ", get_viewport_rect().has_point(global_position))
```

## 8. Common "Nuclear Rewrite" Mistakes

Your symptoms match these typical rewrite errors:

**Mistake #1: Over-modularization**
- Split code into many functions
- Forgot to call them all from _ready()
- **Fix**: Create checklist of all functions, verify each called

**Mistake #2: Assuming automatic behavior**
- LibGDX Stage automatically draws added Actors
- Godot requires explicit add_child() for rendering
- **Fix**: Add add_child() after every instantiate()

**Mistake #3: Breaking signal connections**
- Removed or renamed functions
- Signals now connect to non-existent methods
- **Fix**: Search for .connect() calls, verify target functions exist

**Mistake #4: Changing initialization order**
- Moved texture loading after usage
- Called update_visual() before setup()
- **Fix**: Trace data dependencies, restore correct order

**Mistake #5: Incomplete conversion**
- Converted some files, left others using old API
- Mixed old and new initialization patterns
- **Fix**: Ensure all files use same initialization pattern

## 9. Quick Diagnostic Test

**Add this to your cards.gd to diagnose the issue:**

```gdscript
func _ready():
    print("=== CARDS DIAGNOSTIC START ===")
    
    # Test 1: Scene tree
    print("In scene tree: ", is_inside_tree())
    print("Children count: ", get_child_count())
    
    # Test 2: Texture manager
    print("TextureManager exists: ", TextureManager != null)
    
    # Test 3: Create test sprite
    var test_sprite = Sprite2D.new()
    test_sprite.texture = preload("res://icon.png")  # Use Godot default icon
    test_sprite.position = Vector2(400, 300)
    test_sprite.scale = Vector2(2, 2)
    add_child(test_sprite)
    print("Test sprite added: ", test_sprite.is_inside_tree())
    print("Test sprite visible: ", test_sprite.visible)
    
    # Test 4: Run your initialization
    _initialize_battle()
    
    # Test 5: Check results
    print("Player1 exists: ", $Player1 != null if has_node("Player1") else false)
    print("Hand container children: ", $HandContainer.get_child_count() if has_node("HandContainer") else 0)
    
    print("=== CARDS DIAGNOSTIC END ===")
```

**If test sprite appears but your cards don't, the problem is in your card creation code.**
**If nothing appears, the problem is scene setup or visibility.**

## Summary: Most Likely Issues

Based on your symptoms, check these in order:

1. **Class selection skipped**: Main menu button connects to wrong scene (cards.tscn instead of single_duel_chooser.tscn)
2. **No cards visible**: Cards instantiated but never added with `add_child()`
3. **No textures**: `update_visual()` called before textures assigned in `setup()`
4. **Everything invisible**: `visible = false` set and never changed to `true`
5. **Wrong background**: Scene root background different from expected

**The fact that it worked before the rewrite means the logic is correct - you just broke the initialization sequence, scene connections, or forgot add_child() calls during the refactor.**

Follow the Phase 1-4 fixes above in order, and you should systematically restore functionality. The key is ensuring `_ready()` does EVERYTHING that LibGDX's `show()` method did, in the exact same order, with explicit `add_child()` calls for every visual node.