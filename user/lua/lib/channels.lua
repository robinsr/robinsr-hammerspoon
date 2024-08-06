local inspect  = require 'inspect'
local Emitter  = require 'EventEmitter'
local params  = require 'user.lua.lib.params'
local strings  = require 'user.lua.lib.string'
local tables   = require 'user.lua.lib.table'
local types    = require 'user.lua.lib.typecheck'
local logr     = require 'user.lua.util.logger'

local log = logr.new('  --CHANNELS--  ', 'info')

local emitter = Emitter.new({ wildcard = true, delimiter = ':' })


---@class hs.events
local evts = {}

--
--
---@param channel string|string[]
---@param data table
function evts.publish(channel, data)
  assert(types.either(types.isString, types.isTable), 'Channel must be a string or string array')
  params.assert.tabl(data, 2)

  log.df('Publishing data on channel %s - %s',channel, inspect(data))

  emitter:emit(channel, data)
end


--
--
--
---@param channel string
---@param callback fun(data: table, channel: string): nil
function evts.subscribe(channel, callback)
  params.assert.string(channel, 1)
  params.assert.func(callback, 2)

  log.df('New sub to channel [%s] for module [%s]', channel, debug.getinfo(2).source)


  emitter:on(channel, function(self, event, data)
    log.df('Emitting on channel %s: %s', channel, inspect(data))
    callback(data, event)
  end)
end

return evts



--[[
2024-08-04 19:49:57: {
  addListener = <function 1>,
  emit = <function 2>,
  many = <function 3>,
  manyAny = <function 4>,
  off = <function 5>,
  offAny = <function 6>,
  on = <function 7>,
  onAny = <function 8>,
  once = <function 9>,
  onceAny = <function 10>,
  removeAllListeners = <function 11>,
  removeListener = <function 12>
}

thing:on('resize', function(self, event, w, h)
  print(self, ("Resized %dx%d"):format(w, h))
end)

thing:emit('resize', 125, 250)

]]
