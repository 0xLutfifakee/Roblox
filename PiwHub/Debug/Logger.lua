--[[
    Logger.lua - Advanced logging system untuk PiwHub
    BLATANT debug system
]]--

local Logger = {
    ServiceName = "Logger",
    Version = "2.0.0",
    LogLevel = "INFO", -- DEBUG, INFO, WARN, ERROR
    LogHistory = {},
    MaxHistory = 1000,
    Colors = {
        DEBUG = Color3.fromRGB(100, 100, 255),
        INFO = Color3.fromRGB(0, 200, 255),
        WARN = Color3.fromRGB(255, 165, 0),
        ERROR = Color3.fromRGB(255, 50, 50),
        SUCCESS = Color3.fromRGB(0, 255, 100)
    },
    OutputConsole = true,
    OutputUI = true
}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function Logger:Initialize()
    self.Player = Players.LocalPlayer
    self:CreateOutputUI()
    
    self:Info(self.ServiceName, string.format(
        "Logger initialized v%s (Level: %s)",
        self.Version,
        self.LogLevel
    ))
end

function Logger:CreateOutputUI()
    if not self.OutputUI then return end
    
    -- ScreenGui untuk log output
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "PiwHub_Logger"
    self.ScreenGui.DisplayOrder = 999
    self.ScreenGui.ResetOnSpawn = false
    
    -- Log Container
    self.LogContainer = Instance.new("Frame")
    self.LogContainer.Name = "LogContainer"
    self.LogContainer.Size = UDim2.new(0, 400, 0.5, 0)
    self.LogContainer.Position = UDim2.new(1, -410, 0.5, -100)
    self.LogContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    self.LogContainer.BackgroundTransparency = 0.3
    self.LogContainer.BorderSizePixel = 0
    self.LogContainer.Visible = false
    self.LogContainer.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.LogContainer
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.LogContainer
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "PIWHUB DEBUG LOGS"
    titleLabel.TextColor3 = Color3.white
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Toggle Visibility Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -45, 0.5, -10)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleBtn.Text = "HIDE"
    toggleBtn.TextColor3 = Color3.white
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.TextSize = 12
    toggleBtn.Parent = titleBar
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggleBtn
    
    -- Log Scrolling Frame
    self.ScrollingFrame = Instance.new("ScrollingFrame")
    self.ScrollingFrame.Name = "LogScroller"
    self.ScrollingFrame.Size = UDim2.new(1, -10, 1, -40)
    self.ScrollingFrame.Position = UDim2.new(0, 5, 0, 35)
    self.ScrollingFrame.BackgroundTransparency = 1
    self.ScrollingFrame.BorderSizePixel = 0
    self.ScrollingFrame.ScrollBarThickness = 6
    self.ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    self.ScrollingFrame.Parent = self.LogContainer
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 2)
    uiListLayout.Parent = self.ScrollingFrame
    
    -- Button events
    toggleBtn.MouseButton1Click:Connect(function()
        self.LogContainer.Visible = not self.LogContainer.Visible
        toggleBtn.Text = self.LogContainer.Visible and "HIDE" or "SHOW"
    end)
    
    self.ScreenGui.Parent = self.Player:WaitForChild("PlayerGui")
end

function Logger:SetLogLevel(level)
    local validLevels = {"DEBUG", "INFO", "WARN", "ERROR"}
    if table.find(validLevels, level:upper()) then
        self.LogLevel = level:upper()
        self:Info(self.ServiceName, "Log level set to: " .. self.LogLevel)
        return true
    end
    return false
end

function Logger:GetLogLevelNumber(level)
    local levels = {DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4}
    return levels[level:upper()] or 2
end

function Logger:Log(level, service, message, ...)
    local currentLevelNum = self:GetLogLevelNumber(self.LogLevel)
    local messageLevelNum = self:GetLogLevelNumber(level)
    
    if messageLevelNum < currentLevelNum then
        return
    end
    
    -- Format message dengan variadic arguments
    local formattedMessage = tostring(message)
    if ... then
        local args = {...}
        for i, arg in ipairs(args) do
            if type(arg) == "table" then
                formattedMessage = formattedMessage .. " " .. self:TableToString(arg)
            else
                formattedMessage = formattedMessage .. " " .. tostring(arg)
            end
        end
    end
    
    local timestamp = os.date("%H:%M:%S")
    local logEntry = {
        Timestamp = timestamp,
        Level = level:upper(),
        Service = service,
        Message = formattedMessage,
        Color = self.Colors[level:upper()] or self.Colors.INFO
    }
    
    -- Add to history
    table.insert(self.LogHistory, logEntry)
    if #self.LogHistory > self.MaxHistory then
        table.remove(self.LogHistory, 1)
    end
    
    -- Console output
    if self.OutputConsole then
        local consoleMessage = string.format("[%s] [%s] [%s] %s",
            timestamp, level:upper(), service, formattedMessage)
        print(consoleMessage)
    end
    
    -- UI output
    if self.OutputUI and self.ScrollingFrame then
        self:AddLogToUI(logEntry)
    end
    
    return logEntry
