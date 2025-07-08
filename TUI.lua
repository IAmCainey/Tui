-- TUI Main Initialization File
-- Custom UI for Turtle WoW 1.12.1

TUI = {}
TUI.version = "1.0.2"
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

-- Register events
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
    TUI:OnEvent(event, arg1, arg2, arg3, arg4, arg5)
end)
