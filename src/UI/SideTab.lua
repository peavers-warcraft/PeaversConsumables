--------------------------------------------------------------------------------
-- Collapsible Auction House side tab
-- Attaches a QuestLog-style tab to the right edge of the Auction House;
-- clicking it expands or collapses the consumables panel docked alongside
--------------------------------------------------------------------------------

local addonName, PC = ...

local SideTab = {}
PC.SideTab = SideTab

local TAB_X = -2
local TAB_Y = -172 -- below where Profession Shopping List parks its tab, so both fit
local TAB_ICON = "Interface\\AddOns\\PeaversCommons\\src\\Media\\Icon.tga"

-- Circular chip styling (matches the chips in BetterTogether)
local CHIP_SIZE = 30
local CIRCLE_MASK = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"
local CHIP_RIM = { 0.83, 0.67, 0.33, 0.55 } -- gold
local CHIP_FILL = { 0.09, 0.09, 0.12, 1 }

local function AddCircleMask(tab, texture)
    local mask = tab:CreateMaskTexture()
    mask:SetAllPoints(texture)
    mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    texture:AddMaskTexture(mask)
end

-- Gold-rimmed circular chip drawn over the tab plate. The template's own
-- Icon texture is left empty (SetChecked clears it), so the chip is the
-- only artwork; the template's hover and selected glows still apply.
local function CreateChip(tab)
    local rim = tab:CreateTexture(nil, "ARTWORK", nil, 0)
    rim:SetPoint("CENTER", -2, 0)
    rim:SetSize(CHIP_SIZE, CHIP_SIZE)
    rim:SetColorTexture(unpack(CHIP_RIM))
    AddCircleMask(tab, rim)

    local fill = tab:CreateTexture(nil, "ARTWORK", nil, 1)
    fill:SetPoint("CENTER", rim, "CENTER")
    fill:SetSize(CHIP_SIZE - 3, CHIP_SIZE - 3)
    fill:SetColorTexture(unpack(CHIP_FILL))
    AddCircleMask(tab, fill)

    local icon = tab:CreateTexture(nil, "ARTWORK", nil, 2)
    icon:SetPoint("CENTER", rim, "CENTER")
    icon:SetSize(CHIP_SIZE - 9, CHIP_SIZE - 9)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    icon:SetTexture(TAB_ICON)
    AddCircleMask(tab, icon)
end

local function AnchorTab(tab, anchorFrame)
    tab:ClearAllPoints()
    tab:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", TAB_X, TAB_Y)
end

function SideTab:GetTab()
    if self.tab then
        return self.tab
    end

    local ahFrame = _G.AuctionHouseFrame
    if not ahFrame then
        return nil
    end

    local tab = CreateFrame("Frame", "PeaversConsumablesSideTab", ahFrame, "LargeSideTabButtonTemplate")
    tab.tooltipText = "|cff3abdf7Peavers|rConsumables"
    AnchorTab(tab, ahFrame)
    tab:SetChecked(false)
    CreateChip(tab)
    tab:SetCustomOnMouseUpHandler(function(_, button, upInside)
        if button == "LeftButton" and upInside then
            self:Toggle()
        end
    end)

    -- Collapse when the window hides for any other reason (close button, ESC)
    PC.MainFrame:GetFrame():HookScript("OnHide", function()
        if self.expanded then
            self:Collapse()
        end
    end)

    self.tab = tab
    return tab
end

function SideTab:IsAvailable()
    local ahFrame = _G.AuctionHouseFrame
    return PC.Config.showAHTab and self.tab ~= nil and ahFrame and ahFrame:IsShown()
end

function SideTab:Expand()
    local tab = self:GetTab()
    if not tab then
        return
    end

    PC.MainFrame:ShowDocked(_G.AuctionHouseFrame)
    AnchorTab(tab, PC.MainFrame:GetFrame())
    tab:SetChecked(true)

    self.expanded = true
    PC.Config.ahPanelExpanded = true
    PC.Config:Save()
end

-- keepState: collapse without remembering it as the user's choice
-- (used when the Auction House closes underneath an expanded panel)
function SideTab:Collapse(keepState)
    self.expanded = false

    local tab = self.tab
    if tab then
        AnchorTab(tab, _G.AuctionHouseFrame)
        tab:SetChecked(false)
    end

    PC.MainFrame:Hide()
    PC.MainFrame:Undock()

    if not keepState then
        PC.Config.ahPanelExpanded = false
        PC.Config:Save()
    end
end

function SideTab:Toggle()
    if self.expanded then
        self:Collapse()
    else
        self:Expand()
    end
end

function SideTab:OnAuctionHouseShow()
    local tab = self:GetTab()
    if not tab then
        return
    end

    tab:Show()
    if PC.Config.ahPanelExpanded then
        self:Expand()
    end
end

-- Used when the side tab is disabled in settings but was already created
function SideTab:HideTab()
    if self.expanded then
        self:Collapse(true)
    end
    if self.tab then
        self.tab:Hide()
    end
end

function SideTab:OnAuctionHouseClosed()
    if self.expanded then
        self:Collapse(true)
    end
end

return SideTab
