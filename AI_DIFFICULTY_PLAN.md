# AI Difficulty System Plan
## Progressive Intelligence & Deck Optimization for Elemental Aces

**Status:** Planning Phase - No Implementation Yet
**Date:** 2025-11-15

---

## OVERVIEW

This document outlines the plan to implement tiered AI difficulty levels, from the current random behavior (Novice) up to strategic, optimized opponents (Grandmaster). Each tier improves decision-making quality and may include deck advantages.

---

## CURRENT AI STATE (NOVICE BASELINE)

### What the AI Does Now

**Card Selection:** Pure random from enabled cards
```gdscript
# battle_round_thread.gd:139
oppt_pick = oi.pickRandomEnabledCard()  # Shuffles types, picks random card
```

**Slot Placement:** Pure random open slot
```gdscript
# battle_round_thread.gd:361
slot_index = randi() % 6  # Random slot 0-5
```

**Spell Targeting:** Pure random enemy creature
```gdscript
# base_functions.gd:163
random_index = randi() % valid_targets.size()
```

**Attack Strategy:** Always attack with everything, directly across
```gdscript
# base_creature.gd:132
# Attacks whatever is directly opposite, or player if empty
```

**Resource Management:** None - plays first affordable card found

**Board Evaluation:** None

**Planning:** None - no look-ahead, no strategy

---

## DIFFICULTY TIER STRUCTURE

### NOVICE (Current Behavior)
**Skill Level:** Beginner
**Intelligence:** None (pure random)
**Deck:** Standard random 20-card deck (4 of each element)
**Behavior:** Current implementation - no changes needed

**Characteristics:**
- ✓ Random card selection from affordable cards
- ✓ Random slot placement
- ✓ Random spell targeting
- ✓ Always attacks
- ✓ No strategic thinking
- ✓ Easy to beat for learning players

**Win Rate Target:** ~20-30% against average player

---

### EXPERT
**Skill Level:** Intermediate
**Intelligence:** Basic heuristics
**Deck:** Standard deck OR focused deck (player chooses)
**Behavior:** Uses simple evaluation criteria

**Decision Improvements:**

**1. Card Selection - Prioritize High Value**
```gdscript
# Use existing pick_best_enabled_card() function
# Plays highest-cost affordable card
oppt_pick = oi.pick_best_enabled_card()
```

**Logic:** Higher cost = more powerful card (generally true)

**2. Spell Targeting - Kill Biggest Threats**
```gdscript
# Use existing get_highest_attack_enemy() function
if spell.needs_target():
    target = get_highest_attack_enemy()  # Kill strongest creature first
```

**Logic:** Remove opponent's most dangerous creatures

**3. Slot Placement - Adjacent Synergies**
```gdscript
# Check for adjacent-buff creatures (Orc Chieftain, etc.)
# Place next to creatures that benefit from adjacency
slot = find_synergy_slot(card_to_play)
```

**Logic:** Some creatures buff adjacent allies - place strategically

**4. Attack Decisions - Avoid Suicidal Attacks**
```gdscript
# Before attacking, check if creature will die
if my_creature.life <= enemy_creature.attack and my_creature.attack < enemy_creature.life:
    skip_attack()  # Don't suicide for no gain
```

**Logic:** Don't throw away creatures pointlessly

**5. Resource Awareness - Save for Big Plays**
```gdscript
# If strength is high enough for expensive card, maybe save
if current_strength >= 8 and best_card_cost < 5:
    consider_passing_turn()  # Save for better card next turn
```

**Logic:** Basic tempo management

**Deck Options:**
- **Standard:** Same 4×5 random deck
- **Focused:** 8 cards of class type + 4 Fire + 4 Air + 4 Water (no Earth)
  - More consistent, slightly stronger

**Win Rate Target:** ~40-50% against average player

---

### MASTER
**Skill Level:** Advanced
**Intelligence:** Multi-factor evaluation
**Deck:** Optimized synergy deck
**Behavior:** Strategic board evaluation

**Decision Improvements:**

