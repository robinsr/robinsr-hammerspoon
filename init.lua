_G.PkgName = 'ryan-hs'
_G.UpTime = os.time()

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

local time = require 'user.lua.lib.time'

print(string.rep('-', 40))
print(string.rep('-', 15), time.fmt(), string.rep('-', 15))
print(string.rep('-', 40))

require('hs.ipc')

local lists  = require 'user.lua.lib.list'
local regex  = require 'user.lua.lib.regex'
local tabl   = require 'user.lua.lib.table'
local logger = require 'user.lua.util.logger'

local log = logger.new('user:init', 'debug')

log.i("Starting...")

hs.ipc.cliInstall('/opt/homebrew')
hs.ipc.localPort('testtest', function(d)
  log.f('ipc message received: %s', tostring(d))
  return ("Echo '%s'"):format(tostring(d))
end)

local console = require 'user.lua.interface.console'
local desk    = require 'user.lua.interface.desktop'

console.configureHSConsole()
console.setDarkMode(desk.darkMode())

local KS = require 'user.lua.state'
local CmdList = require 'user.lua.commands'


KS.commands = CmdList:new():initialize()


log.i("Setting global hotkeys...")
KS.commands:forEach(function(cmd) cmd:bindHotkey() end)



log.i("Setting up url handlers...")
KS.commands:forEach(function(cmd) cmd:bindURL() end)



log.i("Creating menubar item...")
require('user.lua.interface.menubar').install()



log.i('Running onLoad commands...')

local onLoadFilter = regex.glob('*.onLoad')

local loadcmds = KS.commands
  :filter(function(cmd)
    return onLoadFilter(cmd.id)
  end)
  :reduce({ success = {}, error = {} }, function(m, cmd)
    ---@cast cmd ks.command
    local ok, result = pcall(function() cmd:invoke('load', {}) end)

    table.insert(not ok and m.error or m.success, { cmd = cmd.id, result = result })

    return m
  end)

log.inspect('inLoad command results:', loadcmds, logger.d3)



log.i('Init complete')

---@type hs.distributednotifications|nil
-- local nsDistNotes = hs.distributednotifications.new(function(name, object, userInfo)
--   print('[distributednotifications] ...')
--   print(string.format("name: %s\nobject: %s\nuserInfo: %s\n", name, object, hs.inspect(userInfo)))
-- end)
-- if (nsDistNotes ~= nil) then
--   nsDistNotes:start()
-- end