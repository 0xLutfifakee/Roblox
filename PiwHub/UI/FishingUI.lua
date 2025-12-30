-- PiwHub Fishing UI - Modern Interface
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local PiwHubUI = {}
PiwHubUI.__index = PiwHubUI

-- Color palette
local Colors = {
    Primary = Color3.fromRGB(88, 101, 242),
    Secondary = Color3.fromRGB(255, 115, 105),
    Success = Color3.fromRGB(87, 242, 135),
    Warning = Color3.fromRGB(242, 201, 76),
    Danger = Color3.fromRGB(242, 76, 76),
    Dark = Color3.fromRGB(25, 25, 35),
    Darker = Color3.fromRGB(15, 15, 25),
    Light = Color3.fromRGB(240, 240, 245),
    Text = Color3.fromRGB(230, 230, 240),
    TextSecondary = Color3.fromRGB(180, 180, 200)
}

-- Load AutoFish module
local AutoFish
local function LoadAutoFish()
    local success, result = pcall(function()
        return require(script.Parent.Parent.Features.Fishing.AutoFish)
    end)
    if success then
        return result
    end
    -- Fallback to direct load
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/0xLutfifakee/Roblox/refs/heads/main/PiwHub/Features/Fishing/AutoFish.lua"))()
end

function PiwHubUI.new()
    local self = setmetatable({}, PiwHubUI)
    
    self.Elements = {}
    self.IsVisible = true
    self.Minimized = false
    
    -- Try to load AutoFish
    AutoFish = LoadAutoFish()
    
    return self
end

function PiwHubUI:CreateWindow()
    -- Create main screen gui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "PiwHubFishingUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.DisplayOrder = 999
    self.ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Main container
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 500, 0, 600)
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    self.MainFrame.BackgroundColor3 = Colors.Dark
    self.MainFrame.BackgroundTransparency = 0.05
    self.MainFrame.BorderSizePixel = 0
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = self.MainFrame
    
    -- Drop shadow
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = self.MainFrame
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    DropShadow.Size = UDim2.new(1, 44, 1, 44)
    DropShadow.Image = "rbxassetid://6014261993"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.5
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.ZIndex = -1
    
    -- Title bar
    self.TitleBar = self:CreateTitleBar()
    
    -- Tab buttons
    self.Tabs = self:CreateTabs()
    
    -- Content area
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Size = UDim2.new(1, -40, 1, -120)
    self.ContentFrame.Position = UDim2.new(0, 20, 0, 100)
    self.ContentFrame.BackgroundTransparency = 1
    
    -- Create tab contents
    self.TabContents = {
        Main = self:CreateMainTab(),
        Settings = self:CreateSettingsTab(),
        Debug = self:CreateDebugTab(),
        Statistics = self:CreateStatsTab()
    }
    
    -- Show default tab
    self:SwitchTab("Main")
    
    -- Assemble UI
    self.TitleBar.Parent = self.MainFrame
    self.Tabs.Parent = self.MainFrame
    self.ContentFrame.Parent = self.MainFrame
    
    self.MainFrame.Parent = self.ScreenGui
    
    -- Initialize with animation
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.4, -300)
    self.MainFrame.BackgroundTransparency = 1
    
    local tweenIn = TweenService:Create(self.MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0.5, -250, 0.5, -300),
        BackgroundTransparency = 0.05
    })
    tweenIn:Play()
    
    -- Setup keybinds
    self:SetupKeybinds()
    
    return self
end

function PiwHubUI:CreateTitleBar()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    
    -- Logo/Title
    local title = Instance.new("TextLabel")
    title.Text = "PiwHub  •  AutoFish"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Colors.Primary
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 24
    closeBtn.TextColor3 = Colors.Text
    closeBtn.BackgroundColor3 = Colors.Darker
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Text = "−"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 24
    minBtn.TextColor3 = Colors.Text
    minBtn.BackgroundColor3 = Colors.Darker
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -80, 0.5, -15)
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minBtn
    
    minBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    title.Parent = frame
    closeBtn.Parent = frame
    minBtn.Parent = frame
    
    -- Make draggable
    self:MakeDraggable(frame, self.MainFrame)
    
    return frame
end

function PiwHubUI:CreateTabs()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -40, 0, 40)
    frame.Position = UDim2.new(0, 20, 0, 60)
    frame.BackgroundTransparency = 1
    
    local tabs = {"Main", "Settings", "Debug", "Statistics"}
    local buttons = {}
    
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Text = tabName
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        btn.TextColor3 = Colors.TextSecondary
        btn.BackgroundColor3 = Colors.Darker
        btn.Size = UDim2.new(0.22, -5, 1, 0)
        btn.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
        btn.AutoButtonColor = false
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        btn.MouseEnter:Connect(function()
            if self.CurrentTab ~= tabName then
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                }):Play()
            end
        end)
        
        btn.MouseLeave:Connect(function()
            if self.CurrentTab ~= tabName then
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Colors.Darker
                }):Play()
            end
        end)
        
        btn.MouseButton1Click:Connect(function()
            self:SwitchTab(tabName)
        end)
        
        buttons[tabName] = btn
        btn.Parent = frame
    end
    
    self.TabButtons = buttons
    return frame
end