**1. Board State Evaluation**
```gdscript
# Evaluate multiple factors before each decision
func evaluate_board_state(my_board, enemy_board) -> float:
    var score = 0.0

    # Factor 1: Life difference
    score += (my_life - enemy_life) * 2.0

    # Factor 2: Board presence (creature count)
    score += (my_creatures - enemy_creatures) * 10.0

    # Factor 3: Board strength (total attack)
    score += (my_total_attack - enemy_total_attack) * 5.0

    # Factor 4: Card advantage (cards in hand)
    score += (my_hand_size - enemy_hand_size) * 8.0

    # Factor 5: Resource advantage
    score += (my_total_strength - enemy_total_strength) * 3.0

    # Factor 6: Threat assessment
    score -= evaluate_immediate_threats(enemy_board) * 15.0

    return score
```

**2. Card Selection - Simulate All Options**
```gdscript
func pick_best_card_master(player, opponent) -> CardImage:
    var best_card = null
    var best_score = -999999.0

    for type in Player.TYPES:
        for card in player.get_cards(type):
            if not card.is_enabled():
                continue

            # Simulate playing this card
            var sim_player = player.cloneForEvaluation()
            var sim_opponent = opponent.cloneForEvaluation()

            # Play card in simulation
            simulate_card_play(sim_player, sim_opponent, card)

            # Evaluate resulting board state
            var score = evaluate_board_state(sim_player, sim_opponent)

            if score > best_score:
                best_score = score
                best_card = card

    return best_card
```

**Logic:** Try every possible card, pick the one leading to best board state

**3. Threat Prioritization**
```gdscript
func evaluate_immediate_threats(enemy_board) -> float:
    var threat_level = 0.0

    for enemy in enemy_board:
        # High attack = dangerous
        threat_level += enemy.attack * 2.0

        # Special abilities = extra dangerous
        if enemy.has_ability("flying"):
            threat_level += 10.0
        if enemy.has_ability("first_strike"):
            threat_level += 15.0

        # Low life = easy to kill (remove from threat)
        if enemy.life <= 3:
            threat_level -= 5.0

    return threat_level
```

**4. Defensive Play**
```gdscript
# Don't attack if it leaves me vulnerable
if my_life < 20 and enemy_can_lethal_next_turn():
    keep_blockers()  # Don't attack with everything
```

**5. Combo Recognition**
```gdscript
# Recognize card synergies
# Example: Save Wrath of God if board is losing
# Example: Set up sacrifice combos (Altar of Sacrifice + creatures)
if has_combo_available(hand):
    setup_combo()
else:
    play_normal_card()
```

**Deck Optimization:**
**Synergy Deck** - Handpicked cards that work together
- 8 class cards (all the same type for consistency)
- 4 Fire (aggressive creatures)
- 4 Water (control spells)
- 4 Air (removal spells)
- **No random selection** - specific strong cards chosen

Example Cleric deck:
```
HOLY (8):
- 2× Paladin (strong creature)
- 2× Holy Guard (defensive)
- 2× Wrath of God (board clear)
- 2× Divine Intervention (protection)

FIRE (4):
- 2× Dragon (finisher)
- 2× Armageddon (board clear)

WATER (4):
- 2× Meditation (card draw)
- 2× Mind Master (control)

AIR (4):
- 2× Lightning Bolt (removal)
- 2× Chain Lightning (removal)
```

**Win Rate Target:** ~60-70% against average player

---

### GRANDMASTER
**Skill Level:** Expert
**Intelligence:** Multi-turn planning with lookahead
**Deck:** Perfectly optimized meta deck
**Behavior:** Near-optimal play

**Decision Improvements:**