end

function Logger:AddLogToUI(logEntry)
    local logFrame = Instance.new("Frame")
    logFrame.Name = "LogEntry"
    logFrame.Size = UDim2.new(1, 0, 0, 20)
    logFrame.BackgroundTransparency = 1
    logFrame.Parent = self.ScrollingFrame
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "Time"
    timeLabel.Size = UDim2.new(0, 50, 1, 0)
    timeLabel.Position = UDim2.new(0, 0, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = logEntry.Timestamp
    timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextSize = 11
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = logFrame
    
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "Level"
    levelLabel.Size = UDim2.new(0, 45, 1, 0)
    levelLabel.Position = UDim2.new(0, 55, 0, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "[" .. logEntry.Level .. "]"
    levelLabel.TextColor3 = logEntry.Color
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.TextSize = 11
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    levelLabel.Parent = logFrame
    
    local serviceLabel = Instance.new("TextLabel")
    serviceLabel.Name = "Service"
    serviceLabel.Size = UDim2.new(0, 70, 1, 0)
    serviceLabel.Position = UDim2.new(0, 105, 0, 0)
    serviceLabel.BackgroundTransparency = 1
    serviceLabel.Text = "[" .. logEntry.Service .. "]"
    serviceLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    serviceLabel.Font = Enum.Font.Gotham
    serviceLabel.TextSize = 11
    serviceLabel.TextXAlignment = Enum.TextXAlignment.Left
    serviceLabel.Parent = logFrame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -180, 1, 0)
    messageLabel.Position = UDim2.new(0, 180, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = logEntry.Message
    messageLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 11
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextTruncate = Enum.TextTruncate.AtEnd
    messageLabel.Parent = logFrame
    
    -- Auto-scroll to bottom
    self.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
    self.ScrollingFrame.CanvasPosition = Vector2.new(0, self.ScrollingFrame.CanvasSize.Y.Offset)
end

function Logger:TableToString(tbl, indent)
    indent = indent or 0
    local str = ""
    local spaces = string.rep(" ", indent)
    
    str = str .. "{\n"
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            str = str .. spaces .. "  " .. tostring(k) .. " = " .. self:TableToString(v, indent + 2) .. ",\n"
        else
            str = str .. spaces .. "  " .. tostring(k) .. " = " .. tostring(v) .. ",\n"
        end
    end
    str = str .. spaces .. "}"
    
    return str
end

function Logger:Debug(service, message, ...)
    return self:Log("DEBUG", service, message, ...)
end

function Logger:Info(service, message, ...)
    return self:Log("INFO", service, message, ...)
end

function Logger:Warn(service, message, ...)
    return self:Log("WARN", service, message, ...)
end

function Logger:Error(service, message, ...)
    return self:Log("ERROR", service, message, ...)
end

function Logger:Success(service, message, ...)
    return self:Log("SUCCESS", service, message, ...)
end

function Logger:GetHistory()
    return self.LogHistory
end

function Logger:ClearHistory()
    self.LogHistory = {}
    
    -- Clear UI
    if self.ScrollingFrame then
        for _, child in ipairs(self.ScrollingFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
    
    self:Info(self.ServiceName, "Log history cleared")
end

function Logger:ToggleUI(visible)
    if self.LogContainer then
        self.LogContainer.Visible = visible
        self.OutputUI = visible
        self:Info(self.ServiceName, "Logger UI " .. (visible and "enabled" or "disabled"))
    end
end

function Logger:ExportLogs(format)
    format = format or "TEXT"
    
    if format:upper() == "TEXT" then
        local exportText = "=== PIWHUB LOG EXPORT ===\n"
        exportText = exportText .. "Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
        exportText = exportText .. "Total Logs: " .. #self.LogHistory .. "\n\n"
        
        for _, log in ipairs(self.LogHistory) do
            exportText = exportText .. string.format("[%s] [%s] [%s] %s\n",
                log.Timestamp, log.Level, log.Service, log.Message)
        end
        
        return exportText
    end
    
    return nil
end

return Logger
