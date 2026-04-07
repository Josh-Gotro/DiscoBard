local addonName, ns = ...

ns.addonName = addonName
ns.Constants = ns.Constants or {}
ns.Config = ns.Config or {}
ns.Segments = ns.Segments or {}
ns.CombatLog = ns.CombatLog or {}
ns.Report = ns.Report or {}
ns.UI = ns.UI or {}
ns.Commands = ns.Commands or {}
ns.Trackers = ns.Trackers or {}

local addon = CreateFrame("Frame")
ns.Addon = addon

local function OnPlayerLogin()
    ns.Config:Initialize()
    ns.Segments:Initialize()
    ns.Commands:Initialize()
end

addon:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        OnPlayerLogin(...)
    end
end)

addon:RegisterEvent("PLAYER_LOGIN")
