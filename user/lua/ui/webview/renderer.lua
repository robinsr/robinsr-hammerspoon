local fs       = require 'user.lua.lib.fs'
local paths    = require 'user.lua.lib.path'
local params   = require 'user.lua.lib.params'
local vm       = require 'user.lua.ui.webview.viewmodel'
local logr     = require 'user.lua.util.logger'

local log = logr.new('webview-renderer', 'debug')

local tmpl_dir = paths.expand('@/resources/templates/aspect')

local aspect = require("user.lua.ui.webview.aspect")
require("user.lua.ui.webview.functions")
require("user.lua.ui.webview.tags")




local renderers = {}

renderers.util = {
  compile = function(filename)
    params.assert.string(filename)

    local filepath = paths.join(tmpl_dir, filename)
    params.assert.path(filepath)

    ---@diagnostic disable-next-line
    local compile_err, result, view, fn = aspect:compile(filename)
    
    if compile_err then 
      error("Compile error occurred: " .. tostring(compile_err))
    end
    
    log.vf("Compile result for template %s:\n%s", filename, result:get_code())

    local outpath = paths.rename(filename, '{dir}/{base}.compiled.lua', { dir = tmpl_dir })

    fs.writefile(outpath, result:get_code())

    return result
  end
}


-- Renders a Aspect template at the specified path. The following are valid for `filepath`
-- - basename, eg 'mytemplate'
-- - base + extension, eg 'mytemplate.view'
-- - full absolute path, eg `/Users/bob/whatever/mytemplate.view'
--
---@param filename string
---@param viewmodel table
function renderers.file(filename, viewmodel)
  params.assert.string(filename, 1)

  log.df("Rendering FILE at path %q (loader dir: %s)", filename, tmpl_dir)

  local result, err = aspect:render(filename, vm.merge_models(viewmodel))

  if err ~= nil then
    local details = tostring(err)
    log.ef("Failed to render aspect template [%s]\n%s", filename, details)
    error("Aspect error - " .. err.message)
  end

  log.vf("Aspect render result: %s", tostring(result))

  return tostring(result)
end


-- Renders `template` as the content portion of base.etlua
--
---@param tmpl_name string 
---@param viewmodel table
function renderers.page(tmpl_name, viewmodel)
  log.df("Rendering PAGE named %q (loader dir: %s)", tmpl_name, tmpl_dir)
  
  local model = vm.merge_models(viewmodel)
  model.content = renderers.file(tmpl_name, model)
  return renderers.file('base.view', model)
end


return renderers