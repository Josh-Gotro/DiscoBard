local _, ns = ...

local Report = ns.Report

local function FormatDuration(seconds)
    seconds = math.max(0, seconds or 0)
    return string.format("%.1fs", seconds)
end

local function SortTargets(targets)
    table.sort(targets, function(left, right)
        if left.totalUptime == right.totalUptime then
            return (left.name or "") < (right.name or "")
        end

        return left.totalUptime > right.totalUptime
    end)
end

local function CollectSpellTargets(segment, spellID)
    local spellData = segment.spellBreakdown[spellID]
    local targets = {}

    if not spellData then
        return targets
    end

    for _, targetData in pairs(spellData.targets) do
        targets[#targets + 1] = targetData
    end

    SortTargets(targets)
    return targets
end

function Report.BuildSegmentText(_, segment)
    if not segment then
        return "No completed segments yet.\n\nEnter combat as Augmentation, then use /dbard to open the review window."
    end

    local lines = {}
    local duration = segment.duration or 0
    local ebonMight = segment.spellBreakdown[ns.Constants.Spells.EBON_MIGHT]
    local prescience = segment.spellBreakdown[ns.Constants.Spells.PRESCIENCE]
    local blisteringScales = segment.spellBreakdown[ns.Constants.Spells.BLISTERING_SCALES]
    local breathOfEons = segment.spellBreakdown[ns.Constants.Spells.BREATH_OF_EONS]

    lines[#lines + 1] = string.format("Segment #%d", segment.id)
    lines[#lines + 1] = string.format("Type: %s", segment.kind or "combat")
    if segment.encounterName then
        lines[#lines + 1] = string.format("Encounter: %s", segment.encounterName)
    end
    lines[#lines + 1] = string.format("Duration: %s", FormatDuration(duration))
    lines[#lines + 1] = string.format("Group snapshot: %d players", #segment.groupMembers)
    lines[#lines + 1] = ""

    lines[#lines + 1] = "Casts"
    lines[#lines + 1] = string.format("Ebon Might: %d", ebonMight and ebonMight.casts or 0)
    lines[#lines + 1] = string.format("Prescience: %d", prescience and prescience.casts or 0)
    lines[#lines + 1] = string.format("Blistering Scales: %d", blisteringScales and blisteringScales.casts or 0)
    lines[#lines + 1] = string.format("Breath of Eons: %d", breathOfEons and breathOfEons.casts or 0)
    lines[#lines + 1] = ""

    lines[#lines + 1] = "Ebon Might Coverage"
    local ebonTargets = CollectSpellTargets(segment, ns.Constants.Spells.EBON_MIGHT)
    if #ebonTargets == 0 then
        lines[#lines + 1] = "No tracked Ebon Might targets."
    else
        for index = 1, math.min(#ebonTargets, 8) do
            local target = ebonTargets[index]
            lines[#lines + 1] = string.format(
                "%s - uptime %s, applies %d, refreshes %d",
                target.name or "Unknown",
                FormatDuration(target.totalUptime),
                target.applications,
                target.refreshes
            )
        end
    end
    lines[#lines + 1] = ""

    lines[#lines + 1] = "Prescience Coverage"
    local prescienceTargets = CollectSpellTargets(segment, ns.Constants.Spells.PRESCIENCE)
    if #prescienceTargets == 0 then
        lines[#lines + 1] = "No tracked Prescience targets."
    else
        for index = 1, math.min(#prescienceTargets, 8) do
            local target = prescienceTargets[index]
            lines[#lines + 1] = string.format(
                "%s - uptime %s, applies %d, refreshes %d",
                target.name or "Unknown",
                FormatDuration(target.totalUptime),
                target.applications,
                target.refreshes
            )
        end
    end
    lines[#lines + 1] = ""

    lines[#lines + 1] = "Blistering Scales Coverage"
    local blisteringTargets = CollectSpellTargets(segment, ns.Constants.Spells.BLISTERING_SCALES)
    if #blisteringTargets == 0 then
        lines[#lines + 1] = "No tracked Blistering Scales targets."
    else
        for index = 1, math.min(#blisteringTargets, 8) do
            local target = blisteringTargets[index]
            lines[#lines + 1] = string.format(
                "%s - uptime %s, applies %d, refreshes %d",
                target.name or "Unknown",
                FormatDuration(target.totalUptime),
                target.applications,
                target.refreshes
            )
        end
    end
    lines[#lines + 1] = ""

    lines[#lines + 1] = "Recent Timeline"
    local timelineStart = math.max(1, #segment.timeline - 9)
    if #segment.timeline == 0 then
        lines[#lines + 1] = "No tracked events."
    else
        for index = timelineStart, #segment.timeline do
            local entry = segment.timeline[index]
            local offset = entry.timestamp - segment.startTime
            local target = entry.destName and (" -> " .. entry.destName) or ""
            lines[#lines + 1] = string.format(
                "[%5.1fs] %s: %s%s",
                offset,
                entry.type,
                entry.spellName or ("Spell " .. (entry.spellID or 0)),
                target
            )
        end
    end

    return table.concat(lines, "\n")
end

function Report.BuildHistoryLabel(_, segment)
    if not segment then
        return "No segment"
    end

    local label = string.format("#%d %.1fs", segment.id, segment.duration or 0)
    if segment.encounterName then
        return label .. " " .. segment.encounterName
    end

    return label .. " " .. (segment.kind or "combat")
end
