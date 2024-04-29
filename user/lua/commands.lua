local M      = require 'moses'
local yabai  = require 'user.lua.adapters.yabai'
local spaces = require 'user.lua.modules.spaces'
local apps   = require 'user.lua.modules.apps'
local ui     = require 'user.lua.ui'
local util   = require 'user.lua.util'

local log = util.log('user:commands', 'debug')


---@class FilterList
local FilterList = {}


---@param list Command[] List of commands to search
function FilterList:new(list)
  o = list or {}
  setmetatable(o, self)
  self.__index = self
  return o
end


--
-- Does this filter commands?
-- todo; figure out how generics are annotated
--
---@param id string String to match against command's id field
---@return Command|nil
function FilterList:find(id)
  for k, cmd in ipairs(self) do
    if (cmd.id == id) then
      return cmd
    end
  end

  return nil
end




---@class Command: FilterList
---@field id string Unique string to identify command
---@field title? string
---@field menubar? table
---@field hotkey? table
---@field fn fun(ctx: table, params: table): nil A callback function for the command

---@type Command[]
local command_list = {
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
    hotkey = { "bar", "W" },
    fn = function(ctx)
      util.delay(0.75, hs.reload)
    end,
  },
  {
    id = 'restart-yabai',
    title = "Restarting yabai...",
    menubar = nil,
    hotkey = { "bar", "Y" },
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
    hotkey = { "bar", "L" },
    fn = function (ctx)
      spaces.rename()
    end,
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
    menubar = { "general", nil, ui.icons.unknown },
    hotkey = { "bar", "K" },
    fn = function(ctx, params)
      apps.getMenusForActiveApp()
    end,
  },
  {
    id = 'onLoad',
    fn = function(ctx, params)
      apps.onLoad()
    end,
  }
}

local Commands = FilterList:new(command_list)

return Commands