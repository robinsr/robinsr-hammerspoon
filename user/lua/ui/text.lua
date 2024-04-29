local ui = require 'user.lua.ui'


local text = {}

-- Utility for creating HS StyledText 
--
---@see hs.styledtext (https://www.hammerspoon.org/docs/hs.styledtext.html)
-- 
---@param text string
---@param fontSize integer
---@return hs.styledtext
function text.styleText(text, fontSize)
  local style = { 
    color = { hex = ui.colors.white }, 
    font = { size = fontSize }
  }

  return hs.styledtext.new(text, style) --[[@as hs.styledtext]]
end

return text