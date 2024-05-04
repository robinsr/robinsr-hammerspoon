local List = {}

--
-- Iterates over item in a list
--
---@generic T : any
---@param items T[] list-like table
---@param fn IteratorFn The iteration function
---@return nil
function List.forEach(items, fn)
  for k, v in ipairs(items) do
    fn(v, k)
  end
end

--
-- Maps item in a list
--
---@generic T : any
---@param items T[] list-like table
---@param fn MappingFn Mapping function
---@return T[]
function List.map(items, fn)
  local mapped = {}

  for k, v in ipairs(items) do
    table.insert(mapped, k, fn(v, k))
  end

  return mapped
end

--
-- Filters item in a list
--
---@generic T : any
---@param items T[] list-like table
---@param fn PredicateFn The filter function
---@return T[] The filtered list
function List.filter(items, fn)
  local filtered = {}

  for k, v in ipairs(items) do
    if (fn(v, k)) then
      table.insert(filtered, v)
    end
  end

  return filtered
end


--
-- Reduces items to a single value
--
---@generic T : any
---@generic R : any
---@param init R Initial value of reduction
---@param items T[] list-like table
---@param reducerFn ReducerFn The reducer function
---@return R The filtered list
function List.reduce(init, items, reducerFn)
  List.forEach(items, function(item, i)
    initial = reducerFn(init, item, i)
  end)

  return initial
end

return List