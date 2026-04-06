local _, ns = ...

local Commands = ns.Commands

local function Print(message)
    print(ns.Constants.ADDON_PREFIX, message)
end

local function ParseNumber(value)
    local number = tonumber(value)
    if number and number > 0 then
        return number
    end
end

local function SetSize(widthArg, heightArg)
    local width = ParseNumber(widthArg)
    local height = ParseNumber(heightArg)

    if not width then
        Print("Usage: /dbard size <width> <height>")
        return
    end

    ns.Config:Set("width", width)
    if height then
        ns.Config:Set("height", height)
    end

    ns.Frames:ApplyLayout()
    ns.Frames:Refresh()
    Print("Updated frame size.")
end

local function SetSpacing(spacingArg)
    local spacing = ParseNumber(spacingArg)

    if not spacing then
        Print("Usage: /dbard spacing <value>")
        return
    end

    ns.Config:Set("spacing", spacing)
    ns.Frames:ApplyLayout()
    ns.Frames:Refresh()
    Print("Updated spacing.")
end

local function SetFont(fontArg)
    local fontSize = ParseNumber(fontArg)

    if not fontSize then
        Print("Usage: /dbard font <size>")
        return
    end

    ns.Config:Set("fontSize", fontSize)
    ns.Frames:ApplyLayout()
    ns.Frames:Refresh()
    Print("Updated font size.")
end

local function SetOrientation(value)
    local normalized = value and string.upper(value) or nil

    if normalized ~= "VERTICAL" and normalized ~= "HORIZONTAL" then
        Print("Usage: /dbard orientation <vertical|horizontal>")
        return
    end

    ns.Config:Set("orientation", normalized)
    ns.Frames:ApplyLayout()
    ns.Frames:Refresh()
    Print("Updated orientation.")
end

local function PrintHelp()
    Print("Commands: unlock, lock, test, reset, size, spacing, font, orientation")
end

function Commands.Initialize()
    SLASH_DISCOBARD1 = "/dbard"
    SLASH_DISCOBARD2 = "/disco"
    SlashCmdList.DISCOBARD = function(message)
        local trimmed = strtrim(message or "")
        local command, firstArg, secondArg = trimmed:match("^(%S*)%s*(%S*)%s*(.-)$")
        command = string.lower(command or "")

        if command == "unlock" then
            ns.Config:Set("locked", false)
            ns.Frames:SetLocked(false)
            ns.Frames:Refresh()
            Print("Frame unlocked.")
        elseif command == "lock" then
            ns.Config:Set("locked", true)
            ns.Frames:SetLocked(true)
            ns.Frames:Refresh()
            Print("Frame locked.")
        elseif command == "test" then
            local enabled = ns.Config:Toggle("testMode")
            ns.Frames:Refresh()
            Print(enabled and "Test mode enabled." or "Test mode disabled.")
        elseif command == "reset" then
            ns.Config:Reset()
            ns.Frames:SetLocked(ns.Config:Get("locked"))
            ns.Frames:ApplyLayout()
            ns.Frames:ApplyBuiltinVisibility()
            ns.Frames:Refresh()
            Print("Settings reset.")
        elseif command == "size" then
            SetSize(firstArg, secondArg)
        elseif command == "spacing" then
            SetSpacing(firstArg)
        elseif command == "font" then
            SetFont(firstArg)
        elseif command == "orientation" then
            SetOrientation(firstArg)
        else
            PrintHelp()
        end
    end
end
