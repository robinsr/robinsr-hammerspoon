local List = {}

--
-- WIP! - Adds an item to the end of a list-like table
--
---@generic T
---@param items T[] list-like table
---@param ... T The item to add
---@return T[] List with new items appended
function List.push(items, ...)
  for i, add in ipairs({...}) do
    table.insert(items, add)
  end

  return items
end

--
-- WIP! - Removes and returns last item from a list-like table
--
---@generic T
---@param items T[] list-like table
function List.pop(items)
  local last = items[#items]
  -- local remain = table.pack(select(#items - 1, table.unpack(items)))
  items[#items] = nil
  
  return last
end


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
-- Filters items in a list to just those that pass predicate
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
-- Finds the first item in a list that passes a predicate
--
---@generic T : any
---@param items T[] list-like table
---@param fn PredicateFn The filter function
---@return T[] The filtered list
function List.first(items, fn)
  for k, v in ipairs(items) do
    if (fn(v, k)) then
      return v
    end
  end
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


--
-- Tests every item in a list-like table; all must pass
--
---@generic T : any
---@param items T[] list-like table
---@param fn PredicateFn The test function
---@return boolean
function List.every(items, fn)
  for k, v in ipairs(items) do
    if (fn(v, k) ~= true) then return false end
  end

  return true
end

--
-- Tests every item in a list-like table; at least one must pass
--
---@generic T : any
---@param items T[] list-like table
---@param fn PredicateFn The test function
---@return boolean
function List.any(items, fn)
  for k, v in ipairs(items) do
    if (fn(v, k)) then return true end
  end

  return false
end



function List.new()
  
end

return List