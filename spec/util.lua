local assert = require 'luassert'
local pretty = require 'pl.pretty'
local plstr = require 'pl.stringx'

local testutil = {}

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
    mouse = {},
    screen = {},
    window = {},
    console = {
      consoleFont = hs_noop,
      maxOutputHistory = hs_noop,
    },
    inspect = hs_noop,
    drawing = {
      color = {
        list = hs_spy_returns({}),
        colorsFor = hs_spy_returns({}),
        systemColors = hs_spy_returns({}),
      }
    },
    logger = {
      new = spy.new(function()
        return {
          new = hs_noop,
          getLogLevel = hs_spy_returns(1)
        }
      end),
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
    image = {
      imageFromPath = hs_spy_returns(spy_hs_image)
    },
    styledtext = {
      new = hs_spy_returns({}),
    },
    eventtap = {
      event = {
        types = {}
      }
    }
  }
end

return testutil

