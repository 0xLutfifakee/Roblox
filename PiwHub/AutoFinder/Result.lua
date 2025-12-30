--[[
    Result.lua - Sistem manajemen hasil AutoFinder
    Result processing and management
]]--

local Result = {
    ServiceName = "Result",
    Version = "1.2.0",
    ResultsHistory = {},
    MaxHistorySize = 50,
    CurrentResults = {}
}

function Result:Initialize()
    self.Logger = require(game:GetService("ReplicatedStorage"):WaitForChild("PiwHub"):WaitForChild("Debug"):WaitForChild("Logger"))
    
    -- Initialize modules
    self.Scanner = require(script.Parent.Scanner)
    self.Filter = require(script.Parent.Filter)
    self.Classifier = require(script.Parent.Classifier)
    self.UIConfirm = require(script.Parent.UIConfirm)
    
    self.Scanner:Initialize()
    self.Filter:Initialize()
    self.Classifier:Initialize()
    self.UIConfirm:Initialize()
    
    self.Logger:Info(self.ServiceName, "Result system initialized with all modules")
end

function Result:PerformFullScan(scanSettings, filterSettings)
    self.Logger:Info(self.ServiceName, "Performing full scan...")
    
    -- Step 1: Scan objects
    local rawResults = self.Scanner:PerformScan(scanSettings)
    
    if #rawResults == 0 then
        self.Logger:Warn(self.ServiceName, "No objects found in scan")
        return {}
    end
    
    -- Step 2: Classify objects
    local objects = {}
    for _, result in ipairs(rawResults) do
        table.insert(objects, result.Object)
    end
    
    local classifications = self.Classifier:BulkClassify(objects)
    
    -- Step 3: Merge scan data with classifications
    local mergedResults = {}
    for i, classification in ipairs(classifications) do
        local scanData = rawResults[i]
        if scanData then
            local merged = {
                Object = classification.Object,
                Type = classification.Type,
                Confidence = classification.Confidence,
                Distance = scanData.Distance,
                Position = scanData.Position,
                Priority = classification.Priority,
                ScanData = scanData,
                Timestamp = os.time()
            }
            table.insert(mergedResults, merged)
        end
    end
    
    -- Step 4: Apply filters
    local filteredResults = self.Filter:ApplyFilters(mergedResults, filterSettings)
    
    -- Step 5: Sort by priority and distance
    table.sort(filteredResults, function(a, b)
        if a.Priority == b.Priority then
            return a.Distance < b.Distance
        end
        return a.Priority > b.Priority
    end)
    
    -- Store results
    self.CurrentResults = filteredResults
    
    -- Add to history
    table.insert(self.ResultsHistory, {
        Timestamp = os.time(),
        Results = filteredResults,
        Settings = {
            Scan = scanSettings,
            Filter = filterSettings
        }
    })
    
    -- Trim history if too large
    if #self.ResultsHistory > self.MaxHistorySize then
        table.remove(self.ResultsHistory, 1)
    end
    
    self.Logger:Info(self.ServiceName, string.format(
        "Scan complete: %d total, %d after filtering",
        #rawResults,
        #filteredResults
    ))
    
    return filteredResults
end

function Result:GetBestTarget(targetType)
    if #self.CurrentResults == 0 then
        self.Logger:Warn(self.ServiceName, "No results available")
        return nil
    end
    
    local bestTarget = nil
    
    for _, result in ipairs(self.CurrentResults) do
        if not targetType or result.Type == targetType then
            if not bestTarget then
                bestTarget = result
            else
                -- Compare by confidence and distance
                local currentScore = bestTarget.Confidence * (1 / (bestTarget.Distance + 1))
                local newScore = result.Confidence * (1 / (result.Distance + 1))
                
                if newScore > currentScore then
                    bestTarget = result
                end
            end
        end
    end
    
    if bestTarget then
        self.Logger:Info(self.ServiceName, "Best target found:", bestTarget.Object.Name)
    else
        self.Logger:Warn(self.ServiceName, "No suitable target found")
    end
    
    return bestTarget
end

function Result:RequestTargetConfirmation(target, callback)
    if not target then
        self.Logger:Error(self.ServiceName, "No target provided for confirmation")
        return false
    end
    
    self.UIConfirm:SetConfirmCallback(callback)
    self.UIConfirm:Show(target)
    
    self.Logger:Info(self.ServiceName, "Target confirmation requested:", target.Object.Name)
    return true
end

function Result:GetResultsSummary()
    local summary = {
        CurrentCount = #self.CurrentResults,
        HistoryCount = #self.ResultsHistory,
        ByType = {}
    }
    
    for _, result in ipairs(self.CurrentResults) do
        summary.ByType[result.Type] = (summary.ByType[result.Type] or 0) + 1
    end
    
    return summary
end

function Result:ExportResults(format)
    format = format or "JSON"
    
    if format:upper() == "JSON" then
        -- Simple JSON-like export
        local exportData = {
            Timestamp = os.time(),
            Results = self.CurrentResults,
            Summary = self:GetResultsSummary()
        }
        
        -- Convert to string (simplified)
        local jsonString = "{\n"
        jsonString = jsonString .. '  "timestamp": ' .. exportData.Timestamp .. ",\n"
        jsonString = jsonString .. '  "total_results": ' .. exportData.Summary.CurrentCount .. ",\n"
        jsonString = jsonString .. '  "results": [\n'
        
        for i, result in ipairs(exportData.Results) do
            jsonString = jsonString .. string.format('    {"name": "%s", "type": "%s", "distance": %.2f}',
                result.Object.Name, result.Type, result.Distance)
            
            if i < #exportData.Results then
                jsonString = jsonString .. ",\n"
            else
                jsonString = jsonString .. "\n"
            end
        end
        
        jsonString = jsonString .. "  ]\n}"
        
        self.Logger:Info(self.ServiceName, "Results exported in JSON format")
        return jsonString
    end
    
    return nil
end

function Result:ClearResults()
    self.CurrentResults = {}
    self.Logger:Info(self.ServiceName, "Results cleared")
end

function Result:GetHistory()
    return self.ResultsHistory
end

return Result
