-- TUI Raid Frames Module
-- Handles raid member frames

-- Create raid frames
function TUI.GroupFrames:CreateRaidFrames()
    local config = TUI:GetConfig("groupFrames", "raid")
    if not config or not config.enabled then return end
    
    local raidFrame = CreateFrame("Frame", "TUI_RaidFrame", UIParent)
    raidFrame:SetWidth(400)
    raidFrame:SetHeight(300)
    
    -- Set position
    TUI.Utils:SetFramePosition(raidFrame, "groupFrames", "raid")
    
    -- Make draggable
    TUI.Utils:MakeDraggable(raidFrame, "groupFrames", "raid")
    
    -- Create header
    local header = raidFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOP", raidFrame, "TOP", 0, -5)
    header:SetText("Raid")
    raidFrame.header = header
    
    -- Create raid member frames
    raidFrame.memberFrames = {}
    for i = 1, 40 do
        local memberFrame = self:CreateRaidMemberFrame(raidFrame, i)
        raidFrame.memberFrames[i] = memberFrame
    end
    
    -- Register events
    raidFrame:RegisterEvent("RAID_ROSTER_UPDATE")
    raidFrame:RegisterEvent("UNIT_HEALTH")
    raidFrame:RegisterEvent("UNIT_MAXHEALTH")
    raidFrame:RegisterEvent("UNIT_MANA")
    raidFrame:RegisterEvent("UNIT_MAXMANA")
    raidFrame:RegisterEvent("UNIT_AURA")
    
    raidFrame:SetScript("OnEvent", function()
        TUI.GroupFrames:UpdateRaidFrames()
    end)
    
    self.frames.raid = raidFrame
    
    -- Initial update
    self:UpdateRaidFrames()
end

