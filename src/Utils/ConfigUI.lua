local addonName, PC = ...

local ConfigUI = {}
PC.ConfigUI = ConfigUI

local PeaversCommons = _G.PeaversCommons
if not PeaversCommons then return end

local W = PeaversCommons.Widgets
local C = W.Colors

local INDENT = 25
local ROW = 26

function ConfigUI:BuildGeneralPage(parentFrame)
    local y = -10

    local _, newY = W:CreateSectionHeader(parentFrame, "General Settings", INDENT, y)
    y = newY - 8

    local options = {
        {
            label = "Attach as a collapsible side tab on the Auction House",
            key = "showAHTab",
        },
        {
            label = "Open automatically when the Auction House opens",
            description = "Only applies when the side tab is disabled.",
            key = "autoOpenWithAH",
        },
        {
            label = "Close automatically when the Auction House closes",
            key = "autoCloseWithAH",
        },
    }

    for _, opt in ipairs(options) do
        local cb = W:CreateCheckbox(parentFrame, opt.label, {
            checked = PC.Config[opt.key],
            description = opt.description,
            width = 420,
            onChange = function(checked)
                PC.Config[opt.key] = checked
                PC.Config:Save()
            end,
        })
        cb:SetPoint("TOPLEFT", INDENT, y)
        y = y - (opt.description and ROW + 14 or ROW)
    end

    parentFrame:SetHeight(math.abs(y) + 30)
end

function ConfigUI:BuildDataPage(parentFrame)
    local y = -10

    local _, newY = W:CreateSectionHeader(parentFrame, "Data Source", INDENT, y)
    y = newY - 8

    local ConsumablesData = _G.PeaversConsumablesData
    if ConsumablesData and ConsumablesData.API then
        local updates = ConsumablesData.API.GetLastUpdate()

        for source, timestamp in pairs(updates or {}) do
            local label = W:CreateLabel(parentFrame,
                source:sub(1, 1):upper() .. source:sub(2), { color = C.textSec })
            label:SetPoint("TOPLEFT", INDENT, y)

            local value = W:CreateLabel(parentFrame, timestamp or "unknown", { color = C.text })
            value:SetPoint("TOPLEFT", INDENT + 110, y)

            y = y - 22
        end
    else
        local err = W:CreateLabel(parentFrame,
            "PeaversConsumablesData not available", { color = C.danger })
        err:SetPoint("TOPLEFT", INDENT, y)
        y = y - 22
    end

    parentFrame:SetHeight(math.abs(y) + 30)
end

function ConfigUI:BuildInfoPage(parentFrame)
    PeaversCommons.ConfigUIUtils.BuildInfoPage(parentFrame, "Consumables", {
        "Shows the best consumables, enchants, and gems for your current spec, " ..
            "sourced from wowcompare.io, and searches any of them on the " ..
            "Auction House with one click.",
        { command = "/pcons", desc = "toggle the consumables window" },
        { command = "/pcons config", desc = "open the configuration panel" },

        { header = "Working the Auction House" },
        "Open the Auction House and the window appears alongside it " ..
            "automatically (this can be turned off in General). Click any item " ..
            "to search for it in the browse tab - no typing needed.",

        { header = "Where the data comes from" },
        "Recommendations ship in the PeaversConsumablesData companion addon " ..
            "and refresh automatically with updates, so the lists track the " ..
            "current patch without manual imports.",
    })
end

function ConfigUI:GetPages()
    return {
        -- First entry renders leftmost and is the default-selected tab
        { key = "info", label = "Information", builder = function(f) ConfigUI:BuildInfoPage(f) end },
        { key = "general", label = "General", builder = function(f) ConfigUI:BuildGeneralPage(f) end },
        { key = "data", label = "Data", builder = function(f) ConfigUI:BuildDataPage(f) end },
    }
end

-- Legacy single-panel path, kept for the older ConfigRegistry `buildPanel` contract.
function ConfigUI:BuildIntoFrame(parentFrame)
    self:BuildGeneralPage(parentFrame)
    return parentFrame
end

function ConfigUI:Initialize()
end

function ConfigUI:Open()
    -- Prefer PeaversConfig if available
    if _G.PeaversConfig and _G.PeaversConfig.MainFrame then
        _G.PeaversConfig.MainFrame:Show()
        _G.PeaversConfig.MainFrame:SelectAddon("PeaversConsumables")
        return
    end

    local addon = _G[addonName]

    if Settings and Settings.OpenToCategory and addon then
        if addon.directSettingsCategoryID then
            local success = pcall(Settings.OpenToCategory, addon.directSettingsCategoryID)
            if success then return end
        end

        if addon.directCategoryID then
            local success = pcall(Settings.OpenToCategory, addon.directCategoryID)
            if success then return end
        end
    end

    if SettingsPanel then
        SettingsPanel:Open()
    end
end

return ConfigUI
