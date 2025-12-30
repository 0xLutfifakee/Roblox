--[[
    FishingUI.lua - GUI PiwHub style dengan debug panel
    Advanced UI dengan real-time monitoring
]]--

local FishingUI = {
    ServiceName = "FishingUI",
    Version = "2.0.0",
    IsVisible = true,
    Themes = {
        Dark = {
            Background = Color3.fromRGB(25, 25, 25),
            Primary = Color3.fromRGB(0, 100, 255),
            Secondary = Color3.fromRGB(0, 170, 255),
            Text = Color3.fromRGB(255, 255, 255),
            Accent = Color3.fromRGB(255, 165, 0)
        },
        Light = {
            Background = Color3.fromRGB(240, 240, 240),
            Primary = Color3.fromRGB(0, 120, 215),
            Secondary = Color3.fromRGB(0, 150, 255),
            Text = Color3.fromRGB(30, 30, 30),
            Accent = Color3.fromRGB(255, 140, 0)
        }
    }
}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

function FishingUI:Initialize(autoFishModule)
    self.Player = Players.LocalPlayer
    self.PlayerGui = self.Player:WaitForChild("PlayerGui")
    self.AutoFish = autoFishModule
    
    -- Initialize Logger
    self.Logger = require(game:GetService("ReplicatedStorage"):WaitForChild("PiwHub"):WaitForChild("Debug"):WaitForChild("Logger"))
    
    -- Load AutoFinder UI jika tersedia
    local success, autoFinder = pcall(function()
        return require(game:GetService("ReplicatedStorage"):WaitForChild("PiwHub"):WaitForChild("AutoFinder"):WaitForChild("UIConfirm"))
    end)
    
    if success then
        self.AutoFinderUI = autoFinder
    end
    
    self:CreateUI()
    self:SetupEventHandlers()
    
    self.Logger:Info(self.ServiceName, "FishingUI initialized")
end

function FishingUI:CreateUI()
    -- ScreenGui utama
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "PiwHub_FishingUI"
    self.ScreenGui.DisplayOrder = 10
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = self.PlayerGui
    
    -- Main Container (draggable)
    self.MainContainer = Instance.new("Frame")
    self.MainContainer.Name = "MainContainer"
    self.MainContainer.Size = UDim2.new(0, 350, 0, 500)
    self.MainContainer.Position = UDim2.new(0.05, 0, 0.3, 0)
    self.MainContainer.BackgroundColor3 = self.Themes.Dark.Background
    self.MainContainer.BorderColor3 = self.Themes.Dark.Primary
    self.MainContainer.BorderSizePixel = 2
    self.MainContainer.BackgroundTransparency = 0.05
    self.MainContainer.Parent = self.ScreenGui
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.MainContainer
    
    -- Drop Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = self.MainContainer
    
    -- Title Bar (draggable area)
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.BackgroundColor3 = self.Themes.Dark.Primary
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainContainer
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = self.TitleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🎣 PIWHUB FISHING BOT"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = self.TitleBar
    
    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    self.CloseButton.Text = "✕"
    self.CloseButton.TextColor3 = Color3.white
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.TextSize = 16
    self.CloseButton.Parent = self.TitleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = self.CloseButton
    
    -- Minimize Button
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "MinimizeButton"
    self.MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    self.MinimizeButton.Position = UDim2.new(1, -70, 0.5, -15)
    self.MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    self.MinimizeButton.Text = "─"
    self.MinimizeButton.TextColor3 = Color3.white
    self.MinimizeButton.Font = Enum.Font.GothamBold
    self.MinimizeButton.TextSize = 16
    self.MinimizeButton.Parent = self.TitleBar
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 4)
    minimizeCorner.Parent = self.MinimizeButton
    
    -- Content Area
    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"
    self.Content.Size = UDim2.new(1, -20, 1, -60)
    self.Content.Position = UDim2.new(0, 10, 0, 50)
    self.Content.BackgroundTransparency = 1
    self.Content.Parent = self.MainContainer
    
    -- Scrollable Content
    self.ScrollingFrame = Instance.new("ScrollingFrame")
    self.ScrollingFrame.Name = "Scroller"
    self.ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    self.ScrollingFrame.BackgroundTransparency = 1
    self.ScrollingFrame.BorderSizePixel = 0
    self.ScrollingFrame.ScrollBarThickness = 6
    self.ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    self.ScrollingFrame.Parent = self.Content
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.Parent = self.ScrollingFrame
    
    -- Status Section
    self:CreateStatusSection()
    
    -- Controls Section
    self:CreateControlsSection()
    
    -- Settings Section
    self:CreateSettingsSection()
    
    -- AutoFinder Section
    self:CreateAutoFinderSection()
    
    -- Stats Section
    self:CreateStatsSection()
    
    -- Debug Section
    self:CreateDebugSection()
    
    -- Update canvas size
    self.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
