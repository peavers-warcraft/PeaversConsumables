--[[ Locales/zhCN.lua
  Simplified Chinese translations.

  .toc files have no conditionals, so every locale file is loaded on every client
  and guards itself. Only overridden strings are listed; anything missing falls
  back to the English source key (see enUS.lua).
]]

local addonName, PC = ...

if GetLocale() ~= "zhCN" then
    return
end

local L = PC.L

-- Window
L["Peavers Consumables"] = "Peavers 消耗品"
L["Click to search on the Auction House"] = "点击在拍卖行中搜索"
L["PeaversConsumablesData is not available."] = "PeaversConsumablesData 不可用。"
L["No specialization detected yet."] = "尚未检测到专精。"
L["No consumable data for %s yet. More specs are coming soon."] = "暂无 %s 的消耗品数据，更多专精即将支持。"
L["your spec"] = "你的专精"

-- Auction House
L["Open the Auction House to search for %s."] = "请先打开拍卖行，才能搜索 %s。"

-- Slash commands
L["Commands:"] = "命令："
L["  /pcons - Toggle the consumables window"] = "  /pcons - 开关消耗品窗口"
L["  /pcons config - Open configuration"] = "  /pcons config - 打开设置"

-- Settings: pages and registry
L["Consumables"] = "消耗品"
L["Best consumables for your spec with Auction House search"] = "为你的专精推荐最佳消耗品，并可在拍卖行中搜索"
L["Information"] = "说明"
L["General"] = "常规"
L["Text"] = "文字"
L["Data"] = "数据"

-- Settings: General page
L["General Settings"] = "常规设置"
L["Attach as a collapsible side tab on the Auction House"] = "以可折叠的侧边标签附加到拍卖行"
L["Open automatically when the Auction House opens"] = "打开拍卖行时自动打开"
L["Only applies when the side tab is disabled."] = "仅在禁用侧边标签时生效。"
L["Close automatically when the Auction House closes"] = "关闭拍卖行时自动关闭"

-- Settings: Data page
L["Data Source"] = "数据来源"
L["unknown"] = "未知"
L["Updated"] = "更新时间"
L["PeaversConsumablesData not available"] = "PeaversConsumablesData 不可用"

-- Settings: Information page
L["Shows the best consumables, enchants, and gems for your current spec, sourced from Wowhead, and searches any of them on the Auction House with one click."] =
    "显示当前专精最佳的消耗品、附魔和宝石，数据来自 Wowhead，只需点击一次即可在拍卖行中搜索其中任意一项。"
L["toggle the consumables window"] = "开关消耗品窗口"
L["open the configuration panel"] = "打开设置面板"
L["Working the Auction House"] = "配合拍卖行使用"
L["Open the Auction House and the window appears alongside it automatically (this can be turned off in General). Click any item to search for it in the browse tab - no typing needed."] =
    "打开拍卖行后，窗口会自动出现在旁边（可在“常规”中关闭）。点击任意物品即可在浏览标签中搜索它，无需手动输入。"
L["Making it readable"] = "让文字更易读"
L["The Text tab sets the font, size, outline and shadow for this window. Rows and the window itself resize with the text, so larger sizes stay readable rather than clipping."] =
    "“文字”标签可设置本窗口的字体、字号、描边和阴影。行高与窗口会随文字一起缩放，因此放大字号后依然清晰，不会被截断。"
L["Where the data comes from"] = "数据从何而来"
L["Recommendations ship in the PeaversConsumablesData companion addon and refresh automatically with updates, so the lists track the current patch without manual imports."] =
    "推荐数据随 PeaversConsumablesData 配套插件一同发布，并会随更新自动刷新，因此列表始终跟随当前版本，无需手动导入。"

-- Data feed labels: category headers and the per-row slot tags, both supplied by
-- PeaversConsumablesData. Values added upstream before a translation lands here
-- fall back to English rather than disappearing.
L["Algari Diamond"] = "阿尔加钻石"
L["Augment Rune"] = "强化符文"
L["Augment Runes"] = "强化符文"
L["Belt"] = "腰带"
L["Boots"] = "靴子"
L["Both Weapons"] = "双武器"
L["Bracers"] = "护腕"
L["Chest"] = "胸甲"
L["Combat Potion"] = "战斗药水"
L["Dazzling Diamond"] = "炫目钻石"
L["Diamond"] = "钻石"
L["Diamond (one of)"] = "钻石（任选其一）"
L["Enchants"] = "附魔"
L["Eversong Diamond"] = "永歌钻石"
L["Feet"] = "脚"
L["Flask"] = "合剂"
L["Flasks"] = "合剂"
L["Food"] = "食物"
L["Food - Feast"] = "食物 - 宴会"
L["Food - Personal"] = "食物 - 个人"
L["Gems"] = "宝石"
L["Group Feast"] = "团队宴会"
L["Head"] = "头部"
L["Health Potion"] = "治疗药水"
L["Helm"] = "头盔"
L["Helmet"] = "头盔"
L["Invisiblity Potion"] = "隐形药水"
L["Legs"] = "腿部"
L["Main Hand"] = "主手"
L["Mana Potion"] = "法力药水"
L["Off Hand"] = "副手"
L["Other"] = "其他"
L["Other Gems"] = "其他宝石"
L["Personal Food"] = "个人食物"
L["Potions"] = "药水"
L["Ring"] = "戒指"
L["Rings"] = "戒指"
L["Shoulder"] = "肩部"
L["Shoulders"] = "肩部"
L["Stats Potion"] = "属性药水"
L["Tea"] = "茶"
L["Thalassian Diamond"] = "萨拉斯钻石"
L["Throughput Potion"] = "输出药水"
L["Weapon"] = "武器"
L["Weapon - Main Hand"] = "武器 - 主手"
L["Weapon - Off Hand"] = "武器 - 副手"
L["Weapon Buff"] = "武器增益"
L["Weapon Buff (Main hand)"] = "武器增益（主手）"
L["Weapon Buff (Off hand)"] = "武器增益（副手）"
L["Weapon Buffs"] = "武器增益"
L["Weapon Oil"] = "武器油"
L["Weapons (2h & Dual-Wield)"] = "武器（双手和双持）"

return L