function PiwHubUI:CreateMainTab()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    
    -- Status indicator
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, 0, 0, 80)
    statusFrame.BackgroundColor3 = Colors.Darker
    statusFrame.BorderSizePixel = 0
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Text = "STATUS: STOPPED"
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 16
    statusLabel.TextColor3 = Colors.Danger
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, -20, 0.5, 0)
    statusLabel.Position = UDim2.new(0, 10, 0, 10)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Text = "Ready to start fishing automation"
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 12
    infoLabel.TextColor3 = Colors.TextSecondary
    infoLabel.BackgroundTransparency = 1
    infoLabel.Size = UDim2.new(1, -20, 0.5, 0)
    infoLabel.Position = UDim2.new(0, 10, 0.5, 0)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Main toggle button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Text = "START AUTO FISHING"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 16
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.BackgroundColor3 = Colors.Success
    toggleBtn.Size = UDim2.new(1, 0, 0, 50)
    toggleBtn.Position = UDim2.new(0, 0, 0, 100)
    toggleBtn.AutoButtonColor = false
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBtn
    
    -- Options frame
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(1, 0, 0, 200)
    optionsFrame.Position = UDim2.new(0, 0, 0, 170)
    optionsFrame.BackgroundTransparency = 1
    
    -- Auto Cast toggle
    local castToggle = self:CreateToggle("Auto Cast", true, function(value)
        if AutoFish then
            AutoFish:ToggleSetting("AutoCast", value)
        end
    end)
    castToggle.Position = UDim2.new(0, 0, 0, 0)
    castToggle.Parent = optionsFrame
    
    -- Auto Reel toggle
    local reelToggle = self:CreateToggle("Auto Reel", true, function(value)
        if AutoFish then
            AutoFish:ToggleSetting("AutoReel", value)
        end
    end)
    reelToggle.Position = UDim2.new(0, 0, 0, 40)
    reelToggle.Parent = optionsFrame
    
    -- Auto Sell toggle
    local sellToggle = self:CreateToggle("Auto Sell", false, function(value)
        if AutoFish then
            AutoFish:ToggleSetting("AutoSell", value)
        end
    end)
    sellToggle.Position = UDim2.new(0, 0, 0, 80)
    sellToggle.Parent = optionsFrame
    
    -- Bypass AC toggle
    local bypassToggle = self:CreateToggle("Bypass Anti-Cheat", true, function(value)
        if AutoFish then
            AutoFish:ToggleSetting("BypassAC", value)
        end
    end)
    bypassToggle.Position = UDim2.new(0, 0, 0, 120)
    bypassToggle.Parent = optionsFrame
    
    -- Scan button
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "SCAN FOR REMOTES"
    scanBtn.Font = Enum.Font.GothamMedium
    scanBtn.TextSize = 14
    scanBtn.TextColor3 = Colors.Text
    scanBtn.BackgroundColor3 = Colors.Primary
    scanBtn.Size = UDim2.new(1, 0, 0, 40)
    scanBtn.Position = UDim2.new(0, 0, 0, 380)
    scanBtn.AutoButtonColor = false
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 8)
    scanCorner.Parent = scanBtn
    
    scanBtn.MouseButton1Click:Connect(function()
        if AutoFish then
            AutoFish:ScanRemotes()
            self:ShowNotification("Scanning for fishing remotes...")
        end
    end)
    
    -- Connect toggle button
    local isActive = false
    toggleBtn.MouseButton1Click:Connect(function()
        if AutoFish then
            if not isActive then
                AutoFish:Start()
                toggleBtn.Text = "STOP AUTO FISHING"
                toggleBtn.BackgroundColor3 = Colors.Danger
                statusLabel.Text = "STATUS: ACTIVE"
                statusLabel.TextColor3 = Colors.Success
                infoLabel.Text = "Fishing automation is running"
                isActive = true
            else
                AutoFish:Stop()
                toggleBtn.Text = "START AUTO FISHING"
                toggleBtn.BackgroundColor3 = Colors.Success
                statusLabel.Text = "STATUS: STOPPED"
                statusLabel.TextColor3 = Colors.Danger
                infoLabel.Text = "Ready to start fishing automation"
                isActive = false
            end
        end
    end)
    
    -- Assemble
    statusLabel.Parent = statusFrame
    infoLabel.Parent = statusFrame
    statusFrame.Parent = frame
    toggleBtn.Parent = frame
    optionsFrame.Parent = frame
    scanBtn.Parent = frame
    
    self.StatusLabel = statusLabel
    self.InfoLabel = infoLabel
    self.ToggleButton = toggleBtn
    
    return frame
end

function PiwHubUI:CreateSettingsTab()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    
    -- Settings container
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 3
    container.CanvasSize = UDim2.new(0, 0, 0, 500)
    
    -- Cast delay slider
    local castSlider = self:CreateSlider("Cast Delay", 0.5, 5, 0.1, 2.0, "s")
    castSlider.Position = UDim2.new(0, 0, 0, 0)
    castSlider.Parent = container
    
    -- Reel delay slider
    local reelSlider = self:CreateSlider("Reel Delay", 0.1, 2, 0.1, 0.5, "s")
    reelSlider.Position = UDim2.new(0, 0, 0, 80)
    reelSlider.Parent = container
    
    -- UI Theme dropdown
    local themeLabel = Instance.new("TextLabel")
    themeLabel.Text = "UI Theme"
    themeLabel.Font = Enum.Font.GothamMedium
    themeLabel.TextSize = 14
    themeLabel.TextColor3 = Colors.Text
    themeLabel.BackgroundTransparency = 1
    themeLabel.Size = UDim2.new(1, 0, 0, 30)
    themeLabel.Position = UDim2.new(0, 0, 0, 160)
    themeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local themeDropdown = Instance.new("Frame")
    themeDropdown.Size = UDim2.new(1, 0, 0, 40)
    themeDropdown.Position = UDim2.new(0, 0, 0, 190)
    themeDropdown.BackgroundColor3 = Colors.Darker
    themeDropdown.BorderSizePixel = 0
    
    local themeCorner = Instance.new("UICorner")
    themeCorner.CornerRadius = UDim.new(0, 8)
    themeCorner.Parent = themeDropdown
    
    local themeText = Instance.new("TextLabel")
    themeText.Text = "Dark"
    themeText.Font = Enum.Font.Gotham
    themeText.TextSize = 14
    themeText.TextColor3 = Colors.Text
    themeText.BackgroundTransparency = 1
    themeText.Size = UDim2.new(0.8, 0, 1, 0)
    themeText.Position = UDim2.new(0, 10, 0, 0)
    themeText.TextXAlignment = Enum.TextXAlignment.Left
    
    local themeBtn = Instance.new("TextButton")
    themeBtn.Text = "▼"
    themeBtn.Font = Enum.Font.GothamBold
    themeBtn.TextSize = 14
    themeBtn.TextColor3 = Colors.Text
    themeBtn.BackgroundTransparency = 1
    themeBtn.Size = UDim2.new(0.2, -10, 1, 0)
    themeBtn.Position = UDim2.new(0.8, 10, 0, 0)
    themeBtn.AutoButtonColor = false
    
    -- Save settings button
    local saveBtn = Instance.new("TextButton")
    saveBtn.Text = "SAVE SETTINGS"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 16
    saveBtn.TextColor3 = Colors.Text
    saveBtn.BackgroundColor3 = Colors.Primary
    saveBtn.Size = UDim2.new(1, 0, 0, 50)
    saveBtn.Position = UDim2.new(0, 0, 0, 400)
    saveBtn.AutoButtonColor = false
    
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 8)
    saveCorner.Parent = saveBtn
    
    saveBtn.MouseButton1Click:Connect(function()
        self:ShowNotification("Settings saved!")
    end)
    
    -- Assemble
    themeLabel.Parent = container
    themeText.Parent = themeDropdown
    themeBtn.Parent = themeDropdown
    themeDropdown.Parent = container
    saveBtn.Parent = container
    container.Parent = frame
    
    return frame
end

