local M      = require 'moses'
local yabai  = require 'user.lua.adapters.yabai'
local alert  = require 'user.lua.interface.alert'
local Set    = require 'user.lua.lib.set'
local spaces = require 'user.lua.modules.spaces'
local apps   = require 'user.lua.modules.apps'
local ui     = require 'user.lua.ui'
local U      = require 'user.lua.util'

local log = U.log('user:commands', 'debug')


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
    on = U.default(params[4], { "pressed" })
  }
end


---@class CommandMenu
---@field section string
---@field key? string
---@field icon? hs.image

---@param params table
---@return CommandMenu
local function menubar(params)
  return {
    section = params[1],
    key = params[2],
    icon = params[3],
  }
end


---@class Command
---@field id string Unique string to identify command
---@field fn fun(ctx: table, params: table): string|nil A callback function for the command, optionally returning an alert string
---@field title? string
---@field menubar? CommandMenu
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
    menubar = menubar{ "general", "y", ui.icons.code },
    fn = function(ctx)
      local layout = spaces.cycleLayout()
      return U.fmt("Changed layout to %s", layout)
    end,
  },
  { 
    id = 'show-console',
    title = "Show console",
    menubar = menubar{ "general", "i", ui.icons.code },
    hotkey = hotkey{ "bar", "I" },
    fn = function()
      hs.openConsole(true)
    end,
  },
  {
    id = 'reload',
    title = "Reload KittySupreme",
    menubar = menubar{ "general", "w", ui.icons.reload },
    hotkey = hotkey{ "bar", "W", "Reload KittySupreme" },
    fn = function(ctx)
      U.delay(0.75, hs.reload)
    end,
  },
  {
    id = 'restart-yabai',
    title = "Restart Yabai",
    menubar = nil,
    hotkey = hotkey{ "bar", "Y" },
    fn = function (ctx)
      yabai:restart()
      
      if (ctx.trigger == 'hotkey') then
        return U.fmt('%s: %s', ctx.hotkey, ctx.title)
      end
    end,
  },
  {
    id = 'rename-space',
    title = "Label current space",
    menubar = menubar{ "desktop", "L", ui.icons.tag },
    hotkey = hotkey{ "bar", "L" },
    fn = function(ctx)
      spaces.rename()

      if (ctx.trigger == 'hotkey') then
        return U.fmt('%s: %s', ctx.hotkey, ctx.title)
      end
    end,
  },
  { 
    id = "float-active",
    title = "Float active window",
    menubar = menubar{ "desktop", nil, ui.icons.float },
    fn = function (ctx)
      yabai:floatActiveWindow()

      if ctx.hotkey then return ctx.title end
    end
  },
  {
    id = 'space-change',
    url = "spaces.changed",
    fn = function(ctx, params)
      spaces.onSpaceChange(params)
    end,
  },
  {
    id = 'space-create',
    url = "spaces.created",
    fn = function(ctx, params)
      spaces.onSpaceCreated(params)
    end,
  },
  {
    id = 'space-destroyed',
    url = "spaces.destroyed",
    fn = function(ctx, params)
      spaces.onSpaceDestroyed(params)
    end,
  },
  {
    id = 'show-active-app-shortcuts',
    title = 'Show Keys for active app',
    menubar = menubar{ "general", nil, ui.icons.command },
    hotkey = hotkey({ "bar", "K", "title" }),
    fn = function(ctx, params)
      apps.getMenusForActiveApp()
    end,
  },
}

return {
  getCommands = function()
    return Set:new(command_list)
    -- return lol
  end
} 

