local _, ns = ...

local Config = ns.Config
local defaults = ns.Constants.Defaults

local function CopyTable(source)
    local result = {}

    for key, value in pairs(source) do
        if type(value) == "table" then
            result[key] = CopyTable(value)
        else
            result[key] = value
        end
    end

    return result
end

function Config:Initialize()
    if type(DiscoBardDB) ~= "table" then
        DiscoBardDB = CopyTable(defaults)
    end

    self.db = DiscoBardDB

    for key, value in pairs(defaults) do
        if self.db[key] == nil then
            if type(value) == "table" then
                self.db[key] = CopyTable(value)
            else
                self.db[key] = value
            end
        end
    end
end

function Config:Get(key)
    return self.db[key]
end

function Config:Set(key, value)
    self.db[key] = value
end

function Config:Toggle(key)
    self.db[key] = not self.db[key]
    return self.db[key]
end

function Config:GetAnchor()
    return self.db.point, self.db.relativePoint, self.db.x, self.db.y
end

function Config:SetAnchor(point, relativePoint, x, y)
    self.db.point = point
    self.db.relativePoint = relativePoint
    self.db.x = x
    self.db.y = y
end

function Config:Reset()
    DiscoBardDB = CopyTable(defaults)
    self.db = DiscoBardDB
end
