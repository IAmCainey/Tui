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

-- Enhanced frame positioning with size support
function TUI.Utils:SetAdvancedFramePosition(frame, configKey)
    local x, y, width, height
    
    -- Handle both table and varargs config key format
    if type(configKey) == "table" then
        x = TUI:GetConfig(configKey[1], configKey[2], configKey[3], "x") or 0
        y = TUI:GetConfig(configKey[1], configKey[2], configKey[3], "y") or 0
        width = TUI:GetConfig(configKey[1], configKey[2], configKey[3], "width")
        height = TUI:GetConfig(configKey[1], configKey[2], configKey[3], "height")
    else
        x = TUI:GetConfig(configKey, "x") or 0
        y = TUI:GetConfig(configKey, "y") or 0
        width = TUI:GetConfig(configKey, "width")
        height = TUI:GetConfig(configKey, "height")
    end
    
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
    
    if width and width > 0 then
        frame:SetWidth(width)
    end
    
    if height and height > 0 then
        frame:SetHeight(height)
    end
end

-- Reset frame to default position and size
function TUI.Utils:ResetFramePosition(frame, configKey, defaults)
    if defaults then
        -- Handle both table and varargs config key format
        if type(configKey) == "table" then
            TUI:SetConfig(defaults.x or 0, configKey[1], configKey[2], configKey[3], "x")
            TUI:SetConfig(defaults.y or 0, configKey[1], configKey[2], configKey[3], "y")
            if defaults.width then
                TUI:SetConfig(defaults.width, configKey[1], configKey[2], configKey[3], "width")
            end
            if defaults.height then
                TUI:SetConfig(defaults.height, configKey[1], configKey[2], configKey[3], "height")
            end
        else
            TUI:SetConfig(defaults.x or 0, configKey, "x")
            TUI:SetConfig(defaults.y or 0, configKey, "y")
            if defaults.width then
                TUI:SetConfig(defaults.width, configKey, "width")
            end
            if defaults.height then
                TUI:SetConfig(defaults.height, configKey, "height")
            end
        end
        
        self:SetAdvancedFramePosition(frame, configKey)
        
        if frame.UpdateLayout then
            frame:UpdateLayout()
        end
    end
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
    
    -- Don't create cooldown frame - not needed for basic buttons
    -- and "Cooldown" frame type doesn't exist in WoW 1.12.1
    
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

