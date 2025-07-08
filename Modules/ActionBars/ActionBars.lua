-- TUI Action Bars Module
-- Handles action bars and buttons

TUI.ActionBars = {}
TUI.ActionBars.bars = {}
TUI.ActionBars.buttons = {}

-- Initialize action bars
function TUI:InitializeActionBars()
    if not self:GetConfig("actionBars", "enabled") then return end
    
    self.ActionBars:CreateBars()
    self.ActionBars:UpdateAll()
end

-- Create all action bars
function TUI.ActionBars:CreateBars()
    -- Main action bar
    self:CreateBar("bar1", 1, 12)
    
    -- Secondary action bars
    if TUI:GetConfig("actionBars", "bars", "bar2", "enabled") then
        self:CreateBar("bar2", 13, 12)
    end
    
    if TUI:GetConfig("actionBars", "bars", "bar3", "enabled") then
        self:CreateBar("bar3", 25, 12)
    end
    
    if TUI:GetConfig("actionBars", "bars", "bar4", "enabled") then
        self:CreateBar("bar4", 37, 12)
    end
    
    -- Pet bar
    if TUI:GetConfig("actionBars", "bars", "petBar", "enabled") then
        self:CreatePetBar()
    end
    
    -- Stance/Form bar
    if TUI:GetConfig("actionBars", "bars", "stanceBar", "enabled") then
        self:CreateStanceBar()
    end
end

-- Create a single action bar
function TUI.ActionBars:CreateBar(barName, startSlot, numButtons)
    local config = TUI:GetConfig("actionBars", "bars", barName)
    if not config or not config.enabled then return end
    
    local frame = CreateFrame("Frame", "TUI_" .. barName, UIParent)
    frame:SetWidth(numButtons * 36 + (numButtons - 1) * 4)
    frame:SetHeight(36)
    
    -- Set position
    TUI.Utils:SetFramePosition(frame, "actionBars", "bars", barName)
    
    -- Make draggable
    TUI.Utils:MakeDraggable(frame, "actionBars", "bars", barName)
    
    -- Create buttons
    for i = 1, numButtons do
        local button = self:CreateActionButton(frame, startSlot + i - 1, i)
        button:SetPoint("LEFT", frame, "LEFT", (i - 1) * 40, 0)
    end
    
    self.bars[barName] = frame
end

-- Create action button
function TUI.ActionBars:CreateActionButton(parent, actionSlot, buttonIndex)
    local button = CreateFrame("CheckButton", "TUI_ActionButton" .. actionSlot, parent, "ActionButtonTemplate")
    if not button then return nil end
    
    button:SetID(actionSlot)
    button:SetWidth(36)
    button:SetHeight(36)
    
    -- Set up the button properties required for 1.12.1
    button.showgrid = 1
    
    -- Initialize the button properly before calling ActionButton functions
    if ActionButton_Update then
        ActionButton_Update(button)
    end
    
    if ActionButton_UpdateHotkeys then
        ActionButton_UpdateHotkeys(button, TUI:GetConfig("actionBars", "showHotkeys"))
    end
    
    -- Store reference
    self.buttons[actionSlot] = button
    
    -- Register events with defensive event handling
    button:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    button:RegisterEvent("PLAYER_AURAS_CHANGED")
    button:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    
    button:SetScript("OnEvent", function()
        local buttonRef = this or button
        if not buttonRef then return end
        
        if event == "ACTIONBAR_SLOT_CHANGED" and arg1 == buttonRef:GetID() then
            if ActionButton_Update then
                ActionButton_Update(buttonRef)
            end
        elseif event == "PLAYER_AURAS_CHANGED" or event == "ACTIONBAR_UPDATE_COOLDOWN" then
            if ActionButton_UpdateUsable then
                ActionButton_UpdateUsable(buttonRef)
            end
            if ActionButton_UpdateCooldown then
                ActionButton_UpdateCooldown(buttonRef)
            end
        end
    end)
    
    return button
end

-- Create pet action bar
function TUI.ActionBars:CreatePetBar()
    local frame = CreateFrame("Frame", "TUI_PetBar", UIParent)
    frame:SetWidth(10 * 36 + 9 * 4)
    frame:SetHeight(36)
    
    -- Set position
    TUI.Utils:SetFramePosition(frame, "actionBars", "bars", "petBar")
    
    -- Make draggable
    TUI.Utils:MakeDraggable(frame, "actionBars", "bars", "petBar")
    
    -- Create pet buttons
    for i = 1, 10 do
        local button = CreateFrame("CheckButton", "TUI_PetActionButton" .. i, frame, "PetActionButtonTemplate")
        if button then
            button:SetID(i)
            button:SetWidth(36)
            button:SetHeight(36)
            button:SetPoint("LEFT", frame, "LEFT", (i - 1) * 40, 0)
            
            -- Set up the button with defensive check
            if PetActionButton_Set then
                PetActionButton_Set(button)
            end
        end
    end
    
    self.bars.petBar = frame
    
    -- Update pet bar visibility
    frame:RegisterEvent("PET_BAR_UPDATE")
    frame:RegisterEvent("UNIT_PET")
    frame:SetScript("OnEvent", function()
        if UnitExists("pet") then
            this:Show()
        else
            this:Hide()
        end
    end)
end

-- Create stance/form bar
function TUI.ActionBars:CreateStanceBar()
    local frame = CreateFrame("Frame", "TUI_StanceBar", UIParent)
    frame:SetWidth(10 * 36 + 9 * 4)
    frame:SetHeight(36)
    
    -- Set position
    TUI.Utils:SetFramePosition(frame, "actionBars", "bars", "stanceBar")
    
    -- Make draggable
    TUI.Utils:MakeDraggable(frame, "actionBars", "bars", "stanceBar")
    
    -- Create stance buttons
    for i = 1, 10 do
        local button = CreateFrame("CheckButton", "TUI_StanceButton" .. i, frame, "StanceButtonTemplate")
        button:SetID(i)
        button:SetWidth(36)
        button:SetHeight(36)
        button:SetPoint("LEFT", frame, "LEFT", (i - 1) * 40, 0)
    end
    
    self.bars.stanceBar = frame
    
    -- Update stance bar visibility based on class
    local _, class = UnitClass("player")
    if class == "WARRIOR" or class == "DRUID" or class == "PRIEST" or class == "ROGUE" then
        frame:Show()
    else
        frame:Hide()
    end
end

-- Update all action bars
function TUI.ActionBars:UpdateAll()
    for barName, frame in pairs(self.bars) do
        if frame then
            local scale = TUI:GetConfig("actionBars", "scale") or 1.0
            frame:SetScale(scale)
            
            -- Update position
            TUI.Utils:SetFramePosition(frame, "actionBars", "bars", barName)
        end
    end
    
    -- Update button settings
    for _, button in pairs(self.buttons) do
        if button and ActionButton_UpdateHotkeys then
            ActionButton_UpdateHotkeys(button, TUI:GetConfig("actionBars", "showHotkeys"))
        end
    end
end
