--------------------------------------------------------------------------------
-- PeaversConsumables Configuration
-- Uses PeaversCommons.ConfigManager with AceDB-3.0 for profile management
--------------------------------------------------------------------------------

local addonName, PC = ...

local PeaversCommons = _G.PeaversCommons
local ConfigManager = PeaversCommons.ConfigManager

local PC_DEFAULTS = {
    enabled = true,
    debugMode = false,
    autoOpenWithAH = true,
    autoCloseWithAH = true,
    showAHTab = true,
    ahPanelExpanded = true,
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
