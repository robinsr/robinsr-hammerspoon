local plutils    = require 'pl.utils'
local syswatcher = require 'hs.caffeinate.watcher'
local logr       = require 'user.lua.util.logger'

local log = logr.new('system', 'debug')

local Sys = {}


---@enum HS.SystemEvent
Sys.sysevents = {
  [0] = 'didWake',
  [1] = 'willSleep',
  [2] = 'willPowerOff',
  [3] = 'screensDidSleep',
  [4] = 'screensDidWake',
  [5] = 'sessionDidResignActive',
  [6] = 'sessionDidBecomeActive',
  [7] = 'screensaverDidStart',
  [8] = 'screensaverWillStop',
  [9] = 'screensaverDidStop',
  [10] = 'screensDidLock',
  [11] = 'screensDidUnlock',
}


--
-- Register new caffeinate watcher
--
---@param fn fun(evt: HS.SystemEvent): nil
---@return hs.caffeinate.watcher
function Sys.onEvent(fn)

  local handler = function(evt)
    local event = Sys.sysevents[evt]

    log.i('System watcher event: ', hs.inspect({ evt, event }))

    local ok, err = pcall(fn, event)

    if not ok then
      error(err or 'Sys.onEvent callback error')
    end
  end

  return syswatcher.new(handler):start()
end


return Sys