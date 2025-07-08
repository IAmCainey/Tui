-- TUI Party Frames Module
-- Handles party member frames

-- Create party frames
function TUI.GroupFrames:CreatePartyFrames()
    local config = TUI:GetConfig("groupFrames", "party")
    if not config or not config.enabled then return end
    
    local partyFrame = CreateFrame("Frame", "TUI_PartyFrame", UIParent)
    partyFrame:SetWidth(150)
    partyFrame:SetHeight(200)
    
    -- Set position
    TUI.Utils:SetFramePosition(partyFrame, "groupFrames", "party")
    
    -- Make draggable
    TUI.Utils:MakeDraggable(partyFrame, "groupFrames", "party")
    
    -- Create header
    local header = partyFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOP", partyFrame, "TOP", 0, -5)
    header:SetText("Party")
    partyFrame.header = header
    
    -- Create party member frames
    partyFrame.memberFrames = {}
    for i = 1, 4 do
        local memberFrame = self:CreatePartyMemberFrame(partyFrame, i)
        memberFrame:SetPoint("TOP", partyFrame, "TOP", 0, -20 - (i - 1) * 45)
        partyFrame.memberFrames[i] = memberFrame
    end
    
    -- Register events
    partyFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
    partyFrame:RegisterEvent("PARTY_MEMBER_ENABLE")
    partyFrame:RegisterEvent("PARTY_MEMBER_DISABLE")
    partyFrame:RegisterEvent("UNIT_HEALTH")
    partyFrame:RegisterEvent("UNIT_MAXHEALTH")
    partyFrame:RegisterEvent("UNIT_MANA")
    partyFrame:RegisterEvent("UNIT_MAXMANA")
    partyFrame:RegisterEvent("UNIT_AURA")
    
    partyFrame:SetScript("OnEvent", function()
        TUI.GroupFrames:UpdatePartyFrames()
    end)
    
    self.frames.party = partyFrame
    
    -- Initial update
    self:UpdatePartyFrames()
end

-- Create individual party member frame
function TUI.GroupFrames:CreatePartyMemberFrame(parent, partyIndex)
    local frame = CreateFrame("Button", "TUI_PartyMember" .. partyIndex, parent)
    frame:SetWidth(140)
    frame:SetHeight(40)
    frame.partyIndex = partyIndex
    frame.unit = "party" .. partyIndex
    
    -- Create backdrop
    TUI.Core:CreateBackdrop(frame, 2)
    
    -- Create portrait
    local portrait = CreateFrame("PlayerModel", nil, frame)
    portrait:SetWidth(36)
    portrait:SetHeight(36)
    portrait:SetPoint("LEFT", frame, "LEFT", 2, 0)
    frame.portrait = portrait
    
    -- Create health bar
    local healthBar = TUI.Utils:CreateStatusBar(frame, 96, 18)
    healthBar:SetPoint("TOPLEFT", portrait, "TOPRIGHT", 4, -2)
    healthBar:SetStatusBarColor(0, 1, 0)
    frame.healthBar = healthBar
    
    -- Create mana bar
    local manaBar = TUI.Utils:CreateStatusBar(frame, 96, 16)
    manaBar:SetPoint("BOTTOMLEFT", portrait, "BOTTOMRIGHT", 4, 2)
    manaBar:SetStatusBarColor(0, 0, 1)
    frame.manaBar = manaBar
    
    -- Create name text
    local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 2, 10)
    nameText:SetJustifyH("LEFT")
    frame.nameText = nameText
    
    -- Create status indicators
    local statusFrame = CreateFrame("Frame", nil, frame)
    statusFrame:SetWidth(60)
    statusFrame:SetHeight(12)
    statusFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    frame.statusFrame = statusFrame
    
    -- Create buff/debuff indicators
    local buffFrame = CreateFrame("Frame", nil, frame)
    buffFrame:SetWidth(140)
    buffFrame:SetHeight(16)
    buffFrame:SetPoint("TOP", frame, "BOTTOM", 0, -2)
    frame.buffFrame = buffFrame
    frame.buffIcons = {}
    
    -- Click handling
    frame:SetScript("OnClick", function()
        if arg1 == "LeftButton" then
            TargetUnit(this.unit)
        elseif arg1 == "RightButton" then
            ToggleDropDownMenu(1, nil, PartyMemberFrame_DropDown, "cursor", 0, 0)
        end
    end)
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    -- Tooltip
    frame:SetScript("OnEnter", function()
        if UnitExists(this.unit) then
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetUnit(this.unit)
            GameTooltip:Show()
        end
    end)
    
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    return frame
end

-- Update party frames
function TUI.GroupFrames:UpdatePartyFrames()
    local partyFrame = self.frames.party
    if not partyFrame then return end
    
    local numPartyMembers = GetNumPartyMembers()
    
    for i = 1, 4 do
        local memberFrame = partyFrame.memberFrames[i]
        if i <= numPartyMembers and UnitExists("party" .. i) then
            memberFrame:Show()
            self:UpdatePartyMemberFrame(memberFrame)
        else
            memberFrame:Hide()
        end
    end
    
    -- Adjust party frame height
    local visibleMembers = math.min(numPartyMembers, 4)
    local newHeight = 25 + visibleMembers * 45
    partyFrame:SetHeight(newHeight)
