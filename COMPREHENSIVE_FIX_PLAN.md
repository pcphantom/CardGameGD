# COMPREHENSIVE FIX PLAN - CardGameGD UI & Gameplay
**Created**: 2025-11-09
**Priority**: CRITICAL - UI MUST MATCH ORIGINAL GAME EXACTLY

---

## PHASE 1: UI RESTORATION (IMMEDIATE PRIORITY)

### Objective
Make the UI EXACTLY match the original Java game in every way:
- Same buttons in same positions
- Same behavior when clicked
- Same visual appearance
- Same game flow

### Current Problem
main.tscn had duplicate/conflicting hardcoded UI elements that were replaced by programmatic UI creation. **FIXED**: Cleaned main.tscn to only have Main node + cards.gd script.

### UI Elements That Must Match Original (From Cards.java)

#### 1. Player Panels
**Java (Cards.java:144-145)**:
```java
player = new PlayerImage(null, portraitramka, greenfont, new Player(), 80, ydown(300));
opponent = new PlayerImage(null, portraitramka, greenfont, new Player(), 80, ydown(125));
```

**Current GDScript Implementation** (player_image.gd):
- ✅ Panel positioned correctly
- ✅ Portrait rendering
- ✅ Life/strength labels
- ⚠️ **VERIFY**: Panel is created programmatically in cards.gd

**Action Required**:
1. Verify PlayerImage instances are added to scene tree in cards.gd
2. Confirm positioning matches Java coordinates exactly (already fixed: 300 and 125 from top)
3. Test that panels render with portraits and stats

#### 2. Board Slots
**Java (Cards.java:255-256)**:
```java
addSlotImages(opponent, 330, ydown(170), false);  // Opponent slots at Y=170
addSlotImages(player, 330, ydown(290), true);    // Player slots at Y=290
```

**Current GDScript Implementation** (player_image.gd:208):
```gdscript
var slot_x_positions: Array[float] = [330.0, 427.0, 524.0, 621.0, 718.0, 815.0]
var slots_y: float = SLOTS_Y_LOCAL if is_local_player else SLOTS_Y_OPPONENT
# SLOTS_Y_LOCAL = 290.0, SLOTS_Y_OPPONENT = 170.0
```

**Action Required**:
1. ✅ Coordinates already corrected
2. Verify SlotImage nodes render with correct textures
3. Test slot click handling

#### 3. End Turn Button
**Java (Cards.java:205)**:
```java
skipTurnButton.setBounds(10, ydown(110), 50, 50);
```

**Current GDScript Implementation** (cards.gd:129-130):
```gdscript
end_turn_button.position = Vector2(10, 110)
end_turn_button.size = Vector2(50, 50)
```

**Action Required**:
1. ✅ Position/size already corrected
2. **ADD**: Button texture from endturnbutton.png (Java line 163)
3. Test button press behavior
4. Verify button enables/disables based on turn state

#### 4. Log Panel
**Java (Cards.java:242)**:
```java
logScrollPane.setBounds(24, 36, 451, 173);
```

**Current GDScript Implementation** (cards.gd:138-139):
```gdscript
log_panel.position = Vector2(24, 36)
log_panel.custom_minimum_size = Vector2(451, 173)
```

**Action Required**:
1. ✅ Position/size already corrected
2. Test log message display
3. Verify scrolling behavior
4. Test color coding (COLOR_NORMAL, COLOR_DAMAGE, COLOR_GAME_OVER)

#### 5. Card Hand Positions
**Java (Cards.java:396)**:
```java
int y = ydown(328);  // Hand cards at Y=328 from top
```

**Current GDScript Implementation** (player_image.gd:31):
```gdscript
const HAND_Y_LOCAL: float = 328.0
```

**Action Required**:
1. ✅ Position already corrected
2. Verify cards render in hand
3. Test card spacing (HAND_CARD_SPACING = 130.0)
4. Test card click/drag behavior

