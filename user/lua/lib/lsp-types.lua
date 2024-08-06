---@meta

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

---@alias int integer
---@alias num number
---@alias bool boolean


---@class Array<T>: { [int]: T }

---@class Dict<T>: { [string]: T }

---@class Hash<N, T>: Table : { [N]: T }

---@class Record<N, T>: { [N]: T }

---@class MidClassObject
---@field static table

---@generic T: any
---@alias IteratorFn fun(item: T, index: int): nil

---@generic T: any
---@alias PredicateFn<T> fun(item: T, index: int): boolean

---@generic T: any
---@alias boolfn<T> fun(item: T, index: int): bool

---@generic T: any - Input items type
---@generic C: any - Type items will be classified by
---@alias ClassifierFn<T,C> fun(item: T, index?: int): C

---@generic T: any - Type of items supplied
---@alias Supplier<T> fun(): T


---@generic I: any Input type
---@generic O: any Output type
---@alias MappingFn<I, O> fun(item: I, index: int): O


---@generic T: any List item type
---@generic R: any Type list is reduced to
---@alias ReducerFn fun(memo: R, item: T, index: int): R

---@class Coord
---@field x number
---@field y number

---@class Dimensions
---@field w number
---@field h number


return {}