local colors   = require 'user.lua.ui.color'
local logr     = require 'user.lua.util.logger'

local log = logr.new('Console', 'error')

local console = {}

function console.configureHSConsole()
  log.i("Configuring hammerspoon console")
  local console_font = { 
    size = 16,
    name = 'JetBrainsMono Nerd Font Mono'
  }
  
  -- hs.console.clearConsole()
  hs.console.consoleFont(console_font)
  hs.console.maxOutputHistory(50000) -- sets max character count, not lines
end


function console.setDarkMode(isDark)
  log.i("Setting console dark mode:", isDark)

  if (isDark) then
    hs.console.consolePrintColor(colors.lightgrey)
  else
    hs.console.consolePrintColor(colors.darkgrey)
  end
  
  hs.console.darkMode(isDark)
  hs.preferencesDarkMode(isDark)
end

return console
