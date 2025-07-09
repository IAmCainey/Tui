#!/usr/bin/env lua

-- Test loading order simulation
print("Testing TUI loading order...")

-- Simulate loading Init.lua
print("1. Loading Init.lua...")
dofile("Init.lua")
print("   TUI global created: " .. tostring(TUI ~= nil))
if TUI then
    print("   TUI.version: " .. tostring(TUI.version))
end

-- Simulate loading Core files
print("2. Loading Core files...")
-- Skip actual loading of Core files since they depend on WoW API
print("   Core files would be loaded here")

-- Check if we can simulate calling module initialization
print("3. Testing module function existence...")
print("   InitializeDatabase: " .. tostring(type(TUI.InitializeDatabase)))
print("   HideBlizzardUI: " .. tostring(type(TUI.HideBlizzardUI)))
print("   InitializeActionBars: " .. tostring(type(TUI.InitializeActionBars)))

print("Loading order test complete!")