end

function FishingUI:CreateStatusSection()
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusSection"
    statusFrame.Size = UDim2.new(1, 0, 0, 80)
    statusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    statusFrame.BackgroundTransparency = 0.2
    statusFrame.Parent = self.ScrollingFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusFrame
    
    local statusTitle = Instance.new("TextLabel")
    statusTitle.Name = "Title"
    statusTitle.Size = UDim2.new(1, -10, 0, 25)
    statusTitle.Position = UDim2.new(0, 5, 0, 5)
    statusTitle.BackgroundTransparency = 1
    statusTitle.Text = "📊 STATUS"
    statusTitle.TextColor3 = self.Themes.Dark.Secondary
    statusTitle.Font = Enum.Font.GothamBold
    statusTitle.TextSize = 16
    statusTitle.TextXAlignment = Enum.TextXAlignment.Left
    statusTitle.Parent = statusFrame
    
    -- Status Indicator
    self.StatusIndicator = Instance.new("Frame")
    self.StatusIndicator.Name = "Indicator"
    self.StatusIndicator.Size = UDim2.new(0, 12, 0, 12)
    self.StatusIndicator.Position = UDim2.new(1, -20, 0, 10)
    self.StatusIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    self.StatusIndicator.Parent = statusFrame
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = self.StatusIndicator
    
    self.StatusText = Instance.new("TextLabel")
    self.StatusText.Name = "StatusText"
    self.StatusText.Size = UDim2.new(1, -20, 0, 20)
    self.StatusText.Position = UDim2.new(0, 10, 0, 35)
    self.StatusText.BackgroundTransparency = 1
    self.StatusText.Text = "❌ Stopped"
    self.StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    self.StatusText.Font = Enum.Font.Gotham
    self.StatusText.TextSize = 14
    self.StatusText.TextXAlignment = Enum.TextXAlignment.Left
    self.StatusText.Parent = statusFrame
    
    self.TargetText = Instance.new("TextLabel")
    self.TargetText.Name = "TargetText"
    self.TargetText.Size = UDim2.new(1, -20, 0, 20)
    self.TargetText.Position = UDim2.new(0, 10, 0, 55)
    self.TargetText.BackgroundTransparency = 1
    self.TargetText.Text = "🎯 Target: None"
    self.TargetText.TextColor3 = Color3.fromRGB(200, 200, 255)
    self.TargetText.Font = Enum.Font.Gotham
    self.TargetText.TextSize = 12
    self.TargetText.TextXAlignment = Enum.TextXAlignment.Left
    self.TargetText.Parent = statusFrame
end

