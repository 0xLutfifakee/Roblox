--[[
    Scanner.lua - Modul pencarian objek fishing otomatis
    BLATANT detection system untuk Roblox Fishing
]]--

local Scanner = {
    ServiceName = "Scanner",
    Version = "1.2.0",
    IsScanning = false,
    LastScanResults = {},
    ScanInterval = 0.5
}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

function Scanner:Initialize()
    self.Player = Players.LocalPlayer
    self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
    self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart")
    
    self.Logger = require(game:GetService("ReplicatedStorage"):WaitForChild("PiwHub"):WaitForChild("Debug"):WaitForChild("Logger"))
    self.Logger:Info(self.ServiceName, "Scanner initialized")
end

function Scanner:StartScan(scanParams)
    if self.IsScanning then
        self:StopScan()
    end
    
    self.IsScanning = true
    self.Logger:Info(self.ServiceName, "Starting scan with params:", scanParams)
    
    local scanConnection
    scanConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not self.IsScanning then
            scanConnection:Disconnect()
            return
        end
        
        self:PerformScan(scanParams)
    end)
    
    self.CurrentConnection = scanConnection
    return scanConnection
end

function Scanner:PerformScan(params)
    local results = {}
    local maxDistance = params.MaxDistance or 100
    local scanTypes = params.ScanTypes or {"All"}
    
    -- Scan untuk fishing poles
    if table.find(scanTypes, "FishingPole") or table.find(scanTypes, "All") then
        for _, tool in ipairs(Workspace:GetDescendants()) do
            if tool:IsA("Tool") and tool.Name:lower():find("fishing") then
                local distance = (tool.Handle.Position - self.HumanoidRootPart.Position).Magnitude
                if distance <= maxDistance then
                    table.insert(results, {
                        Object = tool,
                        Type = "FishingPole",
                        Distance = distance,
                        Position = tool.Handle.Position
                    })
                end
            end
        end
    end
    
    -- Scan untuk fishing spots (water parts)
    if table.find(scanTypes, "FishingSpot") or table.find(scanTypes, "All") then
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("Part") and part.Name:lower():find("water") then
                local distance = (part.Position - self.HumanoidRootPart.Position).Magnitude
                if distance <= maxDistance then
                    table.insert(results, {
                        Object = part,
                        Type = "FishingSpot",
                        Distance = distance,
                        Position = part.Position,
                        Size = part.Size
                    })
                end
            end
        end
    end
    
    -- Scan untuk fish NPCs
    if table.find(scanTypes, "Fish") or table.find(scanTypes, "All") then
        for _, model in ipairs(Workspace:GetChildren()) do
            if model:IsA("Model") and model.Name:lower():find("fish") then
                local primaryPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
                if primaryPart then
                    local distance = (primaryPart.Position - self.HumanoidRootPart.Position).Magnitude
                    if distance <= maxDistance then
                        table.insert(results, {
                            Object = model,
                            Type = "Fish",
                            Distance = distance,
                            Position = primaryPart.Position,
                            ModelName = model.Name
                        })
                    end
                end
            end
        end
    end
    
    self.LastScanResults = results
    return results
end

function Scanner:StopScan()
    self.IsScanning = false
    if self.CurrentConnection then
        self.CurrentConnection:Disconnect()
        self.CurrentConnection = nil
    end
    self.Logger:Info(self.ServiceName, "Scan stopped")
end

function Scanner:GetBestTarget(targetType)
    local bestTarget = nil
    local shortestDistance = math.huge
    
    for _, result in ipairs(self.LastScanResults) do
        if result.Type == targetType and result.Distance < shortestDistance then
            shortestDistance = result.Distance
            bestTarget = result
        end
    end
    
    return bestTarget
end

function Scanner:GetScanSummary()
    local summary = {
        TotalObjects = #self.LastScanResults,
        ByType = {}
    }
    
    for _, result in ipairs(self.LastScanResults) do
        summary.ByType[result.Type] = (summary.ByType[result.Type] or 0) + 1
    end
    
    return summary
end

return Scanner
