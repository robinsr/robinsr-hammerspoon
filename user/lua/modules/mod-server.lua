local ksutil   = require 'user.lua.util'
local strings  = require 'user.lua.lib.string'
local tables   = require 'user.lua.lib.table'
local renderer = require 'user.lua.ui.webview.renderer'

local log = require('user.lua.util.logger').new('mod_server', 'debug')

local server_instance = nil

local server_name = 'Hammerspoon Lua (KittySupreme)'
local date_fmt = '%a, %b %d %Y %I:%M:%S %p'

local path_matchers = {
  keys_viewer = strings.glob('/keys'),
  json_viewer = strings.glob('/data'),
  home = strings.glob('/*'),
  all = strings.glob("*"),
}

local not_found = nil
local function get_404_html()
  if not_found == nil then
    not_found = renderer.file('json.view', { data = { message = 'Not found' } })
  end

  return not_found
end



local web_handler = function(method, path, req_headers, body)
  log.f("Server Request - %s on %q;\n%s\n\n", method, path, hs.inspect(req_headers))

  local resp_body = get_404_html()
  local resp_code = 200
  local resp_headers = {
    ['Server'] = server_name,
    ['Content-Type'] = "text/html; charset=utf-8",
    ['Content-Length'] = tostring(string.len(resp_body)),
    -- ['Expires'] = ksutil.date_str(date_fmt),
    -- ['ETag'] = strings.replace(hs.host.uuid(), '-', ''), -- does this change
    -- ['Cache-Control'] = "no-cache",
    -- ['Access-Control-Allow-Origin'] = "*",
  }

  if path_matchers.keys_viewer(path) then
    local html = renderer.file('cheatsheet.view', {  })

    resp_body = html
    resp_code = 200
    resp_headers = tables.merge(resp_headers, {
      ['Content-Type'] = "text/html",
      ['Content-Length'] = tostring(string.len(html)),
    })
  

  -- if path == "/" then
  elseif path_matchers.all(path) then
    local data = {
      method = method,
      path = path,
      headers = req_headers,
      body = body,
    }

    local html = renderer.file('json.view', { data = data })

    resp_body = html
    resp_code = 200
    resp_headers = tables.merge(resp_headers, {
      ['Content-Type'] = "text/html",
      ['Content-Length'] = tostring(string.len(html)),
    })
  end

  return resp_body, resp_code, resp_headers
end


local function get_server()
  if server_instance == nil then
    local new_server = hs.httpserver.new(false, false)

    if new_server == nil then
      error('Failed to create hs.httpserver instance')
    end

    new_server:setInterface('localhost')
    new_server:setPort(3000)
    new_server:setCallback(web_handler)

    server_instance = new_server
  end

  return server_instance
end


local start_dev_server = {
  id = 'ks.server.start',
  title = 'Starts/Restarts a HS server on port 3000',
  icon = 'info',
  setup = function(cmd) end,
  exec = function(cmd, ctx, params)
    if server_instance ~= nil then
      server_instance:stop()
    end

    local new_server = get_server()

    if new_server ~= nil then
      new_server:start()
    end
  end,
}

local stop_dev_server = {
  id = 'ks.server.stop',
  title = 'Stops the HS server',
  icon = 'info',
  setup = function(cmd) end,
  exec = function(cmd, ctx, params)
    if server_instance ~= nil then
      server_instance:stop()
    end
  end,
}

return {
  cmds = {
    start_dev_server,
    stop_dev_server
  }
}




--[[
getInterface
getName
getPort
maxBodySize
send
setCallback
setInterface
setName
setPassword
setPort
start
stop
websocket
]]