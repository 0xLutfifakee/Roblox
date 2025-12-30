--[[
    Classifier.lua - Sistem klasifikasi objek fishing
    AI-based classification system
]]--

local Classifier = {
    ServiceName = "Classifier",
    Version = "1.3.0",
    ClassificationRules = {}
}

function Classifier:Initialize()
    self.Logger = require(game:GetService("ReplicatedStorage"):WaitForChild("PiwHub"):WaitForChild("Debug"):WaitForChild("Logger"))
    
    -- Inisialisasi rules klasifikasi
    self:InitializeRules()
    
    self.Logger:Info(self.ServiceName, "Classifier initialized with " .. #self.ClassificationRules .. " rules")
end

function Classifier:InitializeRules()
    -- Rules untuk Fishing Poles
    table.insert(self.ClassificationRules, {
        Type = "FishingPole",
        CheckFunction = function(obj)
            if not obj:IsA("Tool") then return false end
            
            local nameLower = obj.Name:lower()
            local hasFishingInName = nameLower:find("fishing") or nameLower:find("rod") or nameLower:find("pole")
            local hasHandle = obj:FindFirstChild("Handle")
            local hasFishingScript = obj:FindFirstChildWhichIsA("Script") and 
                                     obj:FindFirstChildWhichIsA("Script").Name:find("Fishing")
            
            return hasFishingInName and hasHandle and hasFishingScript
        end,
        ConfidenceScore = 0.95,
        Priority = 1
    })
    
    -- Rules untuk Fishing Spots (Water)
    table.insert(self.ClassificationRules, {
        Type = "FishingSpot",
        CheckFunction = function(obj)
            if not obj:IsA("Part") then return false end
            
            local nameLower = obj.Name:lower()
            local isWater = nameLower:find("water") or 
                           nameLower:find("ocean") or 
                           nameLower:find("sea") or 
                           nameLower:find("lake") or 
                           nameLower:find("river")
            
            local hasWaterAppearance = obj.Transparency > 0.5 or 
                                      obj.Material == Enum.Material.Water or
                                      obj.BrickColor == BrickColor.new("Bright blue")
            
            local size = obj.Size
            local isLargeEnough = size.X * size.Y * size.Z > 50
            
            return (isWater or hasWaterAppearance) and isLargeEnough
        end,
        ConfidenceScore = 0.85,
        Priority = 2
    })
    
    -- Rules untuk Fish NPCs
    table.insert(self.ClassificationRules, {
        Type = "Fish",
        CheckFunction = function(obj)
            if not obj:IsA("Model") then return false end
            
            local nameLower = obj.Name:lower()
            local isFish = nameLower:find("fish") or 
                          nameLower:find("shark") or 
                          nameLower:find("whale") or
                          nameLower:find("salmon") or
                          nameLower:find("trout")
            
            local hasHumanoid = obj:FindFirstChildWhichIsA("Humanoid")
            local hasFishMesh = false
            
            -- Cek mesh untuk bentuk ikan
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("MeshPart") or child:IsA("SpecialMesh") then
                    local meshName = child.MeshId or child.Name or ""
                    if tostring(meshName):lower():find("fish") then
                        hasFishMesh = true
                        break
                    end
                end
            end
            
            return isFish and hasHumanoid and hasFishMesh
        end,
        ConfidenceScore = 0.90,
        Priority = 3
    })
    
    -- Rules untuk Fishing NPCs (Vendors)
    table.insert(self.ClassificationRules, {
        Type = "FishingNPC",
        CheckFunction = function(obj)
            if not obj:IsA("Model") then return false end
            
            local nameLower = obj.Name:lower()
            local isNPC = nameLower:find("npc") or 
                         nameLower:find("vendor") or 
                         nameLower:find("seller") or
                         nameLower:find("merchant")
            
            local hasFishingInName = nameLower:find("fishing") or 
                                    nameLower:find("bait") or 
                                    nameLower:find("rod")
            
            local hasHumanoid = obj:FindFirstChildWhichIsA("Humanoid")
            
            return isNPC and hasFishingInName and hasHumanoid
        end,
        ConfidenceScore = 0.80,
        Priority = 4
    })
end

function Classifier:ClassifyObject(obj)
    local bestClassification = nil
    local highestConfidence = 0
    local highestPriority = 0
    
    for _, rule in ipairs(self.ClassificationRules) do
        local success, result = pcall(function()
            return rule.CheckFunction(obj)
        end)
        
        if success and result then
            -- Hitung confidence score berdasarkan priority dan match quality
            local confidence = rule.ConfidenceScore
            
            -- Adjust confidence berdasarkan additional factors
            if rule.Type == "FishingPole" then
                -- Cek jika memiliki fishing events
                local hasClickDetector = obj:FindFirstChildWhichIsA("ClickDetector")
                if hasClickDetector then
                    confidence = confidence + 0.05
                end
            elseif rule.Type == "Fish" then
                -- Cek jika fish memiliki health bar atau attributes
                local hasHealth = obj:FindFirstChild("Health") or obj:FindFirstChild("MaxHealth")
                if hasHealth then
                    confidence = confidence + 0.10
                end
            end
            
            -- Pilih classification terbaik
            if confidence > highestConfidence or 
               (confidence == highestConfidence and rule.Priority > highestPriority) then
                bestClassification = {
                    Type = rule.Type,
                    Confidence = confidence,
                    Object = obj,
                    Priority = rule.Priority
                }
                highestConfidence = confidence
                highestPriority = rule.Priority
            end
        end
    end
    
    return bestClassification
end

function Classifier:BulkClassify(objects)
    local classifications = {}
    
    for _, obj in ipairs(objects) do
        local classification = self:ClassifyObject(obj)
        if classification then
            table.insert(classifications, classification)
        end
    end
    
    -- Sort by confidence and priority
    table.sort(classifications, function(a, b)
        if a.Confidence == b.Confidence then
            return a.Priority > b.Priority
        end
        return a.Confidence > b.Confidence
    end)
    
    return classifications
end

function Classifier:GetClassificationStats(classifications)
    local stats = {
        Total = #classifications,
        ByType = {},
        AverageConfidence = 0,
        HighConfidence = 0
    }
    
    local totalConfidence = 0
    
    for _, classification in ipairs(classifications) do
        -- Count by type
        stats.ByType[classification.Type] = (stats.ByType[classification.Type] or 0) + 1
        
        -- Sum confidence
        totalConfidence = totalConfidence + classification.Confidence
        
        -- Count high confidence
        if classification.Confidence >= 0.8 then
            stats.HighConfidence = stats.HighConfidence + 1
        end
    end
    
    if #classifications > 0 then
        stats.AverageConfidence = totalConfidence / #classifications
    end
    
    return stats
end

return Classifier
