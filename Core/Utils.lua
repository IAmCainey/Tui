-- TUI Utilities Module
-- Common utility functions

TUI.Utils = {}

-- Create a draggable frame
function TUI.Utils:MakeDraggable(frame, configKey)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    
    frame:SetScript("OnDragStart", function()
        this:StartMoving()
    end)
    
    frame:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
        
        -- Save position if config key provided
        if configKey then
            local x, y = this:GetCenter()
            local scale = this:GetEffectiveScale()
            x = x * scale
            y = y * scale
            
            TUI:SetConfig(x, configKey, "x")
            TUI:SetConfig(y, configKey, "y")
        end
    end)
end

-- Set frame position from config
function TUI.Utils:SetFramePosition(frame, configKey)
    local x = TUI:GetConfig(configKey, "x") or 0
    local y = TUI:GetConfig(configKey, "y") or 0
    
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

-- Create a status bar
function TUI.Utils:CreateStatusBar(parent, width, height)
    local bar = CreateFrame("StatusBar", nil, parent)
    bar:SetWidth(width)
    bar:SetHeight(height)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(1)
    
    -- Create background
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bg:SetAllPoints(bar)
    bg:SetVertexColor(0.3, 0.3, 0.3, 0.8)
    bar.bg = bg
    
    -- Create text
    local text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("CENTER", bar, "CENTER")
    bar.text = text
    
    return bar
end

-- Update status bar
function TUI.Utils:UpdateStatusBar(bar, current, max, text, r, g, b)
    if not bar or not current or not max then return end
    
    if max > 0 then
        bar:SetMinMaxValues(0, max)
        bar:SetValue(current)
    else
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(0)
    end
    
    if r and g and b then
        bar:SetStatusBarColor(r, g, b)
    end
    
    if text and bar.text then
        bar.text:SetText(text)
    end
end

-- Create a button with texture
function TUI.Utils:CreateButton(parent, width, height, texture)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width)
    button:SetHeight(height)
    
    -- Set backdrop
    TUI.Core:CreateBackdrop(button, 2)
    
    -- Create icon texture
    if texture then
        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints(button)
        icon:SetTexture(texture)
        button.icon = icon
    end
    
    -- Create cooldown frame
    local cooldown = CreateFrame("Cooldown", nil, button)
    cooldown:SetAllPoints(button)
    button.cooldown = cooldown
    
    return button
end

-- Format time
function TUI.Utils:FormatTime(seconds)
    if seconds >= 3600 then
        return string.format("%dh", seconds / 3600)
    elseif seconds >= 60 then
        return string.format("%dm", seconds / 60)
    else
        return string.format("%d", seconds)
    end
end

-- Get class color
function TUI.Utils:GetClassColor(class)
    local color = RAID_CLASS_COLORS[class]
    if color then
        return color.r, color.g, color.b
    end
    return 1, 1, 1
end

-- Fade frame in/out
function TUI.Utils:FadeFrame(frame, alpha, duration)
    if not frame then return end
    
    -- Check if UIFrameFade exists (should be available in 1.12.1)
    if not UIFrameFade then
        -- Fallback to direct alpha setting
        frame:SetAlpha(alpha)
        return
    end
    
    if not frame.fadeInfo then
        frame.fadeInfo = {}
    end
    
    frame.fadeInfo.mode = alpha > frame:GetAlpha() and "IN" or "OUT"
    frame.fadeInfo.timeToFade = duration or 0.3
    frame.fadeInfo.startAlpha = frame:GetAlpha()
    frame.fadeInfo.endAlpha = alpha
    frame.fadeInfo.diffAlpha = alpha - frame:GetAlpha()
    
    UIFrameFade(frame, frame.fadeInfo)
end
