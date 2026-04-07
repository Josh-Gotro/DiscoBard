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

    self.frame = frame
end

function CombatLog.HandleEvent(_, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
        if IsAugmentationPlayer() then
            ns.Segments:Start("combat", GetTime())
        end
        return
    end

    if event == "PLAYER_REGEN_ENABLED" then
        local active = ns.Segments:GetActive()
        if active and active.kind ~= "encounter" then
            OnSegmentFinished(ns.Segments:Finish(GetTime(), "left_combat"))
        end
        return
    end

    if event == "ENCOUNTER_START" then
        local encounterID, encounterName = ...
        if not IsAugmentationPlayer() then
            return
        end

        local active = ns.Segments:GetActive()
        if active then
            active.kind = "encounter"
            active.encounterID = encounterID
            active.encounterName = encounterName
        else
            ns.Segments:Start("encounter", GetTime(), encounterName).encounterID = encounterID
        end
        return
    end

    if event == "ENCOUNTER_END" then
        local encounterID, encounterName, _, _, success = ...
        local active = ns.Segments:GetActive()
        if active then
            active.encounterID = encounterID
            active.encounterName = encounterName
            active.success = success
            OnSegmentFinished(ns.Segments:Finish(GetTime(), "encounter_end"))
        end
        return
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if not ns.Segments:GetActive() then
            return
        end

        ns.Trackers.Augmentation:HandleCombatLog(CombatLogGetCurrentEventInfo())
    end
end
