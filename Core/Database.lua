-- TUI Database Module
-- Handles saved variables and configuration

TUI.Database = {}

-- Default configuration
local defaults = {
    profile = {
        actionBars = {
            enabled = true,
            scale = 1.0,
            spacing = 4,
            showHotkeys = true,
            showMacroNames = true,
            fadeOutOfCombat = false,
            bars = {
                bar1 = { enabled = true, x = 0, y = 0, buttonsPerRow = 12 },
                bar2 = { enabled = true, x = 0, y = -40, buttonsPerRow = 12 },
                bar3 = { enabled = false, x = 0, y = -80, buttonsPerRow = 12 },
                bar4 = { enabled = false, x = 0, y = -120, buttonsPerRow = 12 },
                petBar = { enabled = true, x = 0, y = 40, buttonsPerRow = 10 },
                stanceBar = { enabled = true, x = -400, y = 0, buttonsPerRow = 10 }
            }
        },
        unitFrames = {
            enabled = true,
            scale = 1.0,
            showPercent = true,
            showClassColor = true,
            player = { enabled = true, x = -200, y = -200 },
            target = { enabled = true, x = 200, y = -200 },
            targettarget = { enabled = true, x = 320, y = -240 }
        },
        groupFrames = {
            enabled = true,
            scale = 1.0,
            showPets = true,
            showBuffs = true,
            party = { enabled = true, x = -400, y = 0 },
            raid = { enabled = true, x = -400, y = 0, groupsPerRow = 5 }
        }
    }
}

-- Initialize database
function TUI:InitializeDatabase()
    -- Initialize global saved variables
    if not TUIDB then
        TUIDB = {}
    end
    
    -- Initialize character saved variables
    if not TUICharDB then
        TUICharDB = {}
    end
    
    -- Set up profile
    if not TUICharDB.profile then
        TUICharDB.profile = self:DeepCopy(defaults.profile)
    end
    
    -- Store reference for easy access
    self.db = TUICharDB
    
    -- Validate and update config if needed
    self:ValidateConfig()
end

-- Deep copy function
function TUI:DeepCopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:DeepCopy(orig_key)] = self:DeepCopy(orig_value)
        end
    else
        copy = orig
    end
    return copy
end

-- Validate configuration
function TUI:ValidateConfig()
    -- Check if all required keys exist, add missing ones
    local function validateTable(config, default)
        for key, value in pairs(default) do
            if config[key] == nil then
                config[key] = self:DeepCopy(value)
            elseif type(value) == "table" and type(config[key]) == "table" then
                validateTable(config[key], value)
            end
        end
    end
    
    validateTable(self.db.profile, defaults.profile)
end

-- Get configuration value
function TUI:GetConfig(...)
    local config = self.db.profile
    for i = 1, arg.n do
        config = config[arg[i]]
        if not config then
            return nil
        end
    end
    return config
end

-- Set configuration value
function TUI:SetConfig(value, ...)
    local config = self.db.profile
    for i = 1, arg.n - 1 do
        if not config[arg[i]] then
            config[arg[i]] = {}
        end
        config = config[arg[i]]
    end
    config[arg[arg.n]] = value
end

-- Reset configuration to defaults
function TUI:ResetConfig()
    self.db.profile = self:DeepCopy(defaults.profile)
    self:UpdateAllFrames()
end