function FishingUI:CreateControlsSection()
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "ControlsSection"
    controlsFrame.Size = UDim2.new(1, 0, 0, 100)
    controlsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    controlsFrame.BackgroundTransparency = 0.2
    controlsFrame.Parent = self.ScrollingFrame
    
    local controlsCorner = Instance.new("UICorner")
    controlsCorner.CornerRadius = UDim.new(0, 6)
    controlsCorner.Parent = controlsFrame
    
    local controlsTitle = Instance.new("TextLabel")
    controlsTitle.Name = "Title"
    controlsTitle.Size = UDim2.new(1, -10, 0, 25)
    controlsTitle.Position = UDim2.new(0, 5, 0, 5)
    controlsTitle.BackgroundTransparency = 1
    controlsTitle.Text = "🎮 CONTROLS"
    controlsTitle.TextColor3 = self.Themes.Dark.Secondary
    controlsTitle.Font = Enum.Font.GothamBold
    controlsTitle.TextSize = 16
    controlsTitle.TextXAlignment = Enum.TextXAlignment.Left
    controlsTitle.Parent = controlsFrame
    
    -- Start Button
    self.StartButton = Instance.new("TextButton")
    self.StartButton.Name = "StartButton"
    self.StartButton.Size = UDim2.new(0.45, 0, 0, 35)
    self.StartButton.Position = UDim2.new(0.025, 0, 0.5, 0)
    self.StartButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    self.StartButton.Text = "▶ START"
    self.StartButton.TextColor3 = Color3.white
    self.StartButton.Font = Enum.Font.GothamBold
    self.StartButton.TextSize = 14
    self.StartButton.Parent = controlsFrame
    
    local startCorner = Instance.new("UICorner")
    startCorner.CornerRadius = UDim.new(0, 6)
    startCorner.Parent = self.StartButton
    
    -- Stop Button
    self.StopButton = Instance.new("TextButton")
    self.StopButton.Name = "StopButton"
    self.StopButton.Size = UDim2.new(0.45, 0, 0, 35)
    self.StopButton.Position = UDim2.new(0.525, 0, 0.5, 0)
    self.StopButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    self.StopButton.Text = "⏹ STOP"
    self.StopButton.TextColor3 = Color3.white
    self.StopButton.Font = Enum.Font.GothamBold
    self.StopButton.TextSize = 14
    self.StopButton.Parent = controlsFrame
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 6)
    stopCorner.Parent = self.StopButton
end

function FishingUI:CreateSettingsSection()
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "SettingsSection"
    settingsFrame.Size = UDim2.new(1, 0, 0, 200)
    settingsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    settingsFrame.BackgroundTransparency = 0.2
    settingsFrame.Parent = self.ScrollingFrame
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 6)
    settingsCorner.Parent = settingsFrame
    
    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Name = "Title"
    settingsTitle.Size = UDim2.new(1, -10, 0, 25)
    settingsTitle.Position = UDim2.new(0, 5, 0, 5)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "⚙ SETTINGS"
    settingsTitle.TextColor3 = self.Themes.Dark.Secondary
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.TextSize = 16
    settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    settingsTitle.Parent = settingsFrame
    
    -- Auto Cast Toggle
    self:CreateToggle(settingsFrame, "Auto Cast", 30, self.AutoFish.Settings.AutoCast, function(value)
        self.AutoFish:UpdateSettings({AutoCast = value})
    end)
    
    -- Auto Reel Toggle
    self:CreateToggle(settingsFrame, "Auto Reel", 60, self.AutoFish.Settings.AutoReel, function(value)
        self.AutoFish:UpdateSettings({AutoReel = value})
    end)
    
    -- Auto Collect Toggle
    self:CreateToggle(settingsFrame, "Auto Collect", 90, self.AutoFish.Settings.AutoCollect, function(value)
        self.AutoFish:UpdateSettings({AutoCollect = value})
    end)
    
    -- Use AutoFinder Toggle
    self:CreateToggle(settingsFrame, "Use AutoFinder", 120, self.AutoFish.Settings.UseAutoFinder, function(value)
        self.AutoFish:UpdateSettings({UseAutoFinder = value})
    end)
    
    -- Require Confirmation Toggle
    self:CreateToggle(settingsFrame, "Require Confirmation", 150, self.AutoFish.Settings.RequireConfirmation, function(value)
        self.AutoFish:UpdateSettings({RequireConfirmation = value})
    end)
    
    -- Max Distance Slider
    self:CreateSlider(settingsFrame, "Max Distance: " .. self.AutoFish.Settings.MaxDistance .. " studs", 
        180, 50, self.AutoFish.Settings.MaxDistance, 10, 200, function(value)
        self.AutoFish:UpdateSettings({MaxDistance = value})
    end)
