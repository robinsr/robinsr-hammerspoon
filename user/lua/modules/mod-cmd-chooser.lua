local ichooser = require 'user.lua.interface.chooser'
local lists   = require 'user.lua.lib.list'
local regex   = require 'user.lua.lib.regex'
local strings = require 'user.lua.lib.string'
local types   = require "user.lua.lib.typecheck"
local keys    = require "user.lua.model.keys"
local color   = require 'user.lua.ui.color'
local texts   = require 'user.lua.ui.text'
local loggr   = require 'user.lua.util.logger'
local desktop = require 'user.lua.interface.desktop'

local log = loggr.new('mod-cmd-chooser', 'debug')


--
---@return HS.Chooser.Item[]
local getChoices = function()
  local EVT_FILTER = regex.glob('!*.(evt|event|events).*')

  return KittySupreme.commands
    :filter(function(cmd)
      ---@cast cmd ks.command
      return EVT_FILTER(cmd.id) and not cmd:hasFlag('no-chooser')
    end)
    :map(function(cmd)
      ---@cast cmd ks.command
      return ichooser.newItem{
        id      = cmd.id,
        text    = cmd.title or cmd.id,
        subText = cmd.desc or ("%s - %s"):format(cmd.id, cmd.module),
        image   = cmd:getMenuIcon(256),
        valid   = cmd:hasFlag('invalid') == false
      }
    end)
    :values()
end


--
-- Valid item handler
--
local onItemChosen = function(selected)
   log.f("Chosen item: %s", hs.inspect(selected))

  if types.isNil(selected) then
    error('No selection passed to chooser handler')
  end

  local chosen_id = selected.id

  local cmd = KittySupreme.commands:first(function(cmd) return cmd.id == chosen_id end)

  if types.isNil(cmd) then
    error(('Could not find command with id %q'):format(chosen_id))
  end

  ---@cast cmd ks.command
  cmd:invoke('chooser', {})
end


--
--
--
local onInvalidChosen = function(selected)
  log.f("Chosen (invalid) item: %s", hs.inspect(selected))

  if types.isNil(selected) then
    error('No selection passed to chooser handler')
  end

  local chosen_id = selected.id

  local cmd = KittySupreme.commands:first(function(cmd) return cmd.id == chosen_id end)

  if types.isNil(cmd) then
    error(('Could not find command with id %q'):format(chosen_id))
  end
end


--
-- WIP - Right-click handler. Currently no use for this
--
---@param index int
local onRightClick = function(index)
  if types.isNil(index) then
    error('No selection passed to chooser invalid handler')
  end

  local all_choices = getChoices()

  log.df("Chooser items: %s", hs.inspect(all_choices))

  if types.isNil(all_choices[index]) then
    error(('Could not find command with index %q'):format(index))
  end

  log.f("right-click on item %s", hs.inspect(all_choices[index]))
end




local ChooserModule = {
  
  -- ---@type ks.command.setupfn<{ chooser: hs.chooser }>
  -- setup = function (cmd)
  --   return { chooser = ichooser.create(cmd_chooser) }
  -- end,

  ---@type ks.command.execfn<{ chooser: hs.chooser }>
  exec = function (cmd, ctx, params)
    local isDark = desktop.darkMode()

    ctx.chooser = ichooser.create({
      placeholder   = 'Search KittySupreme commands',
      choices       = getChoices(),
      onSelect      = onItemChosen,
      onInvalid     = onInvalidChosen,
      onRightClick  = onRightClick,
      searchSubtext = true,
    })
    

    ctx.chooser:bgDark(isDark)

    -- not necessary to call refresh unless chooser's options have changed
    ctx.chooser:refreshChoicesCallback()
    
    ctx.chooser:show()
  end,
}


local module_desc = [[
Launches the HS chooser widget with a list of commands.
Note — limited to just the commands invocable from the chooser, ie with no arguments.
]]


---@type ks.command.config
local show_command_chooser = {
  id    = 'ks.commands.show_command_chooser',
  title = "Show command chooser",
  icon  = "filemenu.and.selection",
  desc  = module_desc,
  mods  = keys.preset.btms,
  key   = keys.code.SPACE,
  setup = ChooserModule.setup,
  exec  = ChooserModule.exec,
  flags = { 'no-chooser', 'no-alert' },
}


return {
  module = 'Command Chooser',
  cmds = {
    show_command_chooser
  }
}

