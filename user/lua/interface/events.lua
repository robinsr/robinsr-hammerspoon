local func   = require 'user.lua.lib.func'
local params = require 'user.lua.lib.params'
local tables = require 'user.lua.lib.table'

local log = require('user.lua.util.logger').new('events', 'debug')

---@alias ks.events.type
---|'nullEvent'
---|'leftMouseDown'
---|'leftMouseUp'
---|'rightMouseDown'
---|'rightMouseUp'
---|'mouseMoved'
---|'leftMouseDragged'
---|'rightMouseDragged'
---|'keyDown'
---|'keyUp'
---|'flagsChanged'
---|'scrollWheel'
---|'tabletPointer'
---|'tabletProximity'
---|'otherMouseDown'
---|'otherMouseUp'
---|'otherMouseDragged'


---@alias ks.events.callback fun(evt: hs.eventtap.event): nil


---@class ks.events
local events = {}

---@type { [string]: number }
events.types = hs.eventtap.event.types

-- "true if the event should be deleted"
events.blockNext = true
-- "false if it should propagate to any other applications watching for that event"
events.allowNext = false



---@param types number[]
---@param callback ks.events.callback
---@return hs.eventtap
function events.newTap(types, callback)
  return hs.eventtap.new(types, callback) --[[@as hs.eventtap]]
end


---@param callback ks.events.callback
---@return hs.eventtap
function events.newKeyDownTap(callback)
  return hs.eventtap.new({ events.types.keyDown }, callback) --[[@as hs.eventtap]]
end


---@param code string
---@return bool
function events.verifyKeycode(code)
  return tables(hs.keycodes.map):has(code)
end


---@param code string
---@return number
function events.getKeycode(code)
  return tables(hs.keycodes.map):get(code)
end


---@param evt     hs.eventtap.event
---@param keycode string
---@return boolean
function events.isKey(evt, keycode)
  if not events.verifyKeycode(keycode) then
    error(('Invalid keycode: %s'):format(keycode))
  end

  return evt:getKeyCode() == hs.keycodes.map[keycode]
end


return events