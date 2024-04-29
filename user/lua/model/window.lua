local class = require 'middleclass'
local yabai = require 'user.lua.adapters.yabai'


---
--- Class for storing state about touched windows
---

local YabaiWindow = class('YabaiWindow')

function YabaiWindow:initialize(hsWindow)
  self.hsWindow = hsWindow
end

function YabaiWindow.toggleMaximize()
  local id = self.hsWindow:id()

  yabai.window.toggle.maximize(id)
end

return YabaiWindow
