# WoW 1.12.1 Compatibility Notes

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

### Alternative Solutions:
If ActionButton errors persist, the addon includes:
- Delayed initialization (0.1 second delay)
- pcall protection around all ActionButton calls
- Comprehensive error reporting
- Fallback button creation without ActionButton functions

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
