--[[
    AutoFish.lua - Sistem BLATANT Auto Fishing untuk PiwHub
    REAL STRUCTURE dengan AutoFinder integration
]]--

local AutoFish = {
    ServiceName = "AutoFish",
    Version = "3.0.0",
    IsRunning = false,
    Settings = {
        AutoCast = true,
        AutoReel = true,
        AutoCollect = true,
        MaxDistance = 100,
        DetectionInterval = 0.3,
        ReelDelay = 0.5,
        UseAutoFinder = true,
        RequireConfirmation = false
    },
    Stats = {
        FishCaught = 0,
        TotalAttempts = 0,
        StartTime = 0,
        LastCatchTime = 0
    }
}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

function AutoFish:Initialize()
    self.Player = Players.LocalPlayer
    self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
    self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart")
    
    -- Initialize modules
    self.Logger = require(ReplicatedStorage:WaitForChild("PiwHub"):WaitForChild("Debug"):WaitForChild("Logger"))
    self.Logger:Initialize()
    
    -- Initialize AutoFinder jika dienable
    if self.Settings.UseAutoFinder then
        self.AutoFinder = require(ReplicatedStorage:WaitForChild("PiwHub"):WaitForChild("AutoFinder"):WaitForChild("Result"))
        self.AutoFinder:Initialize()
        
        -- Setup confirmation callback
        self.AutoFinder.UIConfirm:SetConfirmCallback(function(target)
            self:OnTargetConfirmed(target)
        end)
    end
    
    self.Logger:Info(self.ServiceName, string.format(
        "AutoFish v%s initialized (AutoFinder: %s)",
        self.Version,
        self.Settings.UseAutoFinder and "ENABLED" : "DISABLED"
    ))
end

function AutoFish:Start()
    if self.IsRunning then
        self.Logger:Warn(self.ServiceName, "AutoFish is already running")
        return false
    end
    
    self.IsRunning = true
    self.Stats.StartTime = os.time()
    self.Logger:Success(self.ServiceName, "AutoFish started!")
    
    -- Start main loop
    self.MainConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not self.IsRunning then return end
        
        self:MainLoop(deltaTime)
    end)
    
    -- Start AutoFinder scanning jika dienable
    if self.Settings.UseAutoFinder then
        self:StartAutoFinderScan()
    end
    
    return true
end

function AutoFish:Stop()
    if not self.IsRunning then
        self.Logger:Warn(self.ServiceName, "AutoFish is not running")
        return false
    end
    
    self.IsRunning = false
    
    if self.MainConnection then
        self.MainConnection:Disconnect()
        self.MainConnection = nil
    end
    
    -- Stop AutoFinder scanning
    if self.AutoFinder then
        self.AutoFinder.Scanner:StopScan()
    end
    
    self.Logger:Info(self.ServiceName, "AutoFish stopped")
    
    -- Print statistics
    self:PrintStats()
    
    return true
end

function AutoFish:MainLoop(deltaTime)
    -- Cek jika karakter masih ada
    if not self.Character or not self.Character.Parent then
        self.Character = self.Player.Character
        if self.Character then
            self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart")
        end
        return
    end
    
    -- AutoFinder-based fishing
    if self.Settings.UseAutoFinder and self.AutoFinder then
        self:AutoFinderFishing()
    else
        -- Legacy fishing system
        self:LegacyFishing()
    end
end

function AutoFish:StartAutoFinderScan()
    if not self.AutoFinder then return end
    
    -- Setup scan settings
    local scanSettings = {
        MaxDistance = self.Settings.MaxDistance,
        ScanTypes = {"FishingPole", "FishingSpot", "Fish"}
    }
    
    -- Setup filter settings
    local filterSettings = self.AutoFinder.Filter:GetDefaultFishingPreset()
    filterSettings.MaxDistance = self.Settings.MaxDistance
    
    -- Perform initial scan
    local results = self.AutoFinder:PerformFullScan(scanSettings, filterSettings)
    
    if #results > 0 then
        self.Logger:Info(self.ServiceName, string.format(
            "AutoFinder found %d fishing targets",
            #results
        ))
        
        -- Cari best target
        local bestTarget = self.AutoFinder:GetBestTarget("FishingPole")
        
        if bestTarget then
            if self.Settings.RequireConfirmation then
                -- Request user confirmation
                self.AutoFinder:RequestTargetConfirmation(bestTarget, function(target)
                    self.CurrentTarget = target
                    self.Logger:Success(self.ServiceName, "Target confirmed:", target.Object.Name)
                end)
            else
                -- Auto-select best target
                self.CurrentTarget = bestTarget
                self.Logger:Info(self.ServiceName, "Auto-selected target:", bestTarget.Object.Name)
            end
        end
    else
        self.Logger:Warn(self.ServiceName, "No fishing targets found by AutoFinder")
    end
end

function AutoFish:AutoFinderFishing()
    if not self.CurrentTarget then
        self.Logger:Debug(self.ServiceName, "No current target, searching...")
        self:StartAutoFinderScan()
        return
    end
    
    -- Cek jika target masih valid
    if not self.CurrentTarget.Object or not self.CurrentTarget.Object.Parent then
        self.Logger:Warn(self.ServiceName, "Current target no longer exists")
        self.CurrentTarget = nil
        return
    end
    
    -- Cek distance
    local targetPos = self.CurrentTarget.Position
    local distance = (targetPos - self.HumanoidRootPart.Position).Magnitude
    
    if distance > self.Settings.MaxDistance then
        self.Logger:Warn(self.ServiceName, "Target too far, searching new target")
        self.CurrentTarget = nil
        return
    end
    
    -- Lakukan fishing action berdasarkan tipe target
    if self.CurrentTarget.Type == "FishingPole" then
        self:HandleFishingPole(self.CurrentTarget.Object)
    elseif self.CurrentTarget.Type == "FishingSpot" then
        self:HandleFishingSpot(self.CurrentTarget.Object)
    elseif self.CurrentTarget.Type == "Fish" then
        self:HandleFish(self.CurrentTarget.Object)
    end
