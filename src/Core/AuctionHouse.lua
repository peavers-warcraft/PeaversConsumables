--------------------------------------------------------------------------------
-- PeaversConsumables Auction House integration
-- Searches the default Auction House UI for a consumable so it can be bought
--------------------------------------------------------------------------------

local addonName, PC = ...

local PeaversCommons = _G.PeaversCommons
local Utils = PeaversCommons.Utils

local AuctionHouse = {}
PC.AuctionHouse = AuctionHouse

function AuctionHouse:IsOpen()
    local frame = _G.AuctionHouseFrame
    return frame ~= nil and frame:IsShown()
end

-- Switch the default AH UI to the buy/browse view so search results are visible
local function EnsureBrowseMode(frame)
    if frame.SetDisplayMode and AuctionHouseFrameDisplayMode and AuctionHouseFrameDisplayMode.Buy then
        pcall(frame.SetDisplayMode, frame, AuctionHouseFrameDisplayMode.Buy)
    end
end

---Search the Auction House for an item so the user can buy it
---@param item table Item row from PeaversConsumablesData (itemID, itemName)
function AuctionHouse:Search(item)
    if not item or not item.itemName then
        return
    end

    if not self:IsOpen() then
        Utils.Print(PC, "Open the Auction House to search for " .. item.itemName .. ".")
        return
    end

    local frame = _G.AuctionHouseFrame
    EnsureBrowseMode(frame)

    -- Preferred path: drive the default search bar so results show in the browse list
    local searchBar = frame.SearchBar
    if searchBar and searchBar.SearchBox and searchBar.StartSearch then
        searchBar.SearchBox:SetText(item.itemName)
        searchBar:StartSearch()
        return
    end

    -- Fallback: query the item key directly
    if item.itemID and C_AuctionHouse and C_AuctionHouse.MakeItemKey then
        local itemKey = C_AuctionHouse.MakeItemKey(item.itemID)
        local sorts = { { sortOrder = Enum.AuctionHouseSortOrder.Price, reverseSort = false } }
        C_AuctionHouse.SendSearchQuery(itemKey, sorts, true)
    end
end

return AuctionHouse