**1. Minimax Lookahead (2-3 turns)**
```gdscript
func minimax_search(player, opponent, depth: int, is_maximizing: bool) -> float:
    # Base case: evaluate current state
    if depth == 0:
        return evaluate_board_state(player, opponent)

    if is_maximizing:  # AI's turn
        var max_eval = -999999.0

        # Try all possible moves
        for card in player.get_enabled_cards():
            for slot in get_valid_slots():
                # Simulate move
                var sim_player = player.cloneForEvaluation()
                var sim_opponent = opponent.cloneForEvaluation()
                simulate_move(sim_player, sim_opponent, card, slot)

                # Recurse
                var eval = minimax_search(sim_player, sim_opponent, depth - 1, false)
                max_eval = max(max_eval, eval)

        return max_eval

    else:  # Opponent's turn (assume they play optimally too)
        var min_eval = 999999.0

        # Try all opponent's possible moves
        for card in opponent.get_enabled_cards():
            for slot in get_valid_slots():
                var sim_player = player.cloneForEvaluation()
                var sim_opponent = opponent.cloneForEvaluation()
                simulate_move(sim_opponent, sim_player, card, slot)

                var eval = minimax_search(sim_player, sim_opponent, depth - 1, true)
                min_eval = min(min_eval, eval)

        return min_eval
```

**Logic:** Assumes both players play perfectly, plans 2-3 turns ahead

**2. Opening Strategy**
```gdscript
# First few turns have specific strategies
if turn_number <= 3:
    follow_opening_book()  # Pre-planned opening moves
else:
    use_minimax()
```

**3. Win Condition Recognition**
```gdscript
# Identify when we can win and go for it
if can_win_in_N_turns(2):
    execute_winning_line()  # Aggressive push for victory
elif opponent_can_win_in_N_turns(2):
    execute_defensive_line()  # Desperately survive
else:
    play_value_maximizing_move()  # Normal play
```

**4. Perfect Resource Curves**
```gdscript
# Plan resource expenditure across multiple turns
# Turn 1: Play 1-cost
# Turn 2: Play 2-cost (total strength = 2)
# Turn 3: Play 3-cost (total strength = 3)
# Etc.
plan_resource_curve(10)  # Plan next 10 turns
```

**5. Card Draw Optimization**
```gdscript
# Meditation and similar cards = card advantage
# Calculate expected value of drawing cards
if card_draw_value() > direct_damage_value():
    play_meditation()  # Long-term value
else:
    play_fireball()  # Immediate impact
```

**Deck Optimization:**
**Meta Deck** - The absolute strongest possible deck

Characteristics:
- **No weak cards** - every card is tier 1
- **Perfect curve** - costs from 1 to 8+, no gaps
- **Multiple win conditions** - aggro AND control
- **Answers to everything** - removal, healing, counters
- **Maximum synergy** - every card combos with others

Example Grandmaster Cleric deck:
```
HOLY (8):
- 2× Archangel (huge threat)
- 2× Wrath of God (reset button)
- 2× Divine Intervention (protection)
- 2× Crusader (efficient beater)

FIRE (4):
- 2× Dragon (finisher)
- 2× Armageddon (total board wipe)

WATER (4):
- 2× Mind Master (steal creatures)
- 2× Meditation (card advantage)

AIR (4):
- 2× Phoenix (unkillable)
- 2× Chain Lightning (multi-target removal)
```

**Behavioral Additions:**
- **Bluffing:** Sometimes holds back strong cards to bait opponent
- **Baiting:** Plays weak creatures to tempt opponent into bad trades
- **Psychology:** Varies play patterns to be unpredictable

**Win Rate Target:** ~80-90% against average player

---

## IMPLEMENTATION ARCHITECTURE

### New Files to Create

