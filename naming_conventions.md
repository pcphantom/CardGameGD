# CardGameGD Naming Conventions - GOLD STANDARD

**CRITICAL**: This document defines the **PERMANENT** naming conventions for the CardGameGD project. Once an entry is listed here, it becomes the canonical reference. All future code MUST conform to these conventions. DO NOT deviate from this standard.

**Last Updated**: 2025-11-09

---

## Table of Contents
1. [File Path Conventions](#file-path-conventions)
2. [Class Name Conventions](#class-name-conventions)
3. [Method Name Conventions](#method-name-conventions)
4. [Field/Variable Name Conventions](#field-variable-name-conventions)
5. [Enum Conventions](#enum-conventions)
6. [Asset Path Conventions](#asset-path-conventions)
7. [Package/Directory Structure](#package-directory-structure)

---

## File Path Conventions

### Java → GDScript File Mappings

**Format**: `Java Source Path` → `GDScript Target Path`

#### Core Files
```
source-ref/main/java/org/antinori/cards/Card.java → CardGameGD/scripts/core/card.gd
source-ref/main/java/org/antinori/cards/CardType.java → CardGameGD/scripts/core/card_type.gd
source-ref/main/java/org/antinori/cards/CardSetup.java → CardGameGD/scripts/autoload/card_setup.gd
source-ref/main/java/org/antinori/cards/CardPredicate.java → CardGameGD/scripts/ai/card_predicate.gd
source-ref/main/java/org/antinori/cards/Cards.java → CardGameGD/scripts/cards.gd
source-ref/main/java/org/antinori/cards/Creature.java → CardGameGD/scripts/core/creature.gd
source-ref/main/java/org/antinori/cards/CreatureFactory.java → CardGameGD/scripts/factories/creature_factory.gd
source-ref/main/java/org/antinori/cards/Dice.java → CardGameGD/scripts/core/dice.gd
source-ref/main/java/org/antinori/cards/GameOverException.java → CardGameGD/scripts/core/game_over_exception.gd
source-ref/main/java/org/antinori/cards/Player.java → CardGameGD/scripts/core/player.gd
source-ref/main/java/org/antinori/cards/SimpleGame.java → CardGameGD/scripts/simple_game.gd
source-ref/main/java/org/antinori/cards/Sound.java → CardGameGD/scripts/core/sound_types.gd
source-ref/main/java/org/antinori/cards/Sounds.java → CardGameGD/scripts/autoload/sound_manager.gd
source-ref/main/java/org/antinori/cards/Specializations.java → CardGameGD/scripts/core/specializations.gd
source-ref/main/java/org/antinori/cards/Spell.java → CardGameGD/scripts/core/spell.gd
source-ref/main/java/org/antinori/cards/SpellFactory.java → CardGameGD/scripts/factories/spell_factory.gd
source-ref/main/java/org/antinori/cards/Utils.java → CardGameGD/scripts/core/utils.gd
source-ref/main/java/org/antinori/cards/BaseFunctions.java → CardGameGD/scripts/core/base_functions.gd
```

#### UI Files
```
source-ref/main/java/org/antinori/cards/CardDescriptionImage.java → CardGameGD/scripts/ui/card_description_image.gd
source-ref/main/java/org/antinori/cards/CardImage.java → CardGameGD/scripts/ui/card_image.gd
source-ref/main/java/org/antinori/cards/LogScrollPane.java → CardGameGD/scripts/ui/log_scroll_pane.gd
source-ref/main/java/org/antinori/cards/OpponentCardWindow.java → CardGameGD/scripts/ui/opponent_card_window.gd
source-ref/main/java/org/antinori/cards/PlayerImage.java → CardGameGD/scripts/ui/player_image.gd
source-ref/main/java/org/antinori/cards/SingleDuelChooser.java → CardGameGD/scripts/ui/single_duel_chooser.gd
source-ref/main/java/org/antinori/cards/SlotImage.java → CardGameGD/scripts/ui/slot_image.gd
```

#### AI Files
```
source-ref/main/java/org/antinori/cards/ai/Evaluation.java → CardGameGD/scripts/ai/evaluation.gd
source-ref/main/java/org/antinori/cards/ai/Move.java → CardGameGD/scripts/ai/move.gd
```

#### Actions Files
```
source-ref/main/java/org/antinori/cards/ActionMoveCircular.java → CardGameGD/scripts/actions/action_move_circular.gd
```

#### Creature Files (Partial List - Pattern Established)
```
source-ref/main/java/org/antinori/cards/characters/BaseCreature.java → CardGameGD/scripts/creatures/base_creature.gd
source-ref/main/java/org/antinori/cards/characters/BeeSoldier.java → CardGameGD/scripts/creatures/bee_soldier.gd
source-ref/main/java/org/antinori/cards/characters/CursedUnicorn.java → CardGameGD/scripts/creatures/cursed_unicorn.gd
source-ref/main/java/org/antinori/cards/characters/DarkSculptor.java → CardGameGD/scripts/creatures/dark_sculptor.gd
source-ref/main/java/org/antinori/cards/characters/ForestSpider.java → CardGameGD/scripts/creatures/forest_spider.gd
source-ref/main/java/org/antinori/cards/characters/Initiate.java → CardGameGD/scripts/creatures/initiate.gd
source-ref/main/java/org/antinori/cards/characters/Mindstealer.java → CardGameGD/scripts/creatures/mindstealer.gd
source-ref/main/java/org/antinori/cards/characters/MonumenttoRage.java → CardGameGD/scripts/creatures/monument_to_rage.gd
```

#### Spell Files (Partial List - Pattern Established)
```
source-ref/main/java/org/antinori/cards/spells/Weakness.java → CardGameGD/scripts/spells/weakness.gd
source-ref/main/java/org/antinori/cards/spells/PoisonousCloud.java → CardGameGD/scripts/spells/poisonous_cloud.gd
```

---

## Class Name Conventions

**Rule**: Java class names remain EXACTLY the same in GDScript using `class_name` declaration.

**Format**: `JavaClassName` → `class_name GDScriptClassName`

### Core Classes
```
Card → class_name Card
CardType → class_name CardType
CardSetup → class_name CardSetup
CardPredicate → class_name CardPredicate
Cards → class_name Cards
Creature → class_name Creature
Dice → class_name Dice
GameOverException → class_name GameOverException
Player → class_name Player
SimpleGame → class_name SimpleGame
SoundTypes → class_name SoundTypes  (SPECIAL: Sound.java → SoundTypes to avoid naming conflict)
Sound → class_name Sound  (DIFFERENT FILE: the sound effect class)
Specializations → class_name Specializations
Spell → class_name Spell
Utils → class_name Utils
BaseFunctions → class_name BaseFunctions
```

### UI Classes
```
CardDescriptionImage → class_name CardDescriptionImage
CardImage → class_name CardImage
LogScrollPane → class_name LogScrollPane
OpponentCardWindow → class_name OpponentCardWindow
PlayerImage → class_name PlayerImage
SingleDuelChooser → class_name SingleDuelChooser
SlotImage → class_name SlotImage
```

### AI Classes
```
Evaluation → class_name Evaluation
Move → class_name Move
```

### Action Classes
```
ActionMoveCircular → class_name ActionMoveCircular
```

### Creature Classes (Pattern Established)
```
BaseCreature → class_name BaseCreature
BeeSoldier → class_name BeeSoldier
CursedUnicorn → class_name CursedUnicorn
DarkSculptor → class_name DarkSculptor
ForestSpider → class_name ForestSpider
Initiate → class_name Initiate
Mindstealer → class_name Mindstealer
MonumenttoRage → class_name MonumenttoRage
```

### Spell Classes (Pattern Established)
```
Weakness → class_name Weakness
PoisonousCloud → class_name PoisonousCloud
```

---

## Method Name Conventions

**Rule**: Java camelCase method names convert to GDScript snake_case.

**CRITICAL EXCEPTIONS**: Some methods keep exact Java names when they're core API methods called from multiple places.

**Format**: `javaMethodName()` → `gdscript_method_name()`

### Universal Conversions (GOLD STANDARD)

#### CardType Methods
```
CardType.getTitle(type) → CardType.get_title(type)  ✅ VERIFIED
CardType.fromString(text) → CardType.from_string(text)
```

#### CardImage Methods
```
CardImage.sort(cards) → CardImage.sort_cards(cards)  ✅ VERIFIED
CardImage.isHighlighted() → CardImage.get_is_highlighted()  ✅ VERIFIED (renamed to avoid collision)
CardImage.setHighlighted(value) → CardImage.set_highlighted(value)
CardImage.getCard() → CardImage.get_card()
```

#### Card Methods
```
Card.getName() → Card.getName()  ✅ KEEP JAVA NAME (core API)
Card.getCost() → Card.getCost()  ✅ KEEP JAVA NAME (core API)
Card.getType() → Card.getType()  ✅ KEEP JAVA NAME (core API)
Card.getCardClass() → Card.getCardClass()  ✅ KEEP JAVA NAME (core API)
Card.setSpell(is_spell) → Card.set_spell(value)  ✅ VERIFIED (parameter renamed to avoid shadowing)
Card.setTargetable(is_targetable) → Card.set_targetable(value)  ✅ VERIFIED
Card.setWall(is_wall) → Card.set_wall(value)  ✅ VERIFIED
Card.isSpell() → Card.is_spell()  ✅ KEEP JAVA NAME
Card.isTargetable() → Card.is_targetable()  ✅ KEEP JAVA NAME
Card.isWall() → Card.is_wall()  ✅ KEEP JAVA NAME
```

#### Player Methods
```
Player.getLife() → Player.getLife()  ✅ KEEP JAVA NAME (core API)
Player.getStrength(type) → Player.getStrength(type)  ✅ KEEP JAVA NAME (core API)
Player.getPlayerClass() → Player.getPlayerClass()  ✅ KEEP JAVA NAME (core API)
Player.decrementLife(value) → Player.decrementLife(value)  ✅ KEEP JAVA NAME
Player.incrementLife(value) → Player.incrementLife(value)  ✅ KEEP JAVA NAME
```

#### PlayerImage Methods
```
PlayerImage(sprite, frame, info) → PlayerImage._init(sprite, frame, info)  ✅ VERIFIED (3-param constructor)
PlayerImage(sprite, frame, font, info, x, y) → PlayerImage._init(sprite, frame, font, info, x, y)  ✅ VERIFIED (6-param constructor)
PlayerImage.getSlots() → PlayerImage.getSlots()  ✅ KEEP JAVA NAME
PlayerImage.getSlotCards() → PlayerImage.getSlotCards()  ✅ KEEP JAVA NAME
```

#### Specializations Methods
```
Specializations.Cleric → Specializations.CLERIC  ✅ VERIFIED (enum constant)
Specializations.Cleric.getTitle() → Specializations.CLERIC.get_title()  ✅ VERIFIED
Specializations.getByTitle(title) → Specializations.get_by_title(title)
Specializations.getById(id) → Specializations.get_by_id(id)
```

#### Cards (Game Controller) Methods
```
Cards.ydown(y) → Cards.ydown(y)  ✅ KEEP JAVA NAME (simple utility)
Cards.init() → Cards.init()  ✅ KEEP JAVA NAME (lifecycle method)
Cards.draw(delta) → Cards.draw(delta)  ✅ KEEP JAVA NAME (lifecycle method)
Cards.initialize() → Cards.initialize()  ✅ KEEP JAVA NAME (lifecycle method)
Cards.getPlayerDescription(pl) → Cards.getPlayerDescription(pl)  ✅ KEEP JAVA NAME
Cards.getPlayerStrength(pl, type) → Cards.getPlayerStrength(pl, type)  ✅ KEEP JAVA NAME
Cards.addVerticalGroupCards(...) → Cards.addVerticalGroupCards(...)  ✅ KEEP JAVA NAME
Cards.moveCardActorOnBattle(...) → Cards.moveCardActorOnBattle(...)  ✅ KEEP JAVA NAME
```

#### Sound/SoundManager Methods
```
Sounds.play(Sound.ATTACK) → SoundManager.play(SoundTypes.Sound.ATTACK)  ✅ VERIFIED
Sounds.playSound(sound) → SoundManager.play_sound(sound)
```

#### Evaluation Methods
```
Evaluation.evaluateMove(move) → Evaluation.evaluateMove(move)  ✅ KEEP JAVA NAME
Evaluation.getFavoriteCard(cards) → Evaluation.getFavoriteCard(cards)  ✅ KEEP JAVA NAME
```

#### Move Methods
```
Move.create(card, target) → Move.create(card, target)  ✅ KEEP JAVA NAME (static factory)
Move.getCard() → Move.getCard()  ✅ KEEP JAVA NAME
Move.getTarget() → Move.getTarget()  ✅ KEEP JAVA NAME
```

---

## Field/Variable Name Conventions

**Rule**: Java field names generally keep camelCase in GDScript for direct translation fidelity.

**Alternative Rule**: When appropriate for GDScript idioms, convert to snake_case.

### Instance Fields (GOLD STANDARD)

#### Cards.gd Fields
```
player → player  ✅ VERIFIED (was incorrectly player_visual)
opponent → opponent  ✅ VERIFIED (was incorrectly opponent_visual)
topStrengthLabels → topStrengthLabels  ✅ VERIFIED
bottomStrengthLabels → bottomStrengthLabels  ✅ VERIFIED
cs → cs  ✅ VERIFIED (CardSetup instance)
selectedCard → selectedCard  ✅ KEEP JAVA NAME
activeTurn → activeTurn  ✅ KEEP JAVA NAME
gameOver → gameOver  ✅ VERIFIED
opptCardsShown → opptCardsShown  ✅ VERIFIED
```

#### CardImage.gd Fields
```
img → img  ✅ KEEP JAVA NAME
frame → frame  ✅ KEEP JAVA NAME
card → card  ✅ KEEP JAVA NAME
font → font  ✅ KEEP JAVA NAME
enabled → enabled  ✅ KEEP JAVA NAME
isHighlighted → is_highlighted  ✅ VERIFIED (snake_case for boolean)
creature → creature  ✅ KEEP JAVA NAME
```

#### PlayerImage.gd Fields
```
img → img  ✅ KEEP JAVA NAME
frame → frame  ✅ KEEP JAVA NAME
playerInfo → player_info  ✅ VERIFIED (snake_case)
font → font  ✅ KEEP JAVA NAME
slots → slots  ✅ KEEP JAVA NAME
slotCards → slot_cards  ✅ VERIFIED (snake_case)
mustSkipNexAttack → must_skip_next_attack  ✅ VERIFIED (snake_case)
```

### Static Fields (GOLD STANDARD)

#### Cards.gd Static Fields
```
NET_GAME → NET_GAME  ✅ KEEP JAVA NAME (SCREAMING_SNAKE_CASE)
smallCardAtlas → smallCardAtlas  ✅ KEEP JAVA NAME
smallTGACardAtlas → smallTGACardAtlas  ✅ KEEP JAVA NAME
largeCardAtlas → largeCardAtlas  ✅ KEEP JAVA NAME
largeTGACardAtlas → largeTGACardAtlas  ✅ KEEP JAVA NAME
faceCardAtlas → faceCardAtlas  ✅ KEEP JAVA NAME
ramka → ramka  ✅ KEEP JAVA NAME
spellramka → spellramka  ✅ KEEP JAVA NAME
portraitramka → portraitramka  ✅ KEEP JAVA NAME
ramkabig → ramkabig  ✅ KEEP JAVA NAME
ramkabigspell → ramkabigspell  ✅ KEEP JAVA NAME
slotTexture → slotTexture  ✅ KEEP JAVA NAME
defaultFont → defaultFont  ✅ KEEP JAVA NAME
greenfont → greenfont  ✅ KEEP JAVA NAME
customFont → customFont  ✅ KEEP JAVA NAME
whiteStyle → whiteStyle  ✅ KEEP JAVA NAME
redStyle → redStyle  ✅ KEEP JAVA NAME
greenStyle → greenStyle  ✅ KEEP JAVA NAME
SCREEN_WIDTH → SCREEN_WIDTH  ✅ KEEP JAVA NAME
SCREEN_HEIGHT → SCREEN_HEIGHT  ✅ KEEP JAVA NAME
background → background  ✅ KEEP JAVA NAME
sprBg → sprBg  ✅ KEEP JAVA NAME
```

---

## Enum Conventions

**Rule**: Java enum constants use SCREAMING_SNAKE_CASE. GDScript enums follow the same convention.

**Access Pattern**: `JavaClass.ENUM_VALUE` → `GDScriptClass.Type.ENUM_VALUE` or `GDScriptClass.ENUM_VALUE`

### CardType Enum
```
CardType.FIRE → CardType.Type.FIRE  ✅ VERIFIED
CardType.WATER → CardType.Type.WATER  ✅ VERIFIED
CardType.AIR → CardType.Type.AIR  ✅ VERIFIED
CardType.EARTH → CardType.Type.EARTH  ✅ VERIFIED
CardType.DEATH → CardType.Type.DEATH  ✅ VERIFIED
CardType.HOLY → CardType.Type.HOLY  ✅ VERIFIED
CardType.MECHANICAL → CardType.Type.MECHANICAL  ✅ VERIFIED
CardType.ILLUSION → CardType.Type.ILLUSION  ✅ VERIFIED
CardType.CONTROL → CardType.Type.CONTROL  ✅ VERIFIED
CardType.CHAOS → CardType.Type.CHAOS  ✅ VERIFIED
CardType.DEMONIC → CardType.Type.DEMONIC  ✅ VERIFIED
CardType.SORCERY → CardType.Type.SORCERY  ✅ VERIFIED
CardType.BEAST → CardType.Type.BEAST  ✅ VERIFIED
CardType.BEASTS_ABILITIES → CardType.Type.BEASTS_ABILITIES  ✅ VERIFIED
CardType.GOBLINS → CardType.Type.GOBLINS  ✅ VERIFIED
CardType.FOREST → CardType.Type.FOREST  ✅ VERIFIED
CardType.TIME → CardType.Type.TIME  ✅ VERIFIED
CardType.SPIRIT → CardType.Type.SPIRIT  ✅ VERIFIED
CardType.VAMPIRIC → CardType.Type.VAMPIRIC  ✅ VERIFIED
CardType.CULT → CardType.Type.CULT  ✅ VERIFIED
CardType.GOLEM → CardType.Type.GOLEM  ✅ VERIFIED
CardType.OTHER → CardType.Type.OTHER  ✅ VERIFIED
```

### Specializations Enum
```
Specializations.Cleric → Specializations.CLERIC  ✅ VERIFIED (capitalization correction)
Specializations.MECHANICIAN → Specializations.MECHANICIAN  ✅ VERIFIED
Specializations.NECROMANCER → Specializations.NECROMANCER  ✅ VERIFIED
Specializations.CHAOSMASTER → Specializations.CHAOSMASTER  ✅ VERIFIED
Specializations.DOMINATOR → Specializations.DOMINATOR  ✅ VERIFIED
Specializations.ILLUSIONIST → Specializations.ILLUSIONIST  ✅ VERIFIED
Specializations.DEMONOLOGIST → Specializations.DEMONOLOGIST  ✅ VERIFIED
Specializations.SORCERER → Specializations.SORCERER  ✅ VERIFIED
Specializations.BEASTMASTER → Specializations.BEASTMASTER  ✅ VERIFIED
Specializations.GOBLIN_CHIEFTAN → Specializations.GOBLIN_CHIEFTAN  ✅ VERIFIED
Specializations.MAD_HERMIT → Specializations.MAD_HERMIT  ✅ VERIFIED
Specializations.CHRONOMANCER → Specializations.CHRONOMANCER  ✅ VERIFIED
Specializations.WARRIOR_PRIEST → Specializations.WARRIOR_PRIEST  ✅ VERIFIED
Specializations.VAMPIRE_LORD → Specializations.VAMPIRE_LORD  ✅ VERIFIED
Specializations.CULTIST → Specializations.CULTIST  ✅ VERIFIED
Specializations.GOLEM_MASTER → Specializations.GOLEM_MASTER  ✅ VERIFIED
Specializations.RANDOM → Specializations.RANDOM  ✅ VERIFIED
```

### Sound Enum
```
Sound.BACKGROUND1 → SoundTypes.Sound.BACKGROUND1  ✅ VERIFIED
Sound.BACKGROUND2 → SoundTypes.Sound.BACKGROUND2  ✅ VERIFIED
Sound.BACKGROUND3 → SoundTypes.Sound.BACKGROUND3  ✅ VERIFIED
Sound.POSITIVE_EFFECT → SoundTypes.Sound.POSITIVE_EFFECT  ✅ VERIFIED
Sound.NEGATIVE_EFFECT → SoundTypes.Sound.NEGATIVE_EFFECT  ✅ VERIFIED
Sound.MAGIC → SoundTypes.Sound.MAGIC  ✅ VERIFIED
Sound.ATTACK → SoundTypes.Sound.ATTACK  ✅ VERIFIED
Sound.SUMMON_DROP → SoundTypes.Sound.SUMMON_DROP  ✅ VERIFIED
Sound.SUMMONED → SoundTypes.Sound.SUMMONED  ✅ VERIFIED
Sound.DAMAGED → SoundTypes.Sound.DAMAGED  ✅ VERIFIED
Sound.DEATH → SoundTypes.Sound.DEATH  ✅ VERIFIED
Sound.GAMEOVER → SoundTypes.Sound.GAMEOVER  ✅ VERIFIED
Sound.CLICK → SoundTypes.Sound.CLICK  ✅ VERIFIED
```

---

## Asset Path Conventions

**Rule**: Java classpath resources convert to Godot `res://` paths.

**Format**: `Gdx.files.classpath("path/to/asset")` → `res://assets/path/to/asset`

### Image Assets
```
images/background.jpg → res://assets/images/background.jpg  ✅ VERIFIED
images/ramka.png → res://assets/images/ramka.png
images/spellramka.png → res://assets/images/spellramka.png
images/portraitramka.png → res://assets/images/portraitramka.png
images/ramkabig.png → res://assets/images/ramkabig.png
images/ramkabigspell.png → res://assets/images/ramkabigspell.png
images/slot.png → res://assets/images/slot.png
images/stunned.png → res://assets/images/stunned.png
images/healthBox.png → res://assets/images/healthBox.png
images/ChooseChar1.png → res://assets/images/ChooseChar1.png
images/combatresult.png → res://assets/images/combatresult.png
images/cursor.png → res://assets/images/cursor.png
images/endturnbutton.png → res://assets/images/endturnbutton.png
```

### Atlas Assets
```
faceCardsPack.txt → res://assets/images/faceCardsPack.txt
faceTiles.png → res://assets/images/faceTiles.png
largeCardsPack.txt → res://assets/images/largeCardsPack.txt
largeTGACardsPack.txt → res://assets/images/largeTGACardsPack.txt
largeTiles.png → res://assets/images/largeTiles.png
largeTGATiles.png → res://assets/images/largeTGATiles.png
smallCardsPack.txt → res://assets/images/smallCardsPack.txt
smallTiles.png → res://assets/images/smallTiles.png
smallTGACardsPack.txt → res://assets/images/smallTGACardsPack.txt
smallTGATiles.png → res://assets/images/smallTGATiles.png
```

### Font Assets
```
fonts/verdana.fnt → res://assets/fonts/verdana.fnt
fonts/greenfont.fnt → res://assets/fonts/greenfont.fnt
fonts/customfont.fnt → res://assets/fonts/customfont.fnt
```

### Sound Assets
```
sounds/background1.ogg → res://assets/sounds/background1.ogg
sounds/background2.ogg → res://assets/sounds/background2.ogg
sounds/background3.ogg → res://assets/sounds/background3.ogg
sounds/positive_effect.wav → res://assets/sounds/positive_effect.wav
sounds/negative_effect.wav → res://assets/sounds/negative_effect.wav
sounds/magic.wav → res://assets/sounds/magic.wav
sounds/attack.wav → res://assets/sounds/attack.wav
sounds/summon_drop.wav → res://assets/sounds/summon_drop.wav
sounds/summoned.wav → res://assets/sounds/summoned.wav
sounds/damaged.wav → res://assets/sounds/damaged.wav
sounds/death.wav → res://assets/sounds/death.wav
sounds/gameover.wav → res://assets/sounds/gameover.wav
sounds/click.wav → res://assets/sounds/click.wav
```

---

## Package/Directory Structure

**Rule**: Java package hierarchy maps to Godot directory structure.

### Directory Mappings
```
org.antinori.cards → CardGameGD/scripts/
org.antinori.cards.ai → CardGameGD/scripts/ai/
org.antinori.cards.characters → CardGameGD/scripts/creatures/
org.antinori.cards.spells → CardGameGD/scripts/spells/
```

### Autoload Singletons (Special Category)
```
CardSetup → CardGameGD/scripts/autoload/card_setup.gd (autoload as CardSetup)
Sounds → CardGameGD/scripts/autoload/sound_manager.gd (autoload as SoundManager)
GameManager → CardGameGD/scripts/autoload/game_manager.gd (autoload as GameManager)
TextureManager → CardGameGD/scripts/autoload/texture_manager.gd (autoload as TextureManager)
NetworkManager → CardGameGD/scripts/autoload/network_manager.gd (autoload as NetworkManager)
```

---

## Special Cases and Exceptions

### 1. Sound.java Naming Conflict
**Problem**: Java has both `Sound.java` (enum) and `Sounds.java` (manager class)
**Solution**:
```
Sound.java (enum) → scripts/core/sound_types.gd (class_name SoundTypes)
Sounds.java (manager) → scripts/autoload/sound_manager.gd (autoload as SoundManager)
Sound references → SoundTypes.Sound.ENUM_VALUE  ✅ VERIFIED
```

### 2. PlayerImage Constructor Overloading
**Problem**: GDScript doesn't support method overloading
**Solution**:
```
PlayerImage(img, frame, info) → _init(img=null, frame=null, font=null, info=null, x=0.0, y=0.0)
PlayerImage(img, frame, font, info, x, y) → Same _init() with all 6 parameters
Result: Single _init() with optional parameters  ✅ VERIFIED
```

### 3. CardImage.isHighlighted() Variable Collision
**Problem**: Both `var is_highlighted` and `func isHighlighted()` existed
**Solution**:
```
var is_highlighted (keep) → var is_highlighted  ✅ VERIFIED
func isHighlighted() (rename) → func get_is_highlighted()  ✅ VERIFIED
```

### 4. Card Setter Parameter Shadowing
**Problem**: Parameters shadowed getter functions with same name
**Solution**:
```
set_spell(is_spell: bool) → set_spell(value: bool)  ✅ VERIFIED
set_targetable(is_targetable: bool) → set_targetable(value: bool)  ✅ VERIFIED
set_wall(is_wall: bool) → set_wall(value: bool)  ✅ VERIFIED
```

---

## Verification Status Legend

- ✅ **VERIFIED**: This conversion has been tested and confirmed working in the codebase
- ⚠️ **PENDING**: This conversion is documented but not yet implemented
- ❌ **DEPRECATED**: This conversion was tried and should NOT be used

---

## Update Protocol

**When adding new conversions to this document**:

1. Document the Java source
2. Document the GDScript target
3. Mark as VERIFIED only after successful compilation
4. Include file path, class name, method signature, and usage examples
5. Update the "Last Updated" date at the top

**When a conflict arises**:

1. Check this document FIRST
2. If documented here, this document is ALWAYS correct
3. Update code to match this document, NOT the other way around
4. Only update this document if you're fixing a proven error

---

## End of Document
