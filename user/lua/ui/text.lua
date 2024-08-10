local inspect = require 'inspect'
local colors = require 'user.lua.ui.color'
local logr   = require 'user.lua.util.logger'

local log = logr.new('ui-text', 'debug')


---@class HS.TextStyles
---@field font?               HS.Font           - A table containing the font name and size or a string, which will be taken as the font named in the string
---@field color?              HS.Color          - A table as described in `hs.drawing.color`. Default is white for hs.drawing text objects; otherwise the default is black.
---@field backgroundColor?    HS.Color          - Default nil, no background color (transparent).
---@field underlineColor?     HS.Color          - Default nil, same as color.
---@field strikethroughColor? HS.Color          - Default nil, same as color.
---@field strokeColor?        HS.Color          - Default nil, same as color.
---@field strokeWidth?        number            - Default 0, no stroke; positive, stroke alone; negative, stroke and fill (a typical value for outlined text would be 3.0)
---@field paragraphStyle?     HS.ParagraphStyle - A table containing the paragraph style. This table may contain any number of the following keys:
---@field superscript?        integer           - An integer indicating if the text is to be displayed as a superscript (positive) or a subscript (negative) or normal (0).
---@field ligature?           integer           - An integer. Default 1, standard ligatures; 0, no ligatures; 2, all ligatures.
---@field strikethroughStyle? integer           - An integer representing the strike-through line style. See hs.styledtext.lineStyles, hs.styledtext.linePatterns and hs.styledtext.lineAppliesTo.
---@field underlineStyle?     integer           - An integer representing the underline style. See hs.styledtext.lineStyles, hs.styledtext.linePatterns and hs.styledtext.lineAppliesTo.
---@field baselineOffset?     number            - A floating point value, as points offset from baseline. Default 0.0.
---@field kerning?            number            - A floating point value, as points by which to modify default kerning. Default nil to use default kerning specified in font file; 0.0, kerning off; non-zero, points by which to modify default kerning.
---@field obliqueness?        number            - A floating point value, as skew to be applied to glyphs. Default 0.0, no skew.
---@field expansion?          number            - A floating point value, as log of expansion factor to be applied to glyphs. Default 0.0, no expansion.
---@field shadow?             HS.Shadow         - Default nil, indicating no drop shadow. A table describing the drop shadow effect for the text. The table may contain any of the following keys:


---@class HS.Font
---@field name? string  - Default for hs.drawing text objects is SystemFont@27; Default is Helvetica@12. You may also  at the default size, when setting this attribute.
---@field size? number  - default 27 or 12


---@alias HS.Alignment "left"|"right"|"center"|"justified"|"natural"


---@class HS.ParagraphStyle
---@field alignment?                     HS.Alignment  - A string indicating the texts alignment.  Default is "natural".
---@field lineBreak?                     string        - A string indicating how text that doesn't fit into the drawingObjects rectangle should be handled. The string may be one of "wordWrap", "charWrap", "clip", "truncateHead", "truncateTail", or "truncateMiddle". Default is "wordWrap".
---@field baseWritingDirection?          string        - A string indicating the base writing direction for the lines of text. The string may be one of "natural", "leftToRight", or "rightToLeft". Default is "natural".
---@field tabStops?                      table         - An array of defined tab stops. Default is an array of 12 left justified tab stops 28 points apart. Each element of the array may contain the following keys:
---@field location?                      number        - A floating point number indicating the number of points the tab stap is located from the line's starting margin (see baseWritingDirection).
---@field tabStopType?                   string        - A string indicating the type of the tab stop: "left", "right", "center", or "decimal"
---@field defaultTabInterval?            number        - A positive floating point number specifying the default tab stop distance in points after the last assigned stop in the tabStops field.
---@field firstLineHeadIndent?           number        - A positive floating point number specifying the distance, in points, from the leading margin of a frame to the beginning of the paragraph's first line. Default 0.0.
---@field headIndent?                    number        - A positive floating point number specifying the distance, in points, from the leading margin of a text container to the beginning of lines other than the first. Default 0.0.
---@field tailIndent?                    number        - A floating point number specifying the distance, in points, from the margin of a frame to the end of lines. If positive, this value is the distance from the leading margin (for example, the left margin in left-to-right text). If 0 or negative, it's the distance from the trailing margin. Default 0.0.
---@field maximumLineHeight?             number        - A positive floating point number specifying the maximum height that any line in the frame will occupy, regardless of the font size. Glyphs exceeding this height will overlap neighboring lines. A maximum height of 0 implies no line height limit. Default 0.0.
---@field minimumLineHeight?             number        - A positive floating point number specifying the minimum height that any line in the frame will occupy, regardless of the font size. Default 0.0.
---@field lineSpacing?                   number        - A positive floating point number specifying the space in points added between lines within the paragraph (commonly known as leading). Default 0.0.
---@field paragraphSpacing?              number        - A positive floating point number specifying the space added at the end of the paragraph to separate it from the following paragraph. Default 0.0.
---@field paragraphSpacingBefore?        number        - A positive floating point number specifying the distance between the paragraph's top and the beginning of its text content. Default 0.0.
---@field lineHeightMultiple?            number        - A positive floating point number specifying the line height multiple. The natural line height of the receiver is multiplied by this factor (if not 0) before being constrained by minimum and maximum line height. Default 0.0.
---@field hyphenationFactor?             number        - The hyphenation factor, a value ranging from 0.0 to 1.0 that controls when hyphenation is attempted. By default, the value is 0.0, meaning hyphenation is off. A factor of 1.0 causes hyphenation to be attempted always.
---@field tighteningFactorForTruncation? number        - A floating point number. When the line break mode specifies truncation, the system attempts to tighten inter character spacing as an alternative to truncation, provided that the ratio of the text width to the line fragment width does not exceed 1.0 + the value of tighteningFactorForTruncation. Otherwise the text is truncated at a location determined by the line break mode. The default value is 0.05.
---@field allowsTighteningForTruncation? number        - A boolean indicating whether the system may tighten inter-character spacing before truncating text. Only available in macOS 10.11 or newer. Default true.
---@field headerLevel?                   integer       - An integer number from 0 to 6 inclusive which specifies whether the paragraph is to be treated as a header, and at what level, for purposes of HTML generation. Defaults to 0.


