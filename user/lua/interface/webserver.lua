local compose  = require('pl.func').compose
local fs       = require 'user.lua.lib.fs'
local lists    = require 'user.lua.lib.list'
local optional = require 'user.lua.lib.optional'
local params   = require 'user.lua.lib.params'
local paths    = require 'user.lua.lib.path'
local regex    = require 'user.lua.lib.regex'
local strings  = require 'user.lua.lib.string'
local tables   = require 'user.lua.lib.table'
local types    = require 'user.lua.lib.typecheck'
local valua    = require 'user.lua.lib.valua'
local logr     = require 'user.lua.util.logger' 
local mime     = require 'user.lua.util.mimetypes'


local log = logr.new('webserver', 'info')

local function dirty_page(content)
  return strings.fmt([[<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>KittySupreme Error</title>
</head>
<body>
  <div><pre>%s</pre></div>
</body>
</html>]], content)
end


---@alias KS.Web.RouteHandler fun(req: Request, res: Response)

---@alias KS.PathMatcher fun(test:string):table

---@class KS.Web.RouteConfig
---@field pattern string
---@field match KS.PathMatcher
---@field handle KS.Web.RouteHandler

---@alias KS.Web.RenderFn fun(viewname: string, viewmodel: table): string


---@class KS.Web.Server
---@field props table
---@field listeners { [integer]: any }
---@field middleware { string: any }
---@field routes { [string]: KS.Web.RouteConfig[] }
---@field renderer KS.Web.RenderFn



local date_fmt = '%a, %b %d %Y %I:%M:%S %p'


--
-- Returns a string representing the byte-length of string `content`
--
---@param content string
---@return string
local function content_length(content)
  return tostring(string.len(content))
end


--
--
--
local function default_model(method, path, headers, body)
  return {
    title = 'KittySupreme',
    data = { method = method, path = path, headers = headers, body = body }
  }
end


---@param pattern string
---@return fun(test:string):boolean
local function get_matcher(pattern)
  params.assert.string(pattern, 1)

  ---@param str string test string
  local matcher = function(str)
    return str:match(pattern)
  end

  if strings.startswith(pattern, 'glob:') then
    local glob = regex.glob(pattern:gsub('^glob:', ''))
    
    matcher = function(str)
      return glob(str)
    end
  end

  if strings.startswith(pattern, 'uri:') then
    local urimatcher = regex.uri(pattern:gsub('^uri:', ''))
    
    matcher = function(str)
      return urimatcher(str)
    end
  end

  return matcher
end


--
--
--
---@class Request
local Request = {}

---@param method 'GET'|'POST'|'PUT'
---@param url string
---@param params table
---@param headers table
---@param body string
---@return Request
function Request:new(method, url, params, headers, body)
  self.method = method
  self.url = url
  self.params = params
  self.headers = headers
  self.body = body
  return self
end

---@param params table
function Request:setParams(params)
  self.params = params
end


--
--
--
---@class Response
local Response = {}

function Response:new()
  self.view = nil
  self.model = {}
  self.headers = {}
  self.file = nil
  self.status = 200
  self.body = nil
  return self
end

---@param code integer
function Response:setStatus(code)
  self.status = code
end

---@param viewname string
function Response:setView(viewname)
  self.view = viewname
end

---@param model table
function Response:setModel(model)
  self.model = model
end

---@param key string
---@param val any
function Response:updateModel(key, val)
  self.model[key] = val
end

---@param key string
---@param val any
function Response:setHeader(key, val)
  self.headers[key] = val -- does this need to be tostring'd ?
end

---@param new_headers table
function Response:setHeaders(new_headers)
  self.headers = tables.merge(self.headers, new_headers)
end

---@param filepath string
function Response:setFile(filepath)
  self.file = filepath
  self:setHeader('Content-Type', paths.extname(filepath))
end

---@param status integer
---@param content string
---@param type string
function Response:response(status, content, type)
  self.status = status
  self.body = content
  self:setHeader('Content-Type', type)
  self:setHeader('Content-Length', content_length(content))
end




---@class KS.Web.Server
local webserver = {}

local webserver_meta = {
  __index = function(ws, arg)
    return webserver[arg]
  end
}


--
-- Creates a new webserver app
--
---@return KS.Web.Server
function webserver:new()

  ---@class KS.Web.Server
  local this = self == webserver and {} or self

  this.props = {
    server_name = 'Hammerspoon Lua (KittySupreme)',
  }

  this.listeners = {}
  
  this.middleware = {}
  
  this.routes = {
    GET = {},
    POST = {},
  }
  
  this.renderer = function(viewname, viewmodel)
    return "NO RENDER SET"
  end

  return setmetatable(this, webserver_meta)