end

-- Update individual party member frame
function TUI.GroupFrames:UpdatePartyMemberFrame(frame)
    local unit = frame.unit
    if not UnitExists(unit) then return end
    
    -- Update portrait
    SetPortraitTexture(frame.portrait, unit)
    
    -- Update health
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local healthText = ""
    
    if TUI:GetConfig("unitFrames", "showPercent") and maxHealth > 0 then
        local percent = math.floor((health / maxHealth) * 100)
        healthText = percent .. "%"
    else
        healthText = TUI.Core:AbbreviateNumber(health)
    end
    
    TUI.Utils:UpdateStatusBar(frame.healthBar, health, maxHealth, healthText, 0, 1, 0)
    
    -- Update mana
    local power = UnitMana(unit)
    local maxPower = UnitManaMax(unit)
    local powerText = ""
    
    if maxPower > 0 then
        if TUI:GetConfig("unitFrames", "showPercent") then
            local percent = math.floor((power / maxPower) * 100)
            powerText = percent .. "%"
        else
            powerText = TUI.Core:AbbreviateNumber(power)
        end
    end
    
    local powerType = UnitPowerType(unit)
    local r, g, b = 0, 0, 1
    if powerType == 1 then
        r, g, b = 1, 0, 0
    elseif powerType == 3 then
        r, g, b = 1, 1, 0
    end
    
    TUI.Utils:UpdateStatusBar(frame.manaBar, power, maxPower, powerText, r, g, b)
    
    -- Update name
    local name = UnitName(unit)
    if TUI:GetConfig("unitFrames", "showClassColor") and UnitIsPlayer(unit) then
        local r, g, b = TUI.Core:GetUnitColor(unit)
        frame.nameText:SetTextColor(r, g, b)
    else
        frame.nameText:SetTextColor(1, 1, 1)
    end
    frame.nameText:SetText(name or "")
    
    -- Update status indicators
    self:UpdatePartyMemberStatus(frame)
    
    -- Update buffs/debuffs
    if TUI:GetConfig("groupFrames", "showBuffs") then
        self:UpdatePartyMemberAuras(frame)
    end
end

-- Update party member status
function TUI.GroupFrames:UpdatePartyMemberStatus(frame)
    local unit = frame.unit
    if not frame.statusFrame then return end
    
    -- Clear existing status icons
    if frame.statusIcons then
        for _, icon in pairs(frame.statusIcons) do
            icon:Hide()
        end
    else
        frame.statusIcons = {}
    end
    
    local iconIndex = 1
    
    -- Leader icon
    if UnitIsPartyLeader(unit) then
        local icon = frame.statusIcons[iconIndex] or frame.statusFrame:CreateTexture(nil, "OVERLAY")
        icon:SetWidth(12)
        icon:SetHeight(12)
        icon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        icon:SetPoint("LEFT", frame.statusFrame, "LEFT", (iconIndex - 1) * 14, 0)
        icon:Show()
        frame.statusIcons[iconIndex] = icon
        iconIndex = iconIndex + 1
    end
    
    -- PvP icon
    if UnitIsPVP(unit) then
        local icon = frame.statusIcons[iconIndex] or frame.statusFrame:CreateTexture(nil, "OVERLAY")
        icon:SetWidth(12)
        icon:SetHeight(12)
        icon:SetTexture("Interface\\GroupFrame\\UI-Group-PVP-" .. UnitFactionGroup(unit))
        icon:SetPoint("LEFT", frame.statusFrame, "LEFT", (iconIndex - 1) * 14, 0)
        icon:Show()
        frame.statusIcons[iconIndex] = icon
        iconIndex = iconIndex + 1
    end
end

-- Update party member auras
function TUI.GroupFrames:UpdatePartyMemberAuras(frame)
    local unit = frame.unit
    if not frame.buffFrame then return end
    
    -- Clear existing buff icons
    if frame.buffIcons then
        for _, icon in pairs(frame.buffIcons) do
            icon:Hide()
        end
    end
    
    local iconIndex = 1
    
    -- Show important debuffs first
    for i = 1, 8 do
        local texture, applications, debuffType = UnitDebuff(unit, i)
        if texture and iconIndex <= 8 then
            local icon = frame.buffIcons[iconIndex]
            if not icon then
                icon = CreateFrame("Frame", nil, frame.buffFrame)
                icon:SetWidth(12)
                icon:SetHeight(12)
                
                local iconTexture = icon:CreateTexture(nil, "ARTWORK")
                iconTexture:SetAllPoints(icon)
                icon.texture = iconTexture
                
                frame.buffIcons[iconIndex] = icon
            end
            
            icon:SetPoint("LEFT", frame.buffFrame, "LEFT", (iconIndex - 1) * 14, 0)
            icon.texture:SetTexture(texture)
            icon:Show()
            iconIndex = iconIndex + 1
        end
    end
end
