local Mediator = require "mediator"
local strings = require 'user.lua.lib.string'
local func    = require 'user.lua.lib.func'


mediator = Mediator()


---@class hs.events
local evts = {}


--
--
--
function evts.publish(channel, data)
  if type(channel) == 'string' then
    channel = strings(channel):split(':')
  end

  mediator:publish(channel, data)
end


--
--
--
function evts.subscribe(channel, fn)
  if type(channel) == 'string' then
    channel = strings(channel):split(':')
  end

  mediator:subscribe(channel, func.bind(fn, strings.join(channel, ':')))
end


--
--
--
function evts.remove(channel)
  if type(channel) == 'string' then
    channel = strings(channel):split(':')
  end

  mediator:remove(channel)
end


return evts