local plfile   = require 'pl.file'
local plpath   = require 'pl.path'
local plstring = require 'pl.stringx'
local pltabl   = require 'pl.tablex'
local lists    = require 'user.lua.lib.list'
local params   = require 'user.lua.lib.params'
local paths    = require 'user.lua.lib.path'
local scan     = require 'user.lua.lib.scan'
local strings  = require 'user.lua.lib.string'
local tables   = require 'user.lua.lib.table'
local types    = require 'user.lua.lib.typecheck'
local json     = require 'user.lua.util.json'


local TMPL_DIR = paths.join(paths.mod('user.lua.ui.webview'), '..', 'templates')

local FMT = {
  link = '<link rel="stylesheet" href="%s" />',
  script = '<script type="text/javascript" src="%s"></script>',
  meta = '<meta name="%s" value="%s" />',
}

local function link_tag(href)
  return strings.fmt(FMT.link, href)
end

local function script_tag(src)
  return strings.fmt(FMT.script, src)
end


local base_model = {
  title = 'KS Webview',
  stylesheet = 'function(){ console.error("ba ahahahaha"); }',
  css = {},
  header_tags = {},
  _stylesheet = link_tag,
  _script = script_tag,
  _strings = strings,
  _stringx = plstring,
  _lists = lists,
  _tables = tables,
  _insert = table.insert,
  _entries = pltabl.sort,
  _json = json.tostring,
  _inspect = function(item) return hs.inspect(item) end,
  _load = function(filepath)
    return plfile.read(filepath) or ""
  end,
}


--
-- Merges viewmodels into one table
--
---@return table
local function merge_models(...)
  local new_base = pltabl.copy(base_model)

  new_base.header_tags = {
    strings.fmt(FMT.link, "https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.lime.min.css")
  }

  new_base.css = {
    plpath.join(TMPL_DIR, 'pico-adjust.css'),
  }


  return tables.merge({}, new_base, table.unpack({...}))
end


return {
  base_model = base_model,
  merge_models = merge_models,
}