end

function FishingUI:CreateAutoFinderSection()
    local autoFinderFrame = Instance.new("Frame")
    autoFinderFrame.Name = "AutoFinderSection"
    autoFinderFrame.Size = UDim2.new(1, 0, 0, 120)
    autoFinderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    autoFinderFrame.BackgroundTransparency = 0.2
    autoFinderFrame.Parent = self.ScrollingFrame
    
    local afCorner = Instance.new("UICorner")
    afCorner.CornerRadius = UDim.new(0, 6)
    afCorner.Parent = autoFinderFrame
    
    local afTitle = Instance.new("TextLabel")
    afTitle.Name = "Title"
    afTitle.Size = UDim2.new(1, -10, 0, 25)
    afTitle.Position = UDim2.new(0, 5, 0, 5)
    afTitle.BackgroundTransparency = 1
    afTitle.Text = "🔍 AUTOFINDER"
    afTitle.TextColor3 = self.Themes.Dark.Secondary
    afTitle.Font = Enum.Font.GothamBold
    afTitle.TextSize = 16
    afTitle.TextXAlignment = Enum.TextXAlignment.Left
    afTitle.Parent = autoFinderFrame
    
    -- Scan Button
    self.ScanButton = Instance.new("TextButton")
    self.ScanButton.Name = "ScanButton"
    self.ScanButton.Size = UDim2.new(0.45, 0, 0, 30)
    self.ScanButton.Position = UDim2.new(0.025, 0, 0.3, 0)
    self.ScanButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    self.ScanButton.Text = "SCAN"
    self.ScanButton.TextColor3 = Color3.white
    self.ScanButton.Font = Enum.Font.GothamBold
    self.ScanButton.TextSize = 13
    self.ScanButton.Parent = autoFinderFrame
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 6)
    scanCorner.Parent = self.ScanButton
    
    -- Results Button
    self.ResultsButton = Instance.new("TextButton")
    self.ResultsButton.Name = "ResultsButton"
    self.ResultsButton.Size = UDim2.new(0.45, 0, 0, 30)
    self.ResultsButton.Position = UDim2.new(0.525, 0, 0.3, 0)
    self.ResultsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    self.ResultsButton.Text = "RESULTS"
    self.ResultsButton.TextColor3 = Color3.white
    self.ResultsButton.Font = Enum.Font.GothamBold
    self.ResultsButton.TextSize = 13
    self.ResultsButton.Parent = autoFinderFrame
    
    local resultsCorner = Instance.new("UICorner")
    resultsCorner.CornerRadius = UDim.new(0, 6)
    resultsCorner.Parent = self.ResultsButton
    
    -- AutoFinder Status
    self.AFStatus = Instance.new("TextLabel")
    self.AFStatus.Name = "AFStatus"
    self.AFStatus.Size = UDim2.new(1, -20, 0, 40)
    self.AFStatus.Position = UDim2.new(0, 10, 0.6, 0)
    self.AFStatus.BackgroundTransparency = 1
    self.AFStatus.Text = "AutoFinder: Ready"
    self.AFStatus.TextColor3 = Color3.fromRGB(200, 255, 200)
    self.AFStatus.Font = Enum.Font.Gotham
    self.AFStatus.TextSize = 12
    self.AFStatus.TextWrapped = true
    self.AFStatus.TextXAlignment = Enum.TextXAlignment.Left
    self.AFStatus.Parent = autoFinderFrame
