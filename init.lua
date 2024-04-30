PkgName = 'ryan-hs'

local logger = require 'user.lua.util.logger'
local log = logger.new('user:init', 'debug')

log.i("Starting...")


local console = require 'user.lua.interface.console'

console.configureHSConsole()
console.setDarkMode(true)

local globalstate = require 'user.lua.state'
local commands = require 'user.lua.commands'

-- log.inspect(commands)

log.i("Setting global hotkeys")
KittySupreme.boundkeys = require('user.lua.interface.hotkeys').bindall(commands)

log.i("Setting up url handlers")
KittySupreme.urlhanders = require('user.lua.interface.url-handler').bindall(commands)

log.i("Creating menubar item")
KittySupreme.menbar = require('user.lua.interface.menubar').installMenuBar(commands)

log.i('Running onLoad commands')

local onLoad = commands:findById('onLoad')

local onLoadErr, onLoadR = pcall(onLoad.fn)

log.inspect(onLoadErr)
log.inspect(onLoadR)


log.i('Init complete')

log.inspect(KittySupreme, { depth = 3 })


--- init_d app container WIP
-- local scanner = require 'user.lua.init_d'
-- local info = debug.getinfo(1, 'S')
-- local module_directory = string.match(info.source, '^@(.*)/')
-- local singles = scanner(module_directory.."/user/lua/adapters")
-- hs.loadSpoon('EmmyLua', true)
-- hs.loadSpoon('SpoonInstall', true)