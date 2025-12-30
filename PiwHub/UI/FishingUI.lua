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
    themeLabel.Size = UDim2.new(1, 0, 0, 
