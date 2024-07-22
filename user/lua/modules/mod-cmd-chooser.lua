local chooser = require 'hs.chooser'
local lists   = require 'user.lua.lib.list'
local regex   = require 'user.lua.lib.regex'
local strings = require 'user.lua.lib.string'
local texts   = require 'user.lua.ui.text'
local types   = require "user.lua.lib.typecheck"

local log = require('user.lua.util.logger').new('mod-cmd-chooser', 'debug')


---@class ChooserModCtx
---@field chooser hs.chooser

---@class ChooserModules
---@field setup CmdSetupFn<ChooserModCtx | CommandCtx>
---@field exec CmdExecFn<ChooserModCtx | CommandCtx>


--
--
--
local get_cmd_choices = function()
  local EVT_FILTER = regex.glob('!*.(evt|event|events).*')

  return lists(KittySupreme.commands)
    :filter(function(cmd)
      return EVT_FILTER(cmd.id) and not lists(cmd.flags):includes('no-chooser')
    end)
    :map(function(cmd)
      ---@cast cmd Command
      return {
        id = cmd.id,
        text = cmd.title or cmd.id,
        subText = cmd.desc or ("%s - %s"):format(cmd.id, cmd.module),
        image = cmd:getMenuIcon(256),
        valid = types.isFalse(cmd:has_flag('invalid_choice'))
      }
    end)
    :values()
end


--
--
--
local on_choice = function(selected)
   log.f("Chosen item: %s", hs.inspect(selected))

  if types.isNil(selected) then
    error('No selection passed to chooser handler')
  end

  local chosen_id = selected.id

  local cmd = KittySupreme.commands:first(function(cmd) return cmd.id == chosen_id end)

  if types.isNil(cmd) then
    error(('Could not find command with id %q'):format(chosen_id))
  end

  ---@cast cmd Command
  cmd:invoke('chooser', {})
end


--
--
--
local on_invalid_choice = function(selected)
  log.f("Chosen (invalid) item: %s", hs.inspect(selected))

  if types.isNil(selected) then
    error('No selection passed to chooser handler')
  end

  local chosen_id = selected.id

  local cmd = KittySupreme.commands:first(function(cmd) return cmd.id == chosen_id end)

  if types.isNil(cmd) then
    error(('Could not find command with id %q'):format(chosen_id))
  end

  ---@cast cmd Command
  -- cmd:invoke('chooser', {}) -- possible new invoke type 'chooser-invald'?
end


--
--
--
local on_right_click = function(index)
  if types.isNil(index) then
    error('No selection passed to chooser invalid handler')
  end

  local all_choices = get_cmd_choices()

  log.df("Chooser items: %s", hs.inspect(all_choices))
  
  local cmd = all_choices[index]

  if types.isNil(cmd) then
    error(('Could not find command with index %q'):format(index))
  end

  log.f("right-click on item %s", hs.inspect(cmd))
end


--
--
--
---@type ChooserModules
local ChooserModule = {
  
  exec = function (cmd, ctx, params)
    -- not necessary to call refresh unless chooser's options have changed
    -- ctx.chooser:refreshChoicesCallback()
    ctx.chooser:show()
  end,

  setup = function (cmd)
    local cmd_chooser = chooser.new(on_choice)
      :choices(get_cmd_choices)
      :invalidCallback(on_invalid_choice)
      :rightClickCallback(on_right_click)
      :placeholderText('Search KittySupreme commands')
      :searchSubText(true)


    return { chooser = cmd_chooser }
  end
}


local module_desc = [[
Launches the HS chooser widget with a list of commands.
Note — limited to just the commands invocable from the chooser, ie with no arguments.
]]


return {
  cmds = {
    {
      id = 'ks.commands.show_command_chooser',
      title = "Show command chooser",
      icon = "filemenu.and.selection",
      desc = module_desc,
      flags = { 'no-chooser' },
      mods = "btms",
      key = "C",
      setup = ChooserModule.setup,
      exec = ChooserModule.exec,
    }
  }
}

