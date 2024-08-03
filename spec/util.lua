local inspect = require 'inspect'
local assert = require 'luassert'
local pretty = require 'pl.pretty'
local plstr = require 'pl.stringx'

local testutil = {}

local print = print

testutil.pretty = pretty.write


--
-- Get a variable-length list of single alpha characters
--
---@param len? integer desired length of list
function testutil.alphalist(len)
  len = len or 4
  
  local alphas = "abcdefghijklmnopqrstuvwxyz"
  local chars = {}

  for i=1,len do
    table.insert(chars, alphas:sub(i, i))
  end

  return table.pack(table.unpack(chars))
end


--
-- Get a test table
--
---@return table<string,string>
function testutil.ttable()
  local keys = { 'foo', 'bar', 'baz', 'quz', 'quuz' }
  local tbl = {}

  for i,v in ipairs(keys) do
    tbl[v] = string.reverse(v)
  end

  return tbl
end


---@param pattern string
---@param ... any
---@return string
function testutil.fmt(pattern, ...)

  local vars = {}

  for i, v in ipairs({...}) do
    table.insert(vars, type(v) == 'table' and pretty.write(v) or tostring(v))
  end

  return string.format(pattern, table.unpack(vars))
end

--
--
--
function testutil.msg(...)
  return table.concat(table.pack(...), " ")
end

--
--
--
function testutil.msgf(pat, ...)
  return string.format(pat, table.unpack({...}))
end

--
--
--
function testutil.hl(thing, chars)
  local notNil = type(thing) ~= 'nil'
  local isStr = type(thing) == 'string'

  chars = (notNil and chars) or (isStr and '""') or '<>'
  thing = thing or (thing == false and 'false') or 'nil'
  return table.concat{ chars:sub(1,1), thing, chars:sub(2,2) }
end

--
--
--
function testutil.dump(...)
  for i, v in ipairs({...}) do
    print("")
    print(type(v) == 'table' and pretty.write(v) or tostring(v))
  end
end


--
--
--
function testutil.group(msg, testfn)

  local ok, err = pcall(testfn)

  if not ok then
    error(string.format("%s\n\n%s", msg, plstr.indent(tostring(err), 8)), 2)
  end
end


function testutil.pkgloaded()
  local lib_pkgs = {}

  for k,v in pairs(package.loaded) do
    if ("%s"):format(k):match("^user%.") then
      table.insert(lib_pkgs, k)
    end
  end

  print("User package.loaded:")
  print(pretty.write(lib_pkgs))
end



testutil.logger_mod = "user.lua.util.logger"

--
-- Usage: package.loaded[tutil.logger_mod] = tutil.mock_logger(spy)
--
---@param spy any
---@param level? 'off'|'inspect'\'verbose'|'debug'|'info'|'warning'|'error'
function testutil.mock_logger(spy, level)
  local hs_noop = spy.new(function() end)

  level = level or 'off'

  local mock_logger = {
    new = spy(function()
      return {
        e = hs_noop,
        ef = hs_noop,
        w = hs_noop,
        wf = hs_noop,
        i = hs_noop,
        f = hs_noop,
        d = hs_noop,
        df = hs_noop,
        v = hs_noop,
        vf = hs_noop,
        inspect = level =='inspect' and testutil.dump or hs_noop,
      }
    end)
  }

  return mock_logger
end


--
--
--
function testutil.hs_mock(spy)
  local hs_noop = spy.new(function() end)

  local hs_spy_returns = function(ret_val)
    return spy.new(function() return ret_val end)
  end


  local spy_hs_image = {
    size = hs_noop,
    setSize = hs_noop,
    template = hs_noop,
  }


  return {
    eventtap = {
      event = {
        types = {}
      }
    },
    canvas = {
      new = spy.new(function()
        return {
          size = hs_noop,
          minimumTextSize = hs_noop,
          imageFromCanvas = hs_spy_returns(spy_hs_image),
        }
      end)
    },
    console = {
      consoleFont = hs_noop,
      maxOutputHistory = hs_noop,
    },
    drawing = {
      color = {
        list = hs_spy_returns({}),
        colorsFor = hs_spy_returns({}),
        systemColors = hs_spy_returns({}),
      }
    },
    httpserver = {
      new = hs_spy_returns({}),
    },
    image = {
      imageFromPath = hs_spy_returns(spy_hs_image)
    },
    inspect = inspect,
    logger = {
      new = spy.new(function()
        return {
          new = hs_noop,
          getLogLevel = hs_spy_returns(1)
        }
      end),
    },
    mouse = {},
    screen = {},
    styledtext = {
      new = hs_spy_returns({}),
    },
    timer = {
      doafter = hs_noop(),
    },
    window = {},
  }
end

return testutil

