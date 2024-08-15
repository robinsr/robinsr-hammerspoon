local inspect  = require 'inspect'
local sh       = require 'user.lua.adapters.shell'
local alert    = require 'user.lua.interface.alert'
local desktop  = require 'user.lua.interface.desktop'
local dialog   = require 'user.lua.interface.dialog'
local channel  = require 'user.lua.lib.channels'
local func     = require 'user.lua.lib.func'
local lists    = require 'user.lua.lib.list'
local Option   = require 'user.lua.lib.optional' 
local params   = require 'user.lua.lib.params'
local strings  = require 'user.lua.lib.string'
local types    = require 'user.lua.lib.typecheck'
local colors   = require 'user.lua.ui.color'
local image    = require 'user.lua.ui.image'
local logr     = require 'user.lua.util.logger'
local hss      = require 'user.lua.util.hs-objects'


local log = logr.new('ModSpaces', 'info')


local Spaces = {}


-- Returns either `"hs"` or `"yabai"` indicating that the space is maanged by 
-- one or the other and commands to the other program will not work or error out
---@param spaceId int
---@return 'hs'|'yabai'
local function getSpaceManager(spaceId)
  params.assert.number(spaceId)

  local spaceIndex = desktop.getIndexOfSpace(spaceId)
  
  local ok, result = pcall(function()
    local yabai = KittySupreme:getService('Yabai')

    if yabai ~= nil and yabai then
      return yabai:getLayout(spaceIndex)
    else
      return 'no-yabai'
    end
  end)

  if ok and lists({"bsp","stack"}):includes(result) then
    return 'yabai'
  end

  return 'hs'
end


-- Ensures the current space is managed by yabai (space.type ~= 'bsp'|'stack')
---@type ks.command.verifyfn
local function verifyYabaiSpace(cmd, ctx)
  return getSpaceManager(ctx.activeSpace) == 'yabai'
end


-- Ensures the current space is managed by yabai (space.type ~= 'bsp'|'stack')
---@type ks.command.verifyfn
local function verifyHammerSpace(cmd, ctx)
  return getSpaceManager(ctx.activeSpace) == 'hs'
end


-- Ensures there is an active window
---@type ks.command.verifyfn
local function verifyActiveWindow(cmd, ctx)
  return ctx.activeWindow ~= nil
end


---@type ks.command.flag[]
Spaces.NO_ALERT = { 'no-alert', 'no-chooser' }

---@type ks.command.verifyfn[]
Spaces.HAS_ACTIVE = { verifyActiveWindow }

---@type ks.command.verifyfn[]
Spaces.YABAI_MANAGED_SPACE = { verifyYabaiSpace }

---@type ks.command.verifyfn[]
Spaces.YABAI_MANAGED_WINDOW = { verifyActiveWindow, verifyYabaiSpace }

---@type ks.command.verifyfn[]
Spaces.HS_MANAGED_SPACE = { verifyHammerSpace }

---@type ks.command.verifyfn[]
Spaces.HS_MANAGED_WINDOW = { verifyActiveWindow, verifyHammerSpace }


Spaces.RESIZE_SPEED = 0.4

Spaces.INBOUNDS = {
  YES = true,
  NO = false,
}




---
-- Gets text input via a HS TextInput and applies the resulting
-- name to the current space as a yabai "label"
---
function Spaces.rename()
  local yabai = KittySupreme:getService('Yabai')

  local space = yabai:getSpace()
  local label = params.default(space.label, strings.fmt("Space #%d", space.index))

  local title = "Rename Space"
  local info = "Input a name for current space"

  local clicked, input = dialog.prompt(title, info, label)

  log.f("RenameSpace - Clicked %s; Value: %s", clicked, input)

  if clicked then
    channel.publish('ks:space:rename', {
      space = space.index,
      label = input,
    })
  end
end


---@class SpaceChangeParams
---@field to number
---@field from number

--
-- Handles space change events
-- Currently responds after Yabai has already changed the active space
--
---@param cmd ks.command
---@param ctx ks.command.context The event context
---@param params SpaceChangeParams to/from index of change
function Spaces.onSpaceChange(cmd, ctx, params)

  ---@type [string, number, string]
  local disp = { 'Irratic space change...', alert.timing.NORMAL, 'tornado' }

  local screen = desktop.getScreen('active')
  local submsg = strings.fmt("(%s - %s)", screen:id(), screen:name())
  local movement = { params.from, params.to }

  if (lists(movement):every(types.isString)) then
    message = strings.fmt("Moved to space %s", movement[1])

    local from, to = tonumber(movement[1]), tonumber(movement[2])

    if (from - to > 0) then 
      disp = { 'Moved space left', alert.timing.FAST, 'spaceLeft' }
    elseif (from - to < 0) then
      disp = { 'Moved space right', alert.timing.FAST, 'spaceRight' }
    else
      disp = { 'Moved space', alert.timing.NORMAL, 'tornado' }
    end
  end

  local text, timing, icon = table.unpack(disp)

  return alert:new(text)
    :icon(image.fromIcon(icon, 72, colors.black))
    :show(timing)
