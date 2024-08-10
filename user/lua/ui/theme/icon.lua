local base = require 'user.lua.ui.theme.colorbase'

---@type ks.theme
local theme = {
  name = "MacOS Icon Theme",
  red = {
    -- name  = "Carnation",
    -- hex   = "#fa5352",
    red   = 0.97911924,
    green = 0.3238641,
    blue  = 0.32278943,
    alpha = 1,
  },
  violet = {
    -- name  = "Lavender",
    -- hex   = "#cc5de8",
    red   = 0.79932541,
    green = 0.36294571,
    blue  = 0.90982467,
    alpha = 1,
  },
  darkblue = {
    -- name  = "Cornflower Blue",
    -- hex   = "#5d7cfa",
    red   = 0.36278126,
    green = 0.48584139,
    blue  = 0.98091358,
    alpha = 1,
  },
  blue = {
    -- name  = "Picton Blue",
    -- hex   = "#339af0",
    red   = 0.19869339,
    green = 0.6043641,
    blue  = 0.93983543,
    alpha = 1,
  },
  teal = {
    -- name  = "Mountain Meadow",
    -- hex   = "#1ec997",
    red   = 0.1184508,
    green = 0.78798324,
    blue  = 0.591093,
    alpha = 1,
  },
  green = {
    -- name  = "Atlantis",
    -- hex   = "#94d82d",
    red   = 0.58149654,
    green = 0.84631032,
    blue  = 0.17491421,
    alpha = 1,
  },
  yellow = {
    -- name  = "Lightning Yellow",
    -- hex   = "#fcc418",
    red   = 0.98709089,
    green = 0.76783949,
    blue  = 0.09448441,
    alpha = 1,
  },
  darkgrey = {
    red   = 1,
    green = 1,
    blue  = 1,
    alpha = 0,
  },
  gray = {
    red   = 1,
    green = 1,
    blue  = 1,
    alpha = 0,
  },
  lightgrey = {
    red   = 1,
    green = 1,
    blue  = 1,
    alpha = 0,
  },
  orange = {
    red   = 1,
    green = 1,
    blue  = 1,
    alpha = 0,
  },
  black    = base.black,
  white    = base.white,
  disabled = base.disabled,

}

return theme