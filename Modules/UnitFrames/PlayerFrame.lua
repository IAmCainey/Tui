-- TUI Player Frame Module
-- Handles the player unit frame

-- Create player frame
function TUI.UnitFrames:CreatePlayerFrame()
    local config = TUI:GetConfig("unitFrames", "player")
    if not config or not config.enabled then return end
    
    local frame = self:CreateBaseFrame("TUI_PlayerFrame", "player", 200, 60)
    
    -- Set position
    TUI.Utils:SetFramePosition(frame, "unitFrames", "player")
    
    -- Make draggable
    TUI.Utils:MakeDraggable(frame, "unitFrames", "player")
    
    -- Create cast bar
    local castBar = TUI.Utils:CreateStatusBar(frame, 200, 16)
    castBar:SetPoint("TOP", frame, "BOTTOM", 0, -4)
    castBar:SetStatusBarColor(1, 0.7, 0)
    castBar:Hide()
    frame.castBar = castBar
    
    -- Create cast bar timer text
    local castTimer = castBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    castTimer:SetPoint("RIGHT", castBar, "RIGHT", -2, 0)
    castBar.timer = castTimer
    
    -- Add combat indicator
    local combatText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    combatText:SetPoint("LEFT", frame, "RIGHT", 5, 20)
    combatText:SetText("Combat")
    combatText:SetTextColor(1, 0, 0)
    combatText:Hide()
    frame.combatText = combatText
    
    -- Add resting indicator
    local restingText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    restingText:SetPoint("LEFT", frame, "RIGHT", 5, 0)
    restingText:SetText("Resting")
    restingText:SetTextColor(0, 1, 0)
    restingText:Hide()
    frame.restingText = restingText
    
    -- Player-specific events
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_UPDATE_RESTING")
    frame:RegisterEvent("SPELLCAST_START")
    frame:RegisterEvent("SPELLCAST_STOP")
    frame:RegisterEvent("SPELLCAST_FAILED")
    frame:RegisterEvent("SPELLCAST_INTERRUPTED")
    frame:RegisterEvent("SPELLCAST_DELAYED")
    frame:RegisterEvent("SPELLCAST_CHANNEL_START")
    frame:RegisterEvent("SPELLCAST_CHANNEL_STOP")
    
    -- Override event handler
    local originalOnEvent = frame:GetScript("OnEvent")
    frame:SetScript("OnEvent", function()
        -- Call original handler first
        if originalOnEvent then
            originalOnEvent()
        end
        
        -- Handle player-specific events
        if event == "PLAYER_REGEN_DISABLED" then
            frame.combatText:Show()
        elseif event == "PLAYER_REGEN_ENABLED" then
            frame.combatText:Hide()
        elseif event == "PLAYER_UPDATE_RESTING" then
            if IsResting() then
                frame.restingText:Show()
            else
                frame.restingText:Hide()
            end
        elseif event == "SPELLCAST_START" then
            TUI.UnitFrames:StartCasting(frame, arg1, arg2)
        elseif event == "SPELLCAST_STOP" or event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
            TUI.UnitFrames:StopCasting(frame)
        elseif event == "SPELLCAST_DELAYED" then
            TUI.UnitFrames:DelayCasting(frame, arg1)
        elseif event == "SPELLCAST_CHANNEL_START" then
            TUI.UnitFrames:StartChanneling(frame, arg1, arg2)
        elseif event == "SPELLCAST_CHANNEL_STOP" then
            TUI.UnitFrames:StopCasting(frame)
        end
    end)
    
    -- Store frame
    self.frames.player = frame
    
    -- Initial update
    self:UpdateFrame(frame)
    
    -- Update resting state
    if IsResting() then
        frame.restingText:Show()
    end
end

-- Start casting
function TUI.UnitFrames:StartCasting(frame, spell, delay)
    if not frame.castBar then return end
    
    local castBar = frame.castBar
    castBar.spell = spell
    castBar.startTime = GetTime()
    castBar.maxValue = delay / 1000
    castBar.delay = 0
    castBar.casting = true
    castBar.channeling = false
    
    castBar:SetMinMaxValues(0, castBar.maxValue)
    castBar:SetValue(0)
    castBar.text:SetText(spell)
    castBar:Show()
    
    -- Start updating
    castBar:SetScript("OnUpdate", function()
        TUI.UnitFrames:UpdateCastBar(this)
    end)
end

-- Start channeling
function TUI.UnitFrames:StartChanneling(frame, spell, delay)
    if not frame.castBar then return end
    
    local castBar = frame.castBar
    castBar.spell = spell
    castBar.startTime = GetTime()
    castBar.maxValue = delay / 1000
    castBar.delay = 0
    castBar.casting = false
    castBar.channeling = true
    
    castBar:SetMinMaxValues(0, castBar.maxValue)
    castBar:SetValue(castBar.maxValue)
    castBar.text:SetText(spell)
    castBar:Show()
    
    -- Start updating
    castBar:SetScript("OnUpdate", function()
        TUI.UnitFrames:UpdateCastBar(this)
    end)
end

-- Stop casting/channeling
function TUI.UnitFrames:StopCasting(frame)
    if not frame.castBar then return end
    
    local castBar = frame.castBar
    castBar.casting = false
    castBar.channeling = false
    castBar:SetScript("OnUpdate", nil)
    castBar:Hide()
end

-- Delay casting
function TUI.UnitFrames:DelayCasting(frame, delay)
    if not frame.castBar or not frame.castBar.casting then return end
    
    frame.castBar.delay = frame.castBar.delay + (delay / 1000)
    frame.castBar.maxValue = frame.castBar.maxValue + (delay / 1000)
end

-- Update cast bar
function TUI.UnitFrames:UpdateCastBar(castBar)
    local now = GetTime()
    local elapsed = now - castBar.startTime
    
    if castBar.casting then
        local progress = elapsed / castBar.maxValue
        if progress >= 1 then
            TUI.UnitFrames:StopCasting(castBar:GetParent())
            return
        end
        castBar:SetValue(elapsed)
        
        -- Update timer
        local remaining = castBar.maxValue - elapsed
        if castBar.timer then
            castBar.timer:SetText(string.format("%.1f", remaining))
        end
    elseif castBar.channeling then
        local progress = elapsed / castBar.maxValue
        if progress >= 1 then
            TUI.UnitFrames:StopCasting(castBar:GetParent())
            return
        end
        castBar:SetValue(castBar.maxValue - elapsed)
        
        -- Update timer
        local remaining = castBar.maxValue - elapsed
        if castBar.timer then
            castBar.timer:SetText(string.format("%.1f", remaining))
        end
    end
end
