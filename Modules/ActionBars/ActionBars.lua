-- TUI Action Bars Module
-- Handles action bars and buttons

TUI.ActionBars = {}
TUI.ActionBars.bars = {}
TUI.ActionBars.buttons = {}

-- Initialize action bars
function TUI:InitializeActionBars()
    if not self:GetConfig("actionBars", "enabled") then 
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8000TUI:|r Action bars disabled in config")
        return 
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Initializing action bars...")
    
    -- Initialize with error handling
    local success, err = pcall(function()
        self.ActionBars:CreateBars()
        self.ActionBars:UpdateAll()
    end)
    
    if not success then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000TUI:|r Action bars initialization failed: " .. (err or "unknown error"))
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Action bars initialized successfully")
    end
end

-- Create all action bars
function TUI.ActionBars:CreateBars()
    -- Main action bar
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Creating main action bar...")
    self:CreateBar("bar1", 1, 12)
    
    -- Secondary action bars
    if TUI:GetConfig("actionBars", "bars", "bar2", "enabled") then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Creating action bar 2...")
        self:CreateBar("bar2", 13, 12)
    end
    
    if TUI:GetConfig("actionBars", "bars", "bar3", "enabled") then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Creating action bar 3...")
        self:CreateBar("bar3", 25, 12)
    end
    
    if TUI:GetConfig("actionBars", "bars", "bar4", "enabled") then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Creating action bar 4...")
        self:CreateBar("bar4", 37, 12)
    end
    
    -- Pet bar
    if TUI:GetConfig("actionBars", "bars", "petBar", "enabled") then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Creating pet bar...")
        self:CreatePetBar()
    end
    
    -- Stance/Form bar
    if TUI:GetConfig("actionBars", "bars", "stanceBar", "enabled") then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Creating stance bar...")
        self:CreateStanceBar()
    end
end

-- Create a single action bar
function TUI.ActionBars:CreateBar(barName, startSlot, numButtons)
    local config = TUI:GetConfig("actionBars", "bars", barName)
    if not config or not config.enabled then 
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8000TUI:|r " .. barName .. " is disabled in config")
        return 
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Creating " .. barName .. " (slots " .. startSlot .. "-" .. (startSlot + numButtons - 1) .. ")")
    
    local frame = CreateFrame("Frame", "TUI_" .. barName, UIParent)
    if not frame then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000TUI:|r Failed to create frame for " .. barName)
        return
    end
    
    -- Set initial size (will be overridden by saved config if it exists)
    frame:SetWidth(numButtons * 36 + (numButtons - 1) * 4)
    frame:SetHeight(36)
    
    -- Add layout update function for when frame is resized
    frame.UpdateLayout = function(self)
        local buttonSize = 36
        local spacing = 4
        local frameWidth = self:GetWidth()
        local frameHeight = self:GetHeight()
        
        -- Calculate buttons per row based on frame width
        local maxButtonsPerRow = math.floor((frameWidth + spacing) / (buttonSize + spacing))
        maxButtonsPerRow = math.max(1, math.min(maxButtonsPerRow, numButtons))
        
        -- Update button positions using stored button references
        for i = 1, numButtons do
            local buttonName = "TUI_ActionButton" .. (startSlot + i - 1)
            local button = getglobal(buttonName)
            if button then
                local row = math.floor((i - 1) / maxButtonsPerRow)
                local col = (i - 1) % maxButtonsPerRow
                
                button:ClearAllPoints()
                button:SetPoint("TOPLEFT", self, "TOPLEFT", 
                    col * (buttonSize + spacing), 
                    -row * (buttonSize + spacing))
            end
        end
        
        -- Update stored buttons per row config
        TUI:SetConfig(maxButtonsPerRow, "actionBars", "bars", barName, "buttonsPerRow")
    end
    
    -- Set position and size from config
    local success, err = pcall(TUI.Utils.SetAdvancedFramePosition, TUI.Utils, frame, {"actionBars", "bars", barName})
    if not success then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8000TUI:|r Failed to set position for " .. barName .. ": " .. (err or "unknown error"))
        -- Fallback to basic positioning
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
    end
    
    -- Make advanced draggable with resize capability
    success, err = pcall(TUI.Utils.MakeAdvancedDraggable, TUI.Utils, frame, {"actionBars", "bars", barName}, {
        allowResize = true,
        minWidth = 40,  -- At least 1 button
        maxWidth = 12 * 40,  -- At most 12 buttons wide
        minHeight = 36,  -- At least 1 row
        maxHeight = 5 * 40,  -- At most 5 rows
        snapToGrid = 4
    })
    
    if not success then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff8000TUI:|r Failed to make " .. barName .. " draggable: " .. (err or "unknown error"))
    end
    
    -- Create buttons
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Creating " .. numButtons .. " buttons for " .. barName)
    local buttonsCreated = 0
    
    for i = 1, numButtons do
        local button = self:CreateActionButton(frame, startSlot + i - 1, i)
        if button then
            local row = math.floor((i - 1) / (config.buttonsPerRow or 12))
            local col = (i - 1) % (config.buttonsPerRow or 12)
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", col * 40, -row * 40)
            buttonsCreated = buttonsCreated + 1
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff8000TUI:|r Failed to create button " .. i .. " for " .. barName)
        end
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Created " .. buttonsCreated .. "/" .. numButtons .. " buttons for " .. barName)
    
    -- Initial layout update
    if frame.UpdateLayout then
        local success, err = pcall(frame.UpdateLayout, frame)
        if not success then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff8000TUI:|r Layout update failed for " .. barName .. ": " .. (err or "unknown error"))
        end
    end
    
    self.bars[barName] = frame
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r " .. barName .. " created successfully")
end

