PkgName = 'ryan-hs'

local logger = require 'user.lua.util.logger'
local tabl = require 'user.lua.lib.table'

local log = logger.new('user:init', 'debug')

log.i("Starting...")

local console = require 'user.lua.interface.console'

console.configureHSConsole()
console.setDarkMode(true)

require 'user.lua.state'


local commands = require 'user.lua.commands'.getCommands()

log.i("Setting global hotkeys")
require('user.lua.interface.hotkeys').bindall(commands)

log.i("Setting up url handlers")
require('user.lua.interface.url-handler').bindall(commands)

log.i("Creating menubar item")
require('user.lua.interface.menubar').install(commands)

log.i('Running onLoad commands')

local option = require 'user.lua.lib.optional'

local onLoad = option.ofNil(
  commands:findById('KS.OnLoad'), 'No KS.OnLoad command found'
)

if onLoad:ispresent() then
  local loadCmdOK, loadCmd = pcall(onLoad:get().fn)

  if (not loadCmdOK) then
    log.e('Onload error')
    error(loadCmd)
  end
end

log.i('Init complete')


--- init_d app container WIP
-- local scanner = require 'user.lua.init_d'
-- local info = debug.getinfo(1, 'S')
-- local module_directory = string.match(info.source, '^@(.*)/')
-- local singles = scanner(module_directory.."/user/lua/adapters")
-- hs.loadSpoon('EmmyLua', true)
-- hs.loadSpoon('SpoonInstall', true)