**1. Core AI System**
**File:** `scripts/ai/ai_difficulty.gd`
```gdscript
class_name AIDifficulty
extends RefCounted

enum Level {
    NOVICE,
    EXPERT,
    MASTER,
    GRANDMASTER
}

static var current_level: Level = Level.NOVICE

# Settings per difficulty
static var difficulty_settings = {
    Level.NOVICE: {
        "use_random_selection": true,
        "use_random_targeting": true,
        "use_random_slots": true,
        "evaluate_board": false,
        "plan_ahead_turns": 0,
        "deck_type": "random"
    },
    Level.EXPERT: {
        "use_random_selection": false,
        "use_random_targeting": false,
        "use_random_slots": false,
        "evaluate_board": true,
        "plan_ahead_turns": 0,
        "deck_type": "focused"
    },
    Level.MASTER: {
        "use_random_selection": false,
        "use_random_targeting": false,
        "use_random_slots": false,
        "evaluate_board": true,
        "plan_ahead_turns": 1,
        "deck_type": "synergy"
    },
    Level.GRANDMASTER: {
        "use_random_selection": false,
        "use_random_targeting": false,
        "use_random_slots": false,
        "evaluate_board": true,
        "plan_ahead_turns": 2,
        "deck_type": "meta"
    }
}

static func get_setting(key: String):
    return difficulty_settings[current_level][key]
```

**2. Board Evaluation**
**File:** `scripts/ai/board_evaluator.gd`
```gdscript
class_name BoardEvaluator
extends RefCounted

# Multi-factor board evaluation
static func evaluate(my_player: Player, enemy_player: Player) -> float:
    var score = 0.0

    # Life differential
    score += (my_player.get_life() - enemy_player.get_life()) * 2.0

    # Board presence
    var my_creatures = count_creatures(my_player)
    var enemy_creatures = count_creatures(enemy_player)
    score += (my_creatures - enemy_creatures) * 10.0

    # Attack potential
    var my_attack = total_attack(my_player)
    var enemy_attack = total_attack(enemy_player)
    score += (my_attack - enemy_attack) * 5.0

    # Card advantage
    var my_cards = count_cards_in_hand(my_player)
    var enemy_cards = count_cards_in_hand(enemy_player)
    score += (my_cards - enemy_cards) * 8.0

    # Resource advantage
    var my_resources = total_strength(my_player)
    var enemy_resources = total_strength(enemy_player)
    score += (my_resources - enemy_resources) * 3.0

    # Immediate threats
    score -= evaluate_threats(enemy_player) * 15.0

    return score

static func count_creatures(player: Player) -> int:
    # Count occupied slots

static func total_attack(player: Player) -> int:
    # Sum attack of all creatures

# ... etc
```

**3. Card Selector**
**File:** `scripts/ai/card_selector.gd`
```gdscript
class_name CardSelector
extends RefCounted

static func select_card(player: Player, opponent: Player) -> CardImage:
    var level = AIDifficulty.current_level

    match level:
        AIDifficulty.Level.NOVICE:
            return select_random(player)

        AIDifficulty.Level.EXPERT:
            return select_highest_cost(player)

        AIDifficulty.Level.MASTER:
            return select_best_evaluated(player, opponent, 0)

        AIDifficulty.Level.GRANDMASTER:
            return select_best_evaluated(player, opponent, 2)

    return null

static func select_random(player: Player) -> CardImage:
    return player.pickRandomEnabledCard()

static func select_highest_cost(player: Player) -> CardImage:
    return player.pick_best_enabled_card()

static func select_best_evaluated(player: Player, opponent: Player, lookahead: int) -> CardImage:
    # Try all possible cards, evaluate resulting positions
    var best_card = null
    var best_score = -999999.0

    for type in Player.TYPES:
        for card in player.get_cards(type):
            if not card.is_enabled():
                continue

            # Clone for simulation
            var sim_player = player.cloneForEvaluation()
            var sim_opponent = opponent.cloneForEvaluation()

            # Simulate playing this card
            # (would need to add simulation logic)

            # Evaluate
            var score = BoardEvaluator.evaluate(sim_player, sim_opponent)

            # With lookahead, recurse
            if lookahead > 0:
                score = minimax(sim_player, sim_opponent, lookahead, false)

            if score > best_score:
                best_score = score
                best_card = card

    return best_card
```