end


--
-- Sets the rendering engine callback
--
---@param ext string
---@param render KS.Web.RenderFn
function webserver:engine(ext, render)
  self.renderer = render
  return self
end



---@private
---@param pattern string
---@param handler KS.Web.RouteHandler
---@return KS.Web.RouteConfig
function webserver:create_handler(pattern, handler)
  ---@type KS.Web.RouteConfig
  local new_route = {
    match = get_matcher(pattern), 
    pattern = pattern,
    handle = handler,
  }

  return new_route
end


--
-- Adds a GET route handler
--
---@param pattern string
---@param handler KS.Web.RouteHandler
function webserver:get(pattern, handler)
  table.insert(self.routes.GET, self:create_handler(pattern, handler))
  return self
end


--
-- Adds a POST route handler
--
---@param pattern string
---@param handler KS.Web.RouteHandler
function webserver:post(pattern, handler)
  table.insert(self.routes.POST, self:create_handler(pattern, handler))
  return self
end


--
-- Adds a middleware handler
--
---@param pattern string
---@param handler KS.Web.RouteHandler
function webserver:use(pattern, handler)
  table.insert(self.middleware, self:create_handler(pattern, handler))
end


--
-- TODO
-- Sets and endables static file handling
--
function webserver:static(dirname)
  local files = fs.listdir(dirname)

  ---@param req Request
  ---@param res Response
  return function(req, res)

  end
end


--
--
--
---@param port integer
function webserver:listen(port)
  params.assert.number(port, 1)

  local serverlog = logr.new(('web[%d]'):format(port), 'info')

  local notfound = function(url)
    return dirty_page(('404 - Not Found: %s'):format(url))
  end

  local server_error = function(err)
    return dirty_page(('500 - Server Error: %s'):format(err))
  end

  local function accept(method, path, headers, body)
    serverlog.df("ACCEPT - %s %s", method, path, body)

    local req = Request:new(method, path, {}, headers, body)
    local res = Response:new()

    res:setHeader('Server', self.props.server_name)
    res:setModel(default_model(method, path, headers, body))

    return req, res
  end

  ---@param req Request
  ---@param res Response
  local function web_handler(req, res)
    serverlog.df('WEB HANDLER - %s %s', hs.inspect(req), hs.inspect(res))
    
    local mids = lists(self.middleware):forEach(function(mid) mid.handle(req, res) end)

    local route_match = lists(self.routes[req.method]):first(function(r)
      ---@cast r KS.Web.RouteConfig
      return types.is.truthy(r.match(req.url))
    end)
    
    if route_match == nil then
      res:response(404, notfound(req.url), mime.html)
    else
      ---@cast route_match KS.Web.RouteConfig

      log.df('Matched route: %s', hs.inspect(route_match))

      req:setParams(route_match.match(req.url))
      
      route_match.handle(req, res)

      if res.file ~= nil then
        res:response(200, fs.readfile(res.file), mime.html)
      end

      if res.view and res.model then
        local ok, html = pcall(self.renderer, res.view, res.model)

        if not ok then
          res:response(500, server_error(html), mime.html)
        else
          res:response(200, html, mime.html)
        end
      end
    end


    serverlog.f("%s %s -> [%s] (%d)",
      req.method, req.url,
      route_match and route_match.pattern or 'none',
      res.status)

    return req, res
  end

  ---@param req Request
  ---@param res Response
  local function send(req, res)
    return res.body, res.status, res.headers
  end


  if self.listeners[port] == nil then
    local new_server = hs.httpserver.new(false, false)

    if new_server == nil then
      error('Failed to create hs.httpserver instance')
    end

    new_server
      :setInterface('localhost')
      :setPort(port)

      -- :getInterface()
      -- :getName()
      -- :getPort()
      -- :maxBodySize()
      -- :send()
      -- :setCallback()
      -- :setInterface()
      -- :setName()
      -- :setPassword()
      -- :setPort()
      -- :start()
      -- :stop()
      -- :websocket()


    ---@diagnostic disable-next-line redundant-parameter
    local handler_chain = compose(send, web_handler, accept)

    new_server:setCallback(handler_chain)

    self.listeners[port] = new_server
  end

  return self.listeners[port]
end


return setmetatable({}, webserver_meta) --[[@as KS.Web.Server]]
