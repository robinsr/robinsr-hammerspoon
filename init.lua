PkgName = 'ryan-hs'

local lists  = require 'user.lua.lib.list'
local tabl   = require 'user.lua.lib.table'
local logger = require 'user.lua.util.logger'

local log = logger.new('user:init', 'debug')

log.i("Starting...")

local console = require 'user.lua.interface.console'

console.configureHSConsole()
console.setDarkMode(true)

local KS = require 'user.lua.state'


KS.commands = require 'user.lua.commands'.getCommands()


log.i("Setting global hotkeys")

KS.commands:forEach(function(cmd) 
  log.inspect(cmd, { depth = 3, metatables = true })
  cmd:bindHotkey()
end)

log.i("Setting up url handlers")
lists(KS.commands):forEach(function(cmd) cmd:bindURL() end)

log.i("Creating menubar item")
require('user.lua.interface.menubar').install(KS.commands)

log.i('Running onLoad commands')

local option = require 'user.lua.lib.optional'

local onLoad = option.ofNil(
  KS.commands:findById('KS.OnLoad'), 'No KS.OnLoad command found'
)

if onLoad:ispresent() then
  local loadCmdOK, loadCmd = pcall(onLoad:get().fn)

  if (not loadCmdOK) then
    log.e('Onload error')
    error(loadCmd)
  end
end

log.i('Init complete')

---@type hs.distributednotifications|nil
local nsDistNotes = hs.distributednotifications.new(function(name, object, userInfo)
  print(string.format("name: %s\nobject: %s\nuserInfo: %s\n", name, object, hs.inspect(userInfo)))
end)
if (nsDistNotes ~= nil) then
  nsDistNotes:start()
end


--- init_d app container WIP
-- local scanner = require 'user.lua.init_d'
-- local info = debug.getinfo(1, 'S')
-- local module_directory = string.match(info.source, '^@(.*)/')
-- local singles = scanner(module_directory.."/user/lua/adapters")
-- hs.loadSpoon('EmmyLua', true)
-- hs.loadSpoon('SpoonInstall', true)