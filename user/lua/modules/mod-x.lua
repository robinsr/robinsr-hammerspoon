-- 
-- eXperimental!!!
-- 

local inspect = require 'hs.inspect'
local watch   = require 'user.lua.interface.watchable'
local channel = require 'user.lua.lib.channels'
local fs      = require 'user.lua.lib.fs'
local func    = require 'user.lua.lib.func'
local json    = require 'user.lua.lib.json'
local lists   = require 'user.lua.lib.list'
local paths   = require 'user.lua.lib.path'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local keys    = require 'user.lua.model.keys'
local logr    = require 'user.lua.util.logger'

local log = logr.new('mod-X', 'debug')

local MODX_ICON = '@/resources/images/icons/test-tube.tmpl.png'


---@type ks.command.config
local yabai_signals_experiment = {
  -- id = 'modx.ysignals.onLoad',
  id = 'modx.ysignals.onLoadDisabled',
  title = 'Test adding a signal to Yabai',
  icon = 'info',
  exec = function(cmd, ctx, params)
    local signal_log = logr.new('signals', 'off')
    local signals = require('user.lua.adapters.yabai-signals')

    local yabai = KittySupreme:getService('Yabai')


    ---@type ks.signal.channel[]
    local enabled_channels = {
      'ks:app:switched',
      'ks:window:created',
      'ks:window:destroyed',
      'ks:space:created',
      'ks:space:destroyed',
      'ks:space:changed',
      'ks:screen:added',
      'ks:screen:removed',
      'ks:screen:moved',
      'ks:system:woke',
    }

    lists(signals)
      :filter(function(signal)
        return lists(enabled_channels):includes(signal.channel)
      end)
      :forEach(function(signal)
        ---@cast signal yabai.signal.config
        yabai:addSignal(signal.channel, signal.event, signal.vars)
      end)
      :forEach(function(signal)
        ---@cast signal yabai.signal.config
        channel.subscribe(signal.channel, function(data, chan)
          signal_log.vf('(yabai_signals_experiment) Signal Fired - [%s]: %s', chan, inspect(data))
        end)
      end)
  end,
}

---@type ks.command.config
local watchable_experiment = {
  id = "kstest.evt.notOnLoad",
  exec = function()
    -- Works! Most of the time
    local watchme = watch.create('target', true, {
      whois = 'intial val'
    })

    local onUpdate = function(update)
      log.df('Watcher update fired: %s', hs.inspect(update))
      log.df('%s.%s Updated from [%q] to [%q]', update.path, update.key, update.prev, update.value)
    end

    watch.listen.respondTo('target', 'whois', onUpdate)

    watch.listen.respond('target', onUpdate)

    local watcher = watch.listen.any('target')

    local updaterFnA = func.interval(7, function()
      watchme["whois"] = 'Apples!'
    end)

    local updaterFnB = func.interval(3, function()
      watcher:change('whois', 'Bananas!')
    end)

    local checkerFnA = func.interval(2, function()
      log.df('Watchable value (watchABLE side): %s', watchme['whois'])
    end)

    local checkerFnB = func.interval(2, function()
      log.df('Watchable value (watchER side): %s', watcher:value('whois'))
    end)


    func.delay(22, function()
      updaterFnA:stop()
      updaterFnB:stop()
      checkerFnA:stop()
      checkerFnB:stop()
    end)
  end
}

---@type ks.command.config
local return_err_experiment = {
  id    = "modx.cmd_failed.test",
  title = "Tests that command execution failures surface as expected",
  icon  = MODX_ICON,
  key   = keys.TICK,
  mods  = keys.preset.btms,
  flags = { 'no-alert' },
  exec  = func.ident({ err = 'doodoo' }),
}

---@type ks.command.config
local allow_applescript = {
  id    = 'modx.applescript.allow',
  title = 'Allow Applescript',
  icon  = MODX_ICON,
  flags = { 'no-alert', },
  exec  = function(cmd, ctx, params)
    hs.allowAppleScript(true)
  end,
}

---@type ks.command.config
local test_application_watcher = {
  -- id    = 'modx.appwatcher.onLoad',
  id    = 'modx.appwatcher.onLoadDisabled',
  title = 'Test Application Watcher',
  icon  = MODX_ICON,
  exec  = function(cmd, ctx, params)
    local app_log = logr.new('signals', 'off')

    local evtTypes = {
      [0] = 'launching',
      [1] = 'launched',
      [2] = 'terminated',
      [3] = 'hidden',
      [4] = 'unhidden',
      [5] = 'activated',
      [6] = 'deactivated',
    }

    local evtHandler = function(appName, evt, app)
      app_log.critical('App Event: app "%s" is %s', appName, evtTypes[evt])
    end

    local _ = func.delay(2, function()
      local watcher = hs.application.watcher.new(evtHandler)
      watcher:start()
    end)

  end,
}


---@type ks.module
return {
  module = "X",
  cmds = {
    yabai_signals_experiment,
    watchable_experiment,
    return_err_experiment,
    allow_applescript,
    test_application_watcher,
  },
}