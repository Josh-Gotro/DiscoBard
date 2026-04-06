local _, ns = ...

local Frames = ns.Frames
local Colors = ns.Constants.Colors
local Textures = ns.Constants.Textures
local classColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local unpackValues = unpack or table.unpack

local function SetPointFromConfig(frame)
    local point, relativePoint, x, y = ns.Config:GetAnchor()
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, relativePoint, x, y)
end

local function SavePosition(frame)
    local point, _, relativePoint, x, y = frame:GetPoint(1)
    ns.Config:SetAnchor(point, relativePoint, x, y)
end

local function GetRoleCoords(role)
    return unpackValues(ns.Constants.RoleCoords[role] or ns.Constants.RoleCoords.DAMAGER)
end

local function FormatHealthText(state)
    if not state.connected then
        return "OFF"
    end

    if state.dead then
        return "DEAD"
    end

    if state.ghost then
        return "GHOST"
    end

    if state.healthPct == nil then
        return ""
    end

    return string.format("%d%%", state.healthPct or 0)
end

local function ApplyBorderColor(button, color)
    button.Border:SetBackdropBorderColor(color[1], color[2], color[3], color[4])
end

local function ApplyIcon(slot, aura)
    if aura then
        slot.Icon:SetTexture(aura.icon)
        slot.Count:SetText("")
        slot:Show()
    else
        slot:Hide()
    end
end

local function CreateAuraSlot(parent, size)
    local slot = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    slot:SetSize(size, size)
    slot:SetBackdrop({
        bgFile = Textures.white,
        edgeFile = Textures.white,
        edgeSize = 1,
    })
    slot:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    slot:SetBackdropBorderColor(0.15, 0.15, 0.15, 1.0)

    slot.Icon = slot:CreateTexture(nil, "ARTWORK")
    slot.Icon:SetAllPoints()

    slot.Count = slot:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slot.Count:SetPoint("BOTTOMRIGHT", -1, 1)
    slot.Count:SetJustifyH("RIGHT")

    slot:Hide()

    return slot
end

local function CreateReadyTexture(parent)
    local texture = parent:CreateTexture(nil, "OVERLAY")
    texture:SetSize(12, 12)
    texture:Hide()
    return texture
end

local function UpdateReadyTexture(texture, readyState)
    if readyState == "ready" and READY_CHECK_READY_TEXTURE then
        texture:SetTexture(READY_CHECK_READY_TEXTURE)
        texture:Show()
    elseif readyState == "notready" and READY_CHECK_NOT_READY_TEXTURE then
        texture:SetTexture(READY_CHECK_NOT_READY_TEXTURE)
        texture:Show()
    elseif readyState == "waiting" and READY_CHECK_WAITING_TEXTURE then
        texture:SetTexture(READY_CHECK_WAITING_TEXTURE)
        texture:Show()
    else
        texture:Hide()
    end
end

local function CreateUnitButton(parent, index, unit)
    local button = CreateFrame("Button", ns.addonName .. "UnitButton" .. index, parent, "SecureUnitButtonTemplate")
    button:SetAttribute("unit", unit)
    button:SetAttribute("*type1", "target")
    button:RegisterForClicks("AnyUp")

    button.Background = button:CreateTexture(nil, "BACKGROUND")
    button.Background:SetAllPoints()
    button.Background:SetColorTexture(unpackValues(Colors.background))

    button.Health = CreateFrame("StatusBar", nil, button)
    button.Health:SetPoint("TOPLEFT", 18, -2)
    button.Health:SetPoint("BOTTOMRIGHT", -20, 2)
    button.Health:SetStatusBarTexture(Textures.statusBar)
    button.Health:SetMinMaxValues(0, 1)

    button.HealthBackground = button.Health:CreateTexture(nil, "BACKGROUND")
    button.HealthBackground:SetAllPoints()
    button.HealthBackground:SetColorTexture(0.10, 0.10, 0.12, 0.95)

    button.RoleIcon = button:CreateTexture(nil, "OVERLAY")
    button.RoleIcon:SetSize(14, 14)
    button.RoleIcon:SetPoint("LEFT", 2, 0)
    button.RoleIcon:SetTexture(Textures.role)

    button.Name = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    button.Name:SetPoint("LEFT", button.Health, "LEFT", 4, 0)
    button.Name:SetPoint("RIGHT", button.Health, "RIGHT", -36, 0)
    button.Name:SetJustifyH("LEFT")

    button.HealthText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    button.HealthText:SetPoint("RIGHT", button.Health, "RIGHT", -2, 0)
    button.HealthText:SetJustifyH("RIGHT")

    button.Border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    button.Border:SetPoint("TOPLEFT", -1, 1)
    button.Border:SetPoint("BOTTOMRIGHT", 1, -1)
    button.Border:SetBackdrop({
        edgeFile = Textures.white,
        edgeSize = 1,
    })
    button.Border:SetBackdropBorderColor(unpackValues(Colors.border))

    button.DispelSlot = CreateAuraSlot(button, 14)
    button.DispelSlot:SetPoint("TOPRIGHT", -2, -2)

    button.DefensiveSlot = CreateAuraSlot(button, 14)
    button.DefensiveSlot:SetPoint("BOTTOMRIGHT", -2, 2)

    button.TrackedSlot = CreateAuraSlot(button, 14)
    button.TrackedSlot:SetPoint("BOTTOMLEFT", 20, 2)

    button.Ready = CreateReadyTexture(button)
    button.Ready:SetPoint("TOPLEFT", 20, -2)

    return button
