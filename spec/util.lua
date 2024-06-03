local assert = require 'luassert'
local pretty = require 'pl.pretty'
local plstr = require 'pl.stringx'

local testutil = {}

function testutil.msg(...)
  return table.concat(table.pack(...), " ")
end

function testutil.msgf(pat, ...)
  return string.format(pat, table.unpack({...}))
end

function testutil.hl(thing, chars)
  local notNil = type(thing) ~= 'nil'
  local isStr = type(thing) == 'string'

  chars = (notNil and chars) or (isStr and '""') or '<>'
  thing = thing or (thing == false and 'false') or 'nil'
  return table.concat{ chars:sub(1,1), thing, chars:sub(2,2) }
end

function testutil.dump(...)
  for i, v in ipairs({...}) do
    print(type(v) == 'table' and pretty.write(v) or tostring(v))
  end
end

function testutil.group(msg, testfn)

  local ok, err = pcall(testfn)

  if not ok then
    error(string.format("%s\n\n%s", msg, plstr.indent(tostring(err), 8)), 2)
  end
end

return testutil

