-- TUI Group Frames Module
-- Handles party and raid frames

TUI.GroupFrames = {}
TUI.GroupFrames.frames = {}

-- Initialize group frames
function TUI:InitializeGroupFrames()
    if not self:GetConfig("groupFrames", "enabled") then return end
    
    self.GroupFrames:CreatePartyFrames()
    self.GroupFrames:CreateRaidFrames()
    self.GroupFrames:UpdateAll()
end

-- Update all group frames
function TUI.GroupFrames:UpdateAll()
    for _, frame in pairs(self.frames) do
        if frame then
            local scale = TUI:GetConfig("groupFrames", "scale") or 1.0
            frame:SetScale(scale)
        end
    end
    
    self:UpdateGroupVisibility()
end

-- Update group frame visibility based on group type
function TuiUI.GroupFrames:UpdateGroupVisibility()
    local numRaidMembers = GetNumRaidMembers()
    local numPartyMembers = GetNumPartyMembers()
    
    if numRaidMembers > 0 then
        -- In raid
        if self.frames.party then
            self.frames.party:Hide()
        end
        if self.frames.raid then
            self.frames.raid:Show()
            self:UpdateRaidFrames()
        end
    elseif numPartyMembers > 0 then
        -- In party
        if self.frames.raid then
            self.frames.raid:Hide()
        end
        if self.frames.party then
            self.frames.party:Show()
            self:UpdatePartyFrames()
        end
    else
        -- Solo
        if self.frames.party then
            self.frames.party:Hide()
        end
        if self.frames.raid then
            self.frames.raid:Hide()
        end
    end
end
