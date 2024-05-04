--[[
  REFERENCE - Lua-LSP types

  nil
  any
  boolean
  string
  number
  integer
  function
  table
  thread
  userdata
  lightuserdata
]]

---@class MidClassObject
---@field static table

---@generic T: any
---@alias IteratorFn fun(item: T, index: integer): nil

---@generic T: any
---@alias PredicateFn fun(item: T, index: integer): boolean


---@generic I: any Input type
---@generic O: any Output type
---@alias MappingFn fun(item: I, index: integer): O


---@generic T: any List item type
---@generic R: any Type list is reduced to
---@alias ReducerFn fun(memo: R, item: T, index: integer): R

return {}