**4. Slot Selector**
**File:** `scripts/ai/slot_selector.gd`
```gdscript
class_name SlotSelector
extends RefCounted

static func select_slot(player: Player, opponent: Player, card: CardImage) -> int:
    var level = AIDifficulty.current_level

    match level:
        AIDifficulty.Level.NOVICE:
            return select_random_slot(player)

        AIDifficulty.Level.EXPERT:
            return select_synergy_slot(player, card)

        AIDifficulty.Level.MASTER, AIDifficulty.Level.GRANDMASTER:
            return select_optimal_slot(player, opponent, card)

    return 0

static func select_random_slot(player: Player) -> int:
    # Current behavior
    var slots = player.get_slots()
    for i in range(100):
        var index = randi() % 6
        if not slots[index].is_occupied():
            return index
    return 0

static func select_synergy_slot(player: Player, card: CardImage) -> int:
    # Find slot next to allies that benefit from adjacency
    var slots = player.get_slots()

    # Check for adjacent-buff creatures (Orc Chieftain, etc.)
    for i in range(6):
        if slots[i].is_occupied():
            continue

        # Check left neighbor
        if i > 0 and slots[i-1].is_occupied():
            if has_adjacency_bonus(slots[i-1].get_creature()):
                return i

        # Check right neighbor
        if i < 5 and slots[i+1].is_occupied():
            if has_adjacency_bonus(slots[i+1].get_creature()):
                return i

    # No synergy found, pick random
    return select_random_slot(player)

static func select_optimal_slot(player: Player, opponent: Player, card: CardImage) -> int:
    # Evaluate all possible slot placements
    var best_slot = -1
    var best_score = -999999.0

    var slots = player.get_slots()
    for i in range(6):
        if slots[i].is_occupied():
            continue

        # Simulate placing card in this slot
        var sim_player = player.cloneForEvaluation()
        # ... place card in slot i ...

        var score = BoardEvaluator.evaluate(sim_player, opponent)

        if score > best_score:
            best_score = score
            best_slot = i

    return best_slot if best_slot >= 0 else select_random_slot(player)
```

**5. Target Selector**
**File:** `scripts/ai/target_selector.gd`
```gdscript
class_name TargetSelector
extends RefCounted

static func select_spell_target(spell: Card, enemy_creatures: Array):
    var level = AIDifficulty.current_level

    match level:
        AIDifficulty.Level.NOVICE:
            return select_random_target(enemy_creatures)

        AIDifficulty.Level.EXPERT:
            return select_highest_threat(enemy_creatures)

        AIDifficulty.Level.MASTER, AIDifficulty.Level.GRANDMASTER:
            return select_optimal_target(spell, enemy_creatures)

    return null

static func select_random_target(enemies: Array):
    if enemies.is_empty():
        return null
    return enemies[randi() % enemies.size()]

static func select_highest_threat(enemies: Array):
    # Kill creature with highest attack
    var best = null
    var highest_attack = -1

    for enemy in enemies:
        if enemy.get_card().get_attack() > highest_attack:
            highest_attack = enemy.get_card().get_attack()
            best = enemy

    return best

static func select_optimal_target(spell: Card, enemies: Array):
    # Depends on spell type and board state
    # Example: removal spell -> kill biggest threat
    # Example: damage spell -> finish off wounded creatures
    # Example: mind control -> steal strongest

    if spell.get_cardname() == "Lightning Bolt":
        # Removal - kill biggest
        return select_highest_threat(enemies)
    elif spell.get_cardname() == "Hypnosis":
        # Mind control - steal best
        return select_highest_value(enemies)
    # ... etc
```

**6. Deck Builder**
**File:** `scripts/ai/deck_builder.gd`
```gdscript
class_name DeckBuilder
extends RefCounted

# Predefined optimized decks for each class at each difficulty
const OPTIMIZED_DECKS = {
    "CLERIC": {
        "focused": ["Paladin", "Paladin", "Holy Guard", "Holy Guard", ...],
        "synergy": ["Archangel", "Archangel", "Wrath of God", ...],
        "meta": ["Archangel", "Archangel", "Divine Intervention", ...]
    },
    "MECHANICIAN": {
        # ... etc for all 17 classes
    }
}

static func build_deck(class_type: String, difficulty: AIDifficulty.Level) -> Array:
    var deck_type = AIDifficulty.get_setting("deck_type")

    if deck_type == "random":
        return build_random_deck(class_type)
    elif deck_type == "focused":
        return OPTIMIZED_DECKS[class_type]["focused"]
    elif deck_type == "synergy":
        return OPTIMIZED_DECKS[class_type]["synergy"]
    elif deck_type == "meta":
        return OPTIMIZED_DECKS[class_type]["meta"]

    return []

static func build_random_deck(class_type: String) -> Array:
    # Current behavior - 4 of each type, random selection
    pass
```