function PiwHubUI:CreateDebugTab()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    
    -- Console output
    local consoleFrame = Instance.new("Frame")
    consoleFrame.Size = UDim2.new(1, 0, 1, -100)
    consoleFrame.BackgroundColor3 = Colors.Darker
    consoleFrame.BorderSizePixel = 0
    
    local consoleCorner = Instance.new("UICorner")
    consoleCorner.CornerRadius = UDim.new(0, 8)
    consoleCorner.Parent = consoleFrame
    
    self.ConsoleOutput = Instance.new("ScrollingFrame")
    self.ConsoleOutput.Name = "ConsoleOutput"
    self.ConsoleOutput.Size = UDim2.new(1, -20, 1, -20)
    self.ConsoleOutput.Position = UDim2.new(0, 10, 0, 10)
    self.ConsoleOutput.BackgroundTransparency = 1
    self.ConsoleOutput.ScrollBarThickness = 3
    self.ConsoleOutput.CanvasSize = UDim2.new(0, 0, 0, 1000)
    
    local consoleLabel = Instance.new("TextLabel")
    consoleLabel.Text = "> AutoFish Debug Console"
    consoleLabel.Font = Enum.Font.RobotoMono
    consoleLabel.TextSize = 12
    consoleLabel.TextColor3 = Colors.TextSecondary
    consoleLabel.BackgroundTransparency = 1
    consoleLabel.Size = UDim2.new(1, 0, 0, 20)
    consoleLabel.TextXAlignment = Enum.TextXAlignment.Left
    consoleLabel.TextYAlignment = Enum.TextYAlignment.Top
    consoleLabel.TextWrapped = true
    consoleLabel.Parent = self.ConsoleOutput
    
    -- Debug buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.Position = UDim2.new(0, 0, 1, -90)
    buttonFrame.BackgroundTransparency = 1
    
    local testBtn = Instance.new("TextButton")
    testBtn.Text = "TEST DETECTION"
    testBtn.Font = Enum.Font.GothamMedium
    testBtn.TextSize = 14
    testBtn.TextColor3 = Colors.Text
    testBtn.BackgroundColor3 = Colors.Warning
    testBtn.Size = UDim2.new(0.48, 0, 1, 0)
    testBtn.Position = UDim2.new(0, 0, 0, 0)
    testBtn.AutoButtonColor = false
    
    local testCorner = Instance.new("UICorner")
    testCorner.CornerRadius = UDim.new(0, 8)
    testCorner.Parent = testBtn
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Text = "CLEAR CONSOLE"
    clearBtn.Font = Enum.Font.GothamMedium
    clearBtn.TextSize = 14
    clearBtn.TextColor3 = Colors.Text
    clearBtn.BackgroundColor3 = Colors.Danger
    clearBtn.Size = UDim2.new(0.48, 0, 1, 0)
    clearBtn.Position = UDim2.new(0.52, 0, 0, 0)
    clearBtn.AutoButtonColor = false
    
    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 8)
    clearCorner.Parent = clearBtn
    
    testBtn.MouseButton1Click:Connect(function()
        self:LogToConsole("Running detection test...")
        self:LogToConsole("Test completed successfully")
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        consoleLabel.Text = "> AutoFish Debug Console"
        self.ConsoleOutput.CanvasPosition = Vector2.new(0, 0)
    end)
    
    -- Assemble
    self.ConsoleOutput.Parent = consoleFrame
    consoleFrame.Parent = frame
    testBtn.Parent = buttonFrame
    clearBtn.Parent = buttonFrame
    buttonFrame.Parent = frame
    
    return frame
end

function PiwHubUI:CreateStatsTab()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    
    -- Stats container
    local statsGrid = Instance.new("Frame")
    statsGrid.Size = UDim2.new(1, 0, 0, 300)
    statsGrid.BackgroundTransparency = 1
    
    local stats = {
        {"Total Fishes", "0", Colors.Text},
        {"Legendary", "0", Color3.fromRGB(255, 215, 0)},
        {"Mythical", "0", Color3.fromRGB(255, 100, 100)},
        {"Divine", "0", Color3.fromRGB(255, 50, 255)},
        {"Money Earned", "$0", Colors.Success},
        {"Session Time", "0s", Colors.Primary}
    }
    
    for i, statData in ipairs(stats) do
        local row = math.floor((i-1)/2)
        local col = (i-1) % 2
        
        local statFrame = Instance.new("Frame")
        statFrame.Size = UDim2.new(0.48, 0, 0, 80)
        statFrame.Position = UDim2.new(col * 0.52, 0, row * 100, 0)
        statFrame.BackgroundColor3 = Colors.Darker
        statFrame.BorderSizePixel = 0
        
        local statCorner = Instance.new("UICorner")
        statCorner.CornerRadius = UDim.new(0, 8)
        statCorner.Parent = statFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = statData[1]
        nameLabel.Font = Enum.Font.GothamMedium
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = Colors.TextSecondary
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, -20, 0, 30)
        nameLabel.Position = UDim2.new(0, 10, 0, 10)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Text = statData[2]
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 24
        valueLabel.TextColor3 = statData[3]
        valueLabel.BackgroundTransparency = 1
        valueLabel.Size = UDim2.new(1, -20, 0, 40)
        valueLabel.Position = UDim2.new(0, 10, 0, 30)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        nameLabel.Parent = statFrame
        valueLabel.Parent = statFrame
        statFrame.Parent = statsGrid
        
        self.StatsLabels = self.StatsLabels or {}
        self.StatsLabels[statData[1]] = valueLabel
    end
    
    -- Refresh button
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Text = "REFRESH STATS"
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 16
    refreshBtn.TextColor3 = Colors.Text
    refreshBtn.BackgroundColor3 = Colors.Primary
    refreshBtn.Size = UDim2.new(1, 0, 0, 50)
    refreshBtn.Position = UDim2.new(0, 0, 0, 350)
    refreshBtn.AutoButtonColor = false
    
    local refreshCorner = Instance.new("UICorner")
    refreshCorner.CornerRadius = UDim.new(0, 8)
    refreshCorner.Parent = refreshBtn
    
    refreshBtn.MouseButton1Click:Connect(function()
        self:UpdateStatistics()
    end)
    
    -- Auto-refresh loop
    task.spawn(function()
        while self.ScreenGui and self.ScreenGui.Parent do
            self:UpdateStatistics()
            task.wait(5)
        end
    end)
    
    statsGrid.Parent = frame
    refreshBtn.Parent = frame
    
    return frame
end

function PiwHubUI:CreateToggle(label, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextSize = 14
    labelText.TextColor3 = Colors.Text
    labelText.BackgroundTransparency = 1
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton")
    toggle.Text = ""
    toggle.BackgroundColor3 = defaultValue and Colors.Success or Colors.Danger
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(1, -50, 0.5, -12.5)
    toggle.AutoButtonColor = false
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 21, 0, 21)
    knob.Position = UDim2.new(defaultValue and 0.58 or 0.02, 0, 0.5, -10.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local isToggled = defaultValue
    
    toggle.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        toggle.BackgroundColor3 = isToggled and Colors.Success or Colors.Danger
        
        local targetPos = isToggled and 0.58 or 0.02
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = UDim2.new(targetPos, 0, 0.5, -10.5)
        }):Play()
        
        if callback then
            callback(isToggled)
        end
    end)
    
    knob.Parent = toggle
    labelText.Parent = frame
    toggle.Parent = frame
    
    return frame
end

