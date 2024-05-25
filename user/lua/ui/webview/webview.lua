local hsdia    = require 'hs.dialog'
local lustache = require 'lustache'
local list     = require 'user.lua.lib.list'
local paths    = require 'user.lua.lib.path'
local scan     = require 'user.lua.lib.scan'
local strings  = require 'user.lua.lib.string'
local tables   = require 'user.lua.lib.table'
local logr     = require 'user.lua.util.logger'


local listdir  = scan.listdir
local format   = strings.fmt
local replace  = strings.replace

local MOD_NAME = paths.mod('user.lua.ui.webview')
local TMPL_DIR = paths.join(MOD_NAME, '..', 'templates') 

local log = logr.new('dialog', 'debug')

local templates = {}


local function load()
  log.f('Using template dir [%s]', TMPL_DIR)

  local files = listdir(TMPL_DIR, 'mustache')

  list.forEach(files, function(filepath)
    local tfile = io.open(filepath, 'r')

    if tfile then
      templates[paths.pl.basename(filepath)] = tfile:read('a')
      tfile:close()
    end
  end)

  log.f('Loaded templates:\n', strings.join(tables.keys(templates), '\n- '))
end



local function render(tmplname, viewmodel)
  if tables.isEmpty(templates) then load() end

  local content = format('<p>No template for name [%s]</p>', tmplname)
  local tmplkey = format('%s.mustache', tmplname)

  if tables.haspath(templates, tmplkey) then
    content = lustache:render(templates[tmplkey], viewmodel)
  else
  -- error(format('No template for name [%s]', tmplname))
  end

  return render('base', { title = 'KS Webview', content = content })
end


local D = {}

function D.showText()
  -- todo
end

local webviewOpts = {
  developerExtrasEnabled = true,
}

function D.test()
  local viewmodel = {
    title = 'HS Webview Test',
    code = hs.inspect(hs.drawing.windowBehaviors, { depth = 4 }),
  }
  local content = render('base', viewmodel)
  local box = hs.geometry.rect(450, 450, 450, 450)

  log.i(content)
  
  local webview = hs.webview.new(box, webviewOpts) --[[@as hs.webview]]

  webview:html(content)

  hs.timer.doAfter(0.5, function()
    webview:show(0.5)
  end)
  
  -- hs.dialog.webviewAlert(webview, testCallbackFn, "Message", "Informative Text", "Button One", "Button Two", "critical")
end


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