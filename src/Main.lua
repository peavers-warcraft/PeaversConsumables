local addonName, PC = ...

local PeaversCommons = _G.PeaversCommons
local Utils = PeaversCommons.Utils

PC = PC or {}
PC.name = addonName
PC.version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "1.0.0"

-- Register slash commands
PeaversCommons.SlashCommands:Register(addonName, "pcons", {
    default = function()
        if PC.SideTab:IsAvailable() then
            PC.SideTab:Toggle()
        else
            PC.MainFrame:Toggle()
        end
    end,
    config = function()
        PC.ConfigUI:Open()
    end,
    help = function()
        Utils.Print(PC, "Commands:")
        print("  /pcons - Toggle the consumables window")
        print("  /pcons config - Open configuration")
    end
})

-- Additional slash command
PeaversCommons.SlashCommands:Register(addonName, "consumables", {
    default = function()
        if PC.SideTab:IsAvailable() then
            PC.SideTab:Toggle()
        else
            PC.MainFrame:Toggle()
        end
    end
})

-- Initialize the addon
PeaversCommons.Events:Init(addonName, function()
    PC.Config:Initialize()
    PC.ConfigUI:Initialize()

    PeaversCommons.Events:RegisterEvent("AUCTION_HOUSE_SHOW", function()
        if PC.Config.showAHTab then
            PC.SideTab:OnAuctionHouseShow()
        else
            PC.SideTab:HideTab()
            if PC.Config.autoOpenWithAH then
                PC.MainFrame:Show()
            end
        end
    end)

    PeaversCommons.Events:RegisterEvent("AUCTION_HOUSE_CLOSED", function()
        PC.SideTab:OnAuctionHouseClosed()
        if PC.Config.autoCloseWithAH then
            PC.MainFrame:Hide()
        end
    end)

    PeaversCommons.Events:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", function()
        PC.MainFrame:RefreshIfShown()
    end)

    C_Timer.After(0.5, function()
        PeaversCommons.SettingsUI:CreateRedirectPage(PC, "PeaversConsumables", "Peavers Consumables")
    end)
    -- Register with PeaversConfig registry
    if PeaversCommons.ConfigRegistry then
        PeaversCommons.ConfigRegistry:Register({
            name = "PeaversConsumables",
            displayName = "Consumables",
            description = "Best consumables for your spec with Auction House search",
            addonRef = PC,
            config = PC.Config,
            pages = PC.ConfigUI:GetPages(),
            order = 9,
        })
    end
end, {
    suppressAnnouncement = true
})

-- Export addon table
_G.PeaversConsumables = PC

return PC
