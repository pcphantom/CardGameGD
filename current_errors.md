# Current Compilation Errors - Priority Fix List

**Last Updated**: 2025-11-09 after sync with main

---

## Critical Errors (Blocking Compilation)

### 1. Missing Autoload File
```
ERROR: Attempt to open script 'res://scripts/autoload/card_database.gd' resulted in error 'File not found'.
```
**Fix**: Create card_database.gd or remove from project.godot autoload

---

### 2. card_setup.gd - Type Errors (8 errors)
```
Line 236, 273: Could not find type "TextureAtlas" in the current scope
Line 247, 283: Could not find type "Sprite" in the current scope
Line 264, 300: Too many arguments for "new()" call. Expected at most 0 but received 2
```
**Fix**:
- TextureAtlas → needs Godot equivalent (AtlasTexture or custom class)
- Sprite → Sprite2D
- Constructor calls need fixing

---

### 3. slot_image.gd - Method Override Conflict
```
Line 70: The function signature doesn't match the parent. Parent signature is "get_index(bool = <default>) -> int"
Line 70: The method "get_index()" overrides a method from native class "Node"
```
**Fix**: Rename get_index() to get_slot_index() or similar to avoid Node built-in conflict

---

### 4. Specializations - Missing Methods (3 errors)
```
single_duel_chooser.gd:138 - Static function "titles()" not found
single_duel_chooser.gd:354 - Static function "from_title_string()" not found
single_duel_chooser.gd:358 - Static function "from_title_string()" not found
```
**Fix**: Add titles() and from_title_string() static methods to Specializations class

---

### 5. action_move_circular.gd - Tween Error
```
Line 171: Function "create_tween()" not found in base self
```
**Fix**: create_tween() is a Node method, ActionMoveCircular may need to extend Node or get tween differently

---

### 6. battle_manager.gd - Member Error
```
Line 113: Could not resolve external class member "get_spell_class"
```
**Fix**: Check Card class for get_spell_class() method

---

### 7. Creature Method Signature Mismatches (Multiple Files)

#### swap_card() - Wrong Signature (10 files)
```
ancient_dragon.gd, basilisk.gd, death_falcon.gd, energy_beast.gd, magic_hamster.gd,
scorpion.gd, white_elephant.gd, wolverine.gd, drain_souls.gd

Expected: swap_card(int)
Called with: swap_card(String, Player, Player, Cards)
```
**Fix**: Check BaseCreature.swap_card() signature in Java source

#### add_creature() - Wrong Signature (7 files)
```
demon_quartermaster.gd, giant_spider.gd, goblin_raider.gd, lemure.gd, phoenix.gd,
three_headed_demon.gd, vampire_elder.gd

Expected: add_creature(slot, creature)
Called with: add_creature(slot, creature, player)
```
**Fix**: Check BaseCreature.add_creature() signature

#### damage_player() - Wrong Signature (4 files)
```
fire_elemental.gd, griffin.gd, sea_sprite.gd, cursed_fog.gd, hypnosis.gd

Expected: damage_player(amount)
Called with: damage_player(amount, player)
```
**Fix**: Check BaseCreature.damage_player() signature

#### Other Method Errors
```
cursed_unicorn.gd:51 - Function "damageSlot()" not found
mindstealer.gd:54 - Function "disposeCardImage()" not found
portal_jumper.gd:20 - Too many arguments for "try_move_to_another_random_slot()"
move_falcon.gd:28 - Too many arguments for "move_card_to_another_slot()"
```

---

### 8. Missing BaseCreature Resolution (4 files)
```
golem_instructor.gd, insanian_shaman.gd, justicar.gd, oracle.gd, orc_chieftain.gd

Parse Error: Could not resolve class "BaseCreature"
```
**Fix**: Check if these files have proper class_name or extends statement

---

### 9. Factory Files - Wrong Type Reference
```
creature_factory.gd:27 - Could not find type "GameController"
spell_factory.gd:27 - Could not find type "GameController"
```
**Fix**: GameController → Cards (correct class name)

---

## Fix Priority Order

1. **HIGH**: Fix card_database.gd (missing file blocking autoload)
2. **HIGH**: Fix Specializations methods (titles, from_title_string)
3. **HIGH**: Fix slot_image.gd get_index() override
4. **HIGH**: Fix factory files GameController → Cards
5. **MEDIUM**: Fix card_setup.gd type errors (TextureAtlas, Sprite)
6. **MEDIUM**: Fix BaseCreature method signatures (swap_card, add_creature, damage_player)
7. **MEDIUM**: Fix action_move_circular.gd create_tween()
8. **LOW**: Fix individual creature method calls (damageSlot, disposeCardImage, etc.)
9. **LOW**: Fix BaseCreature resolution in 4 files

---

## Total Error Count: ~70 errors across 40+ files
