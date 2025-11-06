# Required Assets for Spectromancer Card Game

This document lists all assets needed for the game to function with full audio and visuals.

## Sound Assets Required

The SoundManager references these sound effects. Place audio files in `assets/sounds/`:

### Sound Effects (SFX)
1. **click.ogg** - UI button clicks
2. **card_draw.ogg** - Drawing a card
3. **card_play.ogg** - Playing a card
4. **summon.ogg** - Creature summoned
5. **summon_drop.ogg** - Card dropped into slot
6. **attack.ogg** - Creature attacking
7. **damage.ogg** - Taking damage
8. **heal.ogg** - Healing effect
9. **death.ogg** - Creature death
10. **spell_cast.ogg** - Casting a spell
11. **magic.ogg** - Generic magic effect
12. **negative_effect.ogg** - Debuff applied
13. **positive_effect.ogg** - Buff applied
14. **turn_start.ogg** - Turn beginning
15. **turn_end.ogg** - Turn ending
16. **victory.ogg** - Win fanfare
17. **defeat.ogg** - Loss sound
18. **gameover.ogg** - Game over general
19. **error.ogg** - Invalid action
20. **notification.ogg** - General notification

### Background Music
1. **menu_music.ogg** - Main menu background music
2. **battle_music.ogg** - In-game battle music
3. **victory_music.ogg** - Victory screen music

### Audio Specifications
- **Format**: OGG Vorbis (recommended) or WAV
- **Sample Rate**: 44.1 kHz or 48 kHz
- **Bit Depth**: 16-bit minimum
- **Channels**: Stereo or Mono
- **SFX Length**: 0.5-2 seconds typical
- **Music Length**: 2-5 minutes (looping)

## Image Assets Required

Place image files in `assets/images/`:

### Card Art (100+ cards needed)
- **Creatures** (100 cards):
  - `creatures/[creature_name].png` (e.g., `creatures/dragon.png`)
  - Size: 256x256 pixels or larger
  - Format: PNG with transparency

- **Spells** (50 cards):
  - `spells/[spell_name].png` (e.g., `spells/fireball.png`)
  - Size: 256x256 pixels
  - Format: PNG with transparency

### UI Elements
1. **card_frame.png** - Card border/frame (512x512)
2. **card_back.png** - Card back design (256x256)
3. **slot_empty.png** - Empty slot indicator (140x180)
4. **slot_valid.png** - Valid drop target (140x180)
5. **slot_invalid.png** - Invalid drop target (140x180)
6. **player_avatar_default.png** - Default player icon (64x64)
7. **button_normal.png** - Button background (variable)
8. **button_hover.png** - Button hover state (variable)
9. **button_pressed.png** - Button pressed state (variable)
10. **panel_background.png** - Panel/dialog background (variable)

### Element Icons (40x40 each)
1. **icon_fire.png** - Fire element
2. **icon_water.png** - Water element
3. **icon_air.png** - Air element
4. **icon_earth.png** - Earth element
5. **icon_other.png** - Other/neutral element

### Background Images
1. **background_menu.png** - Main menu background (1024x768)
2. **background_game.png** - Game battlefield background (1024x768)
3. **background_victory.png** - Victory screen background (1024x768)
4. **background_defeat.png** - Defeat screen background (1024x768)

### Particle Textures
1. **particle_fire.png** - Fire particle (32x32)
2. **particle_water.png** - Water particle (32x32)
3. **particle_air.png** - Air particle (32x32)
4. **particle_earth.png** - Earth particle (32x32)
5. **particle_magic.png** - Generic magic particle (32x32)
6. **particle_confetti.png** - Victory confetti (16x16)

### Image Specifications
- **Format**: PNG (with alpha channel for transparency)
- **Color Space**: sRGB
- **Compression**: PNG-8 or PNG-24 as appropriate
- **Naming**: lowercase_with_underscores.png

## Font Assets Required

Place font files in `assets/fonts/`:

1. **main_font.ttf** - Primary UI font
   - Style: Sans-serif, readable
   - Suggested: Open Sans, Roboto, Noto Sans

