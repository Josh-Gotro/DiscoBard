local _, ns = ...

ns.Trackers = ns.Trackers or {}
local Augmentation = {}
ns.Trackers.Augmentation = Augmentation

local trackedSpells = ns.Constants.TrackedSpells

local function EnsureSpellData(segment, spellID, spellName)
    local spellData = segment.spellBreakdown[spellID]

    if spellData then
        return spellData
    end

    spellData = {
        spellID = spellID,
        spellName = spellName or trackedSpells.casts[spellID] or trackedSpells.buffs[spellID] or ("Spell " .. spellID),
        casts = 0,
        applies = 0,
        refreshes = 0,
        removes = 0,
        targets = {},
    }

    segment.spellBreakdown[spellID] = spellData
    return spellData
end

local function EnsureTargetData(spellData, destGUID, destName)
    local targetData = spellData.targets[destGUID]

    if targetData then
        if destName then
            targetData.name = destName
        end
        return targetData
    end

    targetData = {
        guid = destGUID,
        name = destName,
        applications = 0,
        refreshes = 0,
        totalUptime = 0,
        lastApply = nil,
    }

    spellData.targets[destGUID] = targetData
    return targetData
end

local function RecordCast(segment, timestamp, spellID, spellName)
    local spellData = EnsureSpellData(segment, spellID, spellName)
    spellData.casts = spellData.casts + 1

    segment.spells[spellID] = segment.spells[spellID] or {}
    segment.spells[spellID].casts = spellData.casts

    ns.Segments:RecordTimeline({
        timestamp = timestamp,
        type = "cast",
        spellID = spellID,
        spellName = spellData.spellName,
    })
end

local function OpenAura(segment, timestamp, spellID, spellName, destGUID, destName, isRefresh)
    if not destGUID then
        return
    end

    local spellData = EnsureSpellData(segment, spellID, spellName)
    local targetData = EnsureTargetData(spellData, destGUID, destName)

    if isRefresh then
        spellData.refreshes = spellData.refreshes + 1
        targetData.refreshes = targetData.refreshes + 1
    else
        spellData.applies = spellData.applies + 1
        targetData.applications = targetData.applications + 1
    end

    segment.activeAuras[spellID] = segment.activeAuras[spellID] or {}
    local activeAura = segment.activeAuras[spellID][destGUID]

    if activeAura then
        local priorDuration = math.max(0, timestamp - activeAura.startTime)
        targetData.totalUptime = targetData.totalUptime + priorDuration
    end

    targetData.lastApply = timestamp
    segment.activeAuras[spellID][destGUID] = {
        startTime = timestamp,
    }

    ns.Segments:RecordTimeline({
        timestamp = timestamp,
        type = isRefresh and "refresh" or "apply",
        spellID = spellID,
        spellName = spellData.spellName,
        destName = destName,
    })
end

local function CloseAura(segment, timestamp, spellID, spellName, destGUID, destName)
    if not destGUID then
        return
    end

    local spellData = EnsureSpellData(segment, spellID, spellName)
    local targetData = EnsureTargetData(spellData, destGUID, destName)
    local activeSpellAuras = segment.activeAuras[spellID]
    local activeAura = activeSpellAuras and activeSpellAuras[destGUID]

    spellData.removes = spellData.removes + 1

    if activeAura then
        local duration = math.max(0, timestamp - activeAura.startTime)
        targetData.totalUptime = targetData.totalUptime + duration
        targetData.lastApply = nil
        activeSpellAuras[destGUID] = nil
    end

    ns.Segments:RecordTimeline({
        timestamp = timestamp,
        type = "remove",
        spellID = spellID,
        spellName = spellData.spellName,
        destName = destName,
    })
end

function Augmentation.HandleCombatLog(_, ...)
    local segment = ns.Segments:GetActive()
    if not segment then
        return
    end

    local timestamp, subevent, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID, spellName = ...

    if sourceGUID ~= segment.playerGUID then
        return
    end

    if trackedSpells.casts[spellID] and subevent == "SPELL_CAST_SUCCESS" then
        RecordCast(segment, timestamp, spellID, spellName)
        return
    end

    if not trackedSpells.buffs[spellID] then
        return
    end

    if subevent == "SPELL_AURA_APPLIED" then
        OpenAura(segment, timestamp, spellID, spellName, destGUID, destName, false)
    elseif subevent == "SPELL_AURA_REFRESH" then
        OpenAura(segment, timestamp, spellID, spellName, destGUID, destName, true)
    elseif subevent == "SPELL_AURA_REMOVED" then
        CloseAura(segment, timestamp, spellID, spellName, destGUID, destName)
    end
end
