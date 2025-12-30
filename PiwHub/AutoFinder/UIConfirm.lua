--[[
    UIConfirm.lua - UI untuk konfirmasi target fishing
    Interactive confirmation system
]]--

local UIConfirm = {
    ServiceName = "UIConfirm",
    Version = "1.2.0",
    IsVisible = false,
    CurrentTarget = nil
}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

function UIConfirm:Initialize()
    self.Player = Players.LocalPlayer
    self.PlayerGui = self.Player:WaitForChild("PlayerGui")
    self.Logger = require(game:GetService("ReplicatedStorage"):WaitForChild("PiwHub"):WaitForChild("Debug"):WaitForChild("Logger"))
    
    self:CreateUI()
    self.Logger:Info(self.ServiceName, "UIConfirm initialized")
end

function UIConfirm:CreateUI()
    -- ScreenGui utama
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "PiwHub_UIConfirm"
    self.ScreenGui.DisplayOrder = 100
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = self.PlayerGui
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 400, 0, 300)
    self.MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.MainFrame.BorderColor3 = Color3.fromRGB(0, 170, 255)
    self.MainFrame.BorderSizePixel = 2
    self.MainFrame.BackgroundTransparency = 0.1
    self.MainFrame.Visible = false
    self.MainFrame.Parent = self.ScreenGui
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.MainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔍 PIHWUB TARGET CONFIRMATION"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.white
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = self.MainFrame
    
    -- Target Info
    local targetInfo = Instance.new("TextLabel")
    targetInfo.Name = "TargetInfo"
    targetInfo.Size = UDim2.new(1, 0, 0, 100)
    targetInfo.BackgroundTransparency = 1
    targetInfo.Text = "Target information will appear here"
    targetInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    targetInfo.Font = Enum.Font.Gotham
    targetInfo.TextSize = 14
    targetInfo.TextWrapped = true
    targetInfo.Parent = contentFrame
    
    -- Buttons Container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, 0, 0, 50)
    buttonContainer.Position = UDim2.new(0, 0, 1, -50)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = contentFrame
    
    -- Confirm Button
    local confirmButton = Instance.new("TextButton")
    confirmButton.Name = "ConfirmButton"
    confirmButton.Size = UDim2.new(0.4, 0, 0.8, 0)
    confirmButton.Position = UDim2.new(0.05, 0, 0.1, 0)
    confirmButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    confirmButton.Text = "✓ CONFIRM"
    confirmButton.TextColor3 = Color3.white
    confirmButton.Font = Enum.Font.GothamBold
    confirmButton.TextSize = 16
    confirmButton.Parent = buttonContainer
    
    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0, 6)
    confirmCorner.Parent = confirmButton
    
    -- Cancel Button
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0.4, 0, 0.8, 0)
    cancelButton.Position = UDim2.new(0.55, 0, 0.1, 0)
    cancelButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    cancelButton.Text = "✗ CANCEL"
    cancelButton.TextColor3 = Color3.white
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.TextSize = 16
    cancelButton.Parent = buttonContainer
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 6)
    cancelCorner.Parent = cancelButton
    
    -- Event Connections
    closeButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
    confirmButton.MouseButton1Click:Connect(function()
        if self.OnConfirm and self.CurrentTarget then
            self.OnConfirm(self.CurrentTarget)
        end
        self:Hide()
    end)
end

function UIConfirm:Show(targetInfo)
    if not targetInfo then
        self.Logger:Warn(self.ServiceName, "No target info provided")
        return
    end
    
    self.CurrentTarget = targetInfo
    self.MainFrame.Visible = true
    self.IsVisible = true
    
    -- Update target information
    local targetInfoLabel = self.MainFrame.Content.TargetInfo
    local infoText = string.format(
        "🎯 TARGET DETECTED\n\n" ..
        "Type: %s\n" ..
        "Name: %s\n" ..
        "Distance: %.2f studs\n" ..
        "Confidence: %.0f%%\n\n" ..
        "Do you want to target this object?",
        targetInfo.Type or "Unknown",
        targetInfo.Object.Name,
        targetInfo.Distance or 0,
        (targetInfo.Confidence or 0) * 100
    )
    
    targetInfoLabel.Text = infoText
    
    -- Animate appearance
    self.MainFrame.BackgroundTransparency = 1
    local tween = TweenService:Create(
        self.MainFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.1}
    )
    tween:Play()
    
    self.Logger:Info(self.ServiceName, "Confirmation UI shown for target:", targetInfo.Object.Name)
end

function UIConfirm:Hide()
    self.IsVisible = false
    self.CurrentTarget = nil
    
    -- Animate disappearance
    local tween = TweenService:Create(
        self.MainFrame,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {BackgroundTransparency = 1}
    )
    tween:Play()
    
    tween.Completed:Connect(function()
        self.MainFrame.Visible = false
    end)
    
    self.Logger:Info(self.ServiceName, "Confirmation UI hidden")
end

function UIConfirm:SetConfirmCallback(callback)
    self.OnConfirm = callback
    self.Logger:Debug(self.ServiceName, "Confirm callback set")
end

function UIConfirm:IsUIVisible()
    return self.IsVisible
end

return UIConfirm
