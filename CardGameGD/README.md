# Spectromancer Card Game - Godot Conversion

Complete conversion of the Spectromancer card battle game from libGDX to Godot 4.5.1

## Project Overview

This is a full-featured lane-based card battle game featuring:
- Turn-based strategy gameplay
- 5 elemental magic systems (Fire, Water, Air, Earth, Other)
- 100+ unique creature and spell cards
- P2P and WebRTC multiplayer support
- Complete sound system
- Tutorial system
- Advanced UI with visual effects

## Requirements

- **Godot Engine**: 4.5.1 or higher
- **Platform**: Windows, Linux, macOS (GL Compatibility renderer)
- **Resolution**: 1024x768 (resizable)

## Project Structure

```
CardGameGD/
├── assets/
│   ├── sounds/          # Audio files (see ASSETS.md for requirements)
│   ├── images/          # Card art and UI graphics
│   └── fonts/           # Custom fonts
├── data/
│   └── cards.json       # Card database (100+ cards)
├── scenes/
│   ├── main.tscn        # Main game scene
│   └── ui/              # UI scenes (menus, tutorial, etc.)
├── scripts/
│   ├── autoload/        # Singleton systems (GameManager, SoundManager, NetworkManager)
│   ├── core/            # Core game logic (Card, Creature, Spell, Player)
│   ├── creatures/       # 100+ creature implementations
│   ├── spells/          # 50+ spell implementations
│   ├── network/         # P2P and WebRTC networking
│   ├── ui/              # UI controllers
│   └── game_controller.gd  # Main game controller
├── shaders/
│   └── card_glow.gdshader  # Card glow effect shader
└── project.godot        # Godot project configuration
```

## Features Implemented

### Core Game Systems
- ✅ Card system (Creatures and Spells)
- ✅ Player system with elemental powers
- ✅ Turn-based game flow
- ✅ Combat system with simultaneous damage
- ✅ Win/loss conditions
- ✅ Card database with 100+ cards

### Creature System
- ✅ 100+ unique creatures across 5 elements
- ✅ Attack/Life stats
- ✅ Special abilities (On Summon, On Death, On Attack, Start/End Turn, Passive)
- ✅ Visual effects and animations

### Spell System
- ✅ 50+ unique spells
- ✅ Direct damage, healing, buffs, control, area effects
- ✅ Targeting system
- ✅ Instant spell effects

### Multiplayer System
- ✅ P2P Direct Connection (ENetMultiplayerPeer, port 5000)
- ✅ WebRTC Matchmaking with signaling server
- ✅ Unified NetworkManager
- ✅ Network event synchronization
- ✅ Turn-based multiplayer support
- ✅ Server browser with LAN discovery (UDP port 4446)

### Sound System
- ✅ SoundManager with background music and SFX
- ✅ Volume controls (Master, Music, SFX)
- ✅ Sound integration in all game events
- ✅ 20+ sound effect types defined

### UI Systems
- ✅ Main Menu with fade transitions
- ✅ Multiplayer Menu (P2P and WebRTC options)
- ✅ Settings Menu (audio and network configuration)
- ✅ Tutorial System (13 comprehensive pages)
- ✅ Game Log with filtering and color-coding
- ✅ Player visuals (avatar, life bar, power indicators, turn glow)
- ✅ Slot visuals (hover effects, drop indicators)
- ✅ Card visuals (hover, drag, attack, damage, death animations)
- ✅ Victory/Defeat screens with animations
- ✅ Pause menu (ESC key)
- ✅ Card tooltips (0.5s hover delay)
- ✅ Turn timer and FPS counter (F3 toggle)

### Visual Effects
- ✅ Card glow shader
- ✅ Hover effects (scale, z-index, glow)
- ✅ Drag effects (ghost image, transparency, rotation)
- ✅ Attack animations (forward/back movement, particles)
- ✅ Damage effects (red flash, screen shake)
- ✅ Heal effects (green flash, upward particles)
- ✅ Death animations (fade, fall, rotate, explosion)
- ✅ Victory confetti particles
- ✅ Animated life bars with color transitions
- ✅ Pulsating turn indicators
- ✅ Slot drop target indicators

## How to Run

1. **Install Godot 4.5.1** or higher
2. **Open the project** in Godot:
   - Launch Godot
   - Click "Import"
   - Navigate to the CardGameGD folder
   - Select project.godot
   - Click "Import & Edit"
3. **Add Assets** (see ASSETS.md for details)
4. **Run the project** (F5 or click Play button)

## Game Controls

### Mouse Controls
- **Left Click**: Select cards, targets, slots
- **Right Click**: Cancel selection
- **Hover**: Show card tooltips (0.5s delay)

### Keyboard Shortcuts
- **ESC**: Pause menu
- **F3**: Toggle FPS counter
- **Space**: End turn (if available)
- **Arrow Keys**: Navigate tutorial pages

## Multiplayer Setup

### P2P Direct Connection
1. Host: Click "Host P2P Game" in Multiplayer Menu
2. Client: Enter host IP address and click "Join P2P Game"
3. Port 5000 must be open on host machine

### WebRTC Matchmaking
1. Configure WebSocket server URL in Settings
2. Click "Find WebRTC Match" in Multiplayer Menu
3. Enter Match ID or create new match
4. No port forwarding required

## Development Status

### Phase 7 Complete ✅
All planned features for Phase 7 (Network Multiplayer & Polish) are implemented:
- Network systems (P2P and WebRTC)
- Sound system integration
- Complete UI polish
- Tutorial system
- Visual effects
- Game is production-ready for testing

### Known Limitations
- **Assets**: Sound files, images, and fonts not included (see ASSETS.md)
- **AI**: Single-player AI not yet implemented (planned for Phase 8)
- **Card Art**: Using placeholder visuals (actual card art needed)
- **Deck Building**: Using default decks (deck builder planned for Phase 9)

## File Counts

- **Total Scripts**: 200+ GDScript files
- **Creatures**: 100+ unique implementations
- **Spells**: 50+ unique implementations
- **UI Scripts**: 9 files (3,539 lines)
- **Scene Files**: 5 .tscn files
- **Network Scripts**: 3 files
- **Autoload Systems**: 4 singletons
- **Shaders**: 1 custom shader

## Technical Details

- **Engine**: Godot 4.5.1
- **Renderer**: GL Compatibility (for broad platform support)
- **Resolution**: 1024x768 (resizable window)
- **Scripting**: 100% GDScript
- **Architecture**: Signal-based event system
- **Networking**: ENet (P2P) + WebRTC (matchmaking)
- **Audio**: Godot AudioStreamPlayer system
- **Persistence**: ConfigFile (settings), JSON (card database)

## License

This is a conversion project for educational purposes.
Original Spectromancer game © Alexey Stankevich

## Credits

- **Original Game**: Spectromancer by Alexey Stankevich
- **Godot Conversion**: Phase 7 implementation
- **Engine**: Godot 4.5.1

## Next Steps (Future Phases)

- **Phase 8**: AI opponent implementation
- **Phase 9**: Deck building system
- **Phase 10**: Campaign mode
- **Phase 11**: Card collection and progression
- **Phase 12**: Polish and optimization

---

**Status**: Production-ready for multiplayer testing
**Version**: Phase 7 Complete
**Last Updated**: 2025-11-06
