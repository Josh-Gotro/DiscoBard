local addonName, ns = ...

ns.addonName = addonName
ns.Constants = ns.Constants or {}
ns.Config = ns.Config or {}
ns.Filters = ns.Filters or {}
ns.Auras = ns.Auras or {}
ns.State = ns.State or {}
ns.Frames = ns.Frames or {}
ns.Events = ns.Events or {}
ns.Commands = ns.Commands or {}

ns.UnitOrder = { "player", "party1", "party2", "party3", "party4" }

local addon = CreateFrame("Frame")
ns.Addon = addon

local function OnPlayerLogin()
    ns.Config:Initialize()
    ns.Frames:Initialize()
    ns.Commands:Initialize()
    ns.Events:Initialize()
    ns.Events:FullRefresh()
end

addon:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        OnPlayerLogin(...)
    end
end)

addon:RegisterEvent("PLAYER_LOGIN")
