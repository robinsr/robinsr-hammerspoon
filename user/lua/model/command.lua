local U = require 'user.lua.util'

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

local mods = { "hyper", "meh", "bar", "modA", "modB", "shift", "alt", "ctrl", "cmd" }

---@param params table
---@return CommandHotKey
local function hotkey(params)
  if not U.contains(mods, params[1]) then
    error(U.fmt("Invalid value for hotkey 'mods': %s", hs.inspect(params)))
  end

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


return {
  hotkey = hotkey,
  menubar = menubar,
}