end

function AutoFish:HandleFishingPole(fishingPole)
    -- Equip fishing pole
    if not self:HasToolEquipped(fishingPole.Name) then
        self:EquipTool(fishingPole)
    end
    
    -- Auto cast
    if self.Settings.AutoCast then
        self:AutoCast()
    end
    
    -- Auto reel
    if self.Settings.AutoReel then
        self:AutoReel()
    end
end

function AutoFish:HandleFishingSpot(waterPart)
    -- Navigate to fishing spot
    self:NavigateTo(waterPart.Position)
    
    -- Cari fishing pole terdekat
    local nearestPole = self:FindNearestFishingPole()
    if nearestPole then
        self:HandleFishingPole(nearestPole)
    end
end

function AutoFish:HandleFish(fishModel)
    -- Auto collect fish
    if self.Settings.AutoCollect then
        self:CollectFish(fishModel)
    end
end

function AutoFish:LegacyFishing()
    -- Legacy system untuk kompatibilitas
    local fishingPole = self:FindNearestFishingPole()
    if fishingPole then
        self:HandleFishingPole(fishingPole)
    end
end

function AutoFish:FindNearestFishingPole()
    for _, tool in ipairs(Workspace:GetDescendants()) do
        if tool:IsA("Tool") and tool.Name:lower():find("fishing") then
            local distance = (tool.Handle.Position - self.HumanoidRootPart.Position).Magnitude
            if distance <= self.Settings.MaxDistance then
                return tool
            end
        end
    end
    return nil
end

function AutoFish:HasToolEquipped(toolName)
    local character = self.Player.Character
    if not character then return false end
    
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == toolName then
            return true
        end
    end
    return false
end

function AutoFish:EquipTool(tool)
    -- Simulate tool pickup and equip
    firetouchinterest(self.HumanoidRootPart, tool.Handle, 0)
    task.wait(0.1)
    firetouchinterest(self.HumanoidRootPart, tool.Handle, 1)
    
    self.Logger:Debug(self.ServiceName, "Equipped tool:", tool.Name)
end

function AutoFish:AutoCast()
    -- Simulate casting with VirtualInput
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
    
    self.Stats.TotalAttempts = self.Stats.TotalAttempts + 1
    self.Logger:Debug(self.ServiceName, "Casting attempt #" .. self.Stats.TotalAttempts)
end

function AutoFish:AutoReel()
    -- Simulate reeling with mouse click
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
    task.wait(self.Settings.ReelDelay)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
    
    self.Logger:Debug(self.ServiceName, "Reeling action performed")
end

function AutoFish:CollectFish(fishModel)
    -- Simulate collecting fish
    firetouchinterest(self.HumanoidRootPart, fishModel.PrimaryPart, 0)
    task.wait(0.1)
    firetouchinterest(self.HumanoidRootPart, fishModel.PrimaryPart, 1)
    
    self.Stats.FishCaught = self.Stats.FishCaught + 1
    self.Stats.LastCatchTime = os.time()
    
    self.Logger:Success(self.ServiceName, string.format(
        "Fish caught! Total: %d",
        self.Stats.FishCaught
    ))
end

function AutoFish:NavigateTo(position)
    -- Simple navigation system
    local humanoid = self.Character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        humanoid:MoveTo(position)
    end
end

function AutoFish:OnTargetConfirmed(target)
    self.CurrentTarget = target
    self.Logger:Success(self.ServiceName, "Target confirmed:", target.Object.Name)
end

function AutoFish:PrintStats()
    local runtime = os.time() - self.Stats.StartTime
    local minutes = math.floor(runtime / 60)
    local seconds = runtime % 60
    
    self.Logger:Info(self.ServiceName, "=== FISHING STATISTICS ===")
    self.Logger:Info(self.ServiceName, string.format("Runtime: %d:%02d", minutes, seconds))
    self.Logger:Info(self.ServiceName, string.format("Fish Caught: %d", self.Stats.FishCaught))
    self.Logger:Info(self.ServiceName, string.format("Total Attempts: %d", self.Stats.TotalAttempts))
    
    if self.Stats.TotalAttempts > 0 then
        local successRate = (self.Stats.FishCaught / self.Stats.TotalAttempts) * 100
        self.Logger:Info(self.ServiceName, string.format("Success Rate: %.1f%%", successRate))
    end
end

function AutoFish:GetSettings()
    return self.Settings
end

function AutoFish:UpdateSettings(newSettings)
    for key, value in pairs(newSettings) do
        if self.Settings[key] ~= nil then
            self.Settings[key] = value
            self.Logger:Info(self.ServiceName, string.format(
                "Setting updated: %s = %s",
                key,
                tostring(value)
            ))
        end
    end
    return self.Settings
end

function AutoFish:GetStats()
    return self.Stats
end

function AutoFish:ResetStats()
    self.Stats = {
        FishCaught = 0,
        TotalAttempts = 0,
        StartTime = os.time(),
        LastCatchTime = 0
    }
    self.Logger:Info(self.ServiceName, "Statistics reset")
end

-- Export module
return AutoFish
