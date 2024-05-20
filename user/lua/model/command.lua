local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local logr    = require 'user.lua.util.logger'

local log = logr.new('Command', 'info')


---@class Command
---@field id string Unique string to identify command
---@field fn fun(ctx: table, params: table): string|nil A callback function for the command, optionally returning an alert string
---@field title? string
---@field menubar? CommandMenu
---@field hotkey? CommandHotKey
---@field url? string A hammerspoon url to bind to

---@class CommandCtx
---@field trigger 'hotkey'|'menubar' Source invoking the command

---@class CommandHotKey
---@field mods "hyper" | "meh" | "bar" | "modA" | "modB" | "shift" | "alt" | "ctrl" | "cmd"
---@field key string
---@field message? string Alert message to show. Passing an empty string will just show keys, "title" will copy command title as message, nil will disable message
---@field on? ("pressed" | "released" | "repeat")[]

local allowed_mods = { "hyper", "meh", "bar", "modA", "modB", "shift", "alt", "ctrl", "cmd" }


--
-- Returns a Hotkey configuration
--
---@params mods "hyper" | "meh" | "bar" | "modA" | "modB" | "shift" | "alt" | "ctrl" | "cmd"
---@params key string
---@params message? string Alert message to show. Passing an empty string will just show keys, "title" will copy command title as message, nil will disable message
---@params on? ("pressed" | "released" | "repeat")[]
---@return CommandHotKey
local function hotkey(mods, key, message, on)
  if not tables.contains(allowed_mods, mods) then
    log.ef("Hotkey mods '%s' not allowed", mods)
  end


  return {
    mods = mods,
    key = key,
    message = message,
    on = params.default(on, { "pressed" })
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


return {
  hotkey = hotkey,
  menubar = menubar,
}