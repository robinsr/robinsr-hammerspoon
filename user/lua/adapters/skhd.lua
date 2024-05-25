local LaunchAgent = require 'user.lua.adapters.base.launchagent'
local shell       = require 'user.lua.interface.shell'
local proto       = require 'user.lua.lib.proto'
local logr        = require 'user.lua.util.logger'

local log = logr.new('skhd', 'debug')

-- Get plist with: launchctl print gui/501/com.koekeishiya.yabai


---@class SKHD: LaunchAgent
local SKHD = {}

function SKHD:new()
  local this = LaunchAgent.new({}, 'skhd', 'com.koekeishiya.skhd')

  return proto.setProtoOf(this, SKHD)
end

function SKHD:start()
  log.i('Starting SKHD...')
  return shell.run("skhd --start-service")
end


function SKHD:stop()
  log.i('Stopping SKHD...')
  return shell.run("skhd --stop-service")
end


function SKHD:restart()
  log.i('Restarting SKHD...')
  return shell.run("skhd --restart-service")
end

return proto.setProtoOf(SKHD, LaunchAgent)