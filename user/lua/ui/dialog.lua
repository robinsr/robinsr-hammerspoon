local hsdialog = require 'hs.dialog'
local webview  = require 'user.lua.ui.webview'
local U        = require 'user.lua.util'

local log = U.log('dialog', 'debug')

local D = {}

function D.showText()
  -- todo
end

local webviewOpts = {
  developerExtrasEnabled = true,
}

return D

--[[
Window Behaviors

canJoinAllSpaces = 1,
default = 0,
fullScreenAllowsTiling = 2048,
fullScreenAuxiliary = 256,
fullScreenDisallowsTiling = 4096,
fullScreenPrimary = 128,
ignoresCycle = 64,
managed = 4,
moveToActiveSpace = 2,
participatesInCycle = 32,
stationary = 16,
transient = 8

]]