--------------------------------------------------------------------------------
-- PeaversConsumables main window
-- Lists the best consumables for the player's spec; click a row to search
-- for it on the Auction House
--------------------------------------------------------------------------------

local addonName, PC = ...

local PeaversCommons = _G.PeaversCommons
local FrameUtils = PeaversCommons.FrameUtils
local Utils = PeaversCommons.Utils

local MainFrame = {}
PC.MainFrame = MainFrame

-- Sizes below are the ones the window shipped with, produced by the Blizzard
-- GameFont* templates at BASE_FONT_SIZE. Every metric is derived from the
-- configured font size so rows, icons and the window grow with the text
-- instead of clipping it.
local BASE_FONT_SIZE = 12
local FRAME_WIDTH = 340
local FRAME_HEIGHT = 460

local function ResolveOutline(outline)
    if type(outline) == "boolean" then
        return outline and "OUTLINE" or ""
    end
    return outline or ""
end

local function GetFontSize()
    local size = PC.Config and PC.Config.fontSize
    if type(size) ~= "number" or size < 6 then
        return BASE_FONT_SIZE
    end
    return size
end

local function GetMetrics()
    local size = GetFontSize()
    local delta = size - BASE_FONT_SIZE
    return {
        fontSize = size,
        headerFontSize = size + 4,   -- GameFontNormalLarge
        smallFontSize = math.max(6, size - 2), -- GameFontNormalSmall
        rowHeight = size + 14,
        headerHeight = size + 12,
        messageHeight = size * 2 + 16,
        iconSize = size + 8,
        frameWidth = FRAME_WIDTH + delta * 10,
    }
end

local function ApplyFont(fontString, size)
    local config = PC.Config
    Utils.SafeSetFont(fontString, config.fontFace, size, ResolveOutline(config.fontOutline))
    if config.fontShadow then
        fontString:SetShadowColor(0, 0, 0, 1)
        fontString:SetShadowOffset(1, -1)
    else
        fontString:SetShadowOffset(0, 0)
    end
end

local function GetPlayerClassAndSpec()
    local _, _, classID = UnitClass("player")
    local specIndex = GetSpecialization()
    local specID, specName
    if specIndex then
        specID, specName = GetSpecializationInfo(specIndex)
    end
    return classID, specID, specName
end

local function CreateCategoryHeader(content, text, yPos, m)
    local header = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 4, yPos)
    header:SetText(text)
    header:SetTextColor(1, 0.82, 0)
    ApplyFont(header, m.headerFontSize)
    return yPos - m.headerHeight
end

local function CreateMessage(content, text, yPos, m)
    local message = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    message:SetPoint("TOPLEFT", 4, yPos)
    message:SetPoint("RIGHT", content, "RIGHT", -4, 0)
    message:SetJustifyH("LEFT")
    message:SetText(text)
    ApplyFont(message, m.fontSize)
    return yPos - m.messageHeight
end

local function CreateItemRow(content, item, yPos, m)
    local row = CreateFrame("Button", nil, content)
    row:SetPoint("TOPLEFT", 4, yPos)
    row:SetPoint("RIGHT", content, "RIGHT", -4, 0)
    row:SetHeight(m.rowHeight)

    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.1)

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(m.iconSize, m.iconSize)
    icon:SetPoint("LEFT", 2, 0)
    icon:SetTexture(134400) -- question mark placeholder until item data loads

    local slotText = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    slotText:SetPoint("RIGHT", -4, 0)
    slotText:SetText(item.slot or "")
    slotText:SetTextColor(0.6, 0.6, 0.6)
    ApplyFont(slotText, m.smallFontSize)

    local nameText = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    nameText:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    nameText:SetPoint("RIGHT", slotText, "LEFT", -6, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    nameText:SetText(item.itemName)
    ApplyFont(nameText, m.fontSize)

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

    return yPos - m.rowHeight
end

local function CreateWindow()
    local frame = CreateFrame("Frame", "PeaversConsumablesFrame", UIParent, "DefaultPanelTemplate")
    frame:Hide() -- frames are visible on creation; stay hidden until Show() drives a refresh
    frame:SetSize(GetMetrics().frameWidth, FRAME_HEIGHT)
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
    local m = GetMetrics()

    -- Widen with the font so long item names keep their room; docking only
    -- pins the vertical edges, so the width stays ours to set either way
    frame:SetWidth(m.frameWidth)
    ApplyFont(frame.TitleText, m.fontSize)

    -- Replace the scroll child with a fresh container each refresh;
    -- row counts are small so a rebuild is cheap and avoids pooling logic
    if frame.content then
        frame.content:Hide()
        frame.content:SetParent(nil)
    end
    local content = CreateFrame("Frame", nil, frame.scrollFrame)
    local width = frame.scrollFrame:GetWidth()
    if not width or width < 50 then
        width = m.frameWidth - 42 -- scroll frame insets before first layout pass
    end
    content:SetWidth(width)
    frame.scrollFrame:SetScrollChild(content)
    frame.content = content

    local classID, specID, specName = GetPlayerClassAndSpec()
    frame.TitleText:SetText("Peavers Consumables" .. (specName and (" - " .. specName) or ""))

    local yPos = -4

    local ConsumablesData = _G.PeaversConsumablesData
    if not (ConsumablesData and ConsumablesData.API) then
        yPos = CreateMessage(content, "PeaversConsumablesData is not available.", yPos, m)
    elseif not specID then
        yPos = CreateMessage(content, "No specialization detected yet.", yPos, m)
    else
        local API = ConsumablesData.API
        local consumables = API.GetAllConsumables(classID, specID)

        if not consumables or next(consumables) == nil then
            yPos = CreateMessage(content,
                "No consumable data for " .. (specName or "your spec") .. " yet. More specs are coming soon.", yPos, m)
        else
            for _, category in ipairs(API.GetCategories()) do
                local items = consumables[category]
                if items and #items > 0 then
                    yPos = CreateCategoryHeader(content, API.GetCategoryName(category) or category, yPos, m)
                    for _, item in ipairs(items) do
                        yPos = CreateItemRow(content, item, yPos, m)
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
