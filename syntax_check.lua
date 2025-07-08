-- Simple Lua syntax checker for WoW addon files
-- Mocks common WoW API functions to test syntax

-- Mock WoW API functions
CreateFrame = function() return {} end
UIParent = {}
DEFAULT_CHAT_FRAME = { AddMessage = function() end }
GameTooltip = { SetOwner = function() end, SetUnit = function() end, Show = function() end, Hide = function() end }
RAID_CLASS_COLORS = {}
UnitReactionColor = {}
DebuffTypeColor = {}
GetTime = function() return 0 end
UnitExists = function() return true end
UnitHealth = function() return 100 end
UnitHealthMax = function() return 100 end
UnitMana = function() return 100 end
UnitManaMax = function() return 100 end
UnitName = function() return "Player" end
UnitClass = function() return "WARRIOR" end
UnitLevel = function() return 60 end
UnitPowerType = function() return 0 end
UnitReaction = function() return 4 end
UnitIsPlayer = function() return true end
UnitClassification = function() return "normal" end
UnitIsPartyLeader = function() return false end
UnitIsPVP = function() return false end
UnitFactionGroup = function() return "Alliance" end
UnitIsRaidOfficer = function() return false end
UnitIsDeadOrGhost = function() return false end
UnitBuff = function() return nil end
UnitDebuff = function() return nil end
GetNumRaidMembers = function() return 0 end
GetNumPartyMembers = function() return 0 end
GetRaidRosterInfo = function() return nil, nil, 1 end
SetPortraitTexture = function() end
IsResting = function() return false end
TargetUnit = function() end
ToggleDropDownMenu = function() end
ActionButton_Update = function() end
ActionButton_UpdateHotkeys = function() end
ActionButton_UpdateUsable = function() end
ActionButton_UpdateCooldown = function() end
PetActionButton_Set = function() end
UIFrameFade = function() end
getglobal = function(name) return _G[name] end

-- Global variables
arg1, arg2, arg3, arg4, arg5 = nil, nil, nil, nil, nil
event = nil
this = {}

-- Test all Lua files
local function test_file(filename)
    print("Testing: " .. filename)
    local chunk, err = loadfile(filename)
    if chunk then
        print("✓ Syntax OK")
        return true
    else
        print("✗ Syntax Error: " .. tostring(err))
        return false
    end
end

-- Main execution
local function main()
    local files = {
        "TUI.lua",
        "Core/Core.lua",
        "Core/Database.lua", 
        "Core/Utils.lua",
        "Modules/ActionBars/ActionBars.lua",
        "Modules/UnitFrames/UnitFrames.lua",
        "Modules/UnitFrames/PlayerFrame.lua",
        "Modules/UnitFrames/TargetFrame.lua", 
        "Modules/UnitFrames/TargetTargetFrame.lua",
        "Modules/GroupFrames/GroupFrames.lua",
        "Modules/GroupFrames/PartyFrames.lua",
        "Modules/GroupFrames/RaidFrames.lua"
    }
    
    local all_good = true
    for _, file in ipairs(files) do
        if not test_file(file) then
            all_good = false
        end
    end
    
    if all_good then
        print("\n✓ All files passed syntax check!")
    else
        print("\n✗ Some files have syntax errors!")
    end
end

main()
