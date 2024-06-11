local etlua    = require 'etlua'
local plpath   = require 'pl.path'
local plfile   = require 'pl.file'
local plseq    = require 'pl.seq'
local pltabl   = require 'pl.tablex'
local alert    = require 'user.lua.interface.alert'
local desk     = require 'user.lua.interface.desktop'
local lists    = require 'user.lua.lib.list'
local params   = require 'user.lua.lib.params'
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

local FADE_TIME = alert.timing.FAST

local renderers = {}
local template_cache = {}

local conf = {}

conf.base_model = {
  title = 'KS Webview',
  stylesheet = "https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.lime.min.css",
  css = {
    plpath.join(TMPL_DIR, 'pico-adjust.css'),
  },
  _strings = strings,
  _lists = lists,
  _tables = tables,
  _entries = pltabl.sort,
  _inspect = function(item) return hs.inspect(item) end,
  _load = function(filepath)
    return plfile.read(filepath) or ""
  end,
}

conf.webview = {
  developerExtrasEnabled = true,
}

--
-- Merges viewmodels into one table
--
---@return table
local function merge_models(...)
  return tables.merge({}, conf.base_model, table.unpack({...}))
end


---@return string
local function fetchTemplate(filepath)
  return plfile.read(filepath) or ""
end


---@return hs.webview
local function new_webview()
  local win_dimensions = desk.getScreen('active'):frame():scale({ w = 0.50, h = 0.90 })

  local view = hs.webview.new(win_dimensions, conf.webview) --[[@as hs.webview]]

  view:windowStyle({ "borderless", "closable", "utility" })
  -- view:windowStyle("closable")
  view:transparent(true)
  view:darkMode(false)
  view:closeOnEscape(true)
  view:allowGestures(true)
  view:allowTextEntry(true)

  return view
end


local function loadAll()
  log.f('Using template dir [%s]', TMPL_DIR)

  local files = listdir(TMPL_DIR, 'etlua')

  local tmpls = lists(files):reduce({}, function(memo, filepath)
    return tables.merge(memo, { 
      [plpath.basename(filepath)] = etlua.compile(fetchTemplate(filepath))
    })
  end)

  log.inspect('Loaded templates:', tables.keys(tmpls))

  return tmpls
end


---@param template string
---@param viewmodel table
function renderers.cached(template, viewmodel)
  if tables.isEmpty(template_cache) then loadAll() end

  local tmpl_key = format('%s.etlua', template)

  if tables.has(template_cache, tmpl_key) then
    return template_cache[tmpl_key](viewmodel)
  else
    error(format('No template for name [%s]', template))
  end
end


-- Renders a etlua template at the specified path. The following are valid for `filepath`
-- - basename, eg 'mytemplate'
-- - base + extension, eg 'mytemplate.etlua'
-- - full absolute path, eg `/YUsers/bob/whatever/mytemplate.etlua'
--
---@param filepath string
---@param viewmodel table
function renderers.file(filepath, viewmodel)
  params.assert.string(filepath, 1)

  if not filepath:match('^.*%.etlua$') then
    filepath = filepath .. '.etlua'
  end

  if not plpath.isabs(filepath) then
    filepath = plpath.join(TMPL_DIR, filepath)
  end
  
  if plpath.exists(filepath) then
    log.i('Compiling template file: ', filepath)

    local template = etlua.compile(fetchTemplate(filepath))

    if template == nil then
      error('Error compiling template: ' .. filepath)
    end

    return template(viewmodel)
  else
    error(format('No template found at path: %s', filepath))
  end
end


-- Renders `template` as the content portion of base.etlua
--
---@param template string 
---@param viewmodel table
function renderers.page(template, viewmodel)
  local content = renderers.file(template, merge_models(viewmodel))

  return renderers.file('base', merge_models(viewmodel, {
    content = content
  }))
end



local Webview = {}

---@type hs.webview|nil
Webview.current = nil


--
--
---@param template string
---@param viewmodel? table
---@param title? string
function Webview.page(template, viewmodel, title)

  if types.notNil(Webview.current) then
    Webview.current = Webview.current:delete(true, FADE_TIME)
    return
  end

  viewmodel = viewmodel or {}
  title = title or conf.base_model.title

  ---@type hs.webview
  local view = new_webview()

  view:windowTitle(title)
  view:html(renderers.page(template, viewmodel))
  view:show(FADE_TIME)

  Webview.current = view
end

--
--
---@param file string
---@param viewmodel? table
---@param title? string
function Webview.file(file, viewmodel, title)
  if types.notNil(Webview.current) then
    Webview.current = Webview.current:delete(true, FADE_TIME)
    return
  end

  viewmodel = viewmodel or {}
  title = title or conf.base_model.title

  ---@type hs.webview
  local view = new_webview()

  view:windowTitle(title)
  view:html(renderers.file(file, viewmodel))
  view:show(FADE_TIME)

  Webview.current = view
end

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