local plutil  = require 'pl.utils'
local sh      = require 'user.lua.adapters.shell'
local fs      = require 'user.lua.lib.fs'
local json    = require 'user.lua.lib.json'
local lists   = require 'user.lua.lib.list'
local paths   = require 'user.lua.lib.path'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local logr    = require 'user.lua.util.logger'

local strio = require 'pl.stringio'


---@class ShellProg
---@field name string
---@field options ShellOption[]
---@field subcommands SubCommand[]


---@class SubCommand
---@field program string
---@field name type
---@field args ShellOption[]
-- -@field args { [string]: any }

---@class ShellOption
---@field name type
---@field value string
---@field format string


---@class ShellOption
local shellarg = {}


---@class SubCommand
local subcommand = {}

function subcommand:new()

end


---@return string
function subcommand:torcstring()
  local rcstring = strio.create()

  lists(self.args):forEach(function(arg)
    ---@cast arg ShellOption
    rcstring:write(sh.kv(arg.name, arg.value, arg.format or '  ='))
  end):join(' ')
  
  -- for argk, argv in tables.entries(self.args) do
  --   rcstring:write(sh.kv(argk, argv))
  -- end

  return rcstring:value()
end


return subcommand


--[[

example command "yabai -m rule --add app="^Alfred.*$" manage=off"


program
  name = yabai
  options = {}
  subcommands = {
    {
      name = message
      flags = { m, message }
      subcommands = {
        { 
          name = 'config'
          flags = { nil, nil }
          options {
            {
              name = 'config-space'
              flags = { nil, 'space' }
            }
          }
          args = {
            {
              key = { 'auto_balance', 'split_ratio' } --etc 
              format = "%1 %2"
              -- format = "%1=%2"
              -- format = "--%1 %2"
              -- or
              separator = ' '
              separator = '='
            }
          }
        },
        { 
          name = display
        },
        { 
          name = space
        },
        { 
          name = window
        },
        { 
          name = query
        },
        { 
          name = rule
        },
        { 
          name = signal
        },
  
      }
    },
  }



]]