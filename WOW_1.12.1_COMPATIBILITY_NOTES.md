# WoW 1.12.1 Compatibility Notes

## Fixed Issues
- ✅ **MicroButtonFrame**: Replaced with individual micro button hiding
- ✅ **Defensive frame checks**: Added nil checks for all Blizzard UI frames
- ✅ **UIFrameFade fallback**: Added fallback for missing UIFrameFade function
- ✅ **Varargs syntax**: Fixed `...` parameter handling in event functions
- ✅ **Namespace references**: All TuiUI → TUI conversions complete

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