-- Create individual raid member frame
function TUI.GroupFrames:CreateRaidMemberFrame(parent, raidIndex)
    local frame = CreateFrame("Button", "TUI_RaidMember" .. raidIndex, parent)
    frame:SetWidth(75)
    frame:SetHeight(30)
    frame.raidIndex = raidIndex
    frame.unit = "raid" .. raidIndex
    
    -- Create backdrop
    TUI.Core:CreateBackdrop(frame, 1)
    
    -- Create health bar
    local healthBar = TUI.Utils:CreateStatusBar(frame, 73, 14)
    healthBar:SetPoint("TOP", frame, "TOP", 0, -2)
    healthBar:SetStatusBarColor(0, 1, 0)
    frame.healthBar = healthBar
    
    -- Create mana bar (smaller)
    local manaBar = TUI.Utils:CreateStatusBar(frame, 73, 10)
    manaBar:SetPoint("BOTTOM", frame, "BOTTOM", 0, 2)
    manaBar:SetStatusBarColor(0, 0, 1)
    frame.manaBar = manaBar
    
    -- Create name text
    local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("CENTER", healthBar, "CENTER")
    nameText:SetJustifyH("CENTER")
    nameText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
    frame.nameText = nameText
    
    -- Create status indicators
    local statusFrame = CreateFrame("Frame", nil, frame)
    statusFrame:SetWidth(60)
    statusFrame:SetHeight(8)
    statusFrame:SetPoint("TOP", frame, "TOP", 0, 8)
    frame.statusFrame = statusFrame
    frame.statusIcons = {}
    
    -- Click handling
    frame:SetScript("OnClick", function()
        if arg1 == "LeftButton" then
            TargetUnit(this.unit)
        elseif arg1 == "RightButton" then
            ToggleDropDownMenu(1, nil, RaidFrameDropDown, "cursor", 0, 0)
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

-- Update raid frames
function TUI.GroupFrames:UpdateRaidFrames()
    local raidFrame = self.frames.raid
    if not raidFrame then return end
    
    local numRaidMembers = GetNumRaidMembers()
    local groupsPerRow = TUI:GetConfig("groupFrames", "raid", "groupsPerRow") or 5
    
    -- Hide all frames first
    for i = 1, 40 do
        raidFrame.memberFrames[i]:Hide()
    end
    
    -- Organize by groups
    local groupMembers = {}
    for i = 1, 8 do
        groupMembers[i] = {}
    end
    
    for i = 1, numRaidMembers do
        if UnitExists("raid" .. i) then
            local _, _, group = GetRaidRosterInfo(i)
            if group and group <= 8 then
                table.insert(groupMembers[group], i)
            end
        end
    end
    
    -- Position frames by group
    local currentRow = 0
    local currentCol = 0
    
    for group = 1, 8 do
        if table.getn(groupMembers[group]) > 0 then
            -- Position group members
            for j, raidIndex in ipairs(groupMembers[group]) do
                local frame = raidFrame.memberFrames[raidIndex]
                local x = currentCol * 80
                local y = -25 - currentRow * 35 - (j - 1) * 32
                
                frame:SetPoint("TOPLEFT", raidFrame, "TOPLEFT", x, y)
                frame:Show()
                self:UpdateRaidMemberFrame(frame)
            end
            
            -- Move to next column
            currentCol = currentCol + 1
            if currentCol >= groupsPerRow then
                currentCol = 0
                currentRow = currentRow + 6 -- Approximate rows per group
            end
        end
    end
    
    -- Adjust raid frame size
    local cols = math.min(8, groupsPerRow)
    local rows = math.ceil(8 / groupsPerRow) * 6
    raidFrame:SetWidth(cols * 80 + 20)
    raidFrame:SetHeight(25 + rows * 35)
end

-- Update individual raid member frame
function TUI.GroupFrames:UpdateRaidMemberFrame(frame)
    local unit = frame.unit
    if not UnitExists(unit) then return end
    
    -- Update health
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local healthPercent = 0
    
    if maxHealth > 0 then
        healthPercent = math.floor((health / maxHealth) * 100)
    end
    
    -- Color health bar based on health percentage
    local r, g, b = 0, 1, 0
    if healthPercent < 25 then
        r, g, b = 1, 0, 0 -- Red
    elseif healthPercent < 50 then
        r, g, b = 1, 0.5, 0 -- Orange
    elseif healthPercent < 75 then
        r, g, b = 1, 1, 0 -- Yellow
    end
    
    TUI.Utils:UpdateStatusBar(frame.healthBar, health, maxHealth, healthPercent .. "%", r, g, b)
    
    -- Update mana (simplified for raid frames)
    local power = UnitMana(unit)
    local maxPower = UnitManaMax(unit)
    
    local powerType = UnitPowerType(unit)
    local pr, pg, pb = 0, 0, 1
    if powerType == 1 then
        pr, pg, pb = 1, 0, 0
    elseif powerType == 3 then
        pr, pg, pb = 1, 1, 0
    end
    
    TUI.Utils:UpdateStatusBar(frame.manaBar, power, maxPower, "", pr, pg, pb)
    
    -- Update name (shortened for raid)
    local name = UnitName(unit)
    if name and string.len(name) > 8 then
        name = string.sub(name, 1, 8)
    end
    
    if TUI:GetConfig("unitFrames", "showClassColor") and UnitIsPlayer(unit) then
        local r, g, b = TUI.Core:GetUnitColor(unit)
        frame.nameText:SetTextColor(r, g, b)
    else
        frame.nameText:SetTextColor(1, 1, 1)
    end
    frame.nameText:SetText(name or "")
    
    -- Update status indicators
    self:UpdateRaidMemberStatus(frame)
end

-- Update raid member status
function TUI.GroupFrames:UpdateRaidMemberStatus(frame)
    local unit = frame.unit
    if not frame.statusFrame then return end
    
    -- Clear existing status icons
    for _, icon in pairs(frame.statusIcons) do
        icon:Hide()
    end
    
    local iconIndex = 1
    
    -- Leader icon
    if UnitIsRaidOfficer(unit) or UnitIsPartyLeader(unit) then
        local icon = frame.statusIcons[iconIndex]
        if not icon then
            icon = frame.statusFrame:CreateTexture(nil, "OVERLAY")
            icon:SetWidth(8)
            icon:SetHeight(8)
            frame.statusIcons[iconIndex] = icon
        end
        
        if UnitIsPartyLeader(unit) then
            icon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        else
            icon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
        end
        
        icon:SetPoint("LEFT", frame.statusFrame, "LEFT", (iconIndex - 1) * 10, 0)
        icon:Show()
        iconIndex = iconIndex + 1
    end
    
    -- Dead/Ghost indicator
    if UnitIsDeadOrGhost(unit) then
        local icon = frame.statusIcons[iconIndex]
        if not icon then
            icon = frame.statusFrame:CreateTexture(nil, "OVERLAY")
            icon:SetWidth(8)
            icon:SetHeight(8)
            frame.statusIcons[iconIndex] = icon
        end
        
        icon:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
        icon:SetPoint("LEFT", frame.statusFrame, "LEFT", (iconIndex - 1) * 10, 0)
        icon:Show()
        iconIndex = iconIndex + 1
    end
    
    -- Important debuff indicator (simplified)
    for i = 1, 3 do
        local texture, applications, debuffType = UnitDebuff(unit, i)
        if texture and debuffType and debuffType ~= "none" then
            local icon = frame.statusIcons[iconIndex]
            if not icon then
                icon = frame.statusFrame:CreateTexture(nil, "OVERLAY")
                icon:SetWidth(8)
                icon:SetHeight(8)
                frame.statusIcons[iconIndex] = icon
            end
            
            icon:SetTexture(texture)
            icon:SetPoint("LEFT", frame.statusFrame, "LEFT", (iconIndex - 1) * 10, 0)
            icon:Show()
            iconIndex = iconIndex + 1
            break -- Only show one debuff
        end
    end
end