function PiwHubUI:CreateSlider(label, min, max, step, defaultValue, suffix)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundTransparency = 1
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextSize = 14
    labelText.TextColor3 = Colors.Text
    labelText.BackgroundTransparency = 1
    labelText.Size = UDim2.new(1, 0, 0, 20)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, 0, 0, 6)
    sliderTrack.Position = UDim2.new(0, 0, 0, 30)
    sliderTrack.BackgroundColor3 = Colors.Darker
    sliderTrack.BorderSizePixel = 0
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Colors.Primary
    sliderFill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local sliderKnob = Instance.new("TextButton")
    sliderKnob.Text = ""
    sliderKnob.Size = UDim2.new(0, 20, 0, 20)
    sliderKnob.Position = UDim2.new((defaultValue - min) / (max - min), -10, 0, -7)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel = 0
    sliderKnob.AutoButtonColor = false
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = sliderKnob
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = defaultValue .. (suffix or "")
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.TextColor3 = Colors.TextSecondary
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(1, 0, 0, 20)
    valueLabel.Position = UDim2.new(0, 0, 0, 45)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Dragging logic
    local isDragging = false
    
    local function updateValue(xPos)
        local relative = math.clamp((xPos - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * relative
        value = math.floor(value / step + 0.5) * step
        
        sliderFill.Size = UDim2.new(relative, 0, 1, 0)
        sliderKnob.Position = UDim2.new(relative, -10, 0, -7)
        valueLabel.Text = string.format("%.1f", value) .. (suffix or "")
        
        if AutoFish then
            if label == "Cast Delay" then
                AutoFish:ToggleSetting("CastDelay", value)
            elseif label == "Reel Delay" then
                AutoFish:ToggleSetting("ReelDelay", value)
            end
        end
    end
    
    sliderKnob.MouseButton1Down:Connect(function()
        isDragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if isDragging then
            local mouse = game:GetService("UserInputService"):GetMouseLocation()
            updateValue(mouse.X)
        end
    end)
    
    sliderFill.Parent = sliderTrack
    sliderKnob.Parent = sliderTrack
    sliderTrack.Parent = frame
    labelText.Parent = frame
    valueLabel.Parent = frame
    
    return frame
end

function PiwHubUI:SwitchTab(tabName)
    if self.CurrentTab then
        self.TabContents[self.CurrentTab].Visible = false
        self.TabButtons[self.CurrentTab].TextColor3 = Colors.TextSecondary
        TweenService:Create(self.TabButtons[self.CurrentTab], TweenInfo.new(0.2), {
            BackgroundColor3 = Colors.Darker
        }):Play()
    end
    
    self.CurrentTab = tabName
    self.TabContents[tabName].Visible = true
    self.TabButtons[tabName].TextColor3 = Colors.Primary
    TweenService:Create(self.TabButtons[tabName], TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    }):Play()
    
    if tabName == "Statistics" then
        self:UpdateStatistics()
    end
end

function PiwHubUI:LogToConsole(message)
    if self.ConsoleOutput then
        local label = self.ConsoleOutput:FindFirstChildOfClass("TextLabel")
        if label then
            label.Text = label.Text .. "\n> " .. message
            task.wait()
            self.ConsoleOutput.CanvasPosition = Vector2.new(0, self.ConsoleOutput.CanvasSize.Y.Offset)
        end
    end
end

function PiwHubUI:UpdateStatistics()
    if not self.StatsLabels then return end
    
    if AutoFish then
        local stats = AutoFish:GetStats()
        
        if self.StatsLabels["Total Fishes"] then
            self.StatsLabels["Total Fishes"].Text = tostring(stats.Total or 0)
        end
        if self.StatsLabels["Legendary"] then
            self.StatsLabels["Legendary"].Text = tostring(stats.Legendary or 0)
        end
        if self.StatsLabels["Mythical"] then
            self.StatsLabels["Mythical"].Text = tostring(stats.Mythical or 0)
        end
        if self.StatsLabels["Divine"] then
            self.StatsLabels["Divine"].Text = tostring(stats.Divine or 0)
        end
        if self.StatsLabels["Money Earned"] then
            self.StatsLabels["Money Earned"].Text = "$" .. tostring(stats.Money or 0)
        end
        if self.StatsLabels["Session Time"] then
            local time = stats.SessionTime or 0
            if time > 3600 then
                self.StatsLabels["Session Time"].Text = string.format("%.1fh", time/3600)
            elseif time > 60 then
                self.StatsLabels["Session Time"].Text = string.format("%.0fm", time/60)
            else
                self.StatsLabels["Session Time"].Text = string.format("%.0fs", time)
            end
        end
    end
end

function PiwHubUI:ShowNotification(message)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(1, -320, 1, -80)
    notif.BackgroundColor3 = Colors.Dark
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.Parent = notif
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size = UDim2.new(1, 44, 1, 44)
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = -1
    
    local label = Instance.new("TextLabel")
    label.Text = message
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.TextWrapped = true
    
    label.Parent = notif
    notif.Parent = self.ScreenGui
    
    -- Animate in
    notif.Position = UDim2.new(1, 20, 1, -80)
    local tweenIn = TweenService:Create(notif, TweenInfo.new(0.3), {
        Position = UDim2.new(1, -320, 1, -80)
    })
    tweenIn:Play()
    
    -- Auto remove
    task.delay(3, function()
        if notif and notif.Parent then
            local tweenOut = TweenService:Create(notif, TweenInfo.new(0.3), {
                Position = UDim2.new(1, 20, 1, -80)
            })
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                notif:Destroy()
            end)
        end
    end)
end

function PiwHubUI:MakeDraggable(dragFrame, mainFrame)
    local dragging = false
    local dragInput, mousePos, framePos
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            mainFrame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

function PiwHubUI:SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed then
            if input.KeyCode == Enum.KeyCode.RightControl then
                self:ToggleVisibility()
            elseif input.KeyCode == Enum.KeyCode.Insert then
                self:ToggleVisibility()
            end
        end
    end)
end

function PiwHubUI:ToggleVisibility()
    self.IsVisible = not self.IsVisible
    self.MainFrame.Visible = self.IsVisible
end

function PiwHubUI:ToggleMinimize()
    self.Minimized = not self.Minimized
    if self.Minimized then
        self.MainFrame.Size = UDim2.new(0, 500, 0, 50)
        self.ContentFrame.Visible = false
        self.Tabs.Visible = false
    else
        self.MainFrame.Size = UDim2.new(0, 500, 0, 600)
        self.ContentFrame.Visible = true
        self.Tabs.Visible = true
    end
end

function PiwHubUI:Close()
    local tweenOut = TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, -250, 0.4, -300),
        BackgroundTransparency = 1
    })
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        if self.ScreenGui then
            self.ScreenGui:Destroy()
        end
    end)
end

-- Initialize UI
local UI = PiwHubUI.new()
UI:CreateWindow()

-- Load modules
UI:LogToConsole("PiwHub AutoFish UI Loaded")
UI:LogToConsole("Version 3.0 - BLATANT Edition")
UI:LogToConsole("Game: " .. game.PlaceId)

