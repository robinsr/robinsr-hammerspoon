local func   = require 'user.lua.lib.func'
local params = require 'user.lua.lib.params'
local tables = require 'user.lua.lib.table'
local types  = require 'user.lua.lib.typecheck'
local logr   = require 'user.lua.util.logger'

local log = logr.new('watchable', 'info')

---@generic T : any
---@alias hs.watch.update<T> { watcher: string, path: string, key: string, prev: T, value: T }

---@generic T : any
---@alias hs.watch.callback<T> fun(fn: hs.watch.update<T>): any


---@class HS.Watchable : hs.watchable
---@field [string] any


---@class ks.watch
local Watch = {}

--
-- Creates a new `hs.watchable` object
--
---@generic T : table
---@param path  string   - The global name for this internal table that external code can refer to the table as.
---@param ext?  boolean  - (optional) specifying whether external code can make changes to keys within this table (bi-directional communication).
---@param init? T        - (optional) initial value to set on the watchable
---@return HS.Watchable
function Watch.create(path, ext, init)
  local watchable = hs.watchable.new(path, ext) --[[@as HS.Watchable]]

  if init ~= nil then
    for k,v in pairs(init) do
      watchable[k] = v
    end
  end

  return watchable
end

Watch.listen = {}

--
-- Returns a watchable object for the watched object at `path`
--
---@param path  string   - path of object
---@return HS.Watchable
function Watch.listen.all(path)
  params.assert.string(path, 1)

  return hs.watchable.watch(path, '*') --[[@as HS.Watchable]]
end


--
-- Returns a watchable object for the value at `key` in the watched table at `path`
--
---@param path  string   - path of object
---@param key   string   - key of value within the watched table
---@return HS.Watchable
function Watch.listen.key(path, key)
  params.assert.string(path, 1)
  params.assert.string(key, 2)

  return hs.watchable.watch(path, key) --[[@as HS.Watchable]]
end


--
-- Registers an onChange handler, called whenever any changes occur on object at `path`
--
---@param path  string             - path of object
---@param fn    hs.watch.callback  - function to call on changes
function Watch.listen.onPathChange(path, fn)
  params.assert.string(path, 1)
  params.assert.func(fn, 2)

  local callback = function(watcher, path, key, old, new)
    pcall(fn, { watcher = watcher, path = path, key = key, prev = old, value = new })
  end

  hs.watchable.watch(path, callback) --[[@as HS.Watchable]]
end


--
-- Registers an onChange handler, called when the value of `key` is updated in `path`
--
---@param path  string             - path of object
---@param key   string             - (optional) key of item in watchable object
---@param fn    hs.watch.callback  - function to call on changes
function Watch.listen.onKeyChange(path, key, fn)
  params.assert.string(path, 1)
  params.assert.string(key, 2)
  params.assert.func(fn, 3)

  local callback = function(watcher, path, key, old, new)
    pcall(fn, { watcher = watcher, path = path, key = key, prev = old, value = new })
  end

  hs.watchable.watch(path, key, callback) --[[@as HS.Watchable]]
end

return Watch