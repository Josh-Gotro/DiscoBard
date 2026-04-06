local _, ns = ...

local Filters = ns.Filters

local trackedDebuffs = {
    [6788] = 100,   -- Weakened Soul
    [25771] = 90,   -- Forbearance
    [41425] = 80,   -- Hypothermia
    [57723] = 70,   -- Exhaustion
    [57724] = 70,   -- Sated
    [80354] = 70,   -- Temporal Displacement
}

local defensiveBuffs = {
    [642] = 100,    -- Divine Shield
    [45438] = 100,  -- Ice Block
    [48707] = 95,   -- Anti-Magic Shell
    [48792] = 95,   -- Icebound Fortitude
    [1022] = 95,    -- Blessing of Protection
    [33206] = 90,   -- Pain Suppression
    [6940] = 88,    -- Blessing of Sacrifice
    [22812] = 85,   -- Barkskin
    [61336] = 85,   -- Survival Instincts
    [871] = 85,     -- Shield Wall
    [118038] = 85,  -- Die by the Sword
    [108271] = 85,  -- Astral Shift
    [104773] = 85,  -- Unending Resolve
    [186265] = 85,  -- Aspect of the Turtle
    [196555] = 85,  -- Netherwalk
}

Filters.activePack = {
    trackedDebuffs = trackedDebuffs,
    defensiveBuffs = defensiveBuffs,
}

function Filters:GetTrackedDebuffPriority(spellID)
    return self.activePack.trackedDebuffs[spellID]
end

function Filters:GetDefensiveBuffPriority(spellID)
    return self.activePack.defensiveBuffs[spellID]
end

function Filters:SetPack(pack)
    if type(pack) ~= "table" then
        return
    end

    self.activePack = {
        trackedDebuffs = pack.trackedDebuffs or trackedDebuffs,
        defensiveBuffs = pack.defensiveBuffs or defensiveBuffs,
    }
end

function Filters:ResetPack()
    self.activePack = {
        trackedDebuffs = trackedDebuffs,
        defensiveBuffs = defensiveBuffs,
    }
end
