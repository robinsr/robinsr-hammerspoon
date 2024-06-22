local etlua    = require 'etlua'
local plpath   = require 'pl.path'
local plfile   = require 'pl.file'
local plseq    = require 'pl.seq'
local plstring = require 'pl.stringx'
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
local vm     = require 'user.lua.ui.webview.viewmodel'

local log = logr.new('webview-renderer', 'info')

local TMPL_DIR = paths.join(paths.mod('user.lua.ui.webview'), '..', 'templates') 


---@return string
local function fetchTemplate(filepath)
  return plfile.read(filepath) or ""
end


local template_cache = {}
local function loadAll()
  log.f('Using template dir [%s]', TMPL_DIR)

  local files = scan.listdir(TMPL_DIR, 'etlua')

  local tmpls = lists(files):reduce({}, function(memo, filepath)
    return tables.merge(memo, { 
      [plpath.basename(filepath)] = etlua.compile(fetchTemplate(filepath))
    })
  end)

  log.inspect('Loaded templates:', tables.keys(tmpls))

  return tmpls
end



local renderers = {}


---@param template string
---@param viewmodel table
function renderers.cached(template, viewmodel)
  if tables.isEmpty(template_cache) then loadAll() end

  local tmpl_key = strings.fmt('%s.etlua', template)

  if tables.has(template_cache, tmpl_key) then
    return template_cache[tmpl_key](viewmodel)
  else
    error(strings.fmt('No template for name [%s]', template))
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
    error(strings.fmt('No template found at path: %s', filepath))
  end
end


-- Renders `template` as the content portion of base.etlua
--
---@param template string 
---@param viewmodel table
function renderers.page(template, viewmodel)
  local model = vm.merge_models(viewmodel)
  model.content = renderers.file(template, model)
  return renderers.file('base', model)
end

return renderers