---

## FILES TO MODIFY

### 1. Battle Round Thread (Main AI Turn)
**File:** `scripts/core/battle_round_thread.gd`

**Line 139 - Card Selection:**
```gdscript
# OLD:
oppt_pick = oi.pickRandomEnabledCard()

# NEW:
oppt_pick = CardSelector.select_card(opponent, player)
```

**Line 130 - Slot Selection:**
```gdscript
# OLD:
slot = get_opponent_slot()  # Random

# NEW:
slot_index = SlotSelector.select_slot(opponent, player, oppt_pick)
slot = opponent.get_slots()[slot_index]
```

---

### 2. Player Class (Enable Strategic Functions)
**File:** `scripts/core/player.gd`

**Line 249 - Already exists, just needs to be called:**
```gdscript
# This function already exists but is unused!
func pick_best_enabled_card():
    # Picks highest cost card - use for EXPERT level
```

---

### 3. Base Functions (Spell Targeting)
**File:** `scripts/core/base_functions.gd`

**Lines 166-200 - Already exist, just need to be called:**
```gdscript
# These functions already exist!
func get_lowest_attack_enemy():  # Kill weak creatures
func get_highest_attack_enemy(): # Kill strong creatures
```

**Add new targeting wrapper:**
```gdscript
func select_spell_target_by_difficulty(spell: Card, enemies: Array):
    return TargetSelector.select_spell_target(spell, enemies)
```

---

### 4. Individual Spell Files
**Files:** All files in `scripts/spells/`

**Example - gaze.gd (targeted damage):**
```gdscript
# OLD (line 24):
var r = get_random_enemy_creature()

# NEW:
var r = select_spell_target_by_difficulty(card, get_valid_targets())
```

**Apply to all spells that target:**
- hypnosis.gd
- explosion.gd
- mindstealer.gd
- etc.

---

### 5. Cards.gd (Deck Initialization)
**File:** `scripts/cards.gd`

**Around line 891 - Deck creation:**
```gdscript
# OLD:
var types: Array = [CardType.Type.FIRE, CardType.Type.AIR, CardType.Type.WATER, CardType.Type.EARTH, opponent.get_player_class().get_type()]

# NEW:
var opponent_deck = DeckBuilder.build_deck(
    opponent.get_player_class().get_title(),
    AIDifficulty.current_level
)

# If custom deck specified, use it, otherwise use old random method
if opponent_deck.size() > 0:
    initialize_custom_deck(opponent, opponent_deck)
else:
    initialize_random_deck(opponent)  # Current behavior
```

---

### 6. Single Duel Chooser (Difficulty Selection UI)
**File:** `scripts/ui/single_duel_chooser.gd`

**Add difficulty dropdown:**
```gdscript
# Around line 188 (after class dropdowns)

# AI Difficulty selection dropdown
var difficulty_selector = OptionButton.new()
difficulty_selector.add_item("Novice")
difficulty_selector.add_item("Expert")
difficulty_selector.add_item("Master")
difficulty_selector.add_item("Grandmaster")
difficulty_selector.selected = 0  # Default to Novice

# Position it appropriately
difficulty_selector.position = Vector2(x, y + 100)  # Below class selection

# Connect signal
difficulty_selector.item_selected.connect(_on_difficulty_selected)

# Add to UI
add_child(difficulty_selector)
```