-- Enhanced draggable frame with resize and lock functionality
function TUI.Utils:MakeAdvancedDraggable(frame, configKey, options)
    options = options or {}
    local allowResize = options.allowResize ~= false -- Default to true
    local minWidth = options.minWidth or 100
    local maxWidth = options.maxWidth or 1000
    local minHeight = options.minHeight or 36
    local maxHeight = options.maxHeight or 500
    local snapToGrid = options.snapToGrid or 10
    
    -- Store frame reference and config
    frame.configKey = configKey
    frame.isLocked = false
    
    -- Handle both table and varargs config key format for getting lock state
    if type(configKey) == "table" then
        frame.isLocked = TUI:GetConfig(configKey[1], configKey[2], configKey[3], "locked") or false
    else
        frame.isLocked = TUI:GetConfig(configKey, "locked") or false
    end
    
    frame.canResize = allowResize
    
    -- Create lock/unlock button
    local lockButton = CreateFrame("Button", nil, frame)
    lockButton:SetWidth(16)
    lockButton:SetHeight(16)
    lockButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    
    -- Lock button texture
    local lockIcon = lockButton:CreateTexture(nil, "OVERLAY")
    lockIcon:SetAllPoints(lockButton)
    lockIcon:SetTexture("Interface\\Buttons\\LockButton-Border")
    lockButton.icon = lockIcon
    
    -- Lock button background
    local lockBg = lockButton:CreateTexture(nil, "BACKGROUND")
    lockBg:SetAllPoints(lockButton)
    lockBg:SetTexture(0, 0, 0, 0.5)
    lockButton.bg = lockBg
    
    frame.lockButton = lockButton
    
    -- Create resize handles if resizing is enabled
    if allowResize then
        -- Bottom-right resize handle
        local resizeHandle = CreateFrame("Frame", nil, frame)
        resizeHandle:SetWidth(16)
        resizeHandle:SetHeight(16)
        resizeHandle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        
        local resizeTexture = resizeHandle:CreateTexture(nil, "OVERLAY")
        resizeTexture:SetAllPoints(resizeHandle)
        resizeTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        
        resizeHandle:EnableMouse(true)
        resizeHandle:SetScript("OnEnter", function()
            SetCursor("RESIZE_CURSOR")
        end)
        resizeHandle:SetScript("OnLeave", function()
            SetCursor(nil)
        end)
        
        frame.resizeHandle = resizeHandle
        
        -- Create border overlay for better visibility when unlocked
        local border = CreateFrame("Frame", nil, frame)
        border:SetAllPoints(frame)
        border:SetFrameLevel(frame:GetFrameLevel() + 1)
        
        local borderTexture = border:CreateTexture(nil, "OVERLAY")
        borderTexture:SetAllPoints(border)
        borderTexture:SetTexture(1, 1, 1, 0.3)
        borderTexture:SetTexCoord(0, 1, 0, 1)
        border.texture = borderTexture
        
        frame.border = border
    end
    
    -- Update lock state visual
    local function updateLockState()
        if frame.isLocked then
            lockIcon:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
            lockButton:SetAlpha(0.3)
            frame:SetMovable(false)
            frame:EnableMouse(false)
            if frame.resizeHandle then
                frame.resizeHandle:Hide()
            end
            if frame.border then
                frame.border:Hide()
            end
        else
            lockIcon:SetTexture("Interface\\Buttons\\LockButton-Border")
            lockButton:SetAlpha(1.0)
            frame:SetMovable(true)
            frame:EnableMouse(true)
            frame:RegisterForDrag("LeftButton")
            if frame.resizeHandle then
                frame.resizeHandle:Show()
            end
            if frame.border then
                frame.border:Show()
            end
        end
        
        -- Save lock state
        if type(configKey) == "table" then
            TUI:SetConfig(frame.isLocked, configKey[1], configKey[2], configKey[3], "locked")
        else
            TUI:SetConfig(frame.isLocked, configKey, "locked")
        end
    end
    
    -- Lock button click handler
    lockButton:SetScript("OnClick", function()
        frame.isLocked = not frame.isLocked
        updateLockState()
        
        if frame.isLocked then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Frame locked")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r Frame unlocked - drag to move" .. (frame.canResize and ", drag corner to resize" or ""))
        end
    end)
    
    -- Dragging functionality
    frame:SetScript("OnDragStart", function()
        if not frame.isLocked then
            this:StartMoving()
        end
    end)
    
    frame:SetScript("OnDragStop", function()
        if not frame.isLocked then
            this:StopMovingOrSizing()
            
            -- Snap to grid
            local x, y = this:GetCenter()
            local scale = this:GetEffectiveScale()
            x = x * scale
            y = y * scale
            
            -- Snap to grid
            x = math.floor((x + snapToGrid/2) / snapToGrid) * snapToGrid
            y = math.floor((y + snapToGrid/2) / snapToGrid) * snapToGrid
            
            -- Save position based on configKey type
            if type(configKey) == "table" then
                TUI:SetConfig(x, configKey[1], configKey[2], configKey[3], "x")
                TUI:SetConfig(y, configKey[1], configKey[2], configKey[3], "y")
            else
                TUI:SetConfig(x, configKey, "x")
                TUI:SetConfig(y, configKey, "y")
            end
            
            -- Reposition with snapped coordinates
            this:ClearAllPoints()
            this:SetPoint("CENTER", UIParent, "CENTER", x/scale, y/scale)
        end
    end)
    
    -- Resizing functionality
    if allowResize and frame.resizeHandle then
        local isResizing = false
        local startWidth, startHeight, startX, startY
        
        frame.resizeHandle:SetScript("OnMouseDown", function()
            if not frame.isLocked then
                isResizing = true
                startWidth = frame:GetWidth()
                startHeight = frame:GetHeight()
                startX, startY = GetCursorPosition()
                frame:SetScript("OnUpdate", function()
                    if isResizing then
                        local x, y = GetCursorPosition()
                        local scale = frame:GetEffectiveScale()
                        
                        local newWidth = startWidth + (x - startX) / scale
                        local newHeight = startHeight + (startY - y) / scale
                        
                        -- Apply size constraints
                        newWidth = math.max(minWidth, math.min(maxWidth, newWidth))
                        newHeight = math.max(minHeight, math.min(maxHeight, newHeight))
                        
                        -- Snap to grid
                        newWidth = math.floor((newWidth + snapToGrid/2) / snapToGrid) * snapToGrid
                        newHeight = math.floor((newHeight + snapToGrid/2) / snapToGrid) * snapToGrid
                        
                        frame:SetWidth(newWidth)
                        frame:SetHeight(newHeight)
                        
                        -- Save size based on configKey type
                        if type(configKey) == "table" then
                            TUI:SetConfig(newWidth, configKey[1], configKey[2], configKey[3], "width")
                            TUI:SetConfig(newHeight, configKey[1], configKey[2], configKey[3], "height")
                        else
                            TUI:SetConfig(newWidth, configKey, "width")
                            TUI:SetConfig(newHeight, configKey, "height")
                        end
                        
                        -- Trigger layout update if the frame has one
                        if frame.UpdateLayout then
                            frame:UpdateLayout()
                        end
                    end
                end)
            end
        end)
        
        frame.resizeHandle:SetScript("OnMouseUp", function()
            if isResizing then
                isResizing = false
                frame:SetScript("OnUpdate", nil)
                SetCursor(nil)
            end
        end)
    end
    
    -- Initialize lock state
    updateLockState()
    
    -- Add tooltip to lock button
    lockButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        if frame.isLocked then
            GameTooltip:SetText("Click to unlock frame")
            GameTooltip:AddLine("Unlocked frames can be moved and resized", 1, 1, 1)
        else
            GameTooltip:SetText("Click to lock frame")
            GameTooltip:AddLine("Locked frames cannot be moved or resized", 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    
    lockButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-- Global lock/unlock all frames
function TUI.Utils:ToggleAllFrameLocks(locked)
    local frames = {
        {"actionBars", "bars", "bar1"},
        {"actionBars", "bars", "bar2"}, 
        {"actionBars", "bars", "bar3"},
        {"actionBars", "bars", "bar4"},
        {"actionBars", "bars", "petBar"},
        {"actionBars", "bars", "stanceBar"},
        {"unitFrames", "player"},
        {"unitFrames", "target"}, 
        {"unitFrames", "targettarget"},
        {"groupFrames", "party"},
        {"groupFrames", "raid"}
    }
    
    for _, configPath in pairs(frames) do
        if #configPath == 3 then
            TUI:SetConfig(locked, configPath[1], configPath[2], configPath[3], "locked")
        elseif #configPath == 2 then
            TUI:SetConfig(locked, configPath[1], configPath[2], "locked")
        end
    end
    
    if locked then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r All frames locked")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TUI:|r All frames unlocked - use individual lock buttons to lock specific frames")
    end
    
    -- Trigger UI refresh
    TUI:RefreshUI()
end
