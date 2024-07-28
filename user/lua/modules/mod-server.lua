
local web      = require 'user.lua.interface.webserver'
local Hotkey   = require 'user.lua.model.hotkey'
local fs       = require 'user.lua.lib.fs'
local func     = require 'user.lua.lib.func'
local lists    = require 'user.lua.lib.list'
local regex    = require 'user.lua.lib.regex'
local paths    = require 'user.lua.lib.path'
local icons    = require 'user.lua.ui.icons'
local images   = require 'user.lua.ui.image'
local renderer = require 'user.lua.ui.webview.renderer'
local json     = require 'user.lua.util.json'
local logr     = require 'user.lua.util.logger' 
local mime     = require 'user.lua.util.mimetypes'


local log = logr.new('mod_server', 'info')

local server = web:new()

log.inspect(server, { metatables = true })


server:engine('.view', function(viewname, viewmodel)
  return renderer.file(viewname, viewmodel)
end)

server:use('uri:/{+path}', function(req, res)
  res:setHeader('app-name', 'ryans-hs-mod-server')
end)

server:get('favicon.ico', function(req, res)
  local resolved = paths.expand('@/resources/images/favicon.ico')
  
  if paths.exists(resolved) then
    res:setFile(resolved)
  end
end)

server:get('uri:/static/{+filepath}', function(req, res)
  log.f("middleware static/*args;\nRequest: %s\nResponse: %s", hs.inspect(req), hs.inspect(res))

  local resolved = paths.expand('@/resources/' .. req.params.filepath)
  
  if paths.exists(resolved) then
    res:setFile(resolved)
  end

  -- webserver.static(paths.expand('@/resources/')))
end)


server:get('glob:/keys', function(req, res)
  res:setView('cheatsheet.view')
  res:setModel({
    title = "Cheatsheet page",
    mods = Hotkey.presets,
    symbols = icons.keys:toplain(),
    groups = KittySupreme.commands:getHotkeyGroups(),
  })
end)


server:get('glob:/data', function(req, res)
  res:setView('json.view')
  res:updateModel('title', 'JSON data test page')
end)

server:get('glob:/edit', function(req, res)
  res:setView('edit.view')
  res:updateModel('title', 'Edit form test page')
end)

server:get('glob:/edit/:filename', function(req, res)
  res:setView('edit.view')
  res:updateModel('title', 'Edit file test page')
end)

server:get('uri:/icon-editor', function(req, res)
  res:setView('icon-editor.view')
  res:updateModel('title', ('Icon editor - %s'):format('New icon'))
  res:updateModel('image_data', {})
  res:updateModel('image_uri', images.encode_from_path('@/resources/images/yabai-logo.png', 500, 500))
end)

server:get('uri:/icon-editor/{+filepath}', function(req, res)
  res:setView('icon-editor.view')

  local filepath = paths.expand('@/resources/images/'..req.params.filepath)
  local image_data = json.read(filepath)
  local image = images.from_data(image_data):encodeAsURLString()


  res:updateModel('title', ('Icon editor - %s'):format(req.params.filepath))
  res:updateModel('image_data', image_data)
  res:updateModel('image_uri', image)
end)

server:post('uri:/icon-editor/{+filepath}{&save}', function(req, res)
  local image_data = json.decode(req.body)

  log.f('image_data received: %s', image_data)

  local img = images.from_data(image_data)

  res:response(200, img:encodeAsURLString(), mime['.txt'])
end)

server:get('glob:/', function(req, res)
  res:setView('json.view')
  res:updateModel('title', 'Home page (json data test page)')
end)


local get_server = func.singleton(function()
  local new_server = server:listen(3000)

  if new_server == nil then
    error('Failed to create hs.httpserver instance')
  end

  return new_server
end)


---@type ks.command.config
local start_dev_server = {
  id = 'ks.server.start',
  title = 'Starts/Restarts a HS server on port 3000',
  icon = '@/resources/images/server-shutdown.ios17outlined.template.png',
  module = 'Dev Server',
  exec = function(cmd, ctx, params)
    get_server():start()
  end,
}

---@type ks.command.config
local stop_dev_server = {
  id = 'ks.server.stop',
  title = 'Stops the HS server',
  icon = '@/resources/images/server-shutdown.ios17outlined.template.png',
  module = 'Dev Server',
  setup = function(cmd) end,
  exec = function(cmd, ctx, params)
    get_server():stop()
  end,
}


---@type ks.command.config
local onload = {
  id = 'ks.server.onLoad',
  title = 'Onload handler for Dev Server module',
  icon = 'info',
  flags = { 'no-chooser' },
  exec = function(cmd, ctx, params)
    get_server():start()
  end,
}

return {
  module = 'Dev Server',
  cmds = {
    start_dev_server,
    stop_dev_server,
    onload,
  }
}