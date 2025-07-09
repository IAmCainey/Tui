-- TUI Configuration Examples
-- Copy sections to appropriate files as needed

-- Example: Add custom slash commands to TUI.lua
--[[
SLASH_TUICONFIG1 = "/tuiconfig"
SlashCmdList["TUICONFIG"] = function(msg)
    local command = string.lower(msg or "")
    
    if command == "reset" then
        TUI:ResetConfig()
        DEFAULT_CHAT_FRAME:AddMessage("TUI: Configuration reset to defaults")
    elseif string.match(command, "^scale") then
        local scale = tonumber(string.match(msg, "scale%s+([%d%.]+)"))
        if scale and scale >= 0.1 and scale <= 3.0 then
            TUI:SetConfig(scale, "actionBars", "scale")
            TUI:SetConfig(scale, "unitFrames", "scale") 
            TUI:SetConfig(scale, "groupFrames", "scale")
            TUI:UpdateAllFrames()
            DEFAULT_CHAT_FRAME:AddMessage("TUI: Scale set to " .. scale)
        else
            DEFAULT_CHAT_FRAME:AddMessage("TUI: Invalid scale. Use 0.1-3.0")
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("TUI Config Commands:")
        DEFAULT_CHAT_FRAME:AddMessage("/tuiconfig reset - Reset all settings")
        DEFAULT_CHAT_FRAME:AddMessage("/tuiconfig scale X - Set UI scale (0.1-3.0)")
    end
end
--]]

-- Example: Custom backdrop configuration for Core.lua
--[[
function TUI.Core:CreateCustomBackdrop(frame, inset, bgColor, borderColor)
    inset = inset or 0
    bgColor = bgColor or {0, 0, 0, 0.8}
    borderColor = borderColor or {0.3, 0.3, 0.3, 1}
    
    local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = inset, right = inset, top = inset, bottom = inset}
    }
    
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
end
--]]

-- Example: Database defaults modification for Database.lua
--[[
-- Add to defaults.profile in Database.lua:
customSettings = {
    useClassColors = true,
    showTooltips = true,
    autoHide = false,
    combatAlpha = 0.3
}
--]]

-- Example: Action bar customization for ActionBars.lua
--[[
-- Custom button creation with additional features
function TUI.ActionBars:CreateCustomButton(parent, id, slot)
    local button = self:CreateButton(parent, id, slot)
    
    -- Add custom styling
    button:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    
    -- Add glow effect on hover
    button:SetScript("OnEnter", function()
        this:SetBackdropBorderColor(1, 1, 1, 1)
    end)
    
    button:SetScript("OnLeave", function()
        this:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    end)
    
    return button
end
--]]

-- Example: Unit frame position presets for UnitFrames.lua
--[[
function TUI.UnitFrames:ApplyPreset(presetName)
    local presets = {
        ["classic"] = {
            player = {x = -200, y = -200},
            target = {x = 200, y = -200},
            targettarget = {x = 320, y = -240}
        },
        ["compact"] = {
            player = {x = -150, y = -150},
            target = {x = 150, y = -150},
            targettarget = {x = 250, y = -180}
        }
    }
    
    local preset = presets[presetName]
    if preset then
        for frameType, pos in pairs(preset) do
            TUI:SetConfig(pos.x, "unitFrames", frameType, "x")
            TUI:SetConfig(pos.y, "unitFrames", frameType, "y")
        end
        self:UpdateAll()
    end
end
--]]

-- Example: Group frame layout options for GroupFrames.lua
--[[
function TUI.GroupFrames:SetRaidLayout(layout)
    local layouts = {
        ["5x8"] = {groupsPerRow = 5, maxGroups = 8},
        ["8x5"] = {groupsPerRow = 8, maxGroups = 5},
        ["2x20"] = {groupsPerRow = 2, maxGroups = 20}
    }
    
    local config = layouts[layout]
    if config then
        TUI:SetConfig(config.groupsPerRow, "groupFrames", "raid", "groupsPerRow")
        TUI:SetConfig(config.maxGroups, "groupFrames", "raid", "maxGroups")
        self:UpdateRaidFrames()
    end
end
--]]

-- Example: Custom utility functions for Utils.lua
--[[
function TUI.Utils:CreateGlow(frame, color)
    color = color or {1, 1, 0, 0.5}
    
    local glow = frame:CreateTexture(nil, "BACKGROUND")
    glow:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
    glow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
    glow:SetTexture(color[1], color[2], color[3], color[4])
    
    return glow
end

function TUI.Utils:AnimateFrame(frame, startAlpha, endAlpha, duration)
    if not frame.animTimer then
        frame.animTimer = 0
        frame.animDuration = duration or 0.5
        frame.animStartAlpha = startAlpha
        frame.animEndAlpha = endAlpha
        
        frame:SetScript("OnUpdate", function()
            frame.animTimer = frame.animTimer + arg1
            local progress = frame.animTimer / frame.animDuration
            
            if progress >= 1 then
                frame:SetAlpha(frame.animEndAlpha)
                frame:SetScript("OnUpdate", nil)
                frame.animTimer = nil
            else
                local alpha = frame.animStartAlpha + (frame.animEndAlpha - frame.animStartAlpha) * progress
                frame:SetAlpha(alpha)
            end
        end)
    end
end
--]]
