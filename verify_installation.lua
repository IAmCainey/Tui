-- Installation Verification Script for TUI
-- Run this in WoW console to verify addon is properly loaded

local function VerifyTUI()
    -- Check if addon is loaded
    if not TUI then
        print("ERROR: TUI addon not found!")
        print("Please check that TUI folder is in Interface/AddOns/")
        return false
    end
    
    print("TUI Verification Results:")
    print("==========================")
    
    -- Check core components
    local components = {
        {"Core Module", TUI.Core},
        {"Database Module", TUI.Database}, 
        {"Utils Module", TUI.Utils},
        {"Action Bars Module", TUI.ActionBars},
        {"Unit Frames Module", TUI.UnitFrames},
        {"Group Frames Module", TUI.GroupFrames}
    }
    
    local allGood = true
    for _, component in ipairs(components) do
        local name, module = component[1], component[2]
        if module then
            print("✓ " .. name .. " - OK")
        else
            print("✗ " .. name .. " - MISSING")
            allGood = false
        end
    end
    
    -- Check saved variables
    if TUICharDB and TUICharDB.profile then
        print("✓ Character Database - OK")
    else
        print("? Character Database - Not initialized (normal on first load)")
    end
    
    -- Check if UI is loaded
    if TUI.loaded then
        print("✓ UI Initialization - COMPLETE")
    else
        print("? UI Initialization - PENDING (may need /reload)")
    end
    
    -- Version info
    print("Version: " .. (TUI.version or "Unknown"))
    
    if allGood then
        print("\n✓ TUI is properly installed and loaded!")
        print("All default UI elements should be hidden.")
        print("Use /reload or relog if you don't see the custom UI.")
    else
        print("\n✗ TUI installation has issues!")
        print("Check addon folder structure and restart WoW.")
    end
    
    return allGood
end

-- Auto-run verification
VerifyTUI()
