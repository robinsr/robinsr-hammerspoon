-- 
-- eXperimental!!!
-- 
local w      = require 'user.lua.interface.watchable'
local func   = require 'user.lua.lib.func'
local lists  = require 'user.lua.lib.list'
local tables = require 'user.lua.lib.table'
local keys   = require 'user.lua.model.keys'
local logr   = require 'user.lua.util.logger'

local log = logr.new('mod-X', 'debug')


local yabai_signals_experiment =   {
  id = 'exp.yabaiSignals.notonLoad',
  title = 'Test adding a signal to Yabai',
  icon = 'info',
  exec = function(cmd, ctx, params)
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

        yabai:addSignal(
          signal.channel, signal.event, signal.vars
        )
      end)
  end,
}



local watchable_experiment = {
  id = "kstest.evt.notOnLoad",
  exec = function()
    -- Works! Most of the time
    local watchme = w.watch.create('target', true, {
      whois = 'intial val'
    })

    local onUpdate = function(update)
      log.df('Watcher update fired: %s', hs.inspect(update))
      log.df('%s.%s Updated from [%q] to [%q]', update.path, update.key, update.prev, update.value)
    end

    w.listen.respondTo('target', 'whois', onUpdate)

    w.listen.respond('target', onUpdate)

    local watcher = w.listen.any('target')

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

local return_err_experiment = {
  id    = "ks.test.cmd_failed",
  title = "Tests that command execution failures surface as expected",
  icon  = "kitty",
  key   = keys.TICK,
  mods  = keys.preset.btms,
  flags = { 'no-alert' },
  exec  = func.ident({ err = 'doodoo' }),
}

local allow_applescript = {
  id = 'ks.test.allow_applescript',
  title = 'Allow Applescript',
  icon = 'apple',
  flags = { 'no-alert', },
  exec = function(cmd, ctx, params)
    hs.allowAppleScript(true)
  end,
}

local test_webview_alert = {
  id = 'ks.test.test_webview_alert',
  title = 'Tests Webview Alert',
  icon = 'info',
  exec = function(cmd, ctx, params)
    -- return nil, 'Success!'
    testCallbackFn = function(result) print("Callback Result: " .. result) end
    testWebviewA = hs.webview.newBrowser(hs.geometry.rect(250, 250, 250, 250)):show()
    testWebviewB = hs.webview.newBrowser(hs.geometry.rect(450, 450, 450, 450)):show()
    hs.dialog.webviewAlert(testWebviewA, testCallbackFn, "Message", "Informative Text", "Button One", "Button Two", "warning")
    hs.dialog.webviewAlert(testWebviewB, testCallbackFn, "Message", "Informative Text", "Single Button")
  end,
}


return {
  module = "X",
  cmds = {
    yabai_signals_experiment,
    watchable_experiment,
    return_err_experiment,
    allow_applescript,
    test_webview_alert,
  },
}