---@class HS.Shadow
---@field offset      HS.WidthHeight  - A table with h and w keys (a size structure) which specify horizontal and vertical offsets respectively for the shadow. Positive values always extend down and to the right from the user's perspective.
---@field blurRadius  number          - A floating point value specifying the shadow's blur radius. A value of 0 indicates no blur, while larger values produce correspondingly larger blurring. The default value is 0.
---@field color       HS.Color        - The default shadow color is black with an alpha of 1/3. If you set this property to nil, the shadow is not drawn.


---@class HS.WidthHeight
---@field w number   - A width value
---@field h number   - A height value


---@alias hs.anytext string|hs.styledtext



--
-- Utility for creating HS StyledText 
--
---@see hs.styledtext (https://www.hammerspoon.org/docs/hs.styledtext.html)
--
---@class ks.ui.text
local txt = {}



txt.styles = {}

---@type HS.TextStyles
txt.styles.subText = {
  color = colors.disabled,
}

---@type HS.TextStyles
txt.styles.monoText = {
  font = {
    name = 'Menlo'
    -- name = 'JetBrainsMono Nerd Font Mono'
  }
}


--
-- Returns a styled text with attributes appled
--
---@param text  hs.anytext
---@param attrs HS.TextStyles
---@return hs.styledtext
function txt.new(text, attrs)
  if type(text) == "string" then
    return hs.styledtext.new(text, attrs) --[[@as hs.styledtext]]
  else
    return text:setStyle(attrs) --[[@as hs.styledtext]]
  end
end


--
-- Returns a styled text with strikethrough style applied. Optionally pass a boolean
-- `apply` to indicate whether to apply the strikethrough or return text as-is
--
---@param text  hs.anytext
---@param apply? boolean        
---@return hs.styledtext
function txt.strikethrough(text, apply)

  local strikeStyle = apply and 1 or 0

  ---@type HS.TextStyles
  local attrs = {
    strikethroughStyle = strikeStyle,
    strikethroughColor = colors.get('text-content'),
  }

  if type(text) == "string" then
    return txt.new(text, attrs)
  else
    return text:setStyle({ strikethroughStyle = strikeStyle })  --[[@as hs.styledtext]]
  end
end


--
-- Returns a styledtext at the specified text size
--
---@param value     hs.anytext
---@param fontSize  integer
---@return hs.styledtext
function txt.sized(value, fontSize)
  
  ---@type HS.TextStyles
  local style = { 
    font = { size = fontSize }
  }

  if type(value) == "string" then
    return txt.new(value, style)
  else
    return value:setStyle(style) --[[@as hs.styledtext]]
  end
end



--
-- Returns a styledText with large (24pt) main text, and small (12pt) subtext on second line
--
---@param msg hs.anytext
---@param sub hs.anytext
---@return hs.styledtext
function txt.msgWithSub(msg, sub)
  return txt.sized(msg, 24) .. txt.sized("\n\n" .. sub, 12)
end


--
-- Returns a styledText with a a main part and subtext faded
--
---@param msg hs.anytext
---@param sub hs.anytext
---@return hs.styledtext
function txt.textAndHint(msg, sub)

  return txt.new(msg, {}) .. txt.new(sub, txt.styles.subText)
end

return txt