local _, ns = ...

local Constants = ns.Constants

Constants.DB_KEY = "DiscoBardDB"
Constants.ADDON_PREFIX = "|cff66ccffDiscoBard:|r"

Constants.Defaults = {
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 0,
    width = 640,
    height = 420,
    locked = false,
    historyLimit = 20,
    autoShow = true,
    debug = false,
}

Constants.Colors = {
    background = { 0.05, 0.06, 0.09, 0.96 },
    panel = { 0.09, 0.10, 0.14, 0.98 },
    border = { 0.18, 0.21, 0.29, 1.0 },
    accent = { 0.18, 0.72, 0.82, 1.0 },
    accentSoft = { 0.14, 0.31, 0.42, 1.0 },
    text = { 0.95, 0.95, 0.95, 1.0 },
    muted = { 0.70, 0.74, 0.80, 1.0 },
}

Constants.Textures = {
    white = "Interface\\Buttons\\WHITE8x8",
}

Constants.Spells = {
    EBON_MIGHT = 395152,
    PRESCIENCE = 410089,
    BLISTERING_SCALES = 360827,
    BREATH_OF_EONS = 403631,
    UPHEAVAL = 396286,
    ERUPTION = 395160,
}

Constants.SpecIDs = {
    AUGMENTATION = 1473,
}

Constants.TrackedSpells = {
    casts = {
        [Constants.Spells.EBON_MIGHT] = "Ebon Might",
        [Constants.Spells.PRESCIENCE] = "Prescience",
        [Constants.Spells.BLISTERING_SCALES] = "Blistering Scales",
        [Constants.Spells.BREATH_OF_EONS] = "Breath of Eons",
        [Constants.Spells.UPHEAVAL] = "Upheaval",
        [Constants.Spells.ERUPTION] = "Eruption",
    },
    buffs = {
        [Constants.Spells.EBON_MIGHT] = "Ebon Might",
        [Constants.Spells.PRESCIENCE] = "Prescience",
        [Constants.Spells.BLISTERING_SCALES] = "Blistering Scales",
    },
}
