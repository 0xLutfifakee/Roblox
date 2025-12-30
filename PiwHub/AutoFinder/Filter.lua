--[[
    Filter.lua - Sistem filter untuk hasil scan
    Modular filtering system
]]--

local Filter = {
    ServiceName = "Filter",
    Version = "1.1.0",
    ActiveFilters = {}
}

function Filter:Initialize()
    self.Logger = require(game:GetService("ReplicatedStorage"):WaitForChild("PiwHub"):WaitForChild("Debug"):WaitForChild("Logger"))
    self.Logger:Info(self.ServiceName, "Filter system initialized")
end

function Filter:ApplyFilters(scanResults, filterSettings)
    if not filterSettings or not next(filterSettings) then
        return scanResults
    end
    
    local filteredResults = {}
    
    for _, result in ipairs(scanResults) do
        local passed = true
        
        -- Filter berdasarkan tipe
        if filterSettings.ExcludeTypes then
            if table.find(filterSettings.ExcludeTypes, result.Type) then
                passed = false
            end
        end
        
        -- Filter berdasarkan jarak
        if passed and filterSettings.MaxDistance then
            if result.Distance > filterSettings.MaxDistance then
                passed = false
            end
        end
        
        -- Filter berdasarkan nama (keyword)
        if passed and filterSettings.NameKeywords then
            local nameMatch = false
            local objectName = result.Object.Name:lower()
            
            for _, keyword in ipairs(filterSettings.NameKeywords) do
                if objectName:find(keyword:lower()) then
                    nameMatch = true
                    break
                end
            end
            
            if filterSettings.NameFilterMode == "Exclude" and nameMatch then
                passed = false
            elseif filterSettings.NameFilterMode == "Include" and not nameMatch then
                passed = false
            end
        end
        
        -- Filter khusus untuk fishing spots
        if passed and result.Type == "FishingSpot" then
            if filterSettings.MinWaterSize then
                local volume = result.Size.X * result.Size.Y * result.Size.Z
                if volume < filterSettings.MinWaterSize then
                    passed = false
                end
            end
        end
        
        -- Filter khusus untuk fish
        if passed and result.Type == "Fish" then
            if filterSettings.FishRarity then
                -- Implementasi filter rarity fish
                local rarity = self:GetFishRarity(result.Object)
                if not table.find(filterSettings.FishRarity, rarity) then
                    passed = false
                end
            end
        end
        
        if passed then
            table.insert(filteredResults, result)
        end
    end
    
    self.Logger:Debug(self.ServiceName, string.format(
        "Filter applied: %d/%d results passed",
        #filteredResults,
        #scanResults
    ))
    
    return filteredResults
end

function Filter:GetFishRarity(fishModel)
    -- Deteksi rarity berdasarkan nama atau attribute
    local fishName = fishModel.Name:lower()
    
    if fishName:find("legendary") or fishName:find("mythic") then
        return "Legendary"
    elseif fishName:find("epic") or fishName:find("rare") then
        return "Rare"
    elseif fishName:find("uncommon") then
        return "Uncommon"
    else
        return "Common"
    end
end

function Filter:CreatePreset(presetName, settings)
    self.ActiveFilters[presetName] = settings
    self.Logger:Info(self.ServiceName, "Filter preset created:", presetName)
    return settings
end

function Filter:GetPreset(presetName)
    return self.ActiveFilters[presetName]
end

function Filter:GetDefaultFishingPreset()
    return {
        MaxDistance = 50,
        ExcludeTypes = {},
        NameKeywords = {"fishing", "pole", "rod", "water", "fish"},
        NameFilterMode = "Include",
        MinWaterSize = 100,
        FishRarity = {"Common", "Uncommon", "Rare", "Legendary"}
    }
end

return Filter
