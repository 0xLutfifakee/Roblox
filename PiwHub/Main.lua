--[[
    Main.lua - Entry point utama PiwHub Fishing Bot
    Integrasi semua modul
]]--

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create PiwHub folder structure
local PiwHub = Instance.new("Folder")
PiwHub.Name = "PiwHub"
PiwHub.Parent = ReplicatedStorage

-- Create subfolders
local Features = Instance.new("Folder")
Features.Name = "Features"
Features.Parent = PiwHub

local Fishing = Instance.new("Folder")
Fishing.Name = "Fishing"
Fishing.Parent = Features

local UI = Instance.new("Folder")
UI.Name = "UI"
UI.Parent = PiwHub

local Debug = Instance.new("Folder")
Debug.Name = "Debug"
Debug.Parent = PiwHub

local AutoFinder = Instance.new("Folder")
AutoFinder.Name = "AutoFinder"
AutoFinder.Parent = PiwHub

-- Insert modules (dalam real implementation, ini akan di-require dari file)
local modules = {
    ["Debug/Logger"] = require(script.Parent.Debug.Logger),
    ["AutoFinder/Scanner"] = require(script.Parent.AutoFinder.Scanner),
    ["AutoFinder/Filter"] = require(script.Parent.AutoFinder.Filter),
    ["AutoFinder/Classifier"] = require(script.Parent.AutoFinder.Classifier),
    ["AutoFinder/UIConfirm"] = require(script.Parent.AutoFinder.UIConfirm),
    ["AutoFinder/Result"] = require(script.Parent.AutoFinder.Result),
    ["Features/Fishing/AutoFish"] = require(script.Parent.Features.Fishing.AutoFish),
    ["UI/FishingUI"] = require(script.Parent.UI.FishingUI)
}

-- Main execution
local function Main()
    print("=== PIWHUB FISHING BOT ===")
    print("Version: 3.0.0")
    print("Loading modules...")
    
    -- Initialize AutoFish
    local autoFish = modules["Features/Fishing/AutoFish"]
    autoFish:Initialize()
    
    -- Initialize UI
    local fishingUI = modules["UI/FishingUI"]
    fishingUI:Initialize(autoFish)
    
    -- Welcome message
    task.wait(1)
    print("\n✅ PiwHub Fishing Bot loaded successfully!")
    print("📊 Features:")
    print("   • BLATANT Auto Fishing System")
    print("   • Modular AutoFinder")
    print("   • Advanced Classification")
    print("   • Interactive UI with Debug Panel")
    print("   • Real-time Statistics")
    print("\n🎮 Controls:")
    print("   • Use the PiwHub UI to start/stop")
    print("   • Toggle AutoFinder in settings")
    print("   • View debug logs for monitoring")
    
    -- Auto-start if in development
    if game:GetService("RunService"):IsStudio() then
        print("\n🔧 Development mode detected")
        print("   AutoFish ready for testing")
    end
    
    -- Return main module for external access
    return {
        AutoFish = autoFish,
        UI = fishingUI,
        Modules = modules
    }
end

-- Error handling
local success, result = pcall(Main)
if not success then
    warn("❌ Failed to initialize PiwHub:")
    warn(result)
    
    -- Fallback simple UI
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local errorFrame = Instance.new("Frame")
    errorFrame.Size = UDim2.new(0, 300, 0, 150)
    errorFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    errorFrame.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
    errorFrame.Parent = screenGui
    
    local errorText = Instance.new("TextLabel")
    errorText.Size = UDim2.new(1, -20, 1, -20)
    errorText.Position = UDim2.new(0, 10, 0, 10)
    errorText.BackgroundTransparency = 1
    errorText.Text = "PIWHUB ERROR\n\n" .. result
    errorText.TextColor3 = Color3.fromRGB(255, 100, 100)
    errorText.Font = Enum.Font.GothamBold
    errorText.TextSize = 14
    errorText.TextWrapped = true
    errorText.Parent = errorFrame
end