end

function FishingUI:CreateStatsSection()
    local statsFrame = Instance.new("Frame")
    statsFrame.Name = "StatsSection"
    statsFrame.Size = UDim2.new(1, 0, 0, 100)
    statsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    statsFrame.BackgroundTransparency = 0.2
    statsFrame.Parent = self.ScrollingFrame
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 6)
    statsCorner.Parent = statsFrame
    
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Name = "Title"
    statsTitle.Size = UDim2.new(1, -10, 0, 25)
    statsTitle.Position = UDim2.new(0, 5, 0, 5)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Text = "📈 STATISTICS"
    statsTitle.TextColor3 = self.Themes.Dark.Secondary
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.TextSize = 16
    statsTitle.TextXAlignment = Enum.TextXAlignment.Left
    statsTitle.Parent = statsFrame
    
    self.FishCaughtText = Instance.new("TextLabel")
    self.FishCaughtText.Name = "FishCaught"
    self.FishCaughtText.Size = UDim2.new(1, -20, 0, 20)
    self.FishCaughtText.Position = UDim2.new(0, 10, 0.3, 0)
    self.FishCaughtText.BackgroundTransparency = 1
    self.FishCaughtText.Text = "🐟 Fish Caught: 0"
    self.FishCaughtText.TextColor3 = Color3.fromRGB(200, 255, 200)
    self.FishCaughtText.Font = Enum.Font.Gotham
    self.FishCaughtText.TextSize = 14
    self.FishCaughtText.TextXAlignment = Enum.TextXAlignment.Left
    self.FishCaughtText.Parent = statsFrame
    
    self.AttemptsText = Instance.new("TextLabel")
    self.AttemptsText.Name = "Attempts"
    self.AttemptsText.Size = UDim2.new(1, -20, 0, 20)
    self.AttemptsText.Position = UDim2.new(0, 10, 0.6, 0)
    self.AttemptsText.BackgroundTransparency = 1
    self.AttemptsText.Text = "🎣 Total Attempts: 0"
    self.AttemptsText.TextColor3 = Color3.fromRGB(255, 255, 200)
    self.AttemptsText.Font = Enum.Font.Gotham
    self.AttemptsText.TextSize = 14
    self.AttemptsText.TextXAlignment = Enum.TextXAlignment.Left
    self.AttemptsText.Parent = statsFrame
end

function FishingUI:CreateDebugSection()
    local debugFrame = Instance.new("Frame")
    debugFrame.Name = "DebugSection"
    debugFrame.Size = UDim2.new(1, 0, 0, 80)
    debugFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    debugFrame.BackgroundTransparency = 0.2
    debugFrame.Parent = self.ScrollingFrame
    
    local debugCorner = Instance.new("UICorner")
    debugCorner.CornerRadius = UDim.new(0, 6)
    debugCorner.Parent = debugFrame
    
    local debugTitle = Instance.new("TextLabel")
    debugTitle.Name = "Title"
    debugTitle.Size = UDim2.new(1, -10, 0, 25)
    debugTitle.Position = UDim2.new(0, 5, 0, 5)
    debugTitle.BackgroundTransparency = 1
    debugTitle.Text = "🐛 DEBUG"
    debugTitle.TextColor3 = self.Themes.Dark.Accent
    debugTitle.Font = Enum.Font.GothamBold
    debugTitle.TextSize = 16
    debugTitle.TextXAlignment = Enum.TextXAlignment.Left
    debugTitle.Parent = debugFrame
    
    -- Debug Log Button
    self.DebugButton = Instance.new("TextButton")
    self.DebugButton.Name = "DebugButton"
    self.DebugButton.Size = UDim2.new(0.45, 0, 0, 30)
    self.DebugButton.Position = UDim2.new(0.025, 0, 0.5, 0)
    self.DebugButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    self.DebugButton.Text = "SHOW LOGS"
    self.DebugButton.TextColor3 = Color3.white
    self.DebugButton.Font = Enum.Font.GothamBold
    self.DebugButton.TextSize = 13
    self.DebugButton.Parent = debugFrame
    
    local debugCorner = Instance.new("UICorner")
    debugCorner.CornerRadius = UDim.new(0, 6)
    debugCorner.Parent = self.DebugButton
    
    -- Reset Stats Button
    self.ResetButton = Instance.new("TextButton")
    self.ResetButton.Name = "ResetButton"
    self.ResetButton.Size = UDim2.new(0.45, 0, 0, 30)
    self.ResetButton.Position = UDim2.new(0.525, 0, 0.5, 0)
    self.ResetButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    self.ResetButton.Text = "RESET STATS"
    self.ResetButton.TextColor3 = Color3.white
    self.ResetButton.Font = Enum.Font.GothamBold
    self.ResetButton.TextSize = 13
    self.ResetButton.Parent = debugFrame
    
    local resetCorner = Instance.new("UICorner")
    resetCorner.CornerRadius = UDim.new(0, 6)
    resetCorner.Parent = self.ResetButton
