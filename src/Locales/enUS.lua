--[[ Locales/enUS.lua
  Localization table (PC.L), loaded before every consumer.

  PeaversConsumables uses the gettext-style "English-as-key" convention: call sites
  read L["Some English text"] and the default (enUS) locale returns the key verbatim.
  This keeps the source readable and means a missing translation can never render a
  blank or raise an error - it simply falls back to the English source string.

  That fallback also covers strings this addon does not own: category and slot labels
  arrive from the PeaversConsumablesData feed, so a value added upstream before its
  translation lands still displays in English rather than disappearing.

  To translate, copy this file (e.g. to deDE.lua), guard it with
      if GetLocale() ~= "deDE" then return end
  (.toc files have no conditionals, so every locale file is loaded and self-guards),
  add it to the .toc after this one, and fill in values:
      L["Food"] = "Nahrung"
  Only the strings a locale overrides need listing; everything else falls back.
]]

local addonName, PC = ...

-- Identity fallback: an unset key returns itself (the English source string).
local L = setmetatable({}, { __index = function(_, k) return k end })
PC.L = L

-- enUS is the source language, so no overrides are required here. Translators add
-- their own locale files that set L["<English source>"] = "<translation>".

return L
