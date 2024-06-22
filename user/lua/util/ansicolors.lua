local keys = {
  -- reset
  reset =      0,

  -- misc
  bright     = 1,
  dim        = 2,
  underline  = 4,
  blink      = 5,
  reverse    = 7,
  hidden     = 8,

  -- foreground colors
  black     = 30,
  red       = 31,
  green     = 32,
  yellow    = 33,
  blue      = 34,
  magenta   = 35,
  cyan      = 36,
  white     = 37,

  -- background colors
  blackbg   = 40,
  redbg     = 41,
  greenbg   = 42,
  yellowbg  = 43,
  bluebg    = 44,
  magentabg = 45,
  cyanbg    = 46,
  whitebg   = 47
}

local escapeString = string.char(27) .. '[%dm'


local function escapeNumber(number)
  return escapeString:format(number)
end


local function escapeKeys(str)
  local buffer = {}
  local number

  for word in str:gmatch("%w+") do
    number = keys[word]
    assert(number, "Unknown key: " .. word)
    table.insert(buffer, escapeNumber(number) )
  end

  return table.concat(buffer)
end


local function replaceCodes(str)
  return string.gsub(str,"(%%{(.-)})", function(_, str) return escapeKeys(str) end )
end


local function ansicolors( str )
  return replaceCodes('%{reset}' .. tostring(str or '') .. '%{reset}')
end


local P = {
  noReset = replaceCodes
}

local mt = {
  __call = function (_, str)
    return ansicolors(str)
  end
}

return setmetatable(P, mt)