local _, ns = ...

local State = ns.State

local fakeUnits = {
    {
        unitId = "player",
        name = "You",
        classToken = "PRIEST",
        role = "HEALER",
        connected = true,
        dead = false,
        ghost = false,
        inRange = true,
        isTarget = true,
        hasAggro = false,
        healthCurrent = 910000,
        healthMax = 1000000,
        healthPct = 91,
        dispellableDebuffs = {
            {
                spellID = 25771,
                icon = "Interface\\Icons\\Spell_Holy_RemoveCurse",
                name = "Dispellable",
                count = 0,
            },
        },
        trackedDebuffs = {
            { spellID = 6788, icon = "Interface\\Icons\\Spell_Holy_AshesToAshes", name = "Tracked Debuff", count = 0 },
        },
        defensiveBuffs = {
            {
                spellID = 33206,
                icon = "Interface\\Icons\\Spell_Holy_PainSupression",
                name = "Pain Suppression",
                count = 0,
            },
        },
        readyState = "ready",
    },
    {
        unitId = "party1",
        name = "Tank",
        classToken = "WARRIOR",
        role = "TANK",
        connected = true,
        dead = false,
        ghost = false,
        inRange = true,
        isTarget = false,
        hasAggro = true,
        healthCurrent = 540000,
        healthMax = 1000000,
        healthPct = 54,
        dispellableDebuffs = {},
        trackedDebuffs = {},
        defensiveBuffs = {
            { spellID = 871, icon = "Interface\\Icons\\Ability_Warrior_ShieldWall", name = "Shield Wall", count = 0 },
        },
        readyState = "waiting",
    },
    {
        unitId = "party2",
        name = "DPS One",
        classToken = "MAGE",
        role = "DAMAGER",
        connected = true,
        dead = false,
        ghost = false,
        inRange = false,
        isTarget = false,
        hasAggro = false,
        healthCurrent = 1000000,
        healthMax = 1000000,
        healthPct = 100,
        dispellableDebuffs = {},
        trackedDebuffs = {
            {
                spellID = 41425,
                icon = "Interface\\Icons\\Spell_Frost_FrostShock",
                name = "Hypothermia",
                count = 0,
            },
        },
        defensiveBuffs = {
            { spellID = 45438, icon = "Interface\\Icons\\Spell_Frost_Frost", name = "Ice Block", count = 0 },
        },
        readyState = "notready",
    },
    {
        unitId = "party3",
        name = "DPS Two",
        classToken = "HUNTER",
        role = "DAMAGER",
        connected = true,
        dead = true,
        ghost = false,
        inRange = true,
        isTarget = false,
        hasAggro = false,
        healthCurrent = 0,
        healthMax = 1000000,
        healthPct = 0,
        dispellableDebuffs = {},
        trackedDebuffs = {},
        defensiveBuffs = {},
        readyState = nil,
    },
    {
        unitId = "party4",
        name = "Offline",
        classToken = "EVOKER",
        role = "DAMAGER",
        connected = false,
        dead = false,
        ghost = false,
        inRange = false,
        isTarget = false,
        hasAggro = false,
        healthCurrent = 0,
        healthMax = 1000000,
        healthPct = 0,
        dispellableDebuffs = {},
        trackedDebuffs = {},
        defensiveBuffs = {},
        readyState = nil,
    },
}

local function GetRangeState(unit)
    if unit == "player" then
        return true
    end

    if UnitInRange then
        local inRange = UnitInRange(unit)
        if inRange ~= nil then
            return inRange
        end
    end

    return true
end

local function ToSafeNumber(value, fallback)
    local numericValue = tonumber(value)

    if numericValue == nil then
        return fallback or 0
    end

    return numericValue
end

local function BuildUnitState(unit)
    local connected = UnitIsConnected(unit)
    local dead = UnitIsDead(unit)
    local ghost = UnitIsGhost(unit)
    local healthCurrent = UnitHealth(unit)
    local healthMax = ToSafeNumber(UnitHealthMax(unit), 0)
    local healthPct = nil
    local threatStatus = ToSafeNumber(UnitThreatSituation(unit), 0)

    local auraState = ns.Auras:Collect(unit)

    return {
        unitId = unit,
        name = GetUnitName(unit, true) or UNKNOWN,
        classToken = select(2, UnitClass(unit)) or "PRIEST",
        role = UnitGroupRolesAssigned(unit) or "NONE",
        connected = connected,
        dead = dead,
        ghost = ghost,
        inRange = GetRangeState(unit),
        isTarget = UnitIsUnit(unit, "target"),
        hasAggro = threatStatus >= 2,
        healthCurrent = healthCurrent,
        healthMax = healthMax,
        healthPct = healthPct,
        dispellableDebuffs = auraState.dispellableDebuffs,
        trackedDebuffs = auraState.trackedDebuffs,
        defensiveBuffs = auraState.defensiveBuffs,
        readyState = GetReadyCheckStatus and GetReadyCheckStatus(unit) or nil,
    }
end

function State.GetDisplayUnits()
    if ns.Config:Get("testMode") then
        return fakeUnits
    end

    if IsInRaid() then
        return {}
    end

    local units = {}

    for _, unit in ipairs(ns.UnitOrder) do
        if unit == "player" or UnitExists(unit) then
            units[#units + 1] = BuildUnitState(unit)
        end
    end

    return units
end
