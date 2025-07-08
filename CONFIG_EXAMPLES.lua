-- TUI Configuration Examples
-- Copy sections to Core/Databa-- Modify the CreateBackdrop function i-- Add this to TUI.lua to create configuration commands:

-- Slash command handler
SLASH_TUI1 = "/tui"
SLASH_TUI2 = "/tuiui"
SlashCmdList["TUI"] = function(msg)
    local command = string.lower(msg or "")
    
    if command == "reset" then
        TUI:ResetConfig()
        DEFAULT_CHAT_FRAME:AddMessage("TUI: Configuration reset to defaults")
    elseif command == "scale" then
        -- Example: /tui scale 1.2
        local scale = tonumber(string.match(msg, "scale%s+([%d%.]+)"))
        if scale and scale > 0 and scale <= 3 then
            TUI:SetConfig(scale, "actionBars", "scale")
            TUI:SetConfig(scale, "unitFrames", "scale")
            TUI:SetConfig(scale, "groupFrames", "scale")
            TUI:UpdateAllFrames()
            DEFAULT_CHAT_FRAME:AddMessage("TUI: Scale set to " .. scale)
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("TUI Commands:")
        DEFAULT_CHAT_FRAME:AddMessage("/tui reset - Reset all settings")
        DEFAULT_CHAT_FRAME:AddMessage("/tui scale X - Set UI scale (0.1-3.0)")
    end
end/Core.lua:

function TUI.Core:CreateBackdrop(frame, inset)
    inset = inset or 0
    
    local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = inset, right = inset, top = inset, bottom = inset}
    }
    
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0.1, 0.1, 0.2, 0.9)  -- Dark blue background
    frame:SetBackdropBorderColor(0.4, 0.4, 0.6, 1)  -- Light blue border
ende default settings

--[[
Example: Modify Action Bar Layout
To change the default action bar positions, modify the defaults table in Core/Database.lua:

actionBars = {
    enabled = true,
    scale = 1.2,  -- Make bars 20% larger
    spacing = 6,  -- Increase button spacing
    showHotkeys = true,
    showMacroNames = false,  -- Hide macro names
    fadeOutOfCombat = true,  -- Fade when not in combat
    bars = {
        bar1 = { enabled = true, x = 0, y = -50, buttonsPerRow = 12 },
        bar2 = { enabled = true, x = 0, y = -90, buttonsPerRow = 12 },
        bar3 = { enabled = true, x = -300, y = -50, buttonsPerRow = 6 },
        bar4 = { enabled = true, x = 300, y = -50, buttonsPerRow = 6 },
        petBar = { enabled = true, x = 0, y = 50, buttonsPerRow = 10 },
        stanceBar = { enabled = true, x = -200, y = 50, buttonsPerRow = 8 }
    }
}
--]]

--[[
Example: Customize Unit Frame Appearance
To modify unit frames, update the unitFrames section:

unitFrames = {
    enabled = true,
    scale = 0.9,  -- Make frames slightly smaller
    showPercent = false,  -- Show actual numbers instead of percentages
    showClassColor = true,
    player = { enabled = true, x = -300, y = -150 },
    target = { enabled = true, x = 300, y = -150 },
    targettarget = { enabled = true, x = 450, y = -200 }
}
--]]

--[[
Example: Raid Frame Layout
To change raid frame organization:

groupFrames = {
    enabled = true,
    scale = 0.8,  -- Smaller raid frames
    showPets = false,  -- Hide pet frames in raid
    showBuffs = false,  -- Hide buffs to save space
    party = { enabled = true, x = -500, y = 100 },
    raid = { 
        enabled = true, 
        x = -600, 
        y = 0, 
        groupsPerRow = 8  -- Show all 8 groups in one row
    }
}
--]]

--[[
Example: Color Customization
To change the default colors, modify the CreateBackdrop function in Core/Core.lua:

function TuiUI.Core:CreateBackdrop(frame, inset)
    inset = inset or 0
    
    local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = inset, right = inset, top = inset, bottom = inset}
    }
    
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0.1, 0.1, 0.2, 0.9)  -- Dark blue background
    frame:SetBackdropBorderColor(0.4, 0.4, 0.6, 1)  -- Light blue border
end
--]]

--[[
Example: Adding Custom Slash Commands
Add this to TuiUI.lua to create configuration commands:

-- Slash command handler
SLASH_TUIUI1 = "/tuiui"
SLASH_TUIUI2 = "/tui"
SlashCmdList["TUIUI"] = function(msg)
    local command = string.lower(msg or "")
    
    if command == "reset" then
        TuiUI:ResetConfig()
        DEFAULT_CHAT_FRAME:AddMessage("TuiUI: Configuration reset to defaults")
    elseif command == "scale" then
        -- Example: /tuiui scale 1.2
        local scale = tonumber(string.match(msg, "scale%s+([%d%.]+)"))
        if scale and scale > 0 and scale <= 3 then
            TuiUI:SetConfig(scale, "actionBars", "scale")
            TuiUI:SetConfig(scale, "unitFrames", "scale")
            TuiUI:SetConfig(scale, "groupFrames", "scale")
            TuiUI:UpdateAllFrames()
            DEFAULT_CHAT_FRAME:AddMessage("TuiUI: Scale set to " .. scale)
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("TuiUI Commands:")
        DEFAULT_CHAT_FRAME:AddMessage("/tuiui reset - Reset all settings")
        DEFAULT_CHAT_FRAME:AddMessage("/tuiui scale X - Set UI scale (0.1-3.0)")
    end
end
--]]

--[[
Example: Class-Specific Configurations
Add class-specific defaults in Database.lua initialization:

function TUI:InitializeDatabase()
    -- ... existing code ...
    
    -- Apply class-specific overrides
    local _, class = UnitClass("player")
    if class == "HUNTER" then
        -- Hunters might want pet bar more prominent
        self.db.profile.actionBars.bars.petBar.y = 80
    elseif class == "WARRIOR" then
        -- Warriors might want stance bar in a different position
        self.db.profile.actionBars.bars.stanceBar.x = -300
        self.db.profile.actionBars.bars.stanceBar.y = 50
    elseif class == "DRUID" then
        -- Druids might want different stance bar layout
        self.db.profile.actionBars.bars.stanceBar.buttonsPerRow = 4
    end
end
--]]