end

function FishingUI:CreateToggle(parent, label, yPos, initialState, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = label .. "Toggle"
    toggleFrame.Size = UDim2.new(1, -20, 0, 25)
    toggleFrame.Position = UDim2.new(0, 10, 0, yPos)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = label
    toggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0, 50, 0, 25)
    toggleButton.Position = UDim2.new(1, -50, 0, 0)
    toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    toggleButton.Text = initialState and "ON" : "OFF"
    toggleButton.TextColor3 = Color3.white
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 12
    toggleButton.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggleButton
    
    toggleButton.MouseButton1Click:Connect(function()
        local newState = not initialState
        initialState = newState
        toggleButton.BackgroundColor3 = newState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
        toggleButton.Text = newState and "ON" : "OFF"
        
        if callback then
            callback(newState)
        end
    end)
    
    return toggleButton
end

function FishingUI:CreateSlider(parent, label, yPos, width, initialValue, minValue, maxValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = label .. "Slider"
    sliderFrame.Size = UDim2.new(1, -20, 0, 40)
    sliderFrame.Position = UDim2.new(0, 10, 0, yPos)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Name = "Label"
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = label
    sliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.TextSize = 14
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderFrame
    
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Name = "Background"
    sliderBackground.Size = UDim2.new(1, 0, 0, 10)
    sliderBackground.Position = UDim2.new(0, 0, 1, -15)
    sliderBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBackground.BorderSizePixel = 0
    sliderBackground.Parent = sliderFrame
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = sliderBackground
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((initialValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.BackgroundColor3 = self.Themes.Dark.Secondary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBackground
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Name = "SliderButton"
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.Position = UDim2.new((initialValue - minValue) / (maxValue - minValue), -10, 0.5, -10)
    sliderButton.BackgroundColor3 = Color3.white
    sliderButton.Text = ""
    sliderButton.Parent = sliderBackground
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = sliderButton
    
    -- Dragging logic
    local dragging = false
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.Heartbeat:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = sliderBackground.AbsolutePosition
            local frameSize = sliderBackground.AbsoluteSize
            
            local relativeX = math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1)
            local value = math.floor(minValue + relativeX * (maxValue - minValue))
            
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            sliderButton.Position = UDim2.new(relativeX, -10, 0.5, -10)
            sliderLabel.Text = label:gsub("%d+ studs", value .. " studs")
            
            if callback then
                callback(value)
            end
        end
    end)
    
    return sliderButton
end

function FishingUI:SetupEventHandlers()
    -- Dragging functionality
    local dragging = false
    local dragStart, frameStart
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = self.MainContainer.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainContainer.Position = UDim2.new(
                frameStart.X.Scale,
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale,
                frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Button events
    self.CloseButton.MouseButton1Click:Connect(function()
        self:ToggleUI()
    end)
    
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self.Content.Visible = not self.Content.Visible
        if self.Content.Visible then
            self.MainContainer.Size = UDim2.new(0, 350, 0, 500)
            self.MinimizeButton.Text = "─"
        else
            self.MainContainer.Size = UDim2.new(0, 350, 0, 40)
            self.MinimizeButton.Text = "□"
        end
    end)
    
    self.StartButton.MouseButton1Click:Connect(function()
        if self.AutoFish:Start() then
            self:UpdateStatus("Running", Color3.fromRGB(0, 255, 100))
        end
    end)
    
    self.StopButton.MouseButton1Click:Connect(function()
        if self.AutoFish:Stop() then
            self:UpdateStatus("Stopped", Color3.fromRGB(255, 100, 100))
        end
    end)
    
    self.ScanButton.MouseButton1Click:Connect(function()
        if self.AutoFish.AutoFinder then
            self.AutoFish:StartAutoFinderScan()
            self.AFStatus.Text = "AutoFinder: Scanning..."
        end
    end)
    
    self.ResultsButton.MouseButton1Click:Connect(function()
        if self.AutoFish.AutoFinder then
            local results = self.AutoFish.AutoFinder:GetResultsSummary()
            self.AFStatus.Text = string.format(
                "Results: %d objects\n%d Fishing Poles",
                results.CurrentCount,
                results.ByType.FishingPole or 0
            )
        end
    end)
    
    self.DebugButton.MouseButton1Click:Connect(function()
        self.Logger:ToggleUI(not self.Logger.LogContainer.Visible)
    end)
    
    self.ResetButton.MouseButton1Click:Connect(function()
        self.AutoFish:ResetStats()
        self:UpdateStats()
    end)
    
    -- Auto update stats
    self.UpdateConnection = RunService.Heartbeat:Connect(function()
        if self.AutoFish.IsRunning then
            self:UpdateUI()
        end
    end)
end

function FishingUI:UpdateUI()
    self:UpdateStatus()
    self:UpdateStats()
    self:UpdateTargetInfo()
end

function FishingUI:UpdateStatus(status, color)
    if status then
        self.StatusText.Text = status == "Running" and "✅ Running" : "❌ Stopped"
        self.StatusIndicator.BackgroundColor3 = color or 
            (status == "Running" and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50))
    else
        self.StatusText.Text = self.AutoFish.IsRunning and "✅ Running" : "❌ Stopped"
        self.StatusIndicator.BackgroundColor3 = self.AutoFish.IsRunning and 
            Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    end
