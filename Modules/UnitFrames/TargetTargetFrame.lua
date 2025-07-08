-- TUI Target's Target Frame Module
-- Handles the target's target unit frame

-- Create target's target frame
function TUI.UnitFrames:CreateTargetTargetFrame()
    local config = TUI:GetConfig("unitFrames", "targettarget")
    if not config or not config.enabled then return end
    
    local frame = self:CreateBaseFrame("TUI_TargetTargetFrame", "targettarget", 120, 40)
    
    -- Set position
    TUI.Utils:SetFramePosition(frame, "unitFrames", "targettarget")
    
    -- Make draggable
    TUI.Utils:MakeDraggable(frame, "unitFrames", "targettarget")
    
    -- Modify the frame for smaller size
    -- Adjust portrait size
    if frame.portrait then
        frame.portrait:SetWidth(36)
        frame.portrait:SetHeight(36)
    end
    
    -- Adjust bar sizes
    if frame.healthBar then
        frame.healthBar:SetWidth(76)
        frame.healthBar:SetHeight(16)
        frame.healthBar:SetPoint("TOPLEFT", frame.portrait, "TOPRIGHT", 4, -2)
    end
    
    if frame.manaBar then
        frame.manaBar:SetWidth(76)
        frame.manaBar:SetHeight(16)
        frame.manaBar:SetPoint("BOTTOMLEFT", frame.portrait, "BOTTOMRIGHT", 4, 2)
    end
    
    -- Adjust text positions and sizes
    if frame.nameText then
        frame.nameText:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 2, 8)
        frame.nameText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
    end
    
    if frame.levelText then
        frame.levelText:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", -2, 8)
        frame.levelText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
    end
    
    -- TargetTarget-specific events
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("UNIT_TARGET")
    
    -- Override event handler
    local originalOnEvent = frame:GetScript("OnEvent")
    frame:SetScript("OnEvent", function()
        -- Call original handler first
        if originalOnEvent then
            originalOnEvent()
        end
        
        -- Handle targettarget-specific events
        if event == "PLAYER_TARGET_CHANGED" or (event == "UNIT_TARGET" and arg1 == "target") then
            TUI.UnitFrames:UpdateFrame(frame)
        end
    end)
    
    -- Make clickable for targeting
    frame:SetScript("OnClick", function()
        if UnitExists("targettarget") then
            TargetUnit("targettarget")
        end
    end)
    frame:RegisterForClicks("LeftButtonUp")
    
    -- Add tooltip
    frame:SetScript("OnEnter", function()
        if UnitExists("targettarget") then
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetUnit("targettarget")
            GameTooltip:Show()
        end
    end)
    
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Store frame
    self.frames.targettarget = frame
    
    -- Initial update
    self:UpdateFrame(frame)
end

-- Override UpdateFrame for targettarget to handle smaller text
function TUI.UnitFrames:UpdateTargetTargetFrame(frame)
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
    local healthText = ""
    
    -- Use shorter text format for smaller frame
    if maxHealth > 0 then
        local percent = math.floor((health / maxHealth) * 100)
        healthText = percent .. "%"
    end
    
    TUI.Utils:UpdateStatusBar(frame.healthBar, health, maxHealth, healthText, 0, 1, 0)
    
    -- Update mana/energy/rage
    local powerType = UnitPowerType(unit)
    local power = UnitMana(unit)
    local maxPower = UnitManaMax(unit)
    local powerText = ""
    
    -- Use shorter text format for smaller frame
    if maxPower > 0 then
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
    
    -- Update name (shortened)
    if frame.nameText then
        local name = UnitName(unit)
        if name and string.len(name) > 8 then
            name = string.sub(name, 1, 8) .. ".."
        end
        
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
        frame.levelText:SetText(tostring(level))
    end
end
