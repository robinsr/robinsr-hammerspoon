local inspect  = require 'inspect'
local alert    = require 'user.lua.interface.alert'
local desktop  = require 'user.lua.interface.desktop'
local dialog   = require 'user.lua.interface.dialog'
local sh       = require 'user.lua.adapters.shell'
local sub      = require 'user.lua.lib.channels'.subscribe
local pub      = require 'user.lua.lib.channels'.publish
local lists    = require 'user.lua.lib.list'
local Option   = require 'user.lua.lib.optional' 
local params   = require 'user.lua.lib.params'
local strings  = require 'user.lua.lib.string'
local types    = require 'user.lua.lib.typecheck'
local icons    = require 'user.lua.ui.icons'
local logr     = require 'user.lua.util.logger'
local hss      = require 'user.lua.util.hs-objects'


local log = logr.new('ModSpaces', 'info')


local Spaces = {}

---@type ks.command.flag[]
Spaces.NO_ALERT = { 'no-alert' }

---@type ks.command.verifyfn[]
Spaces.HAS_ACTIVE = { Spaces.verifyActiveWindow }

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
    pub('ks:space:rename', {
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

  icon = icons.static:get(icon)

  return alert:new(text):icon(icon):show(timing)
end


-- 
-- Cycles current space's Yabai layout from BSP to Float, to Stack and back again
--
---@type ks.command.execfn
function Spaces.cycleLayout(cmd, ctx)
  local yabai = KittySupreme:getService('Yabai')
  local sbar = KittySupreme:getService('SketchyBar')

  local layouts = { "bsp", "float", "stack" }

  local space = yabai:getSpace()
  local layout = space.type or 'stack'
  local index = space.index

  local nextlayout
  for i, nl in ipairs(layouts) do
    if nl == layout then
      nextlayout = layouts[i % #layouts + 1]
    end
  end

  yabai:setLayout(index, nextlayout)
  sbar:setSpaceIcon(index, nextlayout, #space.windows)

  return ("Changed layout to %s"):format(nextlayout)
end


---@type ks.command.verifyfn
function Spaces.verifyActiveWindow(cmd, ctx)
  local active = desktop.activeWindow()
  
  log.df("hasActiveWindow verfier running (%s): %q", cmd.id, active and active:title() or false)
  
  return types.notNil(active)
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

  ---@type ks.command.execfn
  return function(cmd, ctx)
    return Option:ofNil(ctx.activeWindow)
      :map(function(win)
        ---@cast win hs.window

        local ok, result = pcall(function()
          local sbar = KittySupreme:getService('SketchyBar').running
          
          local screen = desktop.getScreen('active')
          local frame = screen:frame()

          local default_xscale = 0.98 
          local default_yscale = 0.98
          local sbar_height = 40
          local sbar_yscale = ((frame.h-sbar_height)/frame.h) * 0.98

          local screen_scale = { 
            x = default_xscale,
            y = sbar and sbar_yscale or default_yscale
          }

          local screen_offset = {
            x = 0, y = sbar and -sbar_height/2 or 0
          }


          local area = frame:copy()
            :move(screen_offset)
            :scale(screen_scale)
          
          local window_units = {
            x = start.x / grid.w,
            y = start.y / grid.h,
            w = span.w / grid.w,
            h = span.h / grid.h,
          }

          local pos = hs.geometry.new(window_units):fromUnitRect(area) --[[@as hs.geometry]]

          log.df("Screen frame: %s", inspect(area.table))
          log.df("window frame: %s", inspect(pos.table))

          win:move(pos, screen, true, 0.2)

          return cmd.title
        end)

        return { [ok and 'ok' or 'err'] = result }
      end)
      :orElse({ err = 'No active window' })
  end
end



---@type ks.command.config[]
Spaces.cmds = {
--   {
--     id = 'spaces.evt.onSpaceChange',
--     exec = Spaces.onSpaceChange,
--     url = "spaces.changed",
--   },
--   {
--     id = 'spaces.evt.onSpaceCreated',
--     exec = Spaces.onSpaceCreated,
--     url = "spaces.created",
--   },
--   {
--     id = 'spaces.evt.onSpaceDestroyed',
--     exec = Spaces.onSpaceDestroyed,
--     url = "spaces.destroyed",
--   },
--   {
--     id = 'spaces.evt.onDisplayChange',
--     exec = function() end,
--     url = "display.changed",
--   },
}

return Spaces