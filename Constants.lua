local _, ns = ...

local Constants = ns.Constants

Constants.DB_KEY = "DiscoBardDB"
Constants.MAX_UNITS = 5
Constants.ADDON_PREFIX = "|cff66ccffDiscoBard:|r"

Constants.Defaults = {
    locked = true,
    testMode = false,
    hideBlizzardFrames = true,
    width = 190,
    height = 34,
    spacing = 6,
    fontSize = 11,
    orientation = "VERTICAL",
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = -120,
    rangeAlpha = 0.45,
    offlineAlpha = 0.35,
}

Constants.Colors = {
    background = { 0.08, 0.08, 0.10, 0.95 },
    health = { 0.20, 0.72, 0.32, 1.0 },
    disconnected = { 0.40, 0.40, 0.40, 1.0 },
    dead = { 0.25, 0.25, 0.25, 1.0 },
    border = { 0.16, 0.16, 0.18, 1.0 },
    aggro = { 0.85, 0.20, 0.20, 1.0 },
    target = { 0.95, 0.82, 0.18, 1.0 },
    inactive = { 0.55, 0.55, 0.60, 1.0 },
    text = { 0.95, 0.95, 0.95, 1.0 },
}

Constants.Textures = {
    statusBar = "Interface\\TargetingFrame\\UI-StatusBar",
    white = "Interface\\Buttons\\WHITE8x8",
    role = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
}

Constants.RoleCoords = {
    TANK = { 0, 19 / 64, 22 / 64, 41 / 64 },
    HEALER = { 20 / 64, 39 / 64, 1 / 64, 20 / 64 },
    DAMAGER = { 20 / 64, 39 / 64, 22 / 64, 41 / 64 },
}
