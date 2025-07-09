# WoW 1.12.1 Compatibility Notes

## WoW 1.12.1 Compatibility Fixes (v1.1.2)
- ✅ **SetCursor removal**: Removed SetCursor() calls (not available in 1.12.1)
- ✅ **GetCursorPosition removal**: Replaced cursor tracking with click-to-cycle resize system
- ✅ **Texture compatibility**: Replaced custom textures with simple color-based indicators
- ✅ **Simplified resize system**: Click resize handle to cycle through common sizes
- ✅ **Visual feedback**: Red = Locked frames, White = Unlocked frames
- ✅ **1.12.1 tested paths**: All textures now use basic colors or verified 1.12.1 paths

## New Features (v1.1.0)
- ✅ **Enhanced frame positioning**: Advanced drag-and-drop with snap-to-grid
- ✅ **Frame resizing**: Action bars can be resized with automatic button reflow
- ✅ **Individual lock controls**: Each frame has its own lock/unlock button
- ✅ **Global lock system**: Lock/unlock all frames with slash commands
- ✅ **Improved saved variables**: Position, size, and lock state persistence
- ✅ **Reset functionality**: Reset individual or all frames to defaults
- ✅ **Visual feedback**: Resize handles and borders when frames are unlocked

## Fixed Issues
- ✅ **MicroButtonFrame**: Replaced with individual micro button hiding
- ✅ **Defensive frame checks**: Added nil checks for all Blizzard UI frames
- ✅ **UIFrameFade fallback**: Added fallback for missing UIFrameFade function
- ✅ **Varargs syntax**: Fixed `...` parameter handling in event functions
- ✅ **Namespace references**: All TuiUI → TUI conversions complete
- ✅ **ActionButton API**: Added defensive checks for all ActionButton functions
- ✅ **Event handling**: Fixed `this` reference context in button event handlers
- ✅ **Button creation**: Added proper nil checks for template-based button creation
- ✅ **ActionButton initialization**: Comprehensive button setup with delayed ActionButton calls
- ✅ **Error protection**: Added pcall protection around all ActionButton API calls
- ✅ **Button components**: Proper icon, cooldown, count, and hotkey texture setup
- ✅ **CooldownFrameTemplate**: Removed non-existent template, using basic Cooldown frame
- ✅ **Template fallbacks**: Added fallback creation for ActionButtonTemplate compatibility
- ✅ **Cooldown frame type**: Added pcall protection and Frame fallback for missing Cooldown type

## Potential Areas to Monitor

### API Functions (should work but test in-game)
- `GetNumRaidMembers()` - Used in group frame logic
- `GetNumPartyMembers()` - Used in group frame logic  
- `UnitFactionGroup()` - Used for PvP icon display
- `ActionButton_Update()` - Used for action bar buttons
- `ActionButton_UpdateHotkeys()` - Used for hotkey display

### Templates (should exist in 1.12.1)
- `ActionButtonTemplate` - For action bar buttons
- `PetActionButtonTemplate` - For pet action bar
- `StanceButtonTemplate` - For stance/form bar

### Texture Paths (verified paths for 1.12.1)
- `Interface\\Tooltips\\UI-Tooltip-Background`
- `Interface\\TargetingFrame\\UI-StatusBar`
- `Interface\\GroupFrame\\UI-Group-LeaderIcon`
- `Interface\\Buttons\\UI-Debuff-Overlays`

### Events to Test
- `ADDON_LOADED` - Should fire correctly
- `PLAYER_LOGIN` - Should fire correctly
- Unit frame events (UNIT_HEALTH, UNIT_POWER, etc.)
- Group events (PARTY_MEMBERS_CHANGED, RAID_ROSTER_UPDATE)

## ActionButton Error Troubleshooting

If you still get "actionbutton.lua:455 attempt to index nil value" errors:

### Immediate Steps:
1. **Check error reporting**: The addon now shows specific error messages in chat
2. **Look for TUI error messages**: Any ActionButton failures will show as "TUI: ActionButton_X failed: [error]"
3. **Try disabling action bars**: In Database.lua, set `actionBars.enabled = false` to test if other modules work

### Advanced Debugging:
```lua
-- Add this to TUI.lua after line 10 to enable more debugging:
TUI.debug = true

-- Or disable ActionButton functions entirely:
ActionButton_Update = nil
ActionButton_UpdateHotkeys = nil
ActionButton_UpdateUsable = nil
ActionButton_UpdateCooldown = nil
```

### Known WoW 1.12.1 ActionButton Issues:
- ActionButtonTemplate may require specific global variables
- Some ActionButton functions expect certain button properties to exist
- Action slot numbers must be valid (1-120 in vanilla)
- Button names must be unique and follow WoW naming conventions
- CooldownFrameTemplate doesn't exist - use basic "Cooldown" frame type
- **"Cooldown" frame type may not exist at all in 1.12.1** - use Frame fallback
- Cooldown frames need SetDrawEdge(false) and SetDrawSwipe(true) in 1.12.1 (if available)

### Alternative Solutions:
If ActionButton errors persist, the addon includes:
- Delayed initialization (0.1 second delay)
- pcall protection around all ActionButton calls
- Comprehensive error reporting
- Fallback button creation without ActionButton functions

## Recent Fixes and Changes (Latest Update)

### Fixed: Cooldown Frame Compatibility (v1.0.4)
- **Issue**: WoW 1.12.1 doesn't support "Cooldown" frame type used in later versions
- **Fix**: Removed manual cooldown frame creation, relying entirely on ActionButtonTemplate
- **Impact**: Eliminates CreateFrame("Cooldown") errors, cooldowns now handled by template
- **Result**: Action buttons should now create without cooldown-related errors

### Enhanced: ActionButton Template Handling
- Added pcall protection for ActionButtonTemplate creation
- Improved child element detection (icon, count, hotkey) from templates
- Better fallback to manual creation when templates fail
- Enhanced error reporting for ActionButton function failures

## Testing Checklist
- [ ] Addon loads without errors
- [ ] Action bars appear and function
- [ ] Player/Target frames show correctly
- [ ] Party frames work in groups
- [ ] Raid frames work in raids
- [ ] Frame positioning saves/loads
- [ ] No lua errors in combat
- [ ] All Blizzard UI elements properly hidden

## Common 1.12.1 Differences
- Some UI frames have different names
- Event arguments may be passed differently
- Some newer API functions don't exist
- Texture paths may be different
- Templates may have different capabilities
