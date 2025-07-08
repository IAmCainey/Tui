-- TUI Unit Frames Module
-- Handles player, target, and target's target frames

TUI.UnitFrames = {}
TUI.UnitFrames.frames = {}

-- Initialize unit frames
function TUI:InitializeUnitFrames()
    if not self:GetConfig("unitFrames", "enabled") then return end
    
    self.UnitFrames:CreatePlayerFrame()
    self.UnitFrames:CreateTargetFrame()
    self.UnitFrames:CreateTargetTargetFrame()
    self.UnitFrames:UpdateAll()
end

-- Create base unit frame
function TUI.UnitFrames:CreateBaseFrame(name, unit, width, height)
    local frame = CreateFrame("Button", name, UIParent)
    frame:SetWidth(width)
    frame:SetHeight(height)
    frame.unit = unit
    
    -- Create backdrop
    TUI.Core:CreateBackdrop(frame, 2)
    
    -- Create portrait
    local portrait = CreateFrame("PlayerModel", nil, frame)
    portrait:SetWidth(height - 4)
    portrait:SetHeight(height - 4)
    portrait:SetPoint("LEFT", frame, "LEFT", 2, 0)
    frame.portrait = portrait
    
    -- Create health bar
    local healthBar = TUI.Utils:CreateStatusBar(frame, width - height - 8, (height - 8) / 2)
    healthBar:SetPoint("TOPLEFT", portrait, "TOPRIGHT", 4, -2)
    healthBar:SetStatusBarColor(0, 1, 0)
    frame.healthBar = healthBar
    
    -- Create mana bar
    local manaBar = TUI.Utils:CreateStatusBar(frame, width - height - 8, (height - 8) / 2)
    manaBar:SetPoint("BOTTOMLEFT", portrait, "BOTTOMRIGHT", 4, 2)
    manaBar:SetStatusBarColor(0, 0, 1)
    frame.manaBar = manaBar
    
    -- Create name text
    local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 2, 12)
    nameText:SetJustifyH("LEFT")
    frame.nameText = nameText
    
    -- Create level text
    local levelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelText:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", -2, 12)
    levelText:SetJustifyH("RIGHT")
    frame.levelText = levelText
    
    -- Set up events
    frame:RegisterEvent("UNIT_HEALTH")
    frame:RegisterEvent("UNIT_MAXHEALTH")
    frame:RegisterEvent("UNIT_MANA")
    frame:RegisterEvent("UNIT_MAXMANA")
    frame:RegisterEvent("UNIT_RAGE")
    frame:RegisterEvent("UNIT_MAXRAGE")
    frame:RegisterEvent("UNIT_ENERGY")
    frame:RegisterEvent("UNIT_MAXENERGY")
    frame:RegisterEvent("UNIT_NAME_UPDATE")
    frame:RegisterEvent("UNIT_LEVEL")
    frame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    frame:RegisterEvent("UNIT_MODEL_CHANGED")
    
    frame:SetScript("OnEvent", function()
        TUI.UnitFrames:UpdateFrame(this)
    end)
    
    return frame
end

-- Update frame
function TUI.UnitFrames:UpdateFrame(frame)
    if not frame or not frame.unit or not UnitExists(frame.unit) then 
        if frame then
            frame:Hide()
        end
        return 
    end
    
    frame:Show()
    
    local unit = frame.unit
    
    -- Update portrait
    if frame.portrait then
        SetPortraitTexture(frame.portrait, unit)
    end
    
    -- Update health
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local healthText = health .. " / " .. maxHealth
    
    if TUI:GetConfig("unitFrames", "showPercent") and maxHealth > 0 then
        local percent = math.floor((health / maxHealth) * 100)
        healthText = percent .. "%"
    end
    
    TUI.Utils:UpdateStatusBar(frame.healthBar, health, maxHealth, healthText, 0, 1, 0)
    
    -- Update mana/energy/rage
    local powerType = UnitPowerType(unit)
    local power = UnitMana(unit)
    local maxPower = UnitManaMax(unit)
    local powerText = power .. " / " .. maxPower
    
    if TUI:GetConfig("unitFrames", "showPercent") and maxPower > 0 then
        local percent = math.floor((power / maxPower) * 100)
        powerText = percent .. "%"
    end
    
    local r, g, b = 0, 0, 1 -- Default to blue (mana)
    if powerType == 1 then -- Rage
        r, g, b = 1, 0, 0
    elseif powerType == 2 then -- Focus
        r, g, b = 1, 0.5, 0.25
    elseif powerType == 3 then -- Energy
        r, g, b = 1, 1, 0
    end
    
    TUI.Utils:UpdateStatusBar(frame.manaBar, power, maxPower, powerText, r, g, b)
    
    -- Update name
    if frame.nameText then
        local name = UnitName(unit)
        if TUI:GetConfig("unitFrames", "showClassColor") and UnitIsPlayer(unit) then
            local r, g, b = TUI.Core:GetUnitColor(unit)
            frame.nameText:SetTextColor(r, g, b)
        else
            frame.nameText:SetTextColor(1, 1, 1)
        end
        frame.nameText:SetText(name or "")
    end
    
    -- Update level
    if frame.levelText then
        local level = UnitLevel(unit)
        local classification = UnitClassification(unit)
        local levelText = tostring(level)
        
        if classification == "elite" then
            levelText = levelText .. "+"
        elseif classification == "rareelite" then
            levelText = levelText .. "++"
        elseif classification == "rare" then
            levelText = levelText .. " (Rare)"
        elseif classification == "boss" then
            levelText = "Boss"
        end
        
        frame.levelText:SetText(levelText)
    end
end

-- Update all unit frames
function TUI.UnitFrames:UpdateAll()
    for _, frame in pairs(self.frames) do
        if frame then
            local scale = TUI:GetConfig("unitFrames", "scale") or 1.0
            frame:SetScale(scale)
            self:UpdateFrame(frame)
        end
    end
end
