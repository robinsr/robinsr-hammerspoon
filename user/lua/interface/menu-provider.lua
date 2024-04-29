local class   = require 'middleclass'
local M       = require 'moses'
local ui      = require 'user.lua.ui'
local symbols = require 'user.lua.ui.symbols'
local util    = require 'user.lua.util'
local fmt     = require 'user.lua.util.fmt'

local MenuItem = class('MenuItem')

function MenuItem.initialize()
  self.type = 'select' -- 'checkbox', 'radio', 'text'? (based on html's input types)
end

local MenuProvider = class('MenuProvider')

function MenuProvider.getMenus()
  return {}
end

local ServiceMenuProvider = class('ServiceMenuProvider', MenuProvider)

function ServiceMenuProvider.initialize(name)
  self.name = name
end

function ServiceMenuProvider.getMenus()
  function serviceMenuProps(service)
    if (service.pid) then
      return "on" , "("..service.pid..")"
    else
      return "off", "(?)"
    end
  end
  
  return M.chain(services)
    :map(function(i, service)
      local state, text = serviceMenuProps(service)

      return {
        title = fmt("%s %s", service.name, text),
        state = state,
        onStateImage = icons.running,
        offStateImage = icons.stopped,
        mixedStateImage = icons.unknown,
        menu = {
          { 
            title = fmt("Start %s", service.name),
            fn = function()
              service:start()
            end
          },
          { 
            title = fmt("Stop %s", service.name),
            fn = function()
              service:stop()
            end
          },
          { 
            title = fmt("Restart %s", service.name),
            fn = function()
              service:restart()
            end
          },
        }
      }
    end)
    :value()
end