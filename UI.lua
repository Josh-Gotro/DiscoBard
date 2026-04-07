local _, ns = ...

local UI = ns.UI
local Colors = ns.Constants.Colors
local Textures = ns.Constants.Textures

local function SetPointFromConfig(frame)
    local point, relativePoint, x, y = ns.Config:GetAnchor()
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, relativePoint, x, y)
end

local function SavePosition(frame)
    local point, _, relativePoint, x, y = frame:GetPoint(1)
    ns.Config:SetAnchor(point, relativePoint, x, y)
end

local function ApplyBackdrop(frame, background, border)
    frame:SetBackdrop({
        bgFile = Textures.white,
        edgeFile = Textures.white,
        edgeSize = 1,
    })
    frame:SetBackdropColor(background[1], background[2], background[3], background[4])
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

local function CreateButton(parent, label, width)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width, 22)
    ApplyBackdrop(button, Colors.panel, Colors.border)

    button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.Text:SetPoint("CENTER")
    button.Text:SetText(label)

    button:SetScript("OnEnter", function(self)
        ApplyBackdrop(self, Colors.accentSoft, Colors.accent)
    end)

    button:SetScript("OnLeave", function(self)
        ApplyBackdrop(self, Colors.panel, Colors.border)
    end)

    return button
end

function UI:Initialize()
    if self.frame then
        return
    end

    local frame = CreateFrame("Frame", ns.addonName .. "ReviewFrame", UIParent, "BackdropTemplate")
    frame:SetSize(ns.Config:Get("width"), ns.Config:Get("height"))
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(current)
        if ns.Config:Get("locked") then
            return
        end
        current:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(current)
        current:StopMovingOrSizing()
        SavePosition(current)
    end)
    ApplyBackdrop(frame, Colors.background, Colors.border)
    SetPointFromConfig(frame)
    frame:Hide()

    frame.Title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.Title:SetPoint("TOPLEFT", 12, -10)
    frame.Title:SetText("DiscoBard Review")

    frame.Subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.Subtitle:SetPoint("TOPLEFT", frame.Title, "BOTTOMLEFT", 0, -4)
    frame.Subtitle:SetText("Augmentation post-combat coverage review")
    frame.Subtitle:SetTextColor(Colors.muted[1], Colors.muted[2], Colors.muted[3], Colors.muted[4])

    frame.CloseButton = CreateButton(frame, "Close", 64)
    frame.CloseButton:SetPoint("TOPRIGHT", -10, -8)
    frame.CloseButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    frame.PreviousButton = CreateButton(frame, "Prev", 54)
    frame.PreviousButton:SetPoint("TOPLEFT", 12, -42)
    frame.PreviousButton:SetScript("OnClick", function()
        self:SelectRelative(-1)
    end)

    frame.NextButton = CreateButton(frame, "Next", 54)
    frame.NextButton:SetPoint("LEFT", frame.PreviousButton, "RIGHT", 6, 0)
    frame.NextButton:SetScript("OnClick", function()
        self:SelectRelative(1)
    end)

    frame.ClearButton = CreateButton(frame, "Clear", 54)
    frame.ClearButton:SetPoint("LEFT", frame.NextButton, "RIGHT", 6, 0)
    frame.ClearButton:SetScript("OnClick", function()
        ns.Segments:ClearHistory()
        self.selectedIndex = nil
        self:Refresh()
    end)

    frame.Content = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.Content:SetPoint("TOPLEFT", 12, -72)
    frame.Content:SetPoint("BOTTOMRIGHT", -12, 12)
    ApplyBackdrop(frame.Content, Colors.panel, Colors.border)

    frame.ReportText = frame.Content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.ReportText:SetPoint("TOPLEFT", 10, -10)
    frame.ReportText:SetPoint("TOPRIGHT", -10, -10)
    frame.ReportText:SetJustifyH("LEFT")
    frame.ReportText:SetJustifyV("TOP")
    frame.ReportText:SetSpacing(2)
    frame.ReportText:SetText("")

    self.frame = frame
    self:SetLocked(ns.Config:Get("locked"))
end

function UI:ApplyLayout()
    if not self.frame then
        return
    end

    self.frame:SetSize(ns.Config:Get("width"), ns.Config:Get("height"))
    SetPointFromConfig(self.frame)
end

function UI:SetLocked(locked)
    if not self.frame then
        return
    end

    self.frame:EnableMouse(not locked)
end

function UI:SetSegment(segment)
    local history = ns.Segments:GetHistory()
    for index, existing in ipairs(history) do
        if existing == segment then
            self.selectedIndex = index
            break
        end
    end

    self:Refresh()
end

function UI:SelectRelative(offset)
    local history = ns.Segments:GetHistory()
    if #history == 0 then
        self.selectedIndex = nil
        self:Refresh()
        return
    end

    if not self.selectedIndex then
        self.selectedIndex = #history
    else
        self.selectedIndex = math.max(1, math.min(#history, self.selectedIndex + offset))
    end

    self:Refresh()
end

function UI:Refresh()
    if not self.frame then
        return
    end

    local history = ns.Segments:GetHistory()
    local segment = self.selectedIndex and history[self.selectedIndex] or history[#history]

    if segment then
        for index, existing in ipairs(history) do
            if existing == segment then
                self.selectedIndex = index
                break
            end
        end
    end

    self.frame.Title:SetText("DiscoBard Review")
    self.frame.Subtitle:SetText(ns.Report:BuildHistoryLabel(segment))
    self.frame.ReportText:SetText(ns.Report:BuildSegmentText(segment))
end

function UI:Show()
    self:Refresh()
    self.frame:Show()
end

function UI:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

function UI:Toggle()
    if not self.frame then
        return
    end

    if self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end
