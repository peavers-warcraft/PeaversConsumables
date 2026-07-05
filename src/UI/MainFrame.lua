--------------------------------------------------------------------------------
-- PeaversConsumables main window
-- Lists the best consumables for the player's spec; click a row to search
-- for it on the Auction House
--------------------------------------------------------------------------------

local addonName, PC = ...

local PeaversCommons = _G.PeaversCommons
local FrameUtils = PeaversCommons.FrameUtils

local MainFrame = {}
PC.MainFrame = MainFrame

local FRAME_WIDTH = 340
local FRAME_HEIGHT = 460
local ROW_HEIGHT = 26
local HEADER_HEIGHT = 24

local function GetPlayerClassAndSpec()
    local _, _, classID = UnitClass("player")
    local specIndex = GetSpecialization()
    local specID, specName
    if specIndex then
        specID, specName = GetSpecializationInfo(specIndex)
    end
    return classID, specID, specName
end

local function CreateCategoryHeader(content, text, yPos)
    local header = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 4, yPos)
    header:SetText(text)
    header:SetTextColor(1, 0.82, 0)
    return yPos - HEADER_HEIGHT
end

local function CreateMessage(content, text, yPos)
    local message = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    message:SetPoint("TOPLEFT", 4, yPos)
    message:SetPoint("RIGHT", content, "RIGHT", -4, 0)
    message:SetJustifyH("LEFT")
    message:SetText(text)
    return yPos - 40
end

local function CreateItemRow(content, item, yPos)
    local row = CreateFrame("Button", nil, content)
    row:SetPoint("TOPLEFT", 4, yPos)
    row:SetPoint("RIGHT", content, "RIGHT", -4, 0)
    row:SetHeight(ROW_HEIGHT)

    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.1)

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("LEFT", 2, 0)
    icon:SetTexture(134400) -- question mark placeholder until item data loads

    local slotText = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    slotText:SetPoint("RIGHT", -4, 0)
    slotText:SetText(item.slot or "")
    slotText:SetTextColor(0.6, 0.6, 0.6)

    local nameText = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    nameText:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    nameText:SetPoint("RIGHT", slotText, "LEFT", -6, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    nameText:SetText(item.itemName)

    local function ApplyQualityColor(quality)
        local color = quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
        if color then
            nameText:SetTextColor(color.r, color.g, color.b)
        end
    end
    ApplyQualityColor(item.quality)

    -- Load live icon, name and quality from the item cache
    if item.itemID then
        local itemObj = Item:CreateFromItemID(item.itemID)
        itemObj:ContinueOnItemLoad(function()
            icon:SetTexture(itemObj:GetItemIcon())
            nameText:SetText(itemObj:GetItemName() or item.itemName)
            ApplyQualityColor(itemObj:GetItemQuality())
        end)
    end

    row:SetScript("OnClick", function()
        PC.AuctionHouse:Search(item)
    end)

    row:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if item.itemID then
            GameTooltip:SetItemByID(item.itemID)
        else
            GameTooltip:SetText(item.itemName)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click to search on the Auction House", 0.2, 0.74, 0.97)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return yPos - ROW_HEIGHT
end

local function CreateWindow()
    local frame = CreateFrame("Frame", "PeaversConsumablesFrame", UIParent, "DefaultPanelTemplate")
    frame:Hide() -- frames are visible on creation; stay hidden until Show() drives a refresh
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)

    frame.TitleBg = FrameUtils.CreateTitleBackground(frame)
    frame.CloseButton = FrameUtils.CreateCloseButton(frame)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", frame, "TOP", 0, -5)
    frame.TitleText = title

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        if self.docked then return end
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        if self.docked then return end
        self:StopMovingOrSizing()
        self.userMoved = true
    end)
    tinsert(UISpecialFrames, frame:GetName())

    local body = CreateFrame("Frame", nil, frame)
    body:SetPoint("TOPLEFT", 0, -22)
    body:SetPoint("BOTTOMRIGHT", 0, 4)

    -- ScrollFrameTemplate provides the modern MinimalScrollBar (same style as the AH)
    local scrollFrame = CreateFrame("ScrollFrame", nil, body, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 12, -6)
    scrollFrame:SetPoint("BOTTOMRIGHT", -26, 6)
    frame.scrollFrame = scrollFrame

    return frame