end

function Frames:Initialize()
    if self.root then
        return
    end

    local root = CreateFrame("Frame", ns.addonName .. "Root", UIParent)
    root:SetMovable(true)
    root:SetClampedToScreen(true)
    root:RegisterForDrag("LeftButton")
    root:SetScript("OnDragStart", function(frame)
        if ns.Config:Get("locked") then
            return
        end

        frame:StartMoving()
    end)
    root:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        SavePosition(frame)
    end)

    self.root = root
    self.buttons = {}

    for index, unit in ipairs(ns.UnitOrder) do
        self.buttons[index] = CreateUnitButton(root, index, unit)
    end

    self:ApplyLayout()
    self:SetLocked(ns.Config:Get("locked"))
    self:ApplyBuiltinVisibility()
end

function Frames:SetLocked(locked)
    if not self.root then
        return
    end

    self.root:EnableMouse(not locked)
end

function Frames:ApplyLayout()
    if not self.root then
        return
    end

    local width = ns.Config:Get("width")
    local height = ns.Config:Get("height")
    local spacing = ns.Config:Get("spacing")
    local orientation = ns.Config:Get("orientation")
    local totalWidth = width
    local totalHeight = height

    for index, button in ipairs(self.buttons) do
        button:ClearAllPoints()
        button:SetSize(width, height)

        if index == 1 then
            button:SetPoint("TOPLEFT", self.root, "TOPLEFT", 0, 0)
        elseif orientation == "HORIZONTAL" then
            button:SetPoint("LEFT", self.buttons[index - 1], "RIGHT", spacing, 0)
            totalWidth = totalWidth + width + spacing
        else
            button:SetPoint("TOP", self.buttons[index - 1], "BOTTOM", 0, -spacing)
            totalHeight = totalHeight + height + spacing
        end

        local font = button.Name:GetFont()
        local fontSize = ns.Config:Get("fontSize")
        button.Name:SetFont(font, fontSize, "")
        button.HealthText:SetFont(font, fontSize, "")
        button.Health:ClearAllPoints()
        button.Health:SetPoint("TOPLEFT", 18, -2)
        button.Health:SetPoint("BOTTOMRIGHT", -20, 2)
    end

    self.root:SetSize(totalWidth, totalHeight)
    SetPointFromConfig(self.root)
end

function Frames.ApplyBuiltinVisibility()
    if not ns.Config:Get("hideBlizzardFrames") then
        return
    end

    -- Midnight moved more UI under Edit Mode. Keep built-in frame hiding best-effort and
    -- isolated here so exact frame names can be revalidated with /fstack if Blizzard changes them.
    local frameNames = {
        "PartyFrame",
        "CompactPartyFrame",
        "CompactRaidFrameManager",
    }

    for _, frameName in ipairs(frameNames) do
        local frame = _G[frameName]
        if frame and not frame.MPFHidden then
            frame:Hide()
            frame:HookScript("OnShow", frame.Hide)
            frame.MPFHidden = true
        end
    end
end

function Frames:Refresh()
    if not self.root then
        return
    end

    local states = ns.State:GetDisplayUnits()
    local isTestMode = ns.Config:Get("testMode")

    for index, button in ipairs(self.buttons) do
        local state = states[index]
        self:RenderUnit(button, state, isTestMode)
    end

    local shouldShow = (not ns.Config:Get("locked")) or (#states > 0)
    if shouldShow then
        self.root:Show()
    else
        self.root:Hide()
    end
end

function Frames.RenderUnit(_, button, state, isTestMode)
    if not state then
        button:Hide()
        return
    end

    local color = Colors.health

    button:Show()
    button:SetAlpha(1.0)
    button:EnableMouse(not isTestMode)

    if state.classToken and classColors[state.classToken] then
        local classColor = classColors[state.classToken]
        color = { classColor.r, classColor.g, classColor.b, 1.0 }
    end

    if not state.connected then
        color = Colors.disconnected
    elseif state.dead or state.ghost then
        color = Colors.dead
    end

    button.Health:SetMinMaxValues(0, math.max(state.healthMax or 0, 1))
    button.Health:SetValue(state.healthCurrent)
    button.Health:SetStatusBarColor(color[1], color[2], color[3], color[4])
    button.Name:SetText(state.name)
    button.HealthText:SetText(FormatHealthText(state))

    if state.role and state.role ~= "NONE" then
        button.RoleIcon:SetTexCoord(GetRoleCoords(state.role))
        button.RoleIcon:Show()
    else
        button.RoleIcon:Hide()
    end

    ApplyIcon(button.DispelSlot, state.dispellableDebuffs and state.dispellableDebuffs[1] or nil)
    ApplyIcon(button.TrackedSlot, state.trackedDebuffs and state.trackedDebuffs[1] or nil)
    ApplyIcon(button.DefensiveSlot, state.defensiveBuffs and state.defensiveBuffs[1] or nil)
    UpdateReadyTexture(button.Ready, state.readyState)

    if not state.connected or state.dead or state.ghost then
        ApplyBorderColor(button, Colors.inactive)
    elseif state.hasAggro then
        ApplyBorderColor(button, Colors.aggro)
    elseif state.isTarget then
        ApplyBorderColor(button, Colors.target)
    else
        ApplyBorderColor(button, Colors.border)
    end

    if not state.connected then
        button:SetAlpha(ns.Config:Get("offlineAlpha"))
    elseif not state.inRange then
        button:SetAlpha(ns.Config:Get("rangeAlpha"))
    end
end
