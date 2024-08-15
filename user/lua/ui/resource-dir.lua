local hjson   = require 'hjson'
local sh      = require 'user.lua.adapters.shell'
local fs      = require 'user.lua.lib.fs'
local json    = require 'user.lua.lib.json'
local lists   = require 'user.lua.lib.list'
local tables  = require 'user.lua.lib.table'
local paths   = require 'user.lua.lib.path'
local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local types   = require 'user.lua.lib.typecheck'
local images  = require 'user.lua.ui.image'

local basename = paths.basename
local dirname  = paths.dirname
local exists   = paths.exists
local join     = paths.join

local log = require('user.lua.util.logger').new('resource-dir', 'info')


---@class ks.resource.file
---@field path         string
---@field src          string
---@field transform    ks.resource.file.transforms


---@class ks.resource.file.transforms
---@field rotate?   integer
---@field flip?     'Y'|'H'


---@class ks.resource.dir
---@field mpath        string
---@field resources    ks.resource.file[]
---@field watcher?     hs.pathwatcher


---@class ks.manifest
---@field vars    table<string, string>
---@field files   array<ks.manifest.entry>


---@alias ks.manifest.entry [ string, string, ks.resource.file.transforms? ]




local DEFAULT_CONFIG = '_manifest.hjson'


---@param path string
---@return ks.manifest
local function hjson_manifest(path)
  params.assert.path(path, 1)
  return hjson.decode(fs.readfile(path)) --[[@as ks.manifest]]
end


---@param path string
---@return ks.manifest
local function json_manifest(path)
  params.assert.path(path, 1)
  return json.read(path) --[[@as ks.manifest]]
end


---@param path string
---@return ks.manifest
local function parse_manifest(path)
  params.assert.path(path, 1)

  local ext = paths.extname(path)

  local manifest = ext == '.hjson' and hjson_manifest(path) or json_manifest(path)

  local root = paths.expand('@/resources/images')
  local vars = manifest.vars or {}

  return lists(manifest.files):map(function(f)
    ---@cast f ks.manifest.entry

    local name, src, config = table.unpack(f)

    local filename = strings.tmpl(name)(vars)
    local source = strings.tmpl(src)(vars)

    return {
      src = source,
      path = paths.join(root, filename),
      config = config or {}
    }
  end):values()
end


---@param resource ks.resource.file
---@return string
local function get_filename(resource)
  return basename(resource.path)
end



---@class ks.resource.dir
local rdir = {}


--
-- For the directory `dir`, watches for file changes and downloads
-- remote files as configured in a manifest JSON/hJSON file
--
---@param manifest_path    string  - Path to manifest file
---@param run_immediately? boolean - run the file sync sequence on initialization
---@return ks.resource.dir
function rdir:new(manifest_path, run_immediately)
  local mpath = paths.expand(manifest_path)

  params.assert.path(mpath)

  ---@type ks.resource.dir
  local this = self ~= rdir and self or {
    mpath = mpath,
    resources = {}
  }

  setmetatable(this, { __index = rdir })

  this.resources = parse_manifest(this.mpath)

  this.watcher = hs.pathwatcher.new(dirname(this.mpath), function(files, changes)
    if files[1] == this.mpath then
      this.resources = parse_manifest(this.mpath)
      this:ensure_files()
    end
  end)

  if run_immediately then
    this:ensure_files()
  end

  return this
end


--
--
--
function rdir:ensure_files()
  log.f("Syncing files in dir [%s]...", dirname(self.mpath))

  ---@type { ['exists'|'added']: ks.resource.file[] }
  local sorted = lists(self.resources):groupBy(function(r)
    return exists(r.path) and 'exists' or 'added'
  end)

  lists(sorted.added)
    :filter(function(r)
      return not exists(dirname(r.path))
    end)
    :forEach(function(r)
      log.f("Creating directory [%s]", dirname(r.path))
      fs.mkdir(dirname(r.path))
    end)

  ---@type { ['success'|'failed']: ks.resource.file[] }
  local fetched = lists(sorted.added):groupBy(function(r)
    log.df("Fetching file '%s' from URL: %s", r.path, r.src)

    return sh.result({ "curl", r.src, "-o", r.path }):ok() and 'success' or 'failed'
  end)

  lists(fetched.success)
    :filter(function(r) return r.config.rotate end)
    :forEach(function(r)
      images.rotate(images.fromPath(r.path), r.config.rotate):saveToFile(r.path)
    end)

  lists(fetched.success)
    :filter(function(r) return types.notNil(r.config.flip) end)
    :forEach(function(r)
      images.flip(images.fromPath(r.path), r.config.flip):saveToFile(r.path)
    end)

  lists(fetched.success)
    :filter(function(r) return types.notNil(r.config.scale) end)
    :forEach(function(r)
      images.scale(images.fromPath(r.path), table.unpack(r.config.scale)):saveToFile(r.path)
    end)

  log.f("Sync complete; %s", hs.inspect({
    skipped = lists(sorted.exists):map(get_filename):join('\\n'),
    fetched = lists(fetched.success):map(get_filename):join('\\n'),
    failed = lists(fetched.failed):map(get_filename):join('\\n'),
   }))
end


--
-- Starts/Stops the filewatcher
--
---@param stop? boolean
---@return ks.resource.dir
function rdir:watch(stop)
  if stop then
    self.watcher:stop()
  else
    self.watcher:start()
  end

  return self
end


return rdir