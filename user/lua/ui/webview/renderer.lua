-- local etlua    = require 'etlua'
local plpath   = require 'pl.path'
local plfile   = require 'pl.file'
local pltabl   = require 'pl.tablex'
local paths    = require 'user.lua.lib.path'
local params   = require 'user.lua.lib.params'
local strings  = require 'user.lua.lib.string'
local logr     = require 'user.lua.util.logger'
local vm       = require 'user.lua.ui.webview.viewmodel'
local images   = require 'user.lua.ui.image'
local json     = require 'user.lua.util.json'

local log = logr.new('webview-renderer', 'debug')

local json_encode_function = function(data, ...)
  -- log.f('Aspect JSON encode call: %s %s', hs.inspect(data), hs.inspect({...}))
  return json.tostring(data)
end

local json_decode_function = function(data, ...)
-- log.f('Aspect JSON decode call: %s %s', hs.inspect(data), hs.inspect({...}))
  return json.parse(data)
end

local json = require("aspect.config").json
json.encode = json_encode_function
json.decode = json_decode_function

local funcs = require("aspect.funcs")

funcs.add('encoded_img', {
  args = {
    [1] = { name = "filepath", type = 'string' },
    [2] = { name = "width", type = 'number' },
    [3] = { name = "height", type = 'number' },
  }
},
function(_, args)
  local filepath = paths.expand(args.filepath)
  return images.encode_from_path(filepath, args.width, args.height)
end)

local tmpl_dir = paths.expand('@/resources/templates/aspect')

local fs_loader = require("aspect.loader.filesystem").new(tmpl_dir)


local aspect_opts = {
  cache = false,
  debug = true,
  loader = fs_loader,
  env = {
    ['what_does'] = "this_do",
  }
}

local aspect = require("aspect.template").new(aspect_opts)


local renderers = {}

---@return string
local function fetchTemplate(filepath)
  return plfile.read(filepath) or ""
end


-- Renders a Aspect template at the specified path. The following are valid for `filepath`
-- - basename, eg 'mytemplate'
-- - base + extension, eg 'mytemplate.view'
-- - full absolute path, eg `/Users/bob/whatever/mytemplate.view'
--
---@param filepath string
---@param viewmodel table
function renderers.file(filepath, viewmodel)
  params.assert.string(filepath, 1)

  log.df("Rendering FILE at path %q (loader dir: %s)", filepath, tmpl_dir)

  local result, err = aspect:render(filepath, vm.merge_models(viewmodel))

  if err ~= nil then
    local details = tostring(err)
    log.ef("Failed to render aspect template [%s]\n%s", filepath, details)
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