#### 6. Shuffle/Show Opponent Cards Buttons
**Java (Cards.java:191, 219)**:
```java
showOpptCardsButton.setBounds(10, ydown(50), 50, 50);    // Y=718 from bottom = 50 from top
shuffleCardsButton.setBounds(10, ydown(170), 50, 50);   // Y=598 from bottom = 170 from top
```

**Action Required**:
1. ❌ **NOT IMPLEMENTED** in current cards.gd
2. Create showOpptCardsButton at (10, 718) - opens OpponentCardWindow
3. Create shuffleCardsButton at (10, 598) - for debugging/testing
4. Add button textures and click handlers

#### 7. Strength Labels (Element Icons)
**Java (Cards.java:222-236)**:
```java
// Player strength labels
int y = ydown(337);  // Y=431 from bottom = 337 from top
for (int i = 0; i < 5; i++) {
    bottomStrengthLabels[i].setPosition(x += incr, y);  // x starts at 523, incr=103
}

// Opponent strength labels
y = ydown(25);  // Y=743 from bottom = 25 from top
for (int i = 0; i < 5; i++) {
    topStrengthLabels[i].setPosition(x += incr, y);  // x starts at 523, incr=103
}
```

**Action Required**:
1. ❌ **NOT IMPLEMENTED** - these should be separate from player panels
2. Create 10 labels (5 top, 5 bottom) at exact positions
3. Display strength for: FIRE, AIR, WATER, EARTH, player.getPlayerClass().getType()
4. Update on player stat changes

#### 8. Player Info Labels
**Java (Cards.java:159-160)**:
```java
playerInfoLabel.setPosition(80 + 10 + 120, ydown(300));  // (210, 468)
opptInfoLabel.setPosition(80 + 10 + 120, ydown(30));     // (210, 738)
```

**Action Required**:
1. ⚠️ **VERIFY** these are in player panels or separate
2. Display: "Cleric Life: 100" format
3. Update when life/class changes

#### 9. Card Description Image (Hover Preview)
**Java (Cards.java:238)**:
```java
cdi = new CardDescriptionImage(20, ydown(512));  // (20, 256)
```

**Action Required**:
1. ✅ card_description_image.gd exists (from merge)
2. Instantiate at position (20, 256)
3. Show/hide on card hover
4. Display large card artwork + stats

---

## PHASE 2: GAME FLOW FIX

### Current Problem
SingleDuelChooser (class selection) is being skipped - game goes directly to battle.

### Action Required

#### 1. Verify SingleDuelChooser Scene
**File**: `scenes/ui/single_duel_chooser.tscn` (may not exist)

**Action**:
1. Check if scene file exists
2. If not, create scene with SingleDuelChooser script
3. Populate with character portraits (6 classes from Specializations)
4. Position character buttons in grid layout matching Java

#### 2. Fix Main Menu Flow
**File**: `scripts/ui/main_menu.gd`

**Current (WRONG)**:
```gdscript
# Probably goes directly to cards.tscn
get_tree().change_scene_to_file("res://scenes/main.tscn")
```

**Must Be**:
```gdscript
# Single Player button should go to class selection
func _on_single_player_pressed():
    get_tree().change_scene_to_file("res://scenes/ui/single_duel_chooser.tscn")

# After class selection completes, THEN go to main.tscn
func _on_classes_selected(player_class, opponent_class):
    # Store selected classes
    GameManager.player_class = player_class
    GameManager.opponent_class = opponent_class
    get_tree().change_scene_to_file("res://scenes/main.tscn")
```

#### 3. Verify OpponentCardWindow
**Java (Cards.java:176)**:
Shows opponent's cards when showOpptCardsButton clicked.

**Action**:
1. ✅ opponent_card_window.gd exists (from merge)
2. Create scene or instantiate programmatically
3. Display opponent's hand cards in grid
4. Add close button (X)

---

## PHASE 3: COMPILATION ERROR FIXES

