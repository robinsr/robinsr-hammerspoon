local putil  = require 'pl.utils'
local colors = require 'user.lua.ui.mariana'

---@type HS.StyledText
local console_font = { 
  size = 16,
  name = 'JetBrainsMono Nerd Font Mono'
}

hs.console.consoleFont(console_font)
hs.console.maxOutputHistory(50000) -- sets max character count, not lines


local console = {}

function console.configureHSConsole()
  -- log.i("Configuring hammerspoon console")
  -- hs.console.clearConsole()
end


function console.setDarkMode(isDark)
  local print_color = putil.choose(isDark, colors.chateau, colors.bunker)
  hs.console.consolePrintColor(print_color)
  hs.console.darkMode(isDark)
  hs.preferencesDarkMode(isDark)
end


function console.print(msg)
  hs.console.printStyledtext(hs.styledtext.ansi(msg, { font = console_font }))
end

return console
