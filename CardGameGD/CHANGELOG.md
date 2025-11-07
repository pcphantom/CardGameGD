# Changelog - Spectromancer Godot Conversion

All notable changes to this project will be documented in this file.

## [Phase 7 Complete] - 2025-11-06

### Added - Network Multiplayer & Polish

#### Network Systems (STEPS 39-43)
- P2P direct connection using ENetMultiplayerPeer (port 5000)
- WebRTC matchmaking with signaling server support
- Network event system for game state synchronization
- Unified NetworkManager integrating both P2P and WebRTC
- Server browser with LAN discovery (UDP port 4446)
- Network UI components (Multiplayer Menu)
- Network event integration in game controller
- Turn-based multiplayer support with turn indicators

#### Sound System (STEP 44)
- SoundManager autoload singleton
- Background music support with looping
- 20+ sound effect types (attack, heal, damage, summon, etc.)
- Volume controls (Master, Music, SFX)
- Sound integration in all game events (creatures, spells, combat)

#### UI Systems (STEPS 45-46, 49-50)
- Main Menu with fade transitions and button hover effects
- Settings Menu with audio and network configuration
- Settings persistence using ConfigFile (user://settings.cfg)
- Tutorial system with 13 comprehensive pages
- Game log with color-coding and message filtering
- Victory/Defeat screens with animations
- Pause menu (ESC key) with Resume/Settings/Forfeit/Quit
- Turn timer display (MM:SS format)
- FPS counter (F3 toggle)
- Card tooltip system (0.5s hover delay)

#### Visual Polish (STEPS 47, 49)
- Card glow shader (card_glow.gdshader)
- Enhanced player visuals:
  - Player avatar icon
  - Animated life bar with color transitions (green/yellow/red)
  - Pulsating turn indicator (gold glow border)
  - Elemental power change animations (floating numbers)
- Enhanced log panel:
  - Filter panel with checkboxes for message types
  - Auto-scroll toggle
  - Timestamps on all messages
  - Real-time visibility updates
- Enhanced slot visuals:
  - Hover glow effect (white overlay)
  - Drop target indicators (green=valid, red=invalid)
  - Pulsating drop animations
  - Occupation animation (scale + fade)
- Enhanced card visuals:
  - Hover effects (scale, z-index, glow)
  - Drag effects (ghost, transparency, rotation)
  - Attack animations (forward/back, particles)
  - Damage effects (red flash, shake)
  - Heal effects (green flash, particles)
  - Death animations (fade, fall, rotate, explosion)
- Victory confetti particles (50 colored particles)

### Changed
- Updated project.godot to Godot 4.5.1
- Changed main scene to main_menu.tscn
- Updated project name to "Spectromancer Card Game"

### Technical Details
- Total new files: ~17 files created
- Total updated files: ~10 files modified
- New code lines: ~4,000+ lines of GDScript
- Scene files: 4 new .tscn files (menus, tutorial)
- Shader files: 1 custom shader
- Documentation: README.md, ASSETS.md, CHANGELOG.md

### File Structure
```
CardGameGD/
├── README.md                    (NEW)
├── ASSETS.md                    (NEW)
├── CHANGELOG.md                 (NEW)
├── icon.svg                     (NEW)
├── project.godot                (UPDATED)
├── assets/
│   ├── sounds/.gitkeep          (NEW)
│   ├── images/.gitkeep          (NEW)
│   └── fonts/.gitkeep           (NEW)
├── scenes/ui/
│   ├── main_menu.tscn           (NEW)
│   ├── multiplayer_menu.tscn    (NEW)
│   ├── settings_menu.tscn       (NEW)
│   └── tutorial.tscn            (NEW)
├── scripts/network/
│   ├── p2p_connection.gd        (NEW)
│   ├── webrtc_matchmaking.gd    (NEW)
│   └── network_event.gd         (NEW)
├── scripts/autoload/
│   ├── sound_manager.gd         (NEW)
│   └── network_manager.gd       (NEW)
├── scripts/ui/
│   ├── main_menu.gd             (NEW)
│   ├── multiplayer_menu.gd      (NEW)
│   ├── server_browser.gd        (NEW)
│   ├── settings_menu.gd         (NEW)
│   ├── tutorial.gd              (NEW)
│   ├── player_visual.gd         (UPDATED)
│   ├── log_panel.gd             (UPDATED)
│   ├── slot_visual.gd           (UPDATED)
│   └── card_visual.gd           (UPDATED)
├── scripts/creatures/
│   └── base_creature.gd         (UPDATED)
├── scripts/spells/
│   └── base_spell.gd            (UPDATED)
├── scripts/game_controller.gd   (UPDATED)
├── scripts/core/
│   └── sound.gd                 (NEW)
└── shaders/
    └── card_glow.gdshader       (NEW)
```

## Previous Phases

### [Phase 6] - Earlier
- Base creature system with 100+ unique creatures
- Spell system with 50+ unique spells
- Core game mechanics (turn system, combat, resources)
- Card database with JSON data
- Player system with elemental powers
- Card visual system
- Game controller with basic UI

### [Phases 1-5] - Foundation
- Project setup
- Core classes (Card, Creature, Spell, Player)
- Game manager singleton
- Card database system
- Basic UI framework
- Scene structure

## Known Issues

### Missing Assets
- Sound files not included (see ASSETS.md)
- Card art images not included (using ColorRect placeholders)
- Custom fonts not included (using Godot defaults)

### Not Yet Implemented
- AI opponent (planned for Phase 8)
- Deck building system (planned for Phase 9)
- Campaign mode (planned for Phase 10)
- Card collection/progression (planned for Phase 11)

## Testing Notes

### Multiplayer Testing
- P2P requires port 5000 open on host
- WebRTC requires signaling server URL configuration
- LAN discovery uses UDP port 4446
- Test both connection types independently

### UI Testing
- All menus have fade transitions
- Pause menu works during gameplay (ESC)
- Tutorial has 13 pages with keyboard navigation
- Settings persist across sessions
- FPS counter toggles with F3

### Visual Effects Testing
- Card hover/drag/attack animations
- Life bar color changes based on health
- Turn indicator pulses during active turn
- Victory confetti spawns on win
- Defeat screen darkens on loss

## Version Info
- **Phase**: 7 Complete
- **Status**: Production-ready for multiplayer testing
- **Godot Version**: 4.5.1
- **Renderer**: GL Compatibility
- **Architecture**: Signal-based event system
- **Networking**: ENet + WebRTC
- **Last Updated**: 2025-11-06

---

For detailed asset requirements, see ASSETS.md
For project overview, see README.md
