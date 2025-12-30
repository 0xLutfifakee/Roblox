-- Advanced Logger System
local Logger = {}

-- Log levels
Logger.Levels = {
    DEBUG = 0,
    INFO = 1,
    WARN = 2,
    ERROR = 3,
    FATAL = 4
}

-- Colors for each level
Logger.Colors = {
    [0] = Color3.fromRGB(100, 150, 255),   -- DEBUG
    [1] = Color3.fromRGB(100, 255, 100),   -- INFO
    [2] = Color3.fromRGB(255, 215, 0),     -- WARN
    [3] = Color3.fromRGB(255, 100, 100),   -- ERROR
    [4] = Color3.fromRGB(255, 50, 50)      -- FATAL
}

Logger.CurrentLevel = Logger.Levels.INFO
Logger.LogHistory = {}
Logger.MaxHistory = 1000

function Logger:SetLevel(level)
    if type(level) == "string" then
        self.CurrentLevel = self.Levels[level:upper()] or self.Levels.INFO
    else
        self.CurrentLevel = level
    end
end

function Logger:Log(level, message, tag)
    if level < self.CurrentLevel then return end
    
    local timestamp = os.date("%H:%M:%S")
    local levelName = ""
    for name, lvl in pairs(self.Levels) do
        if lvl == level then
            levelName = name
            break
        end
    end
    
    local logEntry = {
        Timestamp = timestamp,
        Level = levelName,
        Message = message,
        Tag = tag or "System",
        Color = self.Colors[level]
    }
    
    table.insert(self.LogHistory, logEntry)
    
    if #self.LogHistory > self.MaxHistory then
        table.remove(self.LogHistory, 1)
    end
    
    -- Print to console
    local output = string.format("[%s] [%s] [%s] %s", 
        timestamp, levelName, tag or "System", message)
    print(output)
    
    return logEntry
end

function Logger:Debug(message, tag)
    return self:Log(self.Levels.DEBUG, message, tag)
end

function Logger:Info(message, tag)
    return self:Log(self.Levels.INFO, message, tag)
end

function Logger:Warn(message, tag)
    return self:Log(self.Levels.WARN, message, tag)
end

function Logger:Error(message, tag)
    return self:Log(self.Levels.ERROR, message, tag)
end

function Logger:Fatal(message, tag)
    return self:Log(self.Levels.FATAL, message, tag)
end

function Logger:GetHistory(count)
    count = count or 50
    local start = math.max(1, #self.LogHistory - count + 1)
    local result = {}
    
    for i = start, #self.LogHistory do
        table.insert(result, self.LogHistory[i])
    end
    
    return result
end

function Logger:ClearHistory()
    self.LogHistory = {}
end

function Logger:ExportToFile(filename)
    filename = filename or "PiwHub_Logs.txt"
    local content = "PiwHub AutoFish Logs\n"
    content = content .. "Generated: " .. os.date() .. "\n"
    content = content .. "=" .. string.rep("=", 50) .. "\n\n"
    
    for _, entry in ipairs(self.LogHistory) do
        content = content .. string.format("[%s] [%s] [%s] %s\n",
            entry.Timestamp, entry.Level, entry.Tag, entry.Message)
    end
    
    if writefile then
        writefile(filename, content)
        return true
    end
    
    return false
end

-- Performance monitoring
Logger.Performance = {
    Marks = {},
    
    Mark = function(name)
        Logger.Performance.Marks[name] = tick()
        return Logger.Performance.Marks[name]
    end,
    
    Measure = function(name)
        local start = Logger.Performance.Marks[name]
        if start then
            local elapsed = tick() - start
            Logger:Debug(string.format("%s took %.3f seconds", name, elapsed), "Performance")
            return elapsed
        end
        return nil
    end,
    
    Clear = function()
        Logger.Performance.Marks = {}
    end
}

-- Network monitoring
Logger.Network = {
    Sent = 0,
    Received = 0,
    Packets = {},
    
    LogPacket = function(direction, size, remote)
        if direction == "sent" then
            Logger.Network.Sent = Logger.Network.Sent + size
        else
            Logger.Network.Received = Logger.Network.Received + size
        end
        
        table.insert(Logger.Network.Packets, {
            Time = tick(),
            Direction = direction,
            Size = size,
            Remote = remote
        })
        
        if #Logger.Network.Packets > 100 then
            table.remove(Logger.Network.Packets, 1)
        end
    },
    
    GetStats = function()
        return {
            Sent = Logger.Network.Sent,
            Received = Logger.Network.Received,
            Total = Logger.Network.Sent + Logger.Network.Received,
            PacketCount = #Logger.Network.Packets
        }
    end
}

return Logger