end

function MainFrame:GetFrame()
    if not self.frame then
        self.frame = CreateWindow()
    end
    return self.frame
end

function MainFrame:Refresh()
    local frame = self:GetFrame()

    -- Replace the scroll child with a fresh container each refresh;
    -- row counts are small so a rebuild is cheap and avoids pooling logic
    if frame.content then
        frame.content:Hide()
        frame.content:SetParent(nil)
    end
    local content = CreateFrame("Frame", nil, frame.scrollFrame)
    local width = frame.scrollFrame:GetWidth()
    if not width or width < 50 then
        width = FRAME_WIDTH - 42 -- scroll frame insets before first layout pass
    end
    content:SetWidth(width)
    frame.scrollFrame:SetScrollChild(content)
    frame.content = content

    local classID, specID, specName = GetPlayerClassAndSpec()
    frame.TitleText:SetText("Peavers Consumables" .. (specName and (" - " .. specName) or ""))

    local yPos = -4

    local ConsumablesData = _G.PeaversConsumablesData
    if not (ConsumablesData and ConsumablesData.API) then
        yPos = CreateMessage(content, "PeaversConsumablesData is not available.", yPos)
    elseif not specID then
        yPos = CreateMessage(content, "No specialization detected yet.", yPos)
    else
        local API = ConsumablesData.API
        local consumables = API.GetAllConsumables(classID, specID)

        if not consumables or next(consumables) == nil then
            yPos = CreateMessage(content,
                "No consumable data for " .. (specName or "your spec") .. " yet. More specs are coming soon.", yPos)
        else
            for _, category in ipairs(API.GetCategories()) do
                local items = consumables[category]
                if items and #items > 0 then
                    yPos = CreateCategoryHeader(content, API.GetCategoryName(category) or category, yPos)
                    for _, item in ipairs(items) do
                        yPos = CreateItemRow(content, item, yPos)
                    end
                    yPos = yPos - 8
                end
            end
        end
    end

    content:SetHeight(math.abs(yPos) + 20)
end

function MainFrame:RefreshIfShown()
    if self.frame and self.frame:IsShown() then
        self:Refresh()
    end
end

function MainFrame:Show()
    local frame = self:GetFrame()

    -- Dock next to the Auction House when it is open, unless the user moved us
    if not frame.userMoved and not frame.docked then
        frame:ClearAllPoints()
        local ahFrame = _G.AuctionHouseFrame
        if ahFrame and ahFrame:IsShown() then
            frame:SetPoint("TOPLEFT", ahFrame, "TOPRIGHT", 12, 0)
        else
            frame:SetPoint("CENTER")
        end
    end

    frame:Show()
    self:Refresh()
end

-- While docked the panel acts as part of the Auction House, so ESC should
-- fall through and close the AH itself rather than just this panel
local function SetEscClosable(frame, closable)
    local name = frame:GetName()
    for i, v in ipairs(UISpecialFrames) do
        if v == name then
            if not closable then
                table.remove(UISpecialFrames, i)
            end
            return
        end
    end
    if closable then
        tinsert(UISpecialFrames, name)
    end
end

-- Dock the window flush against the anchor frame's right edge, matching
-- its full height (used by the collapsible Auction House side tab)
function MainFrame:ShowDocked(anchorFrame)
    local frame = self:GetFrame()
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 0, 0)
    frame:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT", 0, 0)
    frame.docked = true
    SetEscClosable(frame, false)
    frame:Show()
    self:Refresh()
end

function MainFrame:Undock()
    local frame = self.frame
    if not frame or not frame.docked then
        return
    end
    frame.docked = nil
    frame.userMoved = nil
    SetEscClosable(frame, true)
    frame:ClearAllPoints()
    frame:SetHeight(FRAME_HEIGHT)
    frame:SetPoint("CENTER")
end

function MainFrame:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

function MainFrame:Toggle()
    if self.frame and self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

return MainFrame
