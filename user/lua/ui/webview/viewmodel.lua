local pltabl   = require 'pl.tablex'
local plfile   = require 'pl.file'
local desktop  = require 'user.lua.interface.desktop'
local params   = require 'user.lua.lib.params'
local paths    = require 'user.lua.lib.path'
local strings  = require 'user.lua.lib.string'
local tables   = require 'user.lua.lib.table'


---@class ks.viewmodel
---@field title      string
---@field [string]   any



local elems = {
  style_link = '<link rel="stylesheet" href="%s" />',
  style_raw  = '<style type="text/css">%s</style>',
  script_src = '<script type="text/javascript" src="%s"></script>',
  script_raw = '<script type="text/javascript">%s</script>',
  meta       = '<meta name="%s" value="%s" />',
}

local file_contents = function(filename)
  return plfile.read(paths.expand(filename))
end


local function base_model()
  return {
    title = 'KittySupreme dialog window',
    dark_mode = desktop.darkMode(),
    style_blocks = {
      -- content here NOT wrapped in style tags
      file_contents('@/resources/stylesheets/output.css'),
    },
    head_tags = {
      -- elems.style_link:format("https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.lime.min.css"),
      -- elems.style_raw:format(file_contents('@/resources/stylesheets/pico-adjust.css')),
      -- elems.style_raw:format(file_contents('@/resources/stylesheets/output.css')),
    },
    footer_tags = {},
  }
end


--
-- Merges viewmodels into one table
--
---@return table
local function merge_models(...)
  for i, tabl in ipairs({...}) do
    params.assert.tabl(tabl, i)
  end

  local new_base = pltabl.copy(base_model())

  -- new_base.header_tags = {}
  -- new_base.style_blocks = {}
  -- new_base.footer_tags = {}

  return tables.merge({}, new_base, table.unpack({...}))
end


return {
  base_model = base_model,
  merge_models = merge_models,
}