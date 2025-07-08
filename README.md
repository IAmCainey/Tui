# TUI - World of Warcraft Custom UI for Turtle WoW 1.12.1

A complete UI replacement addon for World of Warcraft 1.12.1 (Turtle WoW). This addon disables the default Blizzard UI and provides custom action bars, unit frames, and group frames.

## Features

### Action Bars
- Up to 4 customizable action bars
- Pet action bar
- Stance/Form bar (for applicable classes)
- Fully movable and scalable
- Hotkey and macro name display
- Custom button styling

### Unit Frames
- **Player Frame**: Health, mana, portrait, cast bar, combat/resting indicators
- **Target Frame**: Health, mana, portrait, buffs/debuffs, elite indicators
- **Target's Target Frame**: Compact frame showing your target's target

### Group Frames
- **Party Frames**: Shows party members with health, mana, buffs/debuffs
- **Raid Frames**: Compact raid layout organized by groups
- Leader and status indicators
- Class coloring support

### Core Features
- Completely replaces default Blizzard UI
- Drag-and-drop positioning for all frames
- Persistent settings saved per character
- Modular design for easy customization
- Optimized for 1.12.1 client

## Installation

1. Download or clone this repository
2. Copy the entire `TUI` folder to your WoW AddOns directory:
   ```
   World of Warcraft/Interface/AddOns/TUI/
   ```
3. Restart World of Warcraft or reload UI with `/console reloadui`
4. The addon will automatically load and replace the default UI

## Configuration

The addon creates saved variables that persist across sessions:

- **TUIDB**: Global settings
- **TUICharDB**: Character-specific settings

### Default Keybindings
- All default WoW keybindings remain functional
- Action bars respond to standard action bar keybinds
- Frame positioning can be adjusted by dragging while out of combat

### Frame Positioning
All frames can be repositioned by dragging them around the screen. Positions are automatically saved.

## File Structure

```
TUI/
├── TUI.toc              # Addon table of contents
├── TUI.lua              # Main initialization file
├── Core/
│   ├── Core.lua           # Core functionality and utilities
│   ├── Database.lua       # Saved variables and configuration
│   └── Utils.lua          # Utility functions
└── Modules/
    ├── ActionBars/
    │   └── ActionBars.lua # Action bar implementation
    ├── UnitFrames/
    │   ├── UnitFrames.lua      # Base unit frame system
    │   ├── PlayerFrame.lua     # Player-specific frame
    │   ├── TargetFrame.lua     # Target frame with auras
    │   └── TargetTargetFrame.lua # Target's target frame
    └── GroupFrames/
        ├── GroupFrames.lua  # Base group frame system
        ├── PartyFrames.lua  # Party member frames
        └── RaidFrames.lua   # Raid member frames
```

## Customization

The addon is designed to be easily customizable. Key areas for modification:

### Colors and Styling
- Edit `TUI.Core:CreateBackdrop()` in `Core/Core.lua` for frame backgrounds
- Modify color values in unit frame update functions
- Adjust bar textures in `TUI.Utils:CreateStatusBar()`

### Frame Sizes and Positions
- Default sizes and positions are defined in `Core/Database.lua`
- Modify the `defaults` table to change initial layout

### Features
- Enable/disable modules by editing the `enabled` flags in configuration
- Add new bars by extending the action bar module
- Customize group frame layouts in the respective modules

## Compatibility

This addon is specifically designed for:
- **WoW Version**: 1.12.1 (Vanilla)
- **Server**: Turtle WoW (should work on other 1.12.1 servers)
- **Client**: Original 1.12.1 client

## Known Issues

- Some advanced features may require additional event handling for specific server modifications
- Portrait rendering may vary depending on client version
- Cast bar timing relies on standard 1.12.1 spell events

## Contributing

To contribute to this project:
1. Fork the repository
2. Create a feature branch
3. Test thoroughly in-game
4. Submit a pull request

## License

This project is open source. Please respect Blizzard Entertainment's intellectual property when using this code.

## Support

For issues or questions:
- Check the in-game error logs (`/console scriptErrors 1`)
- Verify addon is properly installed in the AddOns folder
- Ensure you're running on a 1.12.1 client
- Test with a fresh character to rule out saved variable conflicts

## Version History

### 1.0.4
- Fixed remaining TuiUI references in GroupFrames.lua and RaidFrames.lua
- Changed `TuiUI.GroupFrames` to `TUI.GroupFrames` in function definitions

### 1.0.3
- Fixed missing GroupFrames.lua in TOC file loading order
- PartyFrames.lua and RaidFrames.lua now properly load after base GroupFrames module

### 1.0.2
- Fixed varargs syntax compatibility issue for WoW 1.12.1
- Changed `function TUI:OnEvent(event, ...)` to `function TUI:OnEvent(event, arg1)` for better 1.12.1 compatibility

### 1.0.1
- Fixed initialization order bug that caused "attempt to index global TUI (a nil value)" error
- Updated TOC file to load TUI.lua before Core modules
- Cleaned up old TuiUI references in documentation

### 1.0.0
- Initial release
- Complete UI replacement
- Action bars, unit frames, and group frames
- Drag-and-drop positioning
- Saved settings support