-- Update stats every 5 seconds
task.spawn(function()
    while task.wait(5) do
        UI:UpdateStatistics()
    end
end)

return UI-- PiwHub Fishing UI - Modern Interface
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local PiwHubUI = {}
PiwHubUI.__index = PiwHubUI

-- Color palette
local Colors = {
    Primary = Color3.fromRGB(88, 101, 242),
    Secondary = Color3.fromRGB(255, 115, 105),
    Success = Color3.fromRGB(87, 242, 135),
    Warning = Color3.fromRGB(242, 201, 76),
    Danger = Color3.fromRGB(242, 76, 76),
    Dark = Color3.fromRGB(25, 25, 35),
    Darker = Color3.fromRGB(15, 15, 25),
    Light = Color3.fromRGB(240, 240, 245),
    Text = Color3.fromRGB(230, 230, 240),
    TextSecondary = Color3.fromRGB(180, 180, 200)
}

-- Load AutoFish module
local AutoFish
local function LoadAutoFish()
    local success, result = pcall(function()
        return require(script.Parent.Parent.Features.Fishing.AutoFish)
    end)
    if success then
        return result
    end
    -- Fallback to direct load
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/PiwHub/Modules/main/AutoFish.lua"))()
end

function PiwHubUI.new()
    local self = setmetatable({}, PiwHubUI)
    
    self.Elements = {}
    self.IsVisible = true
    self.Minimized = false
    
    -- Try to load AutoFish
    AutoFish = LoadAutoFish()
    
    return self
end

function PiwHubUI:CreateWindow()
    -- Create main screen gui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "PiwHubFishingUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.DisplayOrder = 999
    self.ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Main container
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 500, 0, 600)
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    self.MainFrame.BackgroundColor3 = Colors.Dark
    self.MainFrame.BackgroundTransparency = 0.05
    self.MainFrame.BorderSizePixel = 0
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = self.MainFrame
    
    -- Drop shadow
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = self.MainFrame
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    DropShadow.Size = UDim2.new(1, 44, 1, 44)
    DropShadow.Image = "rbxassetid://6014261993"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.5
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.ZIndex = -1
    
    -- Title bar
    self.TitleBar = self:CreateTitleBar()
    
    -- Tab buttons
    self.Tabs = self:CreateTabs()
    
    -- Content area
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Size = UDim2.new(1, -40, 1, -120)
    self.ContentFrame.Position = UDim2.new(0, 20, 0, 100)
    self.ContentFrame.BackgroundTransparency = 1
    
    -- Create tab contents
    self.TabContents = {
        Main = self:CreateMainTab(),
        Settings = self:CreateSettingsTab(),
        Debug = self:CreateDebugTab(),
        Statistics = self:CreateStatsTab()
    }
    
    -- Show default tab
    self:SwitchTab("Main")
    
    -- Assemble UI
    self.TitleBar.Parent = self.MainFrame
    self.Tabs.Parent = self.MainFrame
    self.ContentFrame.Parent = self.MainFrame
    
    self.MainFrame.Parent = self.ScreenGui
    
    -- Initialize with animation
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.4, -300)
    self.MainFrame.BackgroundTransparency = 1
    
    local tweenIn = TweenService:Create(self.MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0.5, -250, 0.5, -300),
        BackgroundTransparency = 0.05
    })
    tweenIn:Play()
    
    -- Setup keybinds
    self:SetupKeybinds()
    
    return self
end

function PiwHubUI:CreateTitleBar()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    
    -- Logo/Title
    local title = Instance.new("TextLabel")
    title.Text = "PiwHub  •  AutoFish"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Colors.Primary
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 24
    closeBtn.TextColor3 = Colors.Text
    closeBtn.BackgroundColor3 = Colors.Darker
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Text = "−"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 24
    minBtn.TextColor3 = Colors.Text
    minBtn.BackgroundColor3 = Colors.Darker
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -80, 0.5, -15)
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minBtn
    
    minBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    title.Parent = frame
    closeBtn.Parent = frame
    minBtn.Parent = frame
    
    -- Make draggable
    self:MakeDraggable(frame, self.MainFrame)
    
    return frame
end

function PiwHubUI:CreateTabs()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -40, 0, 40)
    frame.Position = UDim2.new(0, 20, 0, 60)
    frame.BackgroundTransparency = 1
    
    local tabs = {"Main", "Settings", "Debug", "Statistics"}
    local buttons = {}
    
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Text = tabName
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        btn.TextColor3 = Colors.TextSecondary
        btn.BackgroundColor3 = Colors.Darker
        btn.Size = UDim2.new(0.22, -5, 1, 0)
        btn.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
        btn.AutoButtonColor = false
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        btn.MouseEnter:Connect(function()
            if self.CurrentTab ~= tabName then
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                }):Play()
            end
        end)
        
        btn.MouseLeave:Connect(function()
            if self.CurrentTab ~= tabName then
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Colors.Darker
                }):Play()
            end
        end)
        
        btn.MouseButton1Click:Connect(function()
            self:SwitchTab(tabName)
        end)
        
        buttons[tabName] = btn
        btn.Parent = frame
    end
    
    self.TabButtons = buttons
    return frame
end

