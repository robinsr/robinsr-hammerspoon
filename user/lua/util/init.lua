local List   = require 'user.lua.lib.list'
local Prms   = require 'user.lua.lib.params'
local Str    = require 'user.lua.lib.string'
local Tabl   = require 'user.lua.lib.table'
local tc     = require 'user.lua.lib.typecheck'
local json   = require 'user.lua.util.json'

local U = {}

U.log = require('user.lua.util.logger').log

U.fmt = Str.fmt
U.join = Str.join
U.split = Str.split
U.pad = Str.pad
U.trim = Str.trim

U.json = json

U.notNil = tc.notNil
U.isString = tc.isString
U.isTable = tc.isTable

U.d1 = { depth = 1 }
U.d2 = { depth = 2 }
U.d3 = { depth = 3 }

U.forEach = List.forEach
U.map = List.map
U.filter = List.filter
U.reduce = List.reduce
U.every = List.every
U.any = List.any

U.keys = Tabl.keys
U.vals = Tabl.vals
U.merge = Tabl.merge
U.concat = Tabl.concat
U.insert = Tabl.insert
U.contains = Tabl.contains
U.path = Tabl.path
U.haspath = Tabl.haspath
U.pick = Tabl.pick


U.default = Prms.default
U.spread = Prms.spread
U.noop = Prms.noop


--
-- FUNCTION - Delay execution of function fn by msec
--
---@param msec integer delay in MS
---@param fn function function to run after delay
---@returns nil
function U.delay(msec, fn)
  hs.timer.doAfter(msec, fn)
end




return U
