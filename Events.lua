local _, ns = ...

local Events = ns.Events

local watchedEvents = {
    "GROUP_ROSTER_UPDATE",
    "PLAYER_ENTERING_WORLD",
    "PLAYER_TARGET_CHANGED",
    "PLAYER_ROLES_ASSIGNED",
    "READY_CHECK",
    "READY_CHECK_CONFIRM",
    "READY_CHECK_FINISHED",
    "UNIT_AURA",
    "UNIT_CONNECTION",
    "UNIT_FLAGS",
    "UNIT_HEALTH",
    "UNIT_MAXHEALTH",
    "UNIT_NAME_UPDATE",
    "UNIT_THREAT_SITUATION_UPDATE",
}

function Events:Initialize()
    if self.frame then
        return
    end

    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", function(_, event, ...)
        self:HandleEvent(event, ...)
    end)

    for _, eventName in ipairs(watchedEvents) do
        frame:RegisterEvent(eventName)
    end

    self.frame = frame
    self.rangeTicker = C_Timer.NewTicker(0.25, function()
        ns.Frames:Refresh()
    end)
end

function Events:HandleEvent(event, ...)
    local unit = ...

    if event:match("^UNIT_") and type(unit) == "string" then
        if unit ~= "player" and not unit:match("^party%d$") then
            return
        end
    elseif event:match("^UNIT_") then
        return
    end

    self:FullRefresh()
end

function Events.FullRefresh()
    ns.Frames:Refresh()
end
