local sh     = require 'user.lua.adapters.shell'
local paths  = require 'user.lua.lib.path'
local params = require 'user.lua.lib.params'
local fs     = require 'user.lua.lib.fs'
local json   = require 'user.lua.util.json'

local log = require('user.lua.util.logger').new('resource-dir', 'debug')


---@class ResourceDir
---@field dir string
---@field config_file string

---@class ResourceDir
local rdir = {}


--
--
--
function rdir:new(dirpath)
  params.assert.path(dirpath)
  
  local this = self or {}

  this.dir = dirpath
  this.config_file = paths.join(dirpath, 'ensure_files.json')

  if not paths.exists(this.config_file) then
    error(('No config file in dir %s'):format(this.dir))
  end

  return this
end


--
--
--
function rdir:ensure_files()
  local current_ls = fs.listdir(self.dir)

  local config = json.parse(fs.readfile(self.config_file))

  for i, file in ipairs(config.files) do
    local filepath = paths.join(self.dir, file.name)

    if paths.exists(filepath) then
      log.f("File %s exists; skipping", filepath)
    else
      log.f("Fetching file '%s' from URL: %s", file.name, file.src)
      
      local fetch_result = sh.result({ "curl", file.src, "-o", filepath })
      
      if not fetch_result:ok() then
        log.ef("Failed to fetch from URL '%s'\n%s", file.src, fetch_result:error_msg())
      end
    end
  end
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