end


-- 
-- Cycles current space's Yabai layout from BSP to Float, to Stack and back again
--
---@type ks.command.execfn
function Spaces.cycleLayout(cmd, ctx)
  local yabai = KittySupreme:getService('Yabai')
  local sbar = KittySupreme:getService('SketchyBar')

  local layouts = { "bsp", "float", "stack" }

  local index = desktop.getIndexOfSpace(ctx.activeSpace)
  local windows = desktop.getWindowsForSpace(ctx.activeSpace)
  local layout = yabai:getLayout(index)


  local nextlayout
  for i, nl in ipairs(layouts) do
    if nl == layout then
      nextlayout = layouts[i % #layouts + 1]
    end
  end

  yabai:setLayout(index, nextlayout)
  sbar:setSpaceIcon(index, nextlayout, #windows)

  return ("Changed layout to %s"):format(nextlayout)
end


--
-- Returns a 'ks.command.execfn' function that invokes Yabai#message with supplied args
--
---@param args string  static args to use on each invoke of fn
---@param msg? string  optional return message
---@return ks.command.execfn
function Spaces.createMessageFn(args, msg)
  return function(cmd, ctx)
    local yabai = KittySupreme:getService('Yabai')
    local result = yabai.message(table.unpack(sh.split(args)))

    log.vf('Yabai cmd "%s" exited with code %q', result.command, result.status or 'none')
    
    return msg
  end
end


--
-- Returns a 'ks.command.execfn' function that invokes Yabai#setGrid with suppiled args
--
---@param grid  Dimensions   Dimensions defining the grid's columns (y) and rows (x)
---@param span  Dimensions   Number of grid units the window will span
---@param start Coord        Start position  of window (the top-left)
---@return ks.command.execfn
function Spaces.createYGridFn(grid, span, start)
  local yabai = KittySupreme:getService('Yabai')

  return function(cmd, ctx)
    return Option:ofNil(ctx.activeWindow)
      :map(function(win)
        local result = yabai.setGrid(win:id(), grid, span, start)

        if result then
          return { err = result }
        else
          return cmd.title
        end
      end)
      :orElse('No active window')
  end
end


--
--
---@param grid  Dimensions   Dimensions defining the grid's columns (y) and rows (x)
---@param span  Dimensions   Number of grid units the window will span
---@param start Coord        Start position  of window (the top-left)
function Spaces.createGridFn(grid, span, start)
  local window_units = {
    x = start.x / grid.w,
    y = start.y / grid.h,
    w = span.w / grid.w,
    h = span.h / grid.h,
  }

  local ensure_bounds = true
  local move_timing = 0.2

  ---@type ks.command.execfn
  return function(cmd, ctx)
    return Option:ofNil(ctx.activeWindow)
      :map(function(win)
        ---@cast win hs.window

        local ok, result = pcall(function()
          local screen = desktop.getScreen('active')
          local area = desktop.getAvailableSpace('active')
          local pos = hs.geometry.new(window_units):fromUnitRect(area) --[[@as hs.geometry]]

          log.df("Screen frame: %s", inspect(area.table))
          log.df("window frame: %s", inspect(pos.table))

          win:move(pos, screen, ensure_bounds, move_timing)

          return cmd.title
        end)

        return ok and { ok = result } or { err = result }
      end)
      :orElse({ err = 'No active window' })
  end
end



---@param scaleFn ExchangeFn<Dimensions, Coord> string
---@return ks.command.execfn
function Spaces.createScaleFn(scaleFn)
  ---@type ks.command.execfn
  return function(cmd, ctx)
    return Option:ofNil(ctx.activeWindow):map(function(win)
      ---@cast win hs.window
      local scrn = desktop.getScreen('active')
      local area = desktop.getAvailableSpace('active')
      local pct = win:frame():toUnitRect(area) --[[@as Dimensions]]

      local size = win:frame():copy():scale(scaleFn(pct)):intersect(area)

      win:move(size, scrn, Spaces.INBOUNDS.YES, Spaces.RESIZE_SPEED)

      return { ok = cmd.hotkey:getLabel('full') }
    end)
    :orElse('No active window')
  end
end


---@type ks.command.config[]
Spaces.cmds = {}


return Spaces