2. **title_font.ttf** - Headers and titles
   - Style: Bold or decorative
   - Suggested: Bebas Neue, Cinzel, Montserrat Bold

3. **card_text_font.ttf** - Card descriptions
   - Style: Small, readable serif or sans-serif
   - Suggested: Merriweather, Lora, PT Sans

### Font Specifications
- **Format**: TrueType (.ttf) or OpenType (.otf)
- **License**: Free for commercial use or SIL Open Font License
- **Character Set**: Latin alphabet + numbers + common symbols
- **Size Range**: Scalable (vector)

## Placeholder Setup (For Testing)

If you don't have assets yet, you can run the game with placeholders:

### Sounds
The game will run without sound files but will show warnings in console. To suppress:
- Create empty .ogg files in `assets/sounds/`
- Or comment out SoundManager calls temporarily

### Images
The game uses ColorRect nodes as placeholders for most visuals:
- Cards: Colored rectangles with text labels
- Slots: Colored borders and backgrounds
- UI: Built-in Godot theme elements

### Fonts
Godot uses default system fonts automatically if custom fonts are missing.

## Asset Sources (Recommended)

### Free Sound Effects
- **Freesound.org** - Creative Commons sound library
- **OpenGameArt.org** - Free game assets
- **Kenney.nl** - Free game asset packs
- **Zapsplat.com** - Free SFX (attribution required)

### Free Music
- **Incompetech.com** - Royalty-free music by Kevin MacLeod
- **FreeSound.org** - User-uploaded music
- **Purple Planet Music** - Free background music

### Free Images/Art
- **OpenGameArt.org** - Free game sprites and art
- **Kenney.nl** - Game asset packs
- **Itch.io** - Free and paid asset packs
- **Game-Icons.net** - Free SVG icons

### Free Fonts
- **Google Fonts** - Hundreds of free fonts
- **Font Squirrel** - Commercial-use free fonts
- **DaFont.com** - Free fonts (check licenses)

## File Structure Example

```
CardGameGD/assets/
├── sounds/
│   ├── click.ogg
│   ├── card_draw.ogg
│   ├── menu_music.ogg
│   └── ... (20+ sound files)
├── images/
│   ├── creatures/
│   │   ├── dragon.png
│   │   ├── phoenix.png
│   │   └── ... (100+ creature images)
│   ├── spells/
│   │   ├── fireball.png
│   │   └── ... (50+ spell images)
│   ├── ui/
│   │   ├── card_frame.png
│   │   ├── button_normal.png
│   │   └── ... (UI elements)
│   ├── icons/
│   │   ├── icon_fire.png
│   │   └── ... (element icons)
│   └── backgrounds/
│       └── ... (background images)
└── fonts/
    ├── main_font.ttf
    ├── title_font.ttf
    └── card_text_font.ttf
```

## Integration Notes

### Importing into Godot
1. Add asset files to appropriate directories
2. Godot will auto-import with default settings
3. Check Import tab for each asset to adjust:
   - **Sounds**: Loop mode for music
   - **Images**: Compression, mipmaps for large textures
   - **Fonts**: Antialiasing, hinting

### Updating SoundManager
Edit `scripts/autoload/sound_manager.gd` to reference your sound files:
```gdscript
func _load_sounds() -> void:
    sounds[Sound.CLICK] = load("res://assets/sounds/click.ogg")
    # ... add all sound loads
```

### Updating Card Visuals
Edit `scripts/ui/card_visual.gd` to load card images:
```gdscript
func _load_card_image(card_name: String) -> Texture2D:
    var path := "res://assets/images/creatures/%s.png" % card_name.to_lower()
    return load(path)
```

## License Compliance

**Important**: Ensure all assets comply with licensing requirements:
- ✅ Free for commercial use, or
- ✅ Creative Commons (check attribution requirements), or
- ✅ Public domain

Always credit asset creators as required by their licenses!

---

**Note**: The game is fully functional without assets, using Godot's built-in ColorRect and Label nodes for visuals and running silently without audio. Assets enhance the experience but aren't required for testing core gameplay.