end

function FishingUI:UpdateStats()
    local stats = self.AutoFish:GetStats()
    self.FishCaughtText.Text = string.format("🐟 Fish Caught: %d", stats.FishCaught)
    self.AttemptsText.Text = string.format("🎣 Total Attempts: %d", stats.TotalAttempts)
end

function FishingUI:UpdateTargetInfo()
    if self.AutoFish.CurrentTarget then
        self.TargetText.Text = string.format(
            "🎯 Target: %s (%.1f studs)",
            self.AutoFish.CurrentTarget.Object.Name,
            self.AutoFish.CurrentTarget.Distance or 0
        )
    else
        self.TargetText.Text = "🎯 Target: None"
    end
end

function FishingUI:ToggleUI()
    self.IsVisible = not self.IsVisible
    self.ScreenGui.Enabled = self.IsVisible
    self.Logger:Info(self.ServiceName, "UI " .. (self.IsVisible and "shown" : "hidden"))
end

function FishingUI:Show()
    self.IsVisible = true
    self.ScreenGui.Enabled = true
end

function FishingUI:Hide()
    self.IsVisible = false
    self.ScreenGui.Enabled = false
end

function FishingUI:Destroy()
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
    end
    
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    
    self.Logger:Info(self.ServiceName, "UI destroyed")
end

return FishingUI