**Callback:**
```gdscript
func _on_difficulty_selected(index: int) -> void:
    match index:
        0: AIDifficulty.current_level = AIDifficulty.Level.NOVICE
        1: AIDifficulty.current_level = AIDifficulty.Level.EXPERT
        2: AIDifficulty.current_level = AIDifficulty.Level.MASTER
        3: AIDifficulty.current_level = AIDifficulty.Level.GRANDMASTER
```

---

## DECK OPTIMIZATION DETAILS

### Deck Types by Difficulty

**NOVICE - Random Deck (Current)**
```
Fire: 4 random fire cards
Air: 4 random air cards
Water: 4 random water cards
Earth: 4 random earth cards
Class: 4 random class cards
```
**Consistency:** Low (could get all weak cards)

---

**EXPERT - Focused Deck**
```
Fire: 4 random fire cards
Air: 4 random air cards
Water: 4 random water cards
Class: 8 random class cards (DOUBLED!)
```
**Consistency:** Medium (more class cards = more synergy)

---

**MASTER - Synergy Deck**
Handpicked cards that combo together:
```
Class (8):
- 2× Best finisher
- 2× Best removal
- 2× Best utility
- 2× Best engine

Fire (4):
- 2× Dragon (win condition)
- 2× Armageddon (board wipe)

Water (4):
- 2× Meditation (card draw)
- 2× Mind Master (control)

Air (4):
- 2× Phoenix (resilient threat)
- 2× Chain Lightning (flexible removal)
```
**Consistency:** High (no weak cards, all synergize)

---

**GRANDMASTER - Meta Deck**
Absolutely optimized for maximum power:
```
Class (8):
- 2× S-tier finisher
- 2× S-tier removal
- 2× S-tier protection
- 2× S-tier engine

Fire (4):
- 2× Dragon (best finisher)
- 2× Armageddon (hard reset)

Water (4):
- 2× Mind Master (best control)
- 2× Meditation (card advantage)

Air (4):
- 2× Phoenix (unkillable)
- 2× Chain Lightning (premium removal)
```
**Consistency:** Maximum (perfect curve, no dead cards)

---

## IMPLEMENTATION PHASES

### Phase 1: Create AI Infrastructure
**Effort:** 3-4 hours

1. Create `ai_difficulty.gd` (difficulty enum + settings)
2. Create `board_evaluator.gd` (evaluation function)
3. Create `card_selector.gd` (NOVICE + EXPERT only for now)
4. Create `slot_selector.gd` (NOVICE + EXPERT)
5. Create `target_selector.gd` (NOVICE + EXPERT)

**Test:** Verify NOVICE = current behavior, EXPERT uses high-cost cards

---

### Phase 2: Add Difficulty UI
**Effort:** 1-2 hours

1. Add dropdown to `single_duel_chooser.gd`
2. Connect to AIDifficulty.current_level
3. Test difficulty switching

---

### Phase 3: Implement MASTER Level
**Effort:** 4-6 hours

1. Complete `board_evaluator.gd` with all factors
2. Add simulation logic to `card_selector.gd`
3. Implement optimal slot selection
4. Implement optimal targeting
5. Create first synergy decks for testing

**Test:** MASTER should be noticeably harder than EXPERT

---

### Phase 4: Create Synergy Decks
**Effort:** 6-8 hours (17 classes × 30 min each)

1. Design synergy deck for each class
2. Add to `deck_builder.gd`
3. Test each deck for power level
4. Balance as needed

---

### Phase 5: Implement GRANDMASTER Level
**Effort:** 8-10 hours

1. Implement minimax with lookahead
2. Add opening book logic
3. Add win condition detection
4. Create meta decks for all classes
5. Optimize performance (minimax is expensive!)

**Test:** GRANDMASTER should be very difficult to beat

---

### Phase 6: Polish & Balance
**Effort:** 4-6 hours

1. Playtest all difficulty levels
2. Adjust win rates if needed
3. Fix edge cases
4. Optimize performance
5. Add tooltips/descriptions for each difficulty

---

## PERFORMANCE CONSIDERATIONS

### Minimax Complexity

