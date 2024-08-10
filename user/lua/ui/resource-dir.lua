local sh     = require 'user.lua.adapters.shell'
local fs     = require 'user.lua.lib.fs'
local lists  = require 'user.lua.lib.list'
local tables = require 'user.lua.lib.table'
local paths  = require 'user.lua.lib.path'
local params = require 'user.lua.lib.params'
local json   = require 'user.lua.util.json'

local log = require('user.lua.util.logger').new('resource-dir', 'info')


---@class FileResource
---@field path string
---@field src string


---@class ResourceDir
---@field dir string
---@field config_file string
---@field resources FileResource[]
---@field watcher? hs.pathwatcher


local DEFAULT_CONFIG = 'ensure_files.json'



---@class ResourceDir
local rdir = {}


--
--
--
---@param dir string
---@param conf? string
function rdir:new(dir, conf)
  params.assert.path(dir)

  conf = conf or DEFAULT_CONFIG
  
  local this = self or {}

  this.dir = dir
  this.config_file = paths.join(dir, conf)

  if not paths.exists(this.config_file) then
    error(('Could not find config file %s'):format(this.config_file))
  end

  this.resources = this:read_config()

  this.watcher = hs.pathwatcher.new(this.dir, function(files, changes)
    log.f("pathwatcher %s event - files: %s\nchanges: %s", this.dir, hs.inspect(files), hs.inspect(changes))

    if files[1] == this.config_file then
      this.resources = this:read_config()
      this:ensure_files()
    end
  end)

  return this
end


--
-- 
--
---@return FileResource[]
function rdir:read_config()
  local config = json.read(self.config_file)

  local file_list = config.files or {}

  return lists(config.files or {}):map(function(entry)
    params.assert.string(entry[1], 999)
    params.assert.url(entry[2], 999)

    return { 
      path = paths.join(self.dir, entry[1]),
      src = entry[2]
    }
  end):values()
end


--
--
--
function rdir:ensure_files()
  local skipped = lists({})
  local fetched = tables({})

  log.f("Syncing files in dir [%s]...", self.dir)

  for i, res in ipairs(self.resources) do
    if paths.exists(res.path) then
      skipped:push(res.path)
    else
      local dir = paths.dirname(res.path)

      if not paths.exists(dir) then
        log.f("Creating directory [%s]", dir)

        fs.mkdir(dir)
      end

      log.df("Fetching file '%s' from URL: %s", res.path, res.src)
      
      local fetch_result = sh.result({ "curl", res.src, "-o", res.path })
      
      if not fetch_result:ok() then
        log.ef("Failed to fetch from URL '%s'\n%s", res.src, fetch_result:error_msg())
        fetched:set(res.path, fetch_result:table())
      end
    end
  end

  log.f("Sync complete; %s", hs.inspect({ skipped = skipped:values(), fetched = fetched:toplain() }))
end


--
--
--
---@param stop? boolean
---@return ResourceDir
function rdir:watch(stop)
  if stop then
    self.watcher:stop()
  else
    self.watcher:start()
  end

  return self
end



local fetch_images_dir = {
  id = 'ks.resources.fetch_images_dir',
  title = 'Ensure image directory has expected files',
  icon = 'info',
  setup = {
    image_dir = rdir:new(paths.expand('@/resources/images/'))
  },
  exec = function(cmd, ctx, params)
    ctx.image_dir:ensure_files()
  end,
}

rdir.cmds = {
  fetch_images_dir,
}


return rdir