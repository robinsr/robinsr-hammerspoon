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


local subtext_tmpl = strings.tmpl '{desc+}({id} - {module})'


--
---@return hs.chooser.option[]
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
        text    = cmd.title,
        subText = subtext_tmpl(cmd),
        image   = cmd:getMenuIcon(256),
        valid   = cmd:hasFlag('invalid') == false
      }
    end)
    :values()
end


--
-- Valid item handler
--
---@param selected ks.chooser.option
local onItemChosen = function(selected)
  local cmd = KittySupreme.commands:find(selected.id)

  if cmd then
    return cmd:invoke('chooser', {})
  else
    log.ef('Could not find command with id %s', selected.id)
  end
end


--
--
local onSubmit = function(text)
  log.f('Default Chooser Action for Query: [%s]', text)


end


--
--
--
---@param selected ks.chooser.option
local onInvalidChosen = function(selected)
  log.f("Chosen (invalid) item: %s", hs.inspect(selected))

  if types.isNil(selected) then
    error('No selection passed to chooser handler')
  end

  local cmd = KittySupreme.commands:find(selected.id)

  if types.isNil(cmd) then
    error(('Could not find command with id %s'):format(selected.id))
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

  ---@type ks.command.execfn<{}>
  exec = function (cmd, ctx, params)
    local isDark = desktop.darkMode()

    local command_chooser = ichooser.create({
      placeholder   = 'Search KittySupreme commands',
      choices       = getChoices,
      onSelect      = onItemChosen,
      onInvalid     = onInvalidChosen,
      onRightClick  = onRightClick,
      onSubmit      = onSubmit,
      searchSubtext = true,
    })
    

    command_chooser:bgDark(isDark)

    -- not necessary to call refresh unless chooser's options have changed
    command_chooser:refreshChoicesCallback()
    
    command_chooser:show()
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