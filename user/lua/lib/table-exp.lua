-- local tbx     = require 'pl.tablex'
-- local pretty  = require 'pl.pretty'
-- local types   = require 'user.lua.lib.typecheck'
-- local params  = require 'user.lua.lib.params'
-- local strings = require 'user.lua.lib.string'


-- ---@class Table
-- ---@field props table
-- ---@field fn TFunctions
-- ---@operator call:Table
-- local Table = {}


-- ---@class TFunctions
-- local tablefns = {}

-- --
-- -- Returns a single table composed of the combined key-values of all table parameters
-- --
-- ---@param ... table[] Tables to merge
-- ---@return table The merged table
-- function tablefns.merge(...)
--   local tables = table.pack(...)

--   for i,v in ipairs(tables) do
--     params.assert.tabl(v, i)
--   end

--   local merged = {}

--   for i, tabl in ipairs(tables) do
--     params.assert.tabl(tabl, i)
    
--     for k, v in pairs(tabl) do
--       merged[k] = v
--     end
--   end

--   return merged
-- end


-- --
-- -- Returns a single list-like table from the entries of all list-like table parameters
-- --
-- ---@param ... table[] Lists to concatenate
-- ---@returns table 
-- function tablefns.concat(...)
--   local tables = table.pack(...)
--   params.assert.tabl(tables)

--   local merged = {}

--   for i, tabl in ipairs(tables) do
--     params.assert.tabl(tabl, i)
    
--     for k, v in pairs(tabl) do
--       table.insert(merged, v)
--     end
--   end

--   return merged
-- end

-- function tablefns.keys(tabl)
--   return Table.keys({ props = tabl, fn = tablefns })
-- end


-- function tablefns.has(tabl, key)
--   return Table.has({ props = tabl, fn = tablefns }, key)
-- end


-- Table.fn = tablefns


-- local TablMeta = {}


-- TablMeta.__index = function(tabl, arg)
--   if (types.isTable(tabl.props) and types.notNil(tabl.props[arg])) then
--     return tabl.props[arg]
--   else
--     return Table[arg]
--   end
-- end


-- ---@return Table
-- local function create(ctx, init)
--   -- print('ctx', pretty.write(ctx), 'init', pretty.write(init))

--   if TablMeta.ident(ctx) then
--     error('You meant to call this as a function, not a method')
--   end


--   local o = { props = {} }
  
--   if types.isTable(init) then
--     if init.__index == Table then
--       return init
--     end

--     if types.isTable(init.props) then
--       o = { props = init.props }
--     end

--     o = { props = init }
--   end

--   return setmetatable(o, TablMeta)
-- end

-- TablMeta.__call = function(tabl, init) return create({}, init) end

-- TablMeta.__len = function(tabl) return #tabl.props end

-- TablMeta.__tostring = function(tabl) return pretty.write(tabl) end

-- TablMeta.ident = function(tabl)
--   return getmetatable(tabl) == TablMeta
-- end


-- ---@generic T
-- ---@param ... T[]
-- ---@return Table
-- function Table.new(...)
--   local args = table.pack(...)
--   return create(args[1], args[1])
-- end


-- --
-- -- Returns the underlying properties table
-- --
-- ---@return table
-- function Table:items()
--   return self.props
-- end


-- --
-- -- Returns a list keys found in `tabl`
-- --
-- ---@param strict? boolean Throw error if table is nil
-- ---@return string[] List of table's keys
-- function Table:keys(strict)
--   params.assert.tabl(self.props, 0)

--   local keys = {}

--   for key, _ in pairs(self.props) do
--     table.insert(keys, key)
--   end

--   return keys
-- end

-- --
-- -- Returns a list of values found in `tabl`
-- --
-- ---@param strict? boolean Throw error if table is nil
-- ---@return any[] list of keys
-- function Table:vals(strict)
--   params.assert.tabl(self.props)

--   local vals = {}

--   for _, val in pairs(self.props) do
--     table.insert(vals, val)
--   end

--   return vals
-- end


-- --
-- -- Determine if a table contains a given object
-- --
-- ---@param elem any An object to search the table for
-- ---@return boolean # true if the element could be f
-- function Table:contains(elem)
--   return hs.fnutils.contains(self.props, elem)
-- end


-- --
-- -- Returns the value at a given path in an object. Path is given as a vararg list of keys.
-- --
-- ---@param ... string A vararg list of keys
-- ---@return any Either a value if found or nil
-- function Table:get(...)
--   local value = self.props
--   local found = false
--   local path = {...}

--   for i, p in ipairs(path) do
--     if (value[p] == nil) then return end
--     value = value[p]
--     found = true
--   end

--   if (not found) then
--     return nil
--   end

--   return value
-- end


-- --
-- -- Assert not nil on a deep nested value in a table, using a dot-path string
-- --
-- ---@param path string Dot-path string key
-- ---@param nilMsg? string Optional error message when value is nil
-- ---@return boolean 
-- function Table:haspath(path, nilMsg)
--   params.assert.tabl(self.props, 0)

--   local val = self:get(table.unpack(strings.split(path, '.')))

--   if (types.notNil(val)) then
--     return true
--   end

--   if types.isString(nilMsg) then error(nilMsg) end

--   return false
-- end


-- --
-- -- Returns true if `tabl` is contains a non-nil value for key `key`
-- --
-- ---@param key string String-key to check for nill-ness
-- ---@param strict? boolean Throw error if table is nil
-- ---@return boolean
-- function Table:has(key, strict)
--   params.assert.tabl(self.props, 0)

--   return types.is_not.Nil(self:get(key))
-- end


-- --
-- -- Maps an array of string keys to associated values in a table
-- --
-- ---@param tabl table Table to pick values from
-- ---@param keys string[] List of keys to pick from table
-- ---@return table
-- function Table.pick(tabl, keys)
--   local picked = {}

--   for i, key in ipairs(keys) do
--     table.insert(picked, params.default(Table.get(tabl, key), ""))
--   end

--   return picked
-- end


-- --
-- -- Returns true if `tabl` is a lua table with zero string keys
-- --
-- ---@return boolean
-- function Table:isEmpty()
--   params.assert.tabl(self.props, 0)

--   local keys = self:keys()

--   if #keys > 0 then
--     return false
--   end

--   return true
-- end


-- --
-- -- Wait, I can just add methods to lua's table object?
-- --
-- -- Yes, but its not like a class with instance methods
-- --
-- -- Eg NOT 
-- -- tab1 = { this = 'that' }
-- -- tab2 = tab1:clone()
-- --
-- -- its just on the table
-- --
-- -- tab2 = table.clone(tab1)
-- --
-- -- And this implementation is naive, only copies array-like tables
-- --
-- function Table.clone(tabl)
--   return setmetatable(tabl, table)
-- end


-- return setmetatable({}, TablMeta) --[[@as Table]]