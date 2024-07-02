_G.PkgName = 'ryan-hs'

_G.clear = function() 
  hs.console.clearConsole()
  hs.reload()
end

-- redefined in user.lua.interface.console
-- leave in cases of debugging failed start-ups
_G.console = {
  log = function(...)
    local args = table.pack(...)
    return hs.printf("%s", #args > 1 and hs.inspect(args) or hs.inspect(args[1]))
  end
}

local util = require 'user.lua.util.init'

print(string.rep('-', 40))
print(string.rep('-', 15), util.date_str(), string.rep('-', 15))
print(string.rep('-', 40))

local lists  = require 'user.lua.lib.list'
local tabl   = require 'user.lua.lib.table'
local logger = require 'user.lua.util.logger'

local log = logger.new('user:init', 'debug')

log.i("Starting...")

local console = require 'user.lua.interface.console'
local desk    = require 'user.lua.interface.desktop'

console.configureHSConsole()
console.setDarkMode(desk.darkMode())

local KS = require 'user.lua.state'


KS.commands = require 'user.lua.commands'.getCommands()


log.i("Setting global hotkeys")

KS.commands:forEach(function(cmd) 
  cmd:bindHotkey()
end)

log.i("Setting up url handlers")
lists(KS.commands):forEach(function(cmd) cmd:bindURL() end)

log.i("Creating menubar item")
require('user.lua.interface.menubar').install()

log.i('Running onLoad commands')

local post_loaded_cmd = KS.commands:first(function(cmd)
  return cmd.id == "ks.evt.onLoad"
end)

if post_loaded_cmd then
  local loadCmdOK, loadCmd = pcall(function() post_loaded_cmd:exec('load', {}) end)

  if (not loadCmdOK) then
    log.e('Onload error')
    error(loadCmd)
  end
end

log.i('Init complete')

---@type hs.distributednotifications|nil
local nsDistNotes = hs.distributednotifications.new(function(name, object, userInfo)
  print('[distributednotifications] ...')
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