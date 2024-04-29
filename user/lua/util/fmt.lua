return function (msg, ...)
  return string.format(msg, table.unpack({...}))
end