**Problem:** Lookahead is exponentially expensive

**Turn with 10 playable cards:**
- Depth 0 (NOVICE/EXPERT): 1 evaluation
- Depth 1 (MASTER): 10 evaluations
- Depth 2 (GRANDMASTER): 100 evaluations
- Depth 3: 1,000 evaluations (too slow!)

**Solutions:**

1. **Alpha-Beta Pruning**
```gdscript
func minimax_alphabeta(player, opponent, depth, alpha, beta, maximizing):
    # Prune branches that can't improve result
    # Reduces 100 evals to ~30 evals
```

2. **Move Ordering**
```gdscript
# Evaluate most promising moves first
# Improves pruning efficiency
func order_moves(moves: Array) -> Array:
    return moves.sorted_by(quick_eval)
```

3. **Depth Limits**
```gdscript
# GRANDMASTER: depth 2 only
# Don't go deeper - too slow
```

4. **Caching/Memoization**
```gdscript
# Cache evaluated positions
var position_cache = {}

func evaluate_cached(board_hash):
    if position_cache.has(board_hash):
        return position_cache[board_hash]

    var score = evaluate(board)
    position_cache[board_hash] = score
    return score
```

---

## EXPECTED WIN RATES

Based on playtesting targets:

| Difficulty | vs Beginner | vs Average | vs Expert |
|------------|-------------|------------|-----------|
| Novice     | 10-20%      | 20-30%     | 30-40%    |
| Expert     | 50-60%      | 40-50%     | 30-40%    |
| Master     | 80-90%      | 60-70%     | 40-50%    |
| Grandmaster| 95%+        | 80-90%     | 60-70%    |

**Beginner player:** New to game, learning mechanics
**Average player:** Understands game, makes some mistakes
**Expert player:** Strong player, rarely makes mistakes

---

## TESTING STRATEGY

### 1. Regression Testing
**Ensure NOVICE = current behavior**
```
Test: Play 10 games vs NOVICE
Expected: Same difficulty as current AI
```

### 2. Progression Testing
**Each tier should be harder**
```
Test: Play 5 games each difficulty
Expected: NOVICE < EXPERT < MASTER < GRANDMASTER
```

### 3. Deck Testing
**Optimized decks should be stronger**
```
Test: Random deck vs Synergy deck (same AI level)
Expected: Synergy deck wins ~70% of time
```

### 4. Performance Testing
**GRANDMASTER shouldn't lag**
```
Test: Measure AI turn time
Expected: < 2 seconds for GRANDMASTER turn
```

### 5. Balance Testing
**Win rates should match targets**
```
Test: 20 games per difficulty by average player
Expected: Win rates match table above
```

---

## QUESTIONS TO RESOLVE

Before implementation:

1. **Deck customization:**
   - Should player see opponent's deck before match?
   - Allow player to build custom AI decks?

2. **Difficulty persistence:**
   - Remember last selected difficulty?
   - Per-class difficulty settings?

3. **Visual feedback:**
   - Show AI "thinking" animation?
   - Display AI's reasoning (for learning)?

4. **Balancing:**
   - Should GRANDMASTER be beatable by average player?
   - Or designed to be nearly unbeatable (chess grandmaster style)?

5. **Future tiers:**
   - Add more levels between MASTER and GRANDMASTER?
   - Add difficulty above GRANDMASTER (LEGENDARY, etc.)?

---

## NEXT STEPS

**Ready for:**
1. Deck designs for all 17 classes (need input on card power levels)
2. Prototype NOVICE/EXPERT split
3. Board evaluation function design
4. Performance profiling of minimax

**When ready to implement:**
1. Create AI infrastructure files
2. Add difficulty selection UI
3. Test NOVICE/EXPERT first
4. Gradually add MASTER/GRANDMASTER

---

**All planning, no implementation yet - awaiting your approval and next discussion phase!**

Current AI behavior preserved as NOVICE baseline ✓
Progressive intelligence tiers designed ✓
Deck optimization strategy planned ✓
Implementation roadmap ready ✓
