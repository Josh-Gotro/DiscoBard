local _, ns = ...

local CombatLog = ns.CombatLog

local watchedEvents = {
    "COMBAT_LOG_EVENT_UNFILTERED",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "ENCOUNTER_START",
    "ENCOUNTER_END",
}

local _ = watchedEvents

local function IsAugmentationPlayer()
    if select(2, UnitClass("player")) ~= "EVOKER" then
        return false
    end

    local activeSpec = GetSpecialization and GetSpecialization() or nil
    if not activeSpec then
        return false
    end

    return GetSpecializationInfo(activeSpec) == ns.Constants.SpecIDs.AUGMENTATION
end

local function PrintDebug(message)
    if ns.Config:Get("debug") then
        print(ns.Constants.ADDON_PREFIX, message)
    end
end

local function OnSegmentFinished(segment)
    if not segment then
        return
    end

    PrintDebug(string.format("Segment finished: #%d (%.1fs)", segment.id, segment.duration or 0))

    if ns.Config:Get("autoShow") then
        ns.UI:Show()
    end

    ns.UI:SetSegment(segment)
end

function CombatLog:Initialize()
    if self.frame then
        return
    end

    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", function(_, event, ...)
        self:HandleEvent(event, ...)
    end)
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("ENCOUNTER_START")
    frame:RegisterEvent("ENCOUNTER_END")
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    self.frame = frame
end

function CombatLog.HandleEvent(_, event, ...)
    return
end
