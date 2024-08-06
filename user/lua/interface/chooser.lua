local desk   = require 'user.lua.interface.desktop'
local tables = require 'user.lua.lib.table'
local colors = require 'user.lua.ui.color'
local images = require 'user.lua.ui.image'
local text   = require 'user.lua.ui.text'
local logr   = require 'user.lua.util.logger' 

local log = logr.new('IChooser', 'info')



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
---@class HS.Chooser.Item
---@field text       string|hs.styledtext
---@field subText?   string|hs.styledtext
---@field image?     hs.image
---@field valid?     bool
---@field [string]   string|num|bool|table


---@class ks.chooser.item.config
---@field id         string
---@field text       string
---@field subText?   string
---@field image?     string|hs.image
---@field valid?     bool

-- -@field [string]   string|num|bool|table


---@class ks.chooser.config
---@field choices         Supplier<HS.Chooser.Item[]>
---@field placeholder     string
---@field onSelect        fun(item: HS.Chooser.Item): nil
---@field onInvalid?      fun(index: number): nil
---@field onRightClick?   fun(index: number): nil
---@field searchSubtext?  boolean


local Chooser = {}


Chooser.styles = {}

---@type HS.TextStyles
Chooser.styles.mainText = {
  -- color = colors.darkgrey,
  font = {
    size = 18,
  }
}

---@type HS.TextStyles
Chooser.styles.subText = {
  -- color = colors.lightgrey,
  font = {
    size = 12,
  }
}

---@type HS.TextStyles
Chooser.styles.subTextMono = tables.merge(Chooser.styles.subText, text.styles.monoText)

Chooser.styles.foreground = colors.black


---@param val string
---@return hs.styledtext
local function mainText(val)
  return text.new(val, Chooser.styles.mainText)
end


---@param val string
---@return hs.styledtext
local function subText(val)
  return text.new(val, Chooser.styles.subText)
end


---@param val string
---@return hs.styledtext
local function subTextMono(val)
  return text.new(val, Chooser.styles.subTextMono)
end


-- Prepares a chooser item: formats text, fetches images
---@param conf ks.chooser.item.config
---@return HS.Chooser.Item
function Chooser.newItem(conf)
  return {
    id      = conf.id,
    text    = mainText(conf.text or conf.id),
    subText = subTextMono(conf.subText),
    image   = images.from(conf.image or 'not_found', images.sizes.chooser),
    valid   = conf.valid or true
  }
end

-- Creates a chooser with reasonable defaults
---@param conf ks.chooser.config
---@return hs.chooser
function Chooser.create(conf)
  log.inspect(conf)
  local ch = hs.chooser.new(conf.onSelect)
    :choices(conf.choices)
    :placeholderText(conf.placeholder)
    :searchSubText(conf.searchSubtext or false)
    :invalidCallback(conf.onInvalid)
    :rightClickCallback(conf.onRightClick)
    -- :bgDark(desk.darkMode())
    -- :fgColor(Chooser.styles.foreground)
    -- :subTextColor(colors.red)
    :width(25)

    log.inspect(ch)

  return ch
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