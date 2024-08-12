local inspect = require 'inspect'
local desk   = require 'user.lua.interface.desktop'
local func   = require 'user.lua.lib.func'
local tables = require 'user.lua.lib.table'
local types  = require 'user.lua.lib.typecheck'
local colors = require 'user.lua.ui.color'
local images = require 'user.lua.ui.image'
local text   = require 'user.lua.ui.text'
local logr   = require 'user.lua.util.logger' 

local log = logr.new('IChooser', 'debug')



-- HS.Chooser.Item Notes:
--
--  * The table of choices (be it provided statically, or returned by the callback) must
--    contain at least the following keys for each choice:
--     * `text` - A string or hs.styledtext object that will be shown as the main text of
--                the choice
--  * Each choice may also optionally contain the following keys:
--     * `subText` - A string or hs.styledtext object that will be shown underneath the
--                   main text of the choice
--     * `image` - An `hs.image` image object that will be displayed next to the choice
--     * `valid` - A boolean that defaults to `true`, if set to `false` selecting the choice
--                 will invoke the `invalidCallback` method instead of dismissing the chooser
--  * Any other keys/values in each choice table will be retained by the chooser and
--    returned to the completion callback when a choice is made. This is useful for
--    storing UUIDs or other non-user-facing information, however, it is important to
--    note that you should not store userdata objects in the table—it is run through
--    internal conversion functions, so only basic Lua types should be stored.
--  * If a function is given, it will be called once, when the chooser window is
--    displayed. The results are then cached until this method is called again, or
--    `hs.chooser:refreshChoicesCallback()` is called.
--  * If you're using a `hs.styledtext` object for `text` or `subText` choices, make sure you
--    specify a color, otherwise your text could appear transparent depending on the
--    `bgDark` setting.
---@class hs.chooser.option
---@field text       hs.anytext
---@field subText?   hs.anytext
---@field image?     hs.image
---@field valid?     bool
---@field [string]   string|num|bool|table


---@class ks.chooser.option
---@field id         string
---@field text       hs.anytext
---@field subText?   hs.anytext
---@field image?     string|hs.image
---@field valid?     bool

-- -@field [string]   string|num|bool|table


---@class ks.chooser.config
---@field choices         Supplier<hs.chooser.option[]>
---@field placeholder     string
---@field onSelect        fun(item: hs.chooser.option): nil
---@field onSubmit?       fun(text: string):nil
---@field onInvalid?      fun(index: number): nil
---@field onRightClick?   fun(index: number): nil
---@field onQuery?        fun(query: string): nil
---@field searchSubtext?  boolean
---@field defQuery?       boolean


local styles = {}


---@type HS.TextStyles
styles.mainText = {
  paragraphStyle = {
    lineHeightMultiple = 1.3,
  },
  font = {
    size = 18,
  }
}

---@type HS.TextStyles
styles.subText = {
  font = {
    size = 12,
  },
  paragraphStyle = {
    lineHeightMultiple = 1.15,
  },
}

---@type HS.TextStyles
styles.subTextMono = tables.merge(styles.subText, text.styles.monoText)


---@param val hs.anytext
---@return hs.styledtext
local function mainText(val)
  return text.new(val, tables.merge(styles.mainText, {
    color = colors.get('text-content')
  }))
end


---@param val hs.anytext
---@return hs.styledtext
local function subText(val)
  return text.new(val, tables.merge(styles.subText, {
    color = colors.get('text-content')
  }))
end


---@param val hs.anytext
---@return hs.styledtext
local function subTextMono(val)
  return text.new(val, tables.merge(styles.subTextMono, {
    color = colors.get('text-content')
  }))
end



---@class ks.chooser
local Chooser = {}

-- Prepares a chooser item: formats text, fetches images
---@param conf ks.chooser.option
---@return hs.chooser.option
function Chooser.newItem(conf)
  return {
    id      = conf.id,
    text    = mainText(conf.text or conf.id),
    subText = conf.subText and subText(conf.subText) or nil,
    image   = images.from(conf.image or 'not_found', images.sizes.chooser),
    valid   = types.isNil(conf.valid) and true or conf.valid,
  }
end

-- Creates a chooser with reasonable defaults
---@param conf ks.chooser.config
---@return hs.chooser
function Chooser.create(conf)
  log.df('Chooser configuration: %s', inspect(conf))

  ---@type hs.chooser
  local chooser

  if types.isFunc(conf.onSubmit) then

    chooser = hs.chooser.new(function(item)
      if item == nil then
        local q = chooser:query() --[[@as string]]
        return conf.onSubmit(q)
      else
        return conf.onSelect(item)
      end
    end)

    ---@diagnostic disable-next-line
    chooser:enableDefaultForQuery(true)

  else
    chooser = hs.chooser.new(conf.onSelect)

  end

  chooser
    :bgDark(desk.darkMode())
    :choices(conf.choices)
    :placeholderText(conf.placeholder or 'Select from...')
    :searchSubText(conf.searchSubtext or false)

  if types.isFunc(conf.onInvalid) then
    chooser:invalidCallback(conf.onInvalid)
  end

  if types.isFunc(conf.onQuery) then
    chooser:queryChangedCallback(conf.onQuery)
  end

  if types.isFunc(conf.onRightClick) then
    chooser:rightClickCallback(conf.onRightClick)
  end

  -- hs.chooser._defaultGlobalCallback()

  log.df('Chooser created: %s', inspect(chooser))
  
  return chooser

  -- :fgColor(Chooser.styles.foreground)
  -- :subTextColor(colors.red)
  -- :width(25)
end

Chooser.mainText = mainText
Chooser.subText = subText
Chooser.subTextMono = subTextMono

return Chooser

-- :enableDefaultForQuery()
-- :hideCallback()
-- :queryChangedCallback()
-- :refreshChoicesCallback()
-- :rows()
-- :select()
-- :show()
-- :attachedToolbar()
-- :selectedRow()
-- :query()
-- :isVisible()
-- :hide()
-- :cancel()
-- :delete()