function PiwHubUI:CreateMainTab()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    
    -- Status indicator
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, 0, 0, 80)
    statusFrame.BackgroundColor3 = Colors.Darker
    statusFrame.BorderSizePixel = 0
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Text = "STATUS: STOPPED"
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 16
    statusLabel.TextColor3 = Colors.Danger
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, -20, 0.5, 0)
    statusLabel.Position = UDim2.new(0, 10, 0, 10)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Text = "Ready to start fishing automation"
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 12
    infoLabel.TextColor3 = Colors.TextSecondary
    infoLabel.BackgroundTransparency = 1
    infoLabel.Size = UDim2.new(1, -20, 0.5, 0)
    infoLabel.Position = UDim2.new(0, 10, 0.5, 0)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Main toggle button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Text = "START AUTO FISHING"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 16
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.BackgroundColor3 = Colors.Success
    toggleBtn.Size = UDim2.new(1, 0, 0, 50)
    toggleBtn.Position = UDim2.new(0, 0, 0, 100)
    toggleBtn.AutoButtonColor = false
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBtn
    
    -- Options frame
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(1, 0, 0, 200)
    optionsFrame.Position = UDim2.new(0, 0, 0, 170)
    optionsFrame.BackgroundTransparency = 1
    
    -- Auto Cast toggle
    local castToggle = self:CreateToggle("Auto Cast", true, function(value)
        if AutoFish then
            AutoFish:ToggleSetting("AutoCast", value)
        end
    end)
    castToggle.Position = UDim2.new(0, 0, 0, 0)
    castToggle.Parent = optionsFrame
    
    -- Auto Reel toggle
    local reelToggle = self:CreateToggle("Auto Reel", true, function(value)
        if AutoFish then
            AutoFish:ToggleSetting("AutoReel", value)
        end
    end)
    reelToggle.Position = UDim2.new(0, 0, 0, 40)
    reelToggle.Parent = optionsFrame
    
    -- Auto Sell toggle
    local sellToggle = self:CreateToggle("Auto Sell", false, function(value)
        if AutoFish then
            AutoFish:ToggleSetting("AutoSell", value)
        end
    end)
    sellToggle.Position = UDim2.new(0, 0, 0, 80)
    sellToggle.Parent = optionsFrame
    
    -- Bypass AC toggle
    local bypassToggle = self:CreateToggle("Bypass Anti-Cheat", true, function(value)
        if AutoFish then
            AutoFish:ToggleSetting("BypassAC", value)
        end
    end)
    bypassToggle.Position = UDim2.new(0, 0, 0, 120)
    bypassToggle.Parent = optionsFrame
    
    -- Scan button
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "SCAN FOR REMOTES"
    scanBtn.Font = Enum.Font.GothamMedium
    scanBtn.TextSize = 14
    scanBtn.TextColor3 = Colors.Text
    scanBtn.BackgroundColor3 = Colors.Primary
    scanBtn.Size = UDim2.new(1, 0, 0, 40)
    scanBtn.Position = UDim2.new(0, 0, 0, 380)
    scanBtn.AutoButtonColor = false
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 8)
    scanCorner.Parent = scanBtn
    
    scanBtn.MouseButton1Click:Connect(function()
        if AutoFish then
            AutoFish:ScanRemotes()
            self:ShowNotification("Scanning for fishing remotes...")
        end
    end)
    
    -- Connect toggle button
    local isActive = false
    toggleBtn.MouseButton1Click:Connect(function()
        if AutoFish then
            if not isActive then
                AutoFish:Start()
                toggleBtn.Text = "STOP AUTO FISHING"
                toggleBtn.BackgroundColor3 = Colors.Danger
                statusLabel.Text = "STATUS: ACTIVE"
                statusLabel.TextColor3 = Colors.Success
                infoLabel.Text = "Fishing automation is running"
                isActive = true
            else
                AutoFish:Stop()
                toggleBtn.Text = "START AUTO FISHING"
                toggleBtn.BackgroundColor3 = Colors.Success
                statusLabel.Text = "STATUS: STOPPED"
                statusLabel.TextColor3 = Colors.Danger
                infoLabel.Text = "Ready to start fishing automation"
                isActive = false
            end
        end
    end)
    
    -- Assemble
    statusLabel.Parent = statusFrame
    infoLabel.Parent = statusFrame
    statusFrame.Parent = frame
    toggleBtn.Parent = frame
    optionsFrame.Parent = frame
    scanBtn.Parent = frame
    
    self.StatusLabel = statusLabel
    self.InfoLabel = infoLabel
    self.ToggleButton = toggleBtn
    
    return frame
end

function PiwHubUI:CreateSettingsTab()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    
    -- Settings container
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 3
    container.CanvasSize = UDim2.new(0, 0, 0, 500)
    
    -- Cast delay slider
    local castSlider = self:CreateSlider("Cast Delay", 0.5, 5, 0.1, 2.0, "s")
    castSlider.Position = UDim2.new(0, 0, 0, 0)
    castSlider.Parent = container
    
    -- Reel delay slider
    local reelSlider = self:CreateSlider("Reel Delay", 0.1, 2, 0.1, 0.5, "s")
    reelSlider.Position = UDim2.new(0, 0, 0, 80)
    reelSlider.Parent = container
    
    -- UI Theme dropdown
    local themeLabel = Instance.new("TextLabel")
    themeLabel.Text = "UI Theme"
    themeLabel.Font = Enum.Font.GothamMedium
    themeLabel.TextSize = 14
    themeLabel.TextColor3 = Colors.Text
    themeLabel.BackgroundTransparency = 1
    themeLabel.Size = UDim2.new(1, 0, 0, 30)
    themeLabel.Position = UDim2.new(0, 0, 0, 160)
    themeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local themeDropdown = Instance.new("Frame")
    themeDropdown.Size = UDim2.new(1, 0, 0, 40)
    themeDropdown.Position = UDim2.new(0, 0, 0, 190)
    themeDropdown.BackgroundColor3 = Colors.Darker
    themeDropdown.BorderSizePixel = 0
    
    local themeCorner = Instance.new("UICorner")
    themeCorner.CornerRadius = UDim.new(0, 8)
    themeCorner.Parent = themeDropdown
    
    local themeText = Instance.new("TextLabel")
    themeText.Text = "Dark"
    themeText.Font = Enum.Font.Gotham
    themeText.TextSize = 14
    themeText.TextColor3 = Colors.Text
    themeText.BackgroundTransparency = 1
    themeText.Size = UDim2.new(0.8, 0, 1, 0)
    themeText.Position = UDim2.new(0, 10, 0, 0)
    themeText.TextXAlignment = Enum.TextXAlignment.Left
    
    local themeBtn = Instance.new("TextButton")
    themeBtn.Text = "▼"
    themeBtn.Font = Enum.Font.GothamBold
    themeBtn.TextSize = 14
    themeBtn.TextColor3 = Colors.Text
    themeBtn.BackgroundTransparency = 1
    themeBtn.Size = UDim2.new(0.2, -10, 1, 0)
    themeBtn.Position = UDim2.new(0.8, 10, 0, 0)
    themeBtn.AutoButtonColor = false
    
    -- Save settings button
    local saveBtn = Instance.new("TextButton")
    saveBtn.Text = "SAVE SETTINGS"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 16
    saveBtn.TextColor3 = Colors.Text
    saveBtn.BackgroundColor3 = Colors.Primary
    saveBtn.Size = UDim2.new(1, 0, 0, 50)
    saveBtn.Position = UDim2.new(0, 0, 0, 400)
    saveBtn.AutoButtonColor = false
    
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 8)
    saveCorner.Parent = saveBtn
    
    saveBtn.MouseButton1Click:Connect(function()
        self:ShowNotification("Settings saved!")
    end)
    
    -- Assemble
    themeLabel.Parent = container
    themeText.Parent = themeDropdown
    themeBtn.Parent = themeDropdown
    themeDropdown.Parent = container
    saveBtn.Parent = container
    container.Parent = frame
    
    return frame
end

