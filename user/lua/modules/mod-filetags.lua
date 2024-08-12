local inspect  = require "inspect"
local ftagger  = require 'user.lua.model.file-tagger'
local chooser  = require 'user.lua.interface.chooser'
local events   = require 'user.lua.interface.events'
local channels = require 'user.lua.lib.channels'
local func     = require 'user.lua.lib.func'
local lists    = require 'user.lua.lib.list'
local colors   = require 'user.lua.ui.color'
local images   = require 'user.lua.ui.image'
local text     = require 'user.lua.ui.text'
local logr     = require 'user.lua.util.logger'

local log = logr.new('mod-filetags', 'verbose')




local iconChecked   = images.fromIcon('checked',   256, colors.get('success')):template(false)
local iconUnchecked = images.fromIcon('unchecked', 256, colors.get('danger')):template(false)
local iconCheck     = images.fromIcon('lgtm',      256, colors.get('text-content')):template(false)
local iconTextInput = images.fromIcon('textinput', 256, colors.get('text-content')):template(false)

local ADD = 'filename-tag-add'
local DONE = 'filename-tag-done'

local doneItem = chooser.newItem({
  id = DONE,
  text = 'Done',
  image = iconCheck,
  valid = true
})

local addItem = chooser.newItem({
  id = ADD,
  text = 'Add new tag',
  image = iconTextInput,
  valid = false
})


--
--
--
---@param filepath string
local function handle_file(filepath)
  ---@type hs.chooser
  local tagChooser
  ---@type user.filetagger
  local tagger = ftagger:new(filepath)

  --
  --
  ---@return hs.chooser.option[]
  local function getChooserItems()
    local chooserItems = lists({})
      :push(addItem)
      :concat(lists(tagger.tags):map(function(tag)
        local icon = tag.selected and iconChecked or iconUnchecked
        local text = text.strikethrough(tag.value, not tag.selected)

        return chooser.newItem({
          id = tag.value,
          text = text,
          image = icon,
          valid = false
        })
      end))
      :push(doneItem)

    log.vf('Getting new chooser items result: %s', inspect(chooserItems))

    return chooserItems:values()
  end

  -- Will fire when a current tag is selected to be removed
  local onInvalidChoice = function(item)
    log.f('onInvalidChoice callback: %s', inspect(item))

    local input = tagChooser:query() --[[@as string]]

    local setInput, setRow

    if item.id == ADD then
      setInput, setRow = tagger:onNewTag(tagChooser:selectedRow(), input)
    else
      setInput, setRow = tagger:onUpdateTag(tagChooser:selectedRow(), input)
    end
    

    tagChooser:query(setInput)
    tagChooser:refreshChoicesCallback(true)
    tagChooser:selectedRow(setRow)
  end

  -- closing the chooser is handled automatically 
  ---@param item hs.chooser.option
  local onChoice = function(item)
    log.vf('onChoice callback: %s', inspect(item))
    
    tagger:renameFile()
    -- if item.id == DONE then
    -- end
  end


  tagChooser = chooser.create({
    placeholder   = 'Toggle tags or enter new tag',
    choices       = getChooserItems,
    onQuery       = func.noop, -- A noop function here ensures chooser doesn't change on each keystroke
    onInvalid     = onInvalidChoice,
    onSelect      = onChoice,
    searchSubtext = false,
    defQuery      = true,
  })

  tagChooser:show()

  events.newKeyDownTap(function(evt)
    if events.isKey(evt, 'escape') then
      log.d('Event tap "escape" key triggered')
      tagChooser:delete()

      return 'finish'
    end

    return 'allow'
  end)
end


---@type ks.command.config
local register_sub = {
  id = 'user.filetags.onLoad',
  icon = 'tag',
  flags = { 'no-alert', 'no-chooser', 'hidden' },
  exec = function(cmd, ctx, params)
    channels.subscribe('ks:service:edit_filename_tags', function(data, channel)
      log.f('handling evt: %s - %s', channel, inspect(data))
      handle_file(data.file)
    end)
  end,
}


local mod = {}

mod.name = "Filename Tags"

mod.cmds = {
  register_sub
}

return mod