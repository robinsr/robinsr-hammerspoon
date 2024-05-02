local M      = require 'moses'
local yabai  = require 'user.lua.adapters.yabai'
local alert  = require 'user.lua.interface.alert'
local List   = require 'user.lua.lib.list'
local spaces = require 'user.lua.modules.spaces'
local apps   = require 'user.lua.modules.apps'
local ui     = require 'user.lua.ui'
local util   = require 'user.lua.util'

local log = util.log('user:commands', 'debug')

---@class HasId
---@field id string

---@class CommandCtx
---@field trigger 'hotkey'|'menubar' Source invoking the command

---@class CommandHotKey
---@field mods "hyper" | "meh" | "bar" | "modA" | "modB" | "shift" | "alt" | "ctrl" | "cmd"
---@field key string
---@field message? string Alert message to show. Passing an empty string will just show keys, "title" will copy command title as message, nil will disable message
---@field on? ("pressed" | "released" | "repeat")[]

---@param params table
---@return CommandHotKey
local function hotkey(params)
  return {
    mods = params[1],
    key = params[2],
    message = params[3],
    on = util.default(params[4], { "pressed" })
  }
end


---@class Command
---@field id string Unique string to identify command
---@field fn fun(ctx: table, params: table): nil A callback function for the command
---@field title? string
---@field menubar? { [1]: string, [2]: string|nil, [3]: hs.image|nil }
---@field hotkey? CommandHotKey
---@field url? string A hammerspoon url to bind to

---@type Command[]
local command_list = {
  {
    id = 'onLoad',
    fn = function(ctx, params)
      apps.onLoad()
      KittySupreme.services.sketchybar.onLoad('Hammerspoon loaded!')
    end,
  },
  {
    id = 'spaces-cycle-layout',
    title = "Space → Cycle Layout",
    hotkey = hotkey{ "modA", "space" },
    menubar = { "general", "y", ui.icons.code },
    fn = function(ctx)
      local layout = spaces.cycleLayout()

      alert.showf("Changed layout to %s", { layout })
    end,
  },
  { 
    id = 'show-console',
    title = "Show console",
    menubar = { "general", "i", ui.icons.code },
    fn = function()
      hs.openConsole(true)
    end,
  },
  {
    id = 'reload',
    title = "Reload KittySupreme",
    menubar = { "general", "w", ui.icons.reload },
    hotkey = hotkey({ "bar", "W", "title" }),
    fn = function(ctx)
      util.delay(0.75, hs.reload)
    end,
  },
  {
    id = 'restart-yabai',
    title = "Restarting yabai...",
    menubar = nil,
    hotkey = hotkey({ "bar", "Y", "title" }),
    fn = function (ctx)
      if (ctx.hotkey) then
        hs.alert.show(ctx.title)
      end
      yabai:restart()
    end,
  },
  {
    id = 'rename-space',
    title = "Label current space",
    menubar = { "desktop", "L", ui.icons.tag },
    -- hotkey = hotkey({ "bar", "L", "title", { "released"} }),
    hotkey = hotkey({ "bar", "L", nil, { "released"} }),
    fn = spaces.rename,
  },
  { 
    id = "float-active",
    title = "Float active window",
    menubar = { "desktop", nil, ui.icons.float },
    hotkey = nil,
    fn = function ()
      yabai:floatActiveWindow()
    end
  },
  {
    id = 'space-change',
    url = "spaces.changed",
    menubar = nil,
    hotkey = nil,
    fn = function(ctx, params)
      spaces.onSpaceChange(params)
    end,
  },
  {
    id = 'space-create',
    url = "spaces.created",
    menubar = nil,
    hotkey = nil,
    fn = function(ctx, params)
      spaces.onSpaceCreated(params)
    end,
  },
  {
    id = 'space-destroyed',
    url = "spaces.destroyed",
    menubar = nil,
    hotkey = nil,
    fn = function(ctx, params)
      spaces.onSpaceDestroyed(params)
    end,
  },
  {
    id = 'show-active-app-shortcuts',
    title = 'Show Keys for active app',
    menubar = { "general", nil, ui.icons.command },
    hotkey = hotkey({ "bar", "K", "title" }),
    fn = function(ctx, params)
      apps.getMenusForActiveApp()
    end,
  },
}

-- local Commands = List:new(command_list)
-- return Commands
return List:new(command_list)
