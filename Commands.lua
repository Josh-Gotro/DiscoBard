local _, ns = ...

local Commands = ns.Commands

local function Print(message)
    print(ns.Constants.ADDON_PREFIX, message)
end

local function PrintHelp()
    Print("Commands: ping, status")
end

function Commands.Initialize()
    SLASH_DISCOBARD1 = "/dbard"
    SLASH_DISCOBARD2 = "/disco"
    SlashCmdList.DISCOBARD = function(message)
        local trimmed = strtrim(message or "")
        local command = string.lower((trimmed:match("^(%S+)") or "ping"))

        if command == "ping" then
            Print("Loaded.")
            return
        end

        if command == "status" then
            local active = ns.Segments:GetActive()
            if active then
                Print("Tracking active segment #" .. active.id)
            else
                Print("No active segment.")
            end
            return
        end

        PrintHelp()
    end
end