### From current_errors.md - Priority Order

#### P1: Critical Blocking Errors

1. **card_database.gd missing** (autoload file)
   - Create empty stub or remove from project.godot autoload

2. **Specializations missing methods**
   - Add `titles()` static method
   - Add `from_title_string()` static method

3. **slot_image.gd get_index() conflict**
   - Rename to `get_slot_index()` throughout codebase

4. **Factory files wrong type reference**
   - creature_factory.gd: GameController → Cards
   - spell_factory.gd: GameController → Cards

#### P2: Medium Priority

5. **card_setup.gd type errors**
   - TextureAtlas → Godot equivalent (use TextureManager)
   - Sprite → Sprite2D
   - Fix constructor calls

6. **BaseCreature method signatures**
   - Verify swap_card() signature
   - Verify add_creature() signature
   - Verify damage_player() signature
   - Update all creature files to match

7. **action_move_circular.gd tween error**
   - Must extend Node to use create_tween()
   - Or pass Node reference in constructor

#### P3: Low Priority

8. **Individual creature method calls**
   - cursed_unicorn.gd: damageSlot() → damage_slot()
   - mindstealer.gd: disposeCardImage() → dispose_card_image()
   - portal_jumper.gd: fix try_move_to_another_random_slot() args
   - move_falcon.gd: fix move_card_to_another_slot() args

9. **BaseCreature resolution** in 4 files
   - Verify class_name/extends statements

---

## PHASE 4: TESTING CHECKLIST

### UI Visual Test
- [ ] Background image renders
- [ ] Player panel at (80, 300) with portrait, life, stats
- [ ] Opponent panel at (80, 125) with portrait, life, stats
- [ ] 6 player slots at Y=290, X=[330, 427, 524, 621, 718, 815]
- [ ] 6 opponent slots at Y=170, X=[330, 427, 524, 621, 718, 815]
- [ ] End Turn button at (10, 110) size 50x50
- [ ] Log panel at (24, 36) size 451x173
- [ ] Strength labels for both players (5 each)
- [ ] Card hand displays at Y=328 for player

### Interaction Test
- [ ] Click End Turn button → turn advances
- [ ] Click card in hand → highlights valid targets
- [ ] Click slot → plays card / attacks
- [ ] Hover over card → shows card description
- [ ] Log displays game events with correct colors

### Game Flow Test
- [ ] Main menu → Single Player → Class Selection screen appears
- [ ] Select player class → Select opponent class → Game starts
- [ ] Game initializes with correct decks for both players
- [ ] Cards draw properly
- [ ] Turn system works (player → opponent → player)

### Battle Test
- [ ] Play creature card → appears in slot
- [ ] Play spell card → effect executes
- [ ] Attack with creature → deals damage
- [ ] Creature abilities trigger correctly
- [ ] Life decreases when damaged
- [ ] Game Over screen when life reaches 0

---

## EXECUTION ORDER

### IMMEDIATE (Today)
1. ✅ Clean main.tscn (DONE)
2. Verify cards.gd creates all UI programmatically
3. Fix end turn button texture
4. Add missing buttons (showOpptCardsButton, shuffleCardsButton)
5. Add strength labels
6. Add card description image hover

### NEXT (Priority)
7. Fix compilation errors (P1 list above)
8. Create/fix SingleDuelChooser scene
9. Fix main menu flow

### THEN (Verification)
10. Test all UI elements render correctly
11. Test all interactions work
12. Test complete game flow
13. Fix any remaining issues

---

## SUCCESS CRITERIA

**The UI is correct when:**
1. Every button, label, and panel is in the EXACT same position as the Java game
2. All buttons do the same thing when clicked as the Java game
3. The game flow from main menu → class selection → battle matches the Java game
4. Cards render with artwork and are playable
5. The battle system works identically to the Java game

**NO EXCUSES. NO APPROXIMATIONS. EXACT MATCH.**
