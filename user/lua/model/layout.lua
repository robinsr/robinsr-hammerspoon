local mod = {}


---@enum ks.layout.type
mod.layouts = {
  FLOAT = 'float',
  BSP = 'bsp',
  STACK = 'stack',
}

mod.layers = {}

---@enum ks.layout.sublayer
mod.sublayers = {
  AUTO = 'auto',
  BELOW = 'below',
  NORMAL = 'normal',
  ABOVE = 'above',
}


---@type table<ks.layout.type, ks.layout.sublayer>
mod.window_layers = {
  bsp   = 'auto',
  stack = 'auto',
  float = 'normal',
}


return mod