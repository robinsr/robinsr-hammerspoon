local putil  = require 'pl.utils'
local tables = require 'user.lua.lib.table'
local colors = require 'user.lua.ui.theme.mariana'

---@type HS.TextStyles
local console_text_styles = {
  font = {
    size = 13,
    name = 'JetBrainsMono Nerd Font Mono',
  },
}

hs.console.consoleFont(console_text_styles.font)
hs.console.maxOutputHistory(50000) -- sets max character count, not lines


local Console = {}


--
--
--
---@param is_dark_mode? boolean
function Console.configureHSConsole(is_dark_mode)
  -- hs.console.behavior(64)
  
  if is_dark_mode ~= nil then
    Console.setDarkMode(is_dark_mode)
  end
end


--
--
--
---@param is_dark_mode? boolean
function Console.setDarkMode(is_dark_mode)
  local print_color = putil.choose(is_dark_mode, colors.white, colors.black)
  hs.console.consolePrintColor(print_color)
  hs.console.darkMode(is_dark_mode)
  hs.preferencesDarkMode(is_dark_mode)
end

--
-- Prints a single static string message to the HS console. Supports:
--   - ANSI control characters
--   - StyledText
--
-- Usage:
--   console.print('[0m[35mPrint as is[0m 3')
--   console.print('Print as is', { color = colors.violet })
--
---@param msg string
---@param style? table If omitted, msg is styled with hs.styletext.anse
function Console.print(msg, style)
  local styledtxt
  
  if type(style) == 'nil' then
    styledtxt = hs.styledtext.ansi(msg, { font = console_text_styles.font })
  else
    local styles = tables.merge({}, console_text_styles, style)
    styledtxt = hs.styledtext.new(msg, styles)
  end
  hs.console.printStyledtext(styledtxt)
end



_G.console = {}

function _G.console.log(...)
  local args = table.pack(...)
  local msg = #args > 1 and hs.inspect(args) or hs.inspect(args[1])

  Console.print(msg, { color = colors.blue })
end



return Console