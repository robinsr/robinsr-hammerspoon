local tables = require 'user.lua.lib.table'
local colors = require 'user.lua.ui.color'
local text   = require 'user.lua.ui.text'

local choices = {
{
 ["text"] = "First Choice",
 ["subText"] = "This is the subtext of the first choice",
 ["uuid"] = "0001"
},
{ ["text"] = "Second Option",
  ["subText"] = "I wonder what I should type here?",
  ["uuid"] = "Bbbb"
},
{ ["text"] = hs.styledtext.new("Third Possibility", {font={size=18}, color=hs.drawing.color.definedCollections.hammerspoon.green}),
  ["subText"] = "What a lot of choosing there is going on here!",
  ["uuid"] = "III3"
},
}

-- Notes:
--  * The table of choices (be it provided statically, or returned by the callback) must
--    contain at least the following keys for each choice:
--   * text - A string or hs.styledtext object that will be shown as the main text of
--     the choice
--  * Each choice may also optionally contain the following keys:
--   * subText - A string or hs.styledtext object that will be shown underneath the main
--     text of the choice
--   * image - An `hs.image` image object that will be displayed next to the choice
--   * valid - A boolean that defaults to `true`, if set to `false` selecting the choice
--     will invoke the `invalidCallback` method instead of dismissing the chooser
--  * Any other keys/values in each choice table will be retained by the chooser and
--    returned to the completion callback when a choice is made. This is useful for
--    storing UUIDs or other non-user-facing information, however, it is important to
--    note that you should not store userdata objects in the table - it is run through
--    internal conversion functions, so only basic Lua types should be stored.
--  * If a function is given, it will be called once, when the chooser window is
--    displayed. The results are then cached until this method is called again, or
--    `hs.chooser:refreshChoicesCallback()` is called.
--  * If you're using a hs.styledtext object for text or subText choices, make sure you
--    specify a color, otherwise your text could appear transparent depending on the
--    bgDark setting.



local Chooser = {}


Chooser.styles = {}

---@type HS.TextStyles
Chooser.styles.mainText = {
  color = colors.yellow,
  font = {
    size = 18,
  }
}

---@type HS.TextStyles
Chooser.styles.subText = {
  -- color = colors.yellow,
  font = {
    size = 12,
  }
}

---@type HS.TextStyles
Chooser.styles.subTextMono = tables.merge(Chooser.styles.subText, text.styles.monoText)


---@param val string
---@return hs.styledtext
function Chooser.mainText(val)
  return text.new(val, Chooser.styles.mainText)
end


---@param val string
---@return hs.styledtext
function Chooser.subText(val)
  return text.new(val, Chooser.styles.subText)
end


---@param val string
---@return hs.styledtext
function Chooser.subTextMono(val)
  return text.new(val, Chooser.styles.subTextMono)
end


return Chooser