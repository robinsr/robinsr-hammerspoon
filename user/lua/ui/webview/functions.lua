local desk     = require 'user.lua.interface.desktop'
local html     = require 'lua_to_html'
local lists    = require 'user.lua.lib.list'
local tables   = require 'user.lua.lib.table'
local paths    = require 'user.lua.lib.path'
local params   = require 'user.lua.lib.params'
local strings  = require 'user.lua.lib.string'
local types    = require 'user.lua.lib.typecheck'
local colors   = require 'user.lua.ui.color'
local images   = require 'user.lua.ui.image'
local logr     = require 'user.lua.util.logger'

local log = logr.new('aspect-fn', 'debug')

local a_funcs = require("aspect.funcs")
local a_utils = require("aspect.utils")

local aspect = require("user.lua.ui.webview.aspect")


---@alias ks.aspect.render_fn fun(...: any): string
---@alias ks.aspect.compile_fn fun(compiler: aspect.compiler, args: table): string,boolean?

---@class ks.aspect.fn_opts
---@field callback ks.aspect.render_fn
---@field compile ks.aspect.compile_fn


--
-- Adds a template function to Aspect
--
---@param fn_name string
---@param fn_args string[]
---@param options ks.aspect.render_fn | ks.aspect.fn_opts
local function add_func(fn_name, fn_args, options)
  local function proxy(fn)
    return function(__, args)
      ok, result = pcall(fn, __, args)

      if not ok then
        error(('Error in template function "%s": %s')
          :format(fn_name, tostring(result)))
      end

      return result
    end
  end


  fn_args = lists(fn_args or {})
    :map(function(arg) return strings.split(arg, ':') end)
    :map(function(args) return {
      name = args[1], type = args[2]
    } end)

  if type(options) == 'function' then
    a_funcs.add(fn_name, { args = fn_args }, proxy(options))
    return
  end

  local fn_config = {
    args = fn_args,
    compile = options.compile,
  }

  a_funcs.add(fn_name, fn_config, proxy(options.callback))
end


--
-- Adds a function alias for macros (macros are wonky in aspect, this is more reliable)
--
---@param file string Filename containing the macro template
---@param name string Name of the macro as appears in template file
---@param arg_def string[] Array of arg definition strings ("[name]:[type]")
local function macro_func(file, name, arg_def)
  local fn_name = 'm' .. name
  
  add_func(fn_name, arg_def, function(__, args)
    local result, err = aspect:render_macro(file, name, args)
    return err == nil and tostring(result) or error(err)
  end)
end


-- local C = require('pl.comprehension').new()
-- return C('x..":title" for x')(keys)

-- ---@param keys string[]
-- local function arg_set_string(keys)
--   return lists(keys):reduce({}, function(m,k) m[k] = k..':string' end)
-- end


-- local attrs = {
--   title = 'title:string',
--   type  = 'type:string',

-- }


macro_func('macros.view' ,'SVG', { 'content:string' })
macro_func('macros.view' ,'KBD', { 'keys:string', 'scale:number' })
macro_func('macros.view' ,'Card', { 'title:string', 'classnames:table', 'content:string' })
macro_func('macros.view' ,'Collapse', { 'title:string', 'classnames:table', 'content:string' })
macro_func('macros.view' ,'Button', { 'color:string', 'size:string', 'content:string', 'attrs:any' })
macro_func('macros.view' ,'DataImage', { 'name:string', 'width:number', 'height:number' })


add_func('modelfn', {'model:table', 'fn:string', 'args:table'}, function(__, args)
  local ok, result = pcall(args.model[args.fn], args.model, table.unpack(args.args or {}))

  if not ok then
    error(result)
  end

  return result
end)


add_func('html', {'el:string', 'attrs:table', 'children:array'}, function(_, args)
  local html_table = lists({ args.children }):flatten():shift(args.el):values()

  return html:translate({
    tables(args.attrs or {}):merge(html_table)
  })
end)


add_func('get_ctx', {}, {
  compile = function(compiler, args)
    local vars = a_utils.implode_hashes(compiler:get_local_vars())
    
    local context = vars and '__.setmetatable({ ' .. vars .. ' }, { __index = _context })' or '_context'  
    
    return '__.fn.get_ctx(__, ' .. context .. ', _context)', false
  end,
  callback = function(__, context, _context)
    -- should merge context and _context 
    -- (context is named params, _context is extra positional args)
    return _context
  end
})


add_func('encoded_img', {'source:table','width:number','height:number','color:string'}, function(_, args)
  local color = desk.darkMode() and colors.white or colors.black

  if args.source.path then
    local filepath = paths.expand(args.source.path)
    return images.from_path(filepath, args.width, args.height):encodeAsURLString()
  end

  if args.source.name then
    return images.from_icon(args.source.name, args.width, color):encodeAsURLString()
  end

  if args.source.point then
    return images.from_codepoint(args.source.point, args.width, color):encodeAsURLString()
  end

  return ''
end)