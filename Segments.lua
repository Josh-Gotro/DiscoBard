local _, ns = ...

local Segments = ns.Segments

local function GetGroupSnapshot()
    local members = {}
    local units = {}

    if IsInRaid() then
        for index = 1, GetNumGroupMembers() do
            units[#units + 1] = "raid" .. index
        end
    else
        units[#units + 1] = "player"
        for index = 1, GetNumSubgroupMembers() do
            units[#units + 1] = "party" .. index
        end
    end

    for _, unit in ipairs(units) do
        if UnitExists(unit) then
            members[#members + 1] = {
                guid = UnitGUID(unit),
                name = GetUnitName(unit, true),
                classToken = select(2, UnitClass(unit)),
                role = UnitGroupRolesAssigned(unit),
            }
        end
    end

    return members
end

local function FinalizeActiveAuras(segment, endTime)
    for spellID, auraByTarget in pairs(segment.activeAuras) do
        for destGUID, active in pairs(auraByTarget) do
            local duration = math.max(0, endTime - active.startTime)
            local spellData = segment.spellBreakdown[spellID]
            local targetData = spellData and spellData.targets[destGUID]

            if targetData then
                targetData.totalUptime = targetData.totalUptime + duration
                targetData.lastApply = nil
            end

            auraByTarget[destGUID] = nil
        end
    end
end

function Segments:Initialize()
    self.history = self.history or {}
    self.active = nil
    self.nextId = self.nextId or 1
end

function Segments:Start(kind, timestamp, encounterName)
    if self.active then
        return self.active
    end

    local activeSpec = GetSpecialization and GetSpecialization() or nil
    local segment = {
        id = self.nextId,
        kind = kind,
        encounterName = encounterName,
        startTime = timestamp or GetTime(),
        endTime = nil,
        duration = nil,
        specID = activeSpec and GetSpecializationInfo(activeSpec) or nil,
        playerGUID = UnitGUID("player"),
        playerName = GetUnitName("player", true),
        groupMembers = GetGroupSnapshot(),
        spells = {},
        spellBreakdown = {},
        activeAuras = {},
        timeline = {},
    }

    self.nextId = self.nextId + 1
    self.active = segment
    return segment
end

function Segments:GetActive()
    return self.active
end

function Segments:RecordTimeline(entry)
    local segment = self.active
    if not segment then
        return
    end

    segment.timeline[#segment.timeline + 1] = entry
end

function Segments:Finish(timestamp, reason)
    local segment = self.active
    if not segment then
        return nil
    end

    segment.endTime = timestamp or GetTime()
    segment.duration = math.max(0, segment.endTime - segment.startTime)
    segment.finishReason = reason
    FinalizeActiveAuras(segment, segment.endTime)

    self.history[#self.history + 1] = segment
    self.active = nil

    local historyLimit = ns.Config:Get("historyLimit") or 20
    while #self.history > historyLimit do
        table.remove(self.history, 1)
    end

    return segment
end

function Segments:GetHistory()
    return self.history
end

function Segments:GetLatest()
    return self.history[#self.history]
end

function Segments:ClearHistory()
    self.history = {}
    self.active = nil
end
