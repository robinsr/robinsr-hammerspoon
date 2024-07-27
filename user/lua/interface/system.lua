local plutils    = require 'pl.utils'
local syswatcher = require 'hs.caffeinate.watcher'
local logr       = require 'user.lua.util.logger'

local log = logr.new('system', 'debug')


-- require('hs.ipc')
-- hs.ipc.cliInstall('/opt/homebrew')

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


--[[
This version of hs leverages functionality added to hs.ipc in Hammerspoon
version 0.9.55 to allow the creation of additional message ports. As such 
raw mode and custom handlers have been removed; use -m name and your own 
callback with hs.ipc.localPort if you require a custom handler.
]]

function Sys.registerIPC(method, fn)
  
  local ipc_port = hs.ipc.localPort(method, fn) --[[@as hs.ipc]]

  local ipc_stat = {
    name = ipc_port:name(),
    valid = ipc_port:isValid(),
    remote = ipc_port:isRemote(),
  }

  log.f("Registered new IPC handler %s", hs.inspect(ipc_stat))

  -- local ipc_remote = hs.ipc.remotePort(method) --[[@as hs.ipc]]
  -- local ok, response = ipc_remote:sendMessage('test data', os.time(), 1)
  -- if not ok then
  --   error(('ipc error: %s'):format(response))
  -- else
  --   log.f('ipc test message response: %s', response)
  -- end

  return ipc_port
end


--
-- Registers a URL handler - `open -g "hammerspoon://<path>"`
--
function Sys.registerURL(path, fn)
  require('hs.ipc')
  
  hs.urlevent.bind(path, fn)
end


--
-- Registers a globally-invocable function - `hs -c 'KittySupreme:<name>()'
--
function Sys.registerGlobal(name, fn)
  _G.KSGlobals = _G.KSGlobals or {}
  _G.KSGlobals[name] = fn
end


return Sys