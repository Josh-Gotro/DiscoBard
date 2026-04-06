local _, ns = ...

local Auras = ns.Auras
local Filters = ns.Filters

local dispelCapabilities = {
    DRUID = { Curse = true, Poison = true, Magic = true },
    EVOKER = { Poison = true, Disease = true, Curse = true, Magic = true },
    MAGE = { Curse = true },
    MONK = { Poison = true, Disease = true, Magic = true },
    PALADIN = { Poison = true, Disease = true, Magic = true },
    PRIEST = { Magic = true, Disease = true },
    SHAMAN = { Curse = true, Magic = true },
}

local function GetPlayerClass()
    return select(2, UnitClass("player")) or "PRIEST"
end

local function CopyAura(aura)
    return {
        spellID = aura.spellId,
        icon = aura.icon,
        name = aura.name,
        dispelName = aura.dispelName,
    }
end

local function CanPlayerDispel(dispelName)
    if not dispelName then
        return false
    end

    -- This is intentionally conservative and class-based for MVP.
    -- If Midnight changes dispel access or a spec-specific pack needs tighter accuracy,
    -- keep that refinement inside this helper instead of spreading it into rendering code.
    local classDispels = dispelCapabilities[GetPlayerClass()]

    if not classDispels then
        return false
    end

    return classDispels[dispelName] == true
end

local function InsertByPriority(list, aura, priority)
    list[#list + 1] = {
        priority = priority,
        aura = CopyAura(aura),
    }
end

local function SortPriorityList(list)
    table.sort(list, function(left, right)
        if left.priority == right.priority then
            return left.aura.spellID < right.aura.spellID
        end

        return left.priority > right.priority
    end)
end

local function UnwrapPriorityList(list)
    local result = {}

    for index = 1, #list do
        result[index] = list[index].aura
    end

    return result
end

local function ForEachPackedAura(unit, filter, callback)
    if AuraUtil and AuraUtil.ForEachAura then
        AuraUtil.ForEachAura(unit, filter, nil, function(aura)
            return callback(aura)
        end, true)
    end
end

function Auras.Collect(_, unit)
    local dispellableDebuffs = {}
    local trackedDebuffs = {}
    local defensiveBuffs = {}

    -- Midnight/TWW aura access should be verified against Blizzard_APIDocumentation.
    -- Keep all packed aura API assumptions localized in this file.
    ForEachPackedAura(unit, "HARMFUL", function(aura)
        if CanPlayerDispel(aura.dispelName) then
            dispellableDebuffs[#dispellableDebuffs + 1] = CopyAura(aura)
        end

        local trackedPriority = Filters:GetTrackedDebuffPriority(aura.spellId)
        if trackedPriority then
            InsertByPriority(trackedDebuffs, aura, trackedPriority)
        end
    end)

    ForEachPackedAura(unit, "HELPFUL", function(aura)
        local defensivePriority = Filters:GetDefensiveBuffPriority(aura.spellId)
        if defensivePriority then
            InsertByPriority(defensiveBuffs, aura, defensivePriority)
        end
    end)

    SortPriorityList(trackedDebuffs)
    SortPriorityList(defensiveBuffs)

    return {
        dispellableDebuffs = dispellableDebuffs,
        trackedDebuffs = UnwrapPriorityList(trackedDebuffs),
        defensiveBuffs = UnwrapPriorityList(defensiveBuffs),
    }
end
