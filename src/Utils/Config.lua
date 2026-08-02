--------------------------------------------------------------------------------
-- PeaversConsumables Configuration
-- Uses PeaversCommons.ConfigManager with AceDB-3.0 for profile management
--------------------------------------------------------------------------------

local addonName, PC = ...

local PeaversCommons = _G.PeaversCommons
local ConfigManager = PeaversCommons.ConfigManager

-- Font defaults deliberately override ConfigManager.CommonDefaults (9pt/OUTLINE):
-- they reproduce the Blizzard GameFont* look the window shipped with, so
-- existing users see no change until they move the slider themselves.
local PC_DEFAULTS = {
    enabled = true,
    debugMode = false,
    autoOpenWithAH = true,
    autoCloseWithAH = true,
    showAHTab = true,
    ahPanelExpanded = true,
    fontSize = 12,
    fontOutline = "",
    fontShadow = true,
}

-- Create the AceDB-backed config
PC.Config = ConfigManager:NewWithAceDB(
    PC,
    PC_DEFAULTS,
    {
        savedVariablesName = "PeaversConsumablesDB",
        profileType = "shared",
    }
)

return PC.Config
