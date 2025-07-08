-- TUI Core Module
-- Handles core functionality and utilities

TUI.Core = {}

-- Hide default Blizzard UI elements
function TUI:HideBlizzardUI()
    -- Hide main action bars
    MainMenuBar:Hide()
    MainMenuBar:UnregisterAllEvents()
    
    -- Hide micro menu
    MicroButtonFrame:Hide()
    MicroButtonFrame:UnregisterAllEvents()
    
    -- Hide bag bar
    MainMenuBarBackpackButton:Hide()
    for i = 0, 3 do
        local bagButton = getglobal("CharacterBag" .. i .. "Slot")
        if bagButton then
            bagButton:Hide()
        end
    end
    
    -- Hide default unit frames
    PlayerFrame:Hide()
    PlayerFrame:UnregisterAllEvents()
    
    TargetFrame:Hide()
    TargetFrame:UnregisterAllEvents()
    
    -- Hide party frames
    for i = 1, 4 do
        local partyFrame = getglobal("PartyMemberFrame" .. i)
        if partyFrame then
            partyFrame:Hide()
            partyFrame:UnregisterAllEvents()
        end
    end
    
    -- Hide other UI elements
    if MainMenuExpBar then
        MainMenuExpBar:Hide()
    end
    
    if ReputationWatchStatusBar then
        ReputationWatchStatusBar:Hide()
    end
    
    -- Hide castbar
    if CastingBarFrame then
        CastingBarFrame:Hide()
        CastingBarFrame:UnregisterAllEvents()
    end
end

-- Utility function to create backdrop
function TUI.Core:CreateBackdrop(frame, inset)
    inset = inset or 0
    
    local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = inset, right = inset, top = inset, bottom = inset}
    }
    
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
end

-- Utility function to format text
function TUI.Core:FormatText(text, color)
    if color then
        return "|cff" .. color .. text .. "|r"
    end
    return text
end

-- Utility function to abbreviate numbers
function TUI.Core:AbbreviateNumber(value)
    if value >= 1000000 then
        return string.format("%.1fm", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fk", value / 1000)
    else
        return tostring(value)
    end
end

-- Utility function to get unit color
function TUI.Core:GetUnitColor(unit)
    if not unit or not UnitExists(unit) then
        return 1, 1, 1
    end
    
    if UnitIsPlayer(unit) then
        local class = UnitClass(unit)
        local color = RAID_CLASS_COLORS[class]
        if color then
            return color.r, color.g, color.b
        end
    else
        local reaction = UnitReaction(unit, "player")
        if reaction then
            local color = UnitReactionColor[reaction]
            if color then
                return color.r, color.g, color.b
            end
        end
    end
    
    return 1, 1, 1
end
