-- TUI Target Frame Module
-- Handles the target unit frame

-- Create target frame
function TUI.UnitFrames:CreateTargetFrame()
    local config = TUI:GetConfig("unitFrames", "target")
    if not config or not config.enabled then return end
    
    local frame = self:CreateBaseFrame("TUI_TargetFrame", "target", 200, 60)
    
    -- Set position
    TUI.Utils:SetFramePosition(frame, "unitFrames", "target")
    
    -- Make draggable
    TUI.Utils:MakeDraggable(frame, "unitFrames", "target")
    
    -- Add target-specific elements
    
    -- Create debuff icons
    local debuffFrame = CreateFrame("Frame", nil, frame)
    debuffFrame:SetWidth(200)
    debuffFrame:SetHeight(20)
    debuffFrame:SetPoint("TOP", frame, "BOTTOM", 0, -4)
    frame.debuffFrame = debuffFrame
    
    -- Create buff icons
    local buffFrame = CreateFrame("Frame", nil, frame)
    buffFrame:SetWidth(200)
    buffFrame:SetHeight(20)
    buffFrame:SetPoint("BOTTOM", frame, "TOP", 0, 4)
    frame.buffFrame = buffFrame
    
    -- Add elite/rare indicator
    local eliteTexture = frame:CreateTexture(nil, "OVERLAY")
    eliteTexture:SetWidth(16)
    eliteTexture:SetHeight(16)
    eliteTexture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 16, 16)
    eliteTexture:SetTexture("Interface\\Tooltips\\EliteNameplateIcon")
    eliteTexture:Hide()
    frame.eliteTexture = eliteTexture
    
    -- Target-specific events
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("UNIT_AURA")
    frame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
    
    -- Override event handler
    local originalOnEvent = frame:GetScript("OnEvent")
    frame:SetScript("OnEvent", function()
        if arg1 and arg1 ~= "target" and event ~= "PLAYER_TARGET_CHANGED" then
            return
        end
        
        -- Call original handler first
        if originalOnEvent then
            originalOnEvent()
        end
        
        -- Handle target-specific events
        if event == "PLAYER_TARGET_CHANGED" then
            TUI.UnitFrames:UpdateFrame(frame)
            TUI.UnitFrames:UpdateTargetAuras(frame)
            TUI.UnitFrames:UpdateTargetClassification(frame)
        elseif event == "UNIT_AURA" then
            TUI.UnitFrames:UpdateTargetAuras(frame)
        elseif event == "UNIT_CLASSIFICATION_CHANGED" then
            TUI.UnitFrames:UpdateTargetClassification(frame)
        end
    end)
    
    -- Make clickable for targeting
    frame:SetScript("OnClick", function()
        if arg1 == "RightButton" and UnitExists("target") then
            ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor", 0, 0)
        end
    end)
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    -- Store frame
    self.frames.target = frame
    
    -- Initial update
    self:UpdateFrame(frame)
end

-- Update target auras (buffs/debuffs)
function TUI.UnitFrames:UpdateTargetAuras(frame)
    if not frame or not UnitExists("target") then return end
    
    -- Clear existing aura icons
    if frame.buffIcons then
        for _, icon in pairs(frame.buffIcons) do
            icon:Hide()
        end
    else
        frame.buffIcons = {}
    end
    
    if frame.debuffIcons then
        for _, icon in pairs(frame.debuffIcons) do
            icon:Hide()
        end
    else
        frame.debuffIcons = {}
    end
    
    -- Update buffs
    local buffIndex = 1
    for i = 1, 16 do
        local texture, applications = UnitBuff("target", i)
        if texture then
            local icon = frame.buffIcons[buffIndex]
            if not icon then
                icon = CreateFrame("Frame", nil, frame.buffFrame)
                icon:SetWidth(16)
                icon:SetHeight(16)
                
                local iconTexture = icon:CreateTexture(nil, "ARTWORK")
                iconTexture:SetAllPoints(icon)
                icon.texture = iconTexture
                
                local countText = icon:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
                countText:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT")
                icon.count = countText
                
                frame.buffIcons[buffIndex] = icon
            end
            
            icon:SetPoint("LEFT", frame.buffFrame, "LEFT", (buffIndex - 1) * 18, 0)
            icon.texture:SetTexture(texture)
            
            if applications and applications > 1 then
                icon.count:SetText(applications)
                icon.count:Show()
            else
                icon.count:Hide()
            end
            
            icon:Show()
            buffIndex = buffIndex + 1
        end
    end
    
    -- Update debuffs
    local debuffIndex = 1
    for i = 1, 16 do
        local texture, applications, debuffType = UnitDebuff("target", i)
        if texture then
            local icon = frame.debuffIcons[debuffIndex]
            if not icon then
                icon = CreateFrame("Frame", nil, frame.debuffFrame)
                icon:SetWidth(16)
                icon:SetHeight(16)
                
                local iconTexture = icon:CreateTexture(nil, "ARTWORK")
                iconTexture:SetAllPoints(icon)
                icon.texture = iconTexture
                
                local countText = icon:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
                countText:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT")
                icon.count = countText
                
                -- Color border by debuff type
                local border = icon:CreateTexture(nil, "OVERLAY")
                border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
                border:SetAllPoints(icon)
                icon.border = border
                
                frame.debuffIcons[debuffIndex] = icon
            end
            
            icon:SetPoint("LEFT", frame.debuffFrame, "LEFT", (debuffIndex - 1) * 18, 0)
            icon.texture:SetTexture(texture)
            
            if applications and applications > 1 then
                icon.count:SetText(applications)
                icon.count:Show()
            else
                icon.count:Hide()
            end
            
            -- Set debuff type color
            if debuffType then
                local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"]
                icon.border:SetVertexColor(color.r, color.g, color.b)
            end
            
            icon:Show()
            debuffIndex = debuffIndex + 1
        end
    end
end

-- Update target classification (elite, rare, etc.)
function TUI.UnitFrames:UpdateTargetClassification(frame)
    if not frame or not frame.eliteTexture then return end
    
    if not UnitExists("target") then
        frame.eliteTexture:Hide()
        return
    end
    
    local classification = UnitClassification("target")
    if classification == "elite" or classification == "rareelite" then
        frame.eliteTexture:Show()
        if classification == "rareelite" then
            frame.eliteTexture:SetVertexColor(1, 0.84, 0) -- Gold for rare elite
        else
            frame.eliteTexture:SetVertexColor(1, 1, 1) -- White for elite
        end
    elseif classification == "rare" then
        frame.eliteTexture:Show()
        frame.eliteTexture:SetVertexColor(0.69, 0.31, 0.31) -- Silver for rare
    else
        frame.eliteTexture:Hide()
    end
end