-- Create action button
function TUI.ActionBars:CreateActionButton(parent, actionSlot, buttonIndex)
    -- Ensure we have a valid action slot
    if not actionSlot or actionSlot < 1 or actionSlot > 120 then
        return nil
    end
    
    -- Create button with unique name
    local buttonName = "TUI_ActionButton" .. actionSlot
    
    -- Try to create button with ActionButtonTemplate, fallback to basic button if template fails
    local button = nil
    local success, templateButton = pcall(CreateFrame, "CheckButton", buttonName, parent, "ActionButtonTemplate")
    if success and templateButton then
        button = templateButton
    else
        -- Fallback: create basic button if ActionButtonTemplate doesn't work
        DEFAULT_CHAT_FRAME:AddMessage("TUI: ActionButtonTemplate failed, creating basic button")
        button = CreateFrame("CheckButton", buttonName, parent)
    end
    
    if not button then return nil end
    
    -- Set up essential button properties BEFORE calling any ActionButton functions
    button:SetID(actionSlot)
    button:SetWidth(36)
    button:SetHeight(36)
    
    -- Initialize required properties for 1.12.1 ActionButtonTemplate
    button.showgrid = 1
    button.action = actionSlot
    
    -- Set up the button icon texture (required for ActionButton functions)
    if not button.icon then
        -- Try to get the icon from the template first
        local templateIcon = getglobal(buttonName .. "Icon")
        if templateIcon then
            button.icon = templateIcon
        else
            -- Create manually if template didn't create it
            button.icon = button:CreateTexture(buttonName .. "Icon", "BORDER")
            button.icon:SetAllPoints(button)
        end
    end
    
    -- Don't manually create cooldown frames - let ActionButtonTemplate handle it
    -- In WoW 1.12.1, the template creates all necessary child frames including cooldown
    
    -- Set up count text (required for stack counting)
    if not button.count then
        -- Try to get the count from the template first
        local templateCount = getglobal(buttonName .. "Count")
        if templateCount then
            button.count = templateCount
        else
            -- Create manually if template didn't create it
            button.count = button:CreateFontString(buttonName .. "Count", "OVERLAY", "NumberFontNormal")
            button.count:SetPoint("BOTTOMRIGHT", button, -2, 2)
        end
    end
    
    -- Set up hotkey text
    if not button.hotkey then
        -- Try to get the hotkey from the template first
        local templateHotkey = getglobal(buttonName .. "HotKey")
        if templateHotkey then
            button.hotkey = templateHotkey
        else
            -- Create manually if template didn't create it
            button.hotkey = button:CreateFontString(buttonName .. "HotKey", "OVERLAY", "NumberFontNormalSmall")
            button.hotkey:SetPoint("TOPLEFT", button, 2, -2)
        end
    end
    
    -- Store reference early
    self.buttons[actionSlot] = button
    
    -- Delay ActionButton function calls to let the template fully initialize
    local function delayedInit()
        -- Initialize the button properly after a short delay
        -- Use pcall for extra safety in case ActionButton functions have internal errors
        if ActionButton_Update then
            local success, err = pcall(ActionButton_Update, button)
            if not success then
                DEFAULT_CHAT_FRAME:AddMessage("TUI: ActionButton_Update failed: " .. (err or "unknown error"))
            end
        end
        
        if ActionButton_UpdateHotkeys then
            local success, err = pcall(ActionButton_UpdateHotkeys, button, TUI:GetConfig("actionBars", "showHotkeys"))
            if not success then
                DEFAULT_CHAT_FRAME:AddMessage("TUI: ActionButton_UpdateHotkeys failed: " .. (err or "unknown error"))
            end
        end
    end
    
    -- Schedule delayed initialization
    local timer = CreateFrame("Frame")
    timer.timeLeft = 0.1
    timer:SetScript("OnUpdate", function()
        timer.timeLeft = timer.timeLeft - arg1
        if timer.timeLeft <= 0 then
            delayedInit()
            timer:SetScript("OnUpdate", nil)
        end
    end)

    -- Register events with defensive event handling
    button:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    button:RegisterEvent("PLAYER_AURAS_CHANGED")
    button:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    
    button:SetScript("OnEvent", function()
        local buttonRef = this or button
        if not buttonRef then return end
        
        if event == "ACTIONBAR_SLOT_CHANGED" and arg1 == buttonRef:GetID() then
            if ActionButton_Update then
                local success, err = pcall(ActionButton_Update, buttonRef)
                if not success then
                    DEFAULT_CHAT_FRAME:AddMessage("TUI: ActionButton_Update event failed: " .. (err or "unknown error"))
                end
            end
        elseif event == "PLAYER_AURAS_CHANGED" or event == "ACTIONBAR_UPDATE_COOLDOWN" then
            if ActionButton_UpdateUsable then
                local success, err = pcall(ActionButton_UpdateUsable, buttonRef)
                if not success then
                    DEFAULT_CHAT_FRAME:AddMessage("TUI: ActionButton_UpdateUsable failed: " .. (err or "unknown error"))
                end
            end
            if ActionButton_UpdateCooldown then
                local success, err = pcall(ActionButton_UpdateCooldown, buttonRef)
                if not success then
                    DEFAULT_CHAT_FRAME:AddMessage("TUI: ActionButton_UpdateCooldown failed: " .. (err or "unknown error"))
                end
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
    
    -- Add layout update function for pet bar
    frame.UpdateLayout = function(self)
        local buttonSize = 36
        local spacing = 4
        local frameWidth = self:GetWidth()
        
        -- Calculate buttons per row based on frame width
        local maxButtonsPerRow = math.floor((frameWidth + spacing) / (buttonSize + spacing))
        maxButtonsPerRow = math.max(1, math.min(maxButtonsPerRow, 10))
        
        -- Update button positions
        for i = 1, 10 do
            local button = getglobal("TUI_PetActionButton" .. i)
            if button then
                local row = math.floor((i - 1) / maxButtonsPerRow)
                local col = (i - 1) % maxButtonsPerRow
                
                button:ClearAllPoints()
                button:SetPoint("TOPLEFT", self, "TOPLEFT", 
                    col * (buttonSize + spacing), 
                    -row * (buttonSize + spacing))
            end
        end
        
        -- Update stored buttons per row config
        TUI:SetConfig(maxButtonsPerRow, "actionBars", "bars", "petBar", "buttonsPerRow")
    end
    
    -- Set position and size from config
    TUI.Utils:SetAdvancedFramePosition(frame, {"actionBars", "bars", "petBar"})
    
    -- Make advanced draggable with resize capability
    TUI.Utils:MakeAdvancedDraggable(frame, {"actionBars", "bars", "petBar"}, {
        allowResize = true,
        minWidth = 40,  -- At least 1 button
        maxWidth = 10 * 40,  -- At most 10 buttons wide
        minHeight = 36,  -- At least 1 row
        maxHeight = 5 * 40,  -- At most 5 rows
        snapToGrid = 4
    })
    
    -- Create pet buttons
    for i = 1, 10 do
        local button = CreateFrame("CheckButton", "TUI_PetActionButton" .. i, frame, "PetActionButtonTemplate")
        if not button then
            -- Fallback: create basic button if PetActionButtonTemplate doesn't work
            DEFAULT_CHAT_FRAME:AddMessage("TUI: PetActionButtonTemplate failed, creating basic button")
            button = CreateFrame("CheckButton", "TUI_PetActionButton" .. i, frame)
        end
        
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
    
    -- Add layout update function for stance bar
    frame.UpdateLayout = function(self)
        local buttonSize = 36
        local spacing = 4
        local frameWidth = self:GetWidth()
        
        -- Calculate buttons per row based on frame width
        local maxButtonsPerRow = math.floor((frameWidth + spacing) / (buttonSize + spacing))
        maxButtonsPerRow = math.max(1, math.min(maxButtonsPerRow, 10))
        
        -- Update button positions
        for i = 1, 10 do
            local button = getglobal("TUI_StanceButton" .. i)
            if button then
                local row = math.floor((i - 1) / maxButtonsPerRow)
                local col = (i - 1) % maxButtonsPerRow
                
                button:ClearAllPoints()
                button:SetPoint("TOPLEFT", self, "TOPLEFT", 
                    col * (buttonSize + spacing), 
                    -row * (buttonSize + spacing))
            end
        end
        
        -- Update stored buttons per row config
        TUI:SetConfig(maxButtonsPerRow, "actionBars", "bars", "stanceBar", "buttonsPerRow")
    end
    
    -- Set position and size from config
    TUI.Utils:SetAdvancedFramePosition(frame, {"actionBars", "bars", "stanceBar"})
    
    -- Make advanced draggable with resize capability
    TUI.Utils:MakeAdvancedDraggable(frame, {"actionBars", "bars", "stanceBar"}, {
        allowResize = true,
        minWidth = 40,  -- At least 1 button
        maxWidth = 10 * 40,  -- At most 10 buttons wide
        minHeight = 36,  -- At least 1 row
        maxHeight = 5 * 40,  -- At most 5 rows
        snapToGrid = 4
    })
    
    -- Create stance buttons
    for i = 1, 10 do
        local button = CreateFrame("CheckButton", "TUI_StanceButton" .. i, frame, "StanceButtonTemplate")
        if not button then
            -- Fallback: create basic button if StanceButtonTemplate doesn't work
            DEFAULT_CHAT_FRAME:AddMessage("TUI: StanceButtonTemplate failed, creating basic button")
            button = CreateFrame("CheckButton", "TUI_StanceButton" .. i, frame)
        end
        
        if button then
            button:SetID(i)
            button:SetWidth(36)
            button:SetHeight(36)
            button:SetPoint("LEFT", frame, "LEFT", (i - 1) * 40, 0)
        end
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
            
            -- Update position using the advanced positioning system
            TUI.Utils:SetAdvancedFramePosition(frame, {"actionBars", "bars", barName})
        end
    end
    
    -- Update button settings
    for _, button in pairs(self.buttons) do
        if button and ActionButton_UpdateHotkeys then
            local success, err = pcall(ActionButton_UpdateHotkeys, button, TUI:GetConfig("actionBars", "showHotkeys"))
            if not success then
                DEFAULT_CHAT_FRAME:AddMessage("|cffff8000TUI:|r ActionButton_UpdateHotkeys failed: " .. (err or "unknown error"))
            end
        end
    end
end
