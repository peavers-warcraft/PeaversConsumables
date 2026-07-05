local addonName, PC = ...

local ConfigUI = {}
PC.ConfigUI = ConfigUI

local PeaversCommons = _G.PeaversCommons

function ConfigUI:InitializeOptions()
    local panel = PeaversCommons.ConfigUIUtils.CreateSettingsPanel(
        "Settings",
        "Configuration options for PeaversConsumables"
    )

    local content = panel.content
    local yPos = panel.yPos
    local baseSpacing = panel.baseSpacing
    local sectionSpacing = panel.sectionSpacing

    yPos = self:CreateGeneralOptions(content, yPos, baseSpacing, sectionSpacing)
    yPos = self:CreateDataOptions(content, yPos, baseSpacing, sectionSpacing)

    panel:UpdateContentHeight(yPos)

    return panel
end

function ConfigUI:CreateGeneralOptions(content, yPos, baseSpacing, sectionSpacing)
    local controlIndent = baseSpacing + 15

    local _, newY = PeaversCommons.ConfigUIUtils.CreateSectionHeader(content, "General Settings", baseSpacing, yPos)
    yPos = newY - 10

    _, newY = PeaversCommons.ConfigUIUtils.CreateCheckbox(
        content,
        "PCShowAHTabCheckbox",
        "Attach as a collapsible side tab on the Auction House",
        controlIndent, yPos,
        PC.Config.showAHTab,
        function(checked)
            PC.Config.showAHTab = checked
            PC.Config:Save()
        end
    )
    yPos = newY - 8

    _, newY = PeaversCommons.ConfigUIUtils.CreateCheckbox(
        content,
        "PCAutoOpenWithAHCheckbox",
        "Open automatically when the Auction House opens (if side tab is disabled)",
        controlIndent, yPos,
        PC.Config.autoOpenWithAH,
        function(checked)
            PC.Config.autoOpenWithAH = checked
            PC.Config:Save()
        end
    )
    yPos = newY - 8

    _, newY = PeaversCommons.ConfigUIUtils.CreateCheckbox(
        content,
        "PCAutoCloseWithAHCheckbox",
        "Close automatically when the Auction House closes",
        controlIndent, yPos,
        PC.Config.autoCloseWithAH,
        function(checked)
            PC.Config.autoCloseWithAH = checked
            PC.Config:Save()
        end
    )
    yPos = newY - 15

    return yPos
end

function ConfigUI:CreateDataOptions(content, yPos, baseSpacing, sectionSpacing)
    local controlIndent = baseSpacing + 15

    local _, newY = PeaversCommons.ConfigUIUtils.CreateSeparator(content, baseSpacing, yPos)
    yPos = newY - 15

    _, newY = PeaversCommons.ConfigUIUtils.CreateSectionHeader(content, "Data Source", baseSpacing, yPos)
    yPos = newY - 10

    local ConsumablesData = _G.PeaversConsumablesData
    if ConsumablesData and ConsumablesData.API then
        local updates = ConsumablesData.API.GetLastUpdate()

        for source, timestamp in pairs(updates) do
            local sourceLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            sourceLabel:SetPoint("TOPLEFT", controlIndent, yPos)
            sourceLabel:SetText(source:sub(1, 1):upper() .. source:sub(2) .. ":")
            sourceLabel:SetTextColor(1, 0.82, 0)

            local updateText = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            updateText:SetPoint("TOPLEFT", sourceLabel, "TOPRIGHT", 10, 0)
            updateText:SetText(timestamp or "unknown")

            yPos = yPos - 20
        end
    else
        local errorText = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        errorText:SetPoint("TOPLEFT", controlIndent, yPos)
        errorText:SetText("PeaversConsumablesData not available")
        errorText:SetTextColor(1, 0, 0)
        yPos = yPos - 20
    end

    yPos = yPos - 15

    return yPos
end

function ConfigUI:BuildIntoFrame(parentFrame)
    local yPos = 0
    local baseSpacing = 25
    local sectionSpacing = 40

    yPos = self:CreateGeneralOptions(parentFrame, yPos, baseSpacing, sectionSpacing)
    yPos = self:CreateDataOptions(parentFrame, yPos, baseSpacing, sectionSpacing)

    parentFrame:SetHeight(math.abs(yPos) + 50)
    return parentFrame
end

function ConfigUI:Initialize()
    self.panel = self:InitializeOptions()
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
