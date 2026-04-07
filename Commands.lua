local _, ns = ...

local Commands = ns.Commands

local function Print(message)
    print(ns.Constants.ADDON_PREFIX, message)
end

local function PrintHelp()
    Print("Commands: show, hide, toggle, clear, lock, unlock, reset, debug")
end

function Commands.Initialize()
    SLASH_DISCOBARD1 = "/dbard"
    SLASH_DISCOBARD2 = "/disco"
    SlashCmdList.DISCOBARD = function(message)
        local trimmed = strtrim(message or "")
        local command = string.lower((trimmed:match("^(%S+)") or "toggle"))

        if command == "show" then
            ns.UI:Show()
            return
        end

        if command == "hide" then
            ns.UI:Hide()
            return
        end

        if command == "toggle" then
            ns.UI:Toggle()
            return
        end

        if command == "clear" then
            ns.Segments:ClearHistory()
            ns.UI:Refresh()
            Print("Segment history cleared.")
            return
        end

        if command == "unlock" then
            ns.Config:Set("locked", false)
            ns.UI:SetLocked(false)
            Print("Review window unlocked.")
            return
        end

        if command == "lock" then
            ns.Config:Set("locked", true)
            ns.UI:SetLocked(true)
            Print("Review window locked.")
            return
        end

        if command == "reset" then
            ns.Config:Reset()
            ns.UI:ApplyLayout()
            ns.UI:SetLocked(ns.Config:Get("locked"))
            ns.UI:Refresh()
            Print("Settings reset.")
            return
        end

        if command == "debug" then
            local enabled = ns.Config:Toggle("debug")
            Print(enabled and "Debug enabled." or "Debug disabled.")
            return
        end

        PrintHelp()
    end
end
