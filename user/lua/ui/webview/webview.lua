local hsweb    = require 'hs.webview'
local lustache = require 'lustache'
local plpath   = require 'pl.path'
local plfile   = require 'pl.file'
local alert    = require 'user.lua.interface.alert'
local desk     = require 'user.lua.interface.desktop'
local lists    = require 'user.lua.lib.list'
local paths    = require 'user.lua.lib.path'
local scan     = require 'user.lua.lib.scan'
local strings  = require 'user.lua.lib.string'
local tables   = require 'user.lua.lib.table'
local types    = require 'user.lua.lib.typecheck'
local logr     = require 'user.lua.util.logger'


local listdir  = scan.listdir
local format   = strings.fmt
local replace  = strings.replace

local MOD_NAME = paths.mod('user.lua.ui.webview')
local TMPL_DIR = paths.join(MOD_NAME, '..', 'templates') 

local log = logr.new('webview', 'debug')

local templates = {}

local partials = {
  doeswork = "<p>Does this work: <strong>{{val}}</strong></p>"
}


---@return string
local function fetchTemplate(filepath)
  return plfile.read(filepath) or ""
end


local function loadAll()
  log.f('Using template dir [%s]', TMPL_DIR)

  local files = listdir(TMPL_DIR, 'mustache')

  local tmpls = lists(files):reduce({}, function(memo, filepath)
    return tables.merge(memo, { 
      [plpath.basename(filepath)] = fetchTemplate(filepath)
    })
  end)

  log.inspect('Loaded templates:', tables.keys(tmpls))

  return tmpls
end


---@param template string
---@param viewmodel table
local function renderCached(template, viewmodel)
  if tables.isEmpty(templates) then loadAll() end

  local tmpl_key = format('%s.mustache', template)

  if tables.has(templates, tmpl_key) then
    return lustache:render(templates[tmpl_key], viewmodel, partials)
  else
    error(format('No template for name [%s]', template))
  end
end


---@param template string
---@param viewmodel table
local function renderFile(template, viewmodel)
  local filepath = plpath.join(TMPL_DIR, template .. '.mustache')
  
  if plpath.exists(filepath) then
    return lustache:render(fetchTemplate(filepath), viewmodel, partials)
  else
    error(format('No template found at path: %s', filepath))
  end
end


---@param template string
---@param viewmodel table
local function renderPage(template, viewmodel)
  return renderFile('base', { 
    title = 'KS Webview',
    content = renderFile(template, viewmodel)
  })
end


local WEBVIEW_OPTS = {
  developerExtrasEnabled = true,
}

local FADE_TIME = alert.timing.FAST


local Webview = {}

---@type hs.webview|nil
Webview.current = nil


---@param title string
---@param template string
---@param viewmodel table
function Webview.show(title, template, viewmodel)

  if types.notNil(Webview.current) then
    Webview.current = Webview.current:delete(true, FADE_TIME)
    return
  end

  local win_dimensions = desk.getScreen('active'):frame():scale({ w = 0.50, h = 0.90 })
  

  ---@type hs.webview
  local view = hsweb.new(win_dimensions, WEBVIEW_OPTS)

  view:html(renderPage(template, viewmodel))
  view:windowStyle({ "borderless", "closable", "utility" })
  view:darkMode(true)
  view:closeOnEscape(true)
  view:allowGestures(true)
  view:allowTextEntry(true)
  view:windowTitle(title)
  view:show(FADE_TIME)

  Webview.current = view
end


Webview.cmds = {
  {
    id = 'KS.webview.test',
    title = "Test Webview Alert",
    key = "F",
    mods = "bar",
    exec = function()

      local title = 'Testing HS Webview...'
      local template = 'content'
      local model = {
        name = 'PooPoo McGillicutty',
        val = function()
          return "It sure will!"
        end,
        date = function(m)
          log.inspect('model args: ', m, logr.d3)
          return os.date("%A, %m %B %Y")
        end,
        namedate = function(m)
          return strings.join({ m.name, m.date() }, ' ')
        end,
        bolddate = function(text, render)
          log.inspect('bolddate args:', text, render)
          return strings.join{ '<b>', render(text),'</b>' }
        end
      }

      log.i('Testing HS Webview...')

      Webview.show(title, template, model)
    end,
  },
}


return Webview

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

---

Window Masks:

HUD                 8192
borderless          0
closable            2
fullSizeContentView 32768
miniaturizable      4
nonactivating       128
resizable           8
texturedBackground  256
titled              1
utility             16

]]