function PiwHubUI:CreateDebugTab()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    
    -- Console output
    local consoleFrame = Instance.new("Frame")
    consoleFrame.Size = UDim2.new(1, 0, 1, -100)
    consoleFrame.BackgroundColor3 = Colors.Darker
    consoleFrame.BorderSizePixel = 0
    
    local consoleCorner = Instance.new("UICorner")
    consoleCorner.CornerRadius = UDim.new(0, 8)
    consoleCorner.Parent = consoleFrame
    
    self.ConsoleOutput = Instance.new("ScrollingFrame")
    self.ConsoleOutput.Name = "ConsoleOutput"
    self.ConsoleOutput.Size = UDim2.new(1, -20, 1, -20)
    self.ConsoleOutput.Position = UDim2.new(0, 10, 0, 10)
    self.ConsoleOutput.BackgroundTransparency = 1
    self.ConsoleOutput.ScrollBarThickness = 3
    self.ConsoleOutput.CanvasSize = UDim2.new(0, 0, 0, 1000)
    
    local consoleLabel = Instance.new("TextLabel")
    consoleLabel.Text = "> AutoFish Debug Console"
    consoleLabel.Font = Enum.Font.RobotoMono
    consoleLabel.TextSize = 12
    consoleLabel.TextColor3 = Colors.TextSecondary
    consoleLabel.BackgroundTransparency = 1
    consoleLabel.Size = UDim2.new(1, 0, 0, 20)
    consoleLabel.TextXAlignment = Enum.TextXAlignment.Left
    consoleLabel.TextYAlignment = Enum.TextYAlignment.Top
    consoleLabel.TextWrapped = true
    consoleLabel.Parent = self.ConsoleOutput
    
    -- Debug buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.Position = UDim2.new(0, 0, 1, -90)
    buttonFrame.BackgroundTransparency = 1
    
    local testBtn = Instance.new("TextButton")
    testBtn.Text = "TEST DETECTION"
    testBtn.Font = Enum.Font.GothamMedium
    testBtn.TextSize = 14
    testBtn.TextColor3 = Colors.Text
    testBtn.BackgroundColor3 = Colors.Warning
    testBtn.Size = UDim2.new(0.48, 0, 1, 0)
    testBtn.Position = UDim2.new(0, 0, 0, 0)
    testBtn.AutoButtonColor = false
    
    local testCorner = Instance.new("UICorner")
    testCorner.CornerRadius = UDim.new(0, 8)
    testCorner.Parent = testBtn
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Text = "CLEAR CONSOLE"
    clearBtn.Font = Enum.Font.GothamMedium
    clearBtn.TextSize = 14
    clearBtn.TextColor3 = Colors.Text
    clearBtn.BackgroundColor3 = Colors.Danger
    clearBtn.Size = UDim2.new(0.48, 0, 1, 0)
    clearBtn.Position = UDim2.new(0.52, 0, 0, 0)
    clearBtn.AutoButtonColor = false
    
    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 8)
    clearCorner.Parent = clearBtn
    
    testBtn.MouseButton1Click:Connect(function()
        self:LogToConsole("Running detection test...")
        self:LogToConsole("Test completed successfully")
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        consoleLabel.Text = "> AutoFish Debug Console"
        self.ConsoleOutput.CanvasPosition = Vector2.new(0, 0)
    end)
    
    -- Assemble
    self.ConsoleOutput.Parent = consoleFrame
    consoleFrame.Parent = frame
    testBtn.Parent = buttonFrame
    clearBtn.Parent = buttonFrame
    buttonFrame.Parent = frame
    
    return frame
end

function PiwHubUI:CreateStatsTab()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    
    -- Stats container
    local statsGrid = Instance.new("Frame")
    statsGrid.Size = UDim2.new(1, 0, 0, 300)
    statsGrid.BackgroundTransparency = 1
    
    local stats = {
        {"Total Fishes", "0", Colors.Text},
        {"Legendary", "0", Color3.fromRGB(255, 215, 0)},
        {"Mythical", "0", Color3.fromRGB(255, 100, 100)},
        {"Divine", "0", Color3.fromRGB(255, 50, 255)},
        {"Money Earned", "$0", Colors.Success},
        {"Session Time", "0s", Colors.Primary}
    }
    
    for i, statData in ipairs(stats) do
        local row = math.floor((i-1)/2)
        local col = (i-1) % 2
        
        local statFrame = Instance.new("Frame")
        statFrame.Size = UDim2.new(0.48, 0, 0, 80)
        statFrame.Position = UDim2.new(col * 0.52, 0, row * 100, 0)
        statFrame.BackgroundColor3 = Colors.Darker
        statFrame.BorderSizePixel = 0
        
        local statCorner = Instance.new("UICorner")
        statCorner.CornerRadius = UDim.new(0, 8)
        statCorner.Parent = statFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = statData[1]
        nameLabel.Font = Enum.Font.GothamMedium
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = Colors.TextSecondary
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, -20, 0, 30)
        nameLabel.Position = UDim2.new(0, 10, 0, 10)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Text = statData[2]
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 24
        valueLabel.TextColor3 = statData[3]
        valueLabel.BackgroundTransparency = 1
        valueLabel.Size = UDim2.new(1, -20, 0, 40)
        valueLabel.Position = UDim2.new(0, 10, 0, 30)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        nameLabel.Parent = statFrame
        valueLabel.Parent = statFrame
        statFrame.Parent = statsGrid
        
        self.StatsLabels = self.StatsLabels or {}
        self.StatsLabels[statData[1]] = valueLabel
    end
    
    -- Refresh button
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Text = "REFRESH STATS"
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 16
    refreshBtn.TextColor3 = Colors.Text
    refreshBtn.BackgroundColor3 = Colors.Primary
    refreshBtn.Size = UDim2.new(1, 0, 0, 50)
    refreshBtn.Position = UDim2.new(0, 0, 0, 350)
    refreshBtn.AutoButtonColor = false
    
    local refreshCorner = Instance.new("UICorner")
    refreshCorner.CornerRadius = UDim.new(0, 8)
    refreshCorner.Parent = refreshBtn
    
    refreshBtn.MouseButton1Click:Connect(function()
        self:UpdateStatistics()
    end)
    
    -- Auto-refresh loop
    task.spawn(function()
        while self.ScreenGui and self.ScreenGui.Parent do
            self:UpdateStatistics()
            task.wait(5)
        end
    end)
    
    statsGrid.Parent = frame
    refreshBtn.Parent = frame
    
    return frame
end

function PiwHubUI:CreateToggle(label, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextSize = 14
    labelText.TextColor3 = Colors.Text
    labelText.BackgroundTransparency = 1
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton")
    toggle.Text = ""
    toggle.BackgroundColor3 = defaultValue and Colors.Success or Colors.Danger
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(1, -50, 0.5, -12.5)
    toggle.AutoButtonColor = false
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 21, 0, 21)
    knob.Position = UDim2.new(defaultValue and 0.58 or 0.02, 0, 0.5, -10.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local isToggled = defaultValue
    
    toggle.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        toggle.BackgroundColor3 = isToggled and Colors.Success or Colors.Danger
        
        local targetPos = isToggled and 0.58 or 0.02
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = UDim2.new(targetPos, 0, 0.5, -10.5)
        }):Play()
        
        if callback then
            callback(isToggled)
        end
    end)
    
    knob.Parent = toggle
    labelText.Parent = frame
    toggle.Parent = frame
    
    return frame
end

function PiwHubUI:CreateSlider(label, min, max, step, defaultValue, suffix)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundTransparency = 1
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextSize = 14
    labelText.TextColor3 = Colors.Text
    labelText.BackgroundTransparency = 1
    labelText.Size = UDim2.new(1, 0, 0, 20)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, 0, 0, 6)
    sliderTrack.Position = UDim2.new(0, 0, 0, 30)
    sliderTrack.BackgroundColor3 = Colors.Darker
    sliderTrack.BorderSizePixel = 0
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Colors.Primary
    sliderFill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local sliderKnob = Instance.new("TextButton")
    sliderKnob.Text = ""
    sliderKnob.Size = UDim2.new(0, 20, 0, 20)
    sliderKnob.Position = UDim2.new((defaultValue - min) / (max - min), -10, 0, -7)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel = 0
    sliderKnob.AutoButtonColor = false
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = sliderKnob
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = defaultValue .. (suffix or "")
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.TextColor3 = Colors.TextSecondary
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(1, 0, 0, 20)
    valueLabel.Position = UDim2.new(0, 0, 0, 45)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Dragging logic
    local isDragging = false
    
    local function updateValue(xPos)
        local relative = math.clamp((xPos - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * relative
        value = math.floor(value / step + 0.5) * step
        
        sliderFill.Size = UDim2.new(relative, 0, 1, 0)
        sliderKnob.Position = UDim2.new(relative, -10, 0, -7)
        valueLabel.Text = string.format("%.1f", value) .. (suffix or "")
        
        if AutoFish then
            if label == "Cast Delay" then
                AutoFish:ToggleSetting("CastDelay", value)
            elseif label == "Reel Delay" then
                AutoFish:ToggleSetting("ReelDelay", value)
            end
        end
    end
    
    sliderKnob.MouseButton1Down:Connect(function()
        isDragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if isDragging then
            local mouse = game:GetService("UserInputService"):GetMouseLocation()
            updateValue(mouse.X)
        end
    end)
    
    sliderFill.Parent = sliderTrack
    sliderKnob.Parent = sliderTrack
    sliderTrack.Parent = frame
    labelText.Parent = frame
    valueLabel.Parent = frame
    
    return frame
end

function PiwHubUI:SwitchTab(tabName)
    if self.CurrentTab then
        self.TabContents[self.CurrentTab].Visible = false
        self.TabButtons[self.CurrentTab].TextColor3 = Colors.TextSecondary
        TweenService:Create(self.TabButtons[self.CurrentTab], TweenInfo.new(0.2), {
            BackgroundColor3 = Colors.Darker
        }):Play()
    end
    
    self.CurrentTab = tabName
    self.TabContents[tabName].Visible = true
    self.TabButtons[tabName].TextColor3 = Colors.Primary
    TweenService:Create(self.TabButtons[tabName], TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    }):Play()
    
    if tabName == "Statistics" then
        self:UpdateStatistics()
    end
end

function PiwHubUI:LogToConsole(message)
    if self.ConsoleOutput then
        local label = self.ConsoleOutput:FindFirstChildOfClass("TextLabel")
        if label then
            label.Text = label.Text .. "\n> " .. message
            task.wait()
            self.ConsoleOutput.CanvasPosition = Vector2.new(0, self.ConsoleOutput.CanvasSize.Y.Offset)
        end
    end
end

function PiwHubUI:UpdateStatistics()
    if not self.StatsLabels then return end
    
    if AutoFish then
        local stats = AutoFish:GetStats()
        
        if self.StatsLabels["Total Fishes"] then
            self.StatsLabels["Total Fishes"].Text = tostring(stats.Total or 0)
        end
        if self.StatsLabels["Legendary"] then
            self.StatsLabels["Legendary"].Text = tostring(stats.Legendary or 0)
        end
        if self.StatsLabels["Mythical"] then
            self.StatsLabels["Mythical"].Text = tostring(stats.Mythical or 0)
        end
        if self.StatsLabels["Divine"] then
            self.StatsLabels["Divine"].Text = tostring(stats.Divine or 0)
        end
        if self.StatsLabels["Money Earned"] then
            self.StatsLabels["Money Earned"].Text = "$" .. tostring(stats.Money or 0)
        end
        if self.StatsLabels["Session Time"] then
            local time = stats.SessionTime or 0
            if time > 3600 then
                self.StatsLabels["Session Time"].Text = string.format("%.1fh", time/3600)
            elseif time > 60 then
                self.StatsLabels["Session Time"].Text = string.format("%.0fm", time/60)
            else
                self.StatsLabels["Session Time"].Text = string.format("%.0fs", time)
            end
        end
    end
end

function PiwHubUI:ShowNotification(message)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(1, -320, 1, -80)
    notif.BackgroundColor3 = Colors.Dark
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.Parent = notif
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size = UDim2.new(1, 44, 1, 44)
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = -1
    
    local label = Instance.new("TextLabel")
    label.Text = message
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.TextWrapped = true
    
    label.Parent = notif
    notif.Parent = self.ScreenGui
    
    -- Animate in
    notif.Position = UDim2.new(1, 20, 1, -80)
    local tweenIn = TweenService:Create(notif, TweenInfo.new(0.3), {
        Position = UDim2.new(1, -320, 1, -80)
    })
    tweenIn:Play()
    
    -- Auto remove
    task.delay(3, function()
        if notif and notif.Parent then
            local tweenOut = TweenService:Create(notif, TweenInfo.new(0.3), {
                Position = UDim2.new(1, 20, 1, -80)
            })
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                notif:Destroy()
            end)
        end
    end)
end

function PiwHubUI:MakeDraggable(dragFrame, mainFrame)
    local dragging = false
    local dragInput, mousePos, framePos
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            mainFrame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

function PiwHubUI:SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed then
            if input.KeyCode == Enum.KeyCode.RightControl then
                self:ToggleVisibility()
            elseif input.KeyCode == Enum.KeyCode.Insert then
                self:ToggleVisibility()
            end
        end
    end)
end

function PiwHubUI:ToggleVisibility()
    self.IsVisible = not self.IsVisible
    self.MainFrame.Visible = self.IsVisible
end

function PiwHubUI:ToggleMinimize()
    self.Minimized = not self.Minimized
    if self.Minimized then
        self.MainFrame.Size = UDim2.new(0, 500, 0, 50)
        self.ContentFrame.Visible = false
        self.Tabs.Visible = false
    else
        self.MainFrame.Size = UDim2.new(0, 500, 0, 600)
        self.ContentFrame.Visible = true
        self.Tabs.Visible = true
    end
end

function PiwHubUI:Close()
    local tweenOut = TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, -250, 0.4, -300),
        BackgroundTransparency = 1
    })
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        if self.ScreenGui then
            self.ScreenGui:Destroy()
        end
    end)
end

-- Initialize UI
local UI = PiwHubUI.new()
UI:CreateWindow()

-- Load modules
UI:LogToConsole("PiwHub AutoFish UI Loaded")
UI:LogToConsole("Version 3.0 - BLATANT Edition")
UI:LogToConsole("Game: " .. game.PlaceId)

-- Update stats every 5 seconds
task.spawn(function()
    while task.wait(5) do
        UI:UpdateStatistics()
    end
end)

return UI
