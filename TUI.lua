-- TUI Main Initialization File
-- Custom UI for Turtle WoW 1.12.1

TUI = {}
TUI.version = "1.1.3"
TUI.loaded = false

-- Event frame for initialization
local eventFrame = CreateFrame("Frame", "TUIEventFrame")

-- Initialize the addon
function TUI:Initialize()
    if self.loaded then return end
    
    -- Print welcome message
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI|r v" .. self.version .. " loaded!")
    
    -- Initialize database
    self:InitializeDatabase()
    
    -- Hide default Blizzard UI elements
    self:HideBlizzardUI()
    
    -- Initialize modules
    self:InitializeActionBars()
    self:InitializeUnitFrames()
    self:InitializeGroupFrames()
    
    self.loaded = true
end

-- Event handler
function TUI:OnEvent(event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == "TUI" then
            self:Initialize()
        end
    elseif event == "PLAYER_LOGIN" then
        -- Ensure everything is set up after login
        self:PostLoginSetup()
    end
end

-- Post-login setup
function TUI:PostLoginSetup()
    -- Additional setup that requires the player to be fully logged in
    self:UpdateAllFrames()
end

-- Update all frames
function TUI:UpdateAllFrames()
    if self.ActionBars then
        self.ActionBars:UpdateAll()
    end
    if self.UnitFrames then
        self.UnitFrames:UpdateAll()
    end
    if self.GroupFrames then
        self.GroupFrames:UpdateAll()
    end
end

-- Refresh UI after config changes
function TUI:RefreshUI()
    -- Refresh action bars
    if self.ActionBars and self:GetConfig("actionBars", "enabled") then
        for barName, frame in pairs(self.ActionBars.bars) do
            if frame and frame.configKey then
                local isLocked = false
                
                -- Handle table format configKey
                if type(frame.configKey) == "table" then
                    isLocked = self:GetConfig(frame.configKey[1], frame.configKey[2], frame.configKey[3], "locked") or false
                else
                    isLocked = self:GetConfig(frame.configKey, "locked") or false
                end
                
                if frame.isLocked ~= isLocked then
                    frame.isLocked = isLocked
                    -- Update visual state manually
                    if frame.lockButton then
                        -- Trigger lock state update without actually clicking
                        if frame.isLocked then
                            frame.lockButton.icon:SetTexture(1, 0, 0, 0.8) -- Red for locked
                            frame.lockButton:SetAlpha(0.7)
                            frame:SetMovable(false)
                            frame:EnableMouse(false)
                            if frame.resizeHandle then
                                frame.resizeHandle:Hide()
                            end
                            if frame.border then
                                frame.border:Hide()
                            end
                        else
                            frame.lockButton.icon:SetTexture(1, 1, 1, 0.8) -- White for unlocked
                            frame.lockButton:SetAlpha(1.0)
                            frame:SetMovable(true)
                            frame:EnableMouse(true)
                            frame:RegisterForDrag("LeftButton")
                            if frame.resizeHandle then
                                frame.resizeHandle:Show()
                            end
                            if frame.border then
                                frame.border:Show()
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Slash commands for UI management
SLASH_TUI1 = "/tui"
SLASH_TUI2 = "/tuiui"

function SlashCmdList.TUI(msg)
    local command = string.lower(msg or "")
    
    if command == "lock" then
        TUI.Utils:ToggleAllFrameLocks(true)
    elseif command == "unlock" then
        TUI.Utils:ToggleAllFrameLocks(false)
    elseif command == "reset" then
        -- Reset all frame positions
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Resetting all frame positions to defaults...")
        
        -- Reset action bars
        TUI.Utils:ResetFramePosition(TUI.ActionBars.bars.bar1, {"actionBars", "bars", "bar1"}, {x = 0, y = -200, width = 480, height = 36})
        TUI.Utils:ResetFramePosition(TUI.ActionBars.bars.bar2, {"actionBars", "bars", "bar2"}, {x = 0, y = -240, width = 480, height = 36})
        TUI.Utils:ResetFramePosition(TUI.ActionBars.bars.petBar, {"actionBars", "bars", "petBar"}, {x = 0, y = -160, width = 400, height = 36})
        TUI.Utils:ResetFramePosition(TUI.ActionBars.bars.stanceBar, {"actionBars", "bars", "stanceBar"}, {x = -400, y = -200, width = 400, height = 36})
        
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Frame positions reset!")
    elseif command == "debug" then
        -- Debug information
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI Debug Information:|r")
        DEFAULT_CHAT_FRAME:AddMessage("Loaded: " .. tostring(TUI.loaded))
        DEFAULT_CHAT_FRAME:AddMessage("ActionBars enabled: " .. tostring(TUI:GetConfig("actionBars", "enabled")))
        
        if TUI.ActionBars then
            local barCount = 0
            for barName, frame in pairs(TUI.ActionBars.bars) do
                if frame then
                    barCount = barCount + 1
                    DEFAULT_CHAT_FRAME:AddMessage("  " .. barName .. ": " .. tostring(frame:GetName()) .. " (" .. frame:GetWidth() .. "x" .. frame:GetHeight() .. ")")
                end
            end
            DEFAULT_CHAT_FRAME:AddMessage("Total bars created: " .. barCount)
            
            local buttonCount = 0
            for _, button in pairs(TUI.ActionBars.buttons) do
                if button then
                    buttonCount = buttonCount + 1
                end
            end
            DEFAULT_CHAT_FRAME:AddMessage("Total buttons created: " .. buttonCount)
        else
            DEFAULT_CHAT_FRAME:AddMessage("ActionBars module not initialized")
        end
    elseif command == "config" or command == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI v" .. TUI.version .. " Commands:|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff/tui lock|r - Lock all frames (prevent moving/resizing)")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff/tui unlock|r - Unlock all frames (allow moving/resizing)")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff/tui reset|r - Reset all frame positions to defaults")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff/tui debug|r - Show debug information")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8000Note:|r Individual frames can be locked/unlocked using the lock button in their top-right corner")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8000Note:|r Drag frames to move them, click the bottom-right corner to cycle resize")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8000Lock indicators:|r Red = Locked, White = Unlocked")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000TUI:|r Unknown command '" .. command .. "'. Type /tui for help.")
    end
end

-- Register events
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
    TUI:OnEvent(event, arg1, arg2, arg3, arg4, arg5)
end)
