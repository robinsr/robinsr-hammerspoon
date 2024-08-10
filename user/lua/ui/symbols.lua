local params = require 'user.lua.lib.params'
local tables = require 'user.lua.lib.table'
local types  = require 'user.lua.lib.typecheck'
local color  = require 'user.lua.ui.color'

local sf_symbol_map = {
  ["antenna.radiowaves.left.and.right"] = 0x100580,
  ["antenna.radiowaves.left.and.right.circle"] = 0x100DC8,
  ["antenna.radiowaves.left.and.right.circle.fill"] = 0x100DC9,
  ["antenna.radiowaves.left.and.right.slash"] = 0x101152,
  ["arrow.counterclockwise"] = 0x100149,
  ["arrowkeys"] = 0x101FB0,
  ["arrowkeys.down.filled"] = 0x101FB3,
  ["arrowkeys.fill"] = 0x101FB1,
  ["arrowkeys.left.filled"] = 0x101FB4,
  ["arrowkeys.right.filled"] = 0x101FB5,
  ["arrowkeys.up.filled"] = 0x101FB2,
  ["bolt"] = 0x1002E5,
  ["bolt.circle"] = 0x1002E7,
  ["bolt.circle.fill"] = 0x1002E8,
  ["bolt.fill"] = 0x1002E6,
  ["bolt.slash.circle"] = 0x1002EB,
  ["bolt.slash.circle.fill"] = 0x1002EC,
  ["bolt.slash.fill"] = 0x1002EA,
  ["brain"] = 0x100BD0,
  ["brain.head.profile.fill"] = 0x102086,
  ["cable.coaxial"] = 0x101292,
  ["camera.macro"] = 0x101082,
  ["cat"] = 0x10207E,
  ["cellularbars"] = 0x100B67,
  ["chart.bar"] = 0x10043E,
  ["chart.bar.fill"] = 0x10043F,
  ["checkmark.circle"] = 0x100062,
  ["checkmark.circle.fill"] = 0x100063,
  ["chevron.backward"] = 0x100BF6,
  ["chevron.backward.circle"] = 0x100BF7,
  ["chevron.backward.circle.fill"] = 0x100BF8,
  ["chevron.down"] = 0x100188,
  ["chevron.down.circle"] = 0x100070,
  ["chevron.down.circle.fill"] = 0x100071,
  ["chevron.forward"] = 0x100BFB,
  ["chevron.forward.circle"] = 0x100BFC,
  ["chevron.forward.circle.fill"] = 0x100BFD,
  ["chevron.left"] = 0x100189,
  ["chevron.left.circle"] = 0x100072,
  ["chevron.left.circle.fill"] = 0x100073,
  ["chevron.left.forwardslash.chevron.right"] = 0x10065A, --alias "htmltag"
  ["chevron.right"] = 0x10018A,
  ["chevron.right.circle"] = 0x100074,
  ["chevron.right.circle.fill"] = 0x100075,
  ["chevron.up"] = 0x100187,
  ["chevron.up.circle"] = 0x10006E,
  ["chevron.up.circle.fill"] = 0x10006F,
  ["circle.fill"] = 0x100001,
  ["circle.grid.cross"] = 0x1009F8,
  ["circle.grid.cross.down.filled"] = 0x100A47,
  ["circle.grid.cross.fill"] = 0x1009F9,
  ["circle.grid.cross.left.filled"] = 0x100A44,
  ["circle.grid.cross.right.filled"] = 0x100A46,
  ["circle.grid.cross.up.filled"] = 0x100A45,
  ["circle.slash"] = 0x100EC3,
  ["command"] = 0x100194,
  ["cube"] = 0x100418,
  ["cube.fill"] = 0x100419,
  ["desktopcomputer"] = 0x100657,
  ["dial.high"] = 0x100A90,
  ["dial.high.fill"] = 0x100A91,
  ["dial.low"] = 0x10037A,
  ["dial.low.fill"] = 0x10037B,
  ["dial.medium"] = 0x1013B4,
  ["dial.medium.fill"] = 0x1013B5,
  ["display"] = 0x1008B9,
  ["doc.on.doc"] = 0x100241,
  ["dog"] = 0x102006,
  ["dot.radiowaves.forward"] = 0x100C2D,
  ["dpad"] = 0x100A32,
  ["dpad.down.filled"] = 0x100A00,
  ["dpad.fill"] = 0x1009FC,
  ["dpad.left.filled"] = 0x1009FD,
  ["dpad.right.filled"] = 0x1009FF,
  ["dpad.up.filled"] = 0x1009FE,
  ["externaldrive"] = 0x100902,
  ["externaldrive.connected.to.line.below"] = 0x100A24,
  ["externaldrive.connected.to.line.below.fill"] = 0x100A25,
  ["eye.slash"] = 0x1002EF,
  ["eyes"] = 0x1009A7,
  ["figure.fall"] = 0x100D6E,
  ["filemenu.and.selection"] = 0x100C62,
  ["fireworks"] = 0x10205E,
  ["fish"] = 0x101590,
  ["flag.checkered"] = 0x10164C,
  ["flask"] = 0x101C0D,
  ["flask.fill"] = 0x101C0E,
  ["fossil.shell"] = 0x101554,
  ["fossil.shell.fill"] = 0x101555,
  ["frying.pan"] = 0x101405,
  ["hammer"] = 0x100644,
  ["hammer.circle"] = 0x100DD4,
  ["hammer.circle.fill"] = 0x100DD5,
  ["hammer.fill"] = 0x100645,
  ["hand.thumbsup"] = 0x10027F,
  ["hare"] = 0x1004CE,
  ["heat.element.windshield"] = 0x1017C9,
  ["heat.waves"] = 0x101C39,
  ["htmltag"] = 0x10065A,
  ["icloud"] = 0x10030B,
  ["icloud.and.arrow.down"] = 0x100315,
  ["icloud.and.arrow.down.fill"] = 0x100316,
  ["icloud.and.arrow.up"] = 0x100317,
  ["icloud.and.arrow.up.fill"] = 0x100318,
  ["info.circle"] = 0x100174,
  ["ladybug"] = 0x100BD4,
  ["light.ribbon"] = 0x10149C,
  ["lightspectrum.horizontal"] = 0x101E69,
  ["list.bullet.circle"] = 0x100EE7,
  ["list.bullet.circle.fill"] = 0x100EE8,
  ["lizard"] = 0x1015DB,
  ["macbook"] = 0x1017EC,
  ["macwindow.on.rectangle"] = 0x10088C,
  ["memorychip"] = 0x100AE6,
  ["memorychip.fill"] = 0x1009D6,
  ["moon"] = 0x1001B9,
  ["mustache.fill"] = 0x100980,
  ["network"] = 0x100906,
  ["network.slash"] = 0x1018E1,
  ["party.popper.fill"] = 0x1014F6,
  ["pawprint"] = 0x100F9E,
  ["pc"] = 0x10097A,
  ["power"] = 0x1001A8,
  ["power.circle"] = 0x100DC3,
  ["power.circle.fill"] = 0x100DC4,
  ["poweroutlet.strip.fill"] = 0x1014DC,
  ["questionmark"] = 0x10014D,
  ["questionmark.app.dashed"] = 0x100FEA,
  ["rainbow"] = 0x100F2D,
  ["rectangle.and.pencil.and.ellipsis"] = 0x10020F,
  ["rectangle.expand.vertical"] = 0x100438,
  ["rectangle.inset.bottomleft.filled"] = 0x100B75,
  ["rectangle.inset.bottomright.filled"] = 0x100B76,
  ["rectangle.inset.topleft.filled"] = 0x100B73,
  ["rectangle.inset.topright.filled"] = 0x100B74,
  ["rectangle.lefthalf.inset.filled.arrow.left"] = 0x10095f,
  ["rectangle.righthalf.inset.filled.arrow.right"] = 0x101065,
  ["rectangle.split.2x2.fill"] = 0x1009CD,
  ["rectangle.split.3x1.fill"] = 0x100578,
  ["rectangle.stack"] = 0x1003ED,
  ["scissors"] = 0x100248,
  ["scope"] = 0x100429,
  ["server.rack"] = 0x100AAC,
  ["slash.circle"] = 0x100567,
  ["slash.circle.fill"] = 0x100568,
  ["slider.horizontal.2.gobackward"] = 0x10168C,
  ["slider.horizontal.2.square"] = 0x101D64,
  ["slider.horizontal.3"] = 0x100306,
  ["sparkles"] = 0x1001BF,
  ["square.3.layers.3d.top.filled"] = 0x100BF1,
  ["swirl.circle.righthalf.filled"] = 0x101E62,
  ["swirl.circle.righthalf.filled.inverse"] = 0x101E6A,
  ["tag"] = 0x1002E1,
  ["teddybear"] = 0x100CAC,
  ["teddybear.fill"] = 0x100CAD,
  ["tent"] = 0x1012E8,
  ["terminal"] = 0x100A7C,
  ["terminal.fill"] = 0x100A8F,
  ["tornado"] = 0x1001E7,
  ["tortoise"] = 0x1004D0,
  ["tree"] = 0x10176F,
  ["wrench.adjustable"] = 0x100395,
  ["wrench.adjustable.fill"] = 0x100396,
  ["wrench.and.screwdriver"] = 0x10090A,
  ["wrench.and.screwdriver.fill"] = 0x10090B,
  ["xserve"] = 0x1009D8,
  ["xserve.raid"] = 0x101EC7,
}


-- Symbol Aliases
local symbol_aliases = {
  bsp        = sf_symbol_map["rectangle.split.2x2.fill"],
  checked    = sf_symbol_map["checkmark.circle"],
  code       = sf_symbol_map["htmltag"],
  cols       = sf_symbol_map["rectangle.split.3x1.fill"],
  command    = sf_symbol_map["command"],
  copy       = sf_symbol_map["doc.on.doc"],
  default    = sf_symbol_map["cat"],
  float      = sf_symbol_map["macwindow.on.rectangle"],
  info       = sf_symbol_map["info.circle"],
  kitty      = sf_symbol_map["cat"],
  lgtm       = sf_symbol_map["hand.thumbsup"],
  not_found  = sf_symbol_map["questionmark.app.dashed"],
  reload     = sf_symbol_map["arrow.counterclockwise"],
  running    = sf_symbol_map["circle.fill"],
  spaceLeft  = sf_symbol_map["rectangle.righthalf.inset.filled.arrow.right"],
  spaceRight = sf_symbol_map["rectangle.lefthalf.inset.filled.arrow.left"],
  stack      = sf_symbol_map["square.3.layers.3d.top.filled"],
  stopped    = sf_symbol_map["circle.fill"],
  tag        = sf_symbol_map["tag"],
  term       = sf_symbol_map["terminal"],
  textinput  = sf_symbol_map["rectangle.and.pencil.and.ellipsis"],
  unchecked  = sf_symbol_map["slash.circle"],
  unknown    = sf_symbol_map["circle.fill"],
  user       = sf_symbol_map["figure.fall"],
}


local symbol_map = tables(tables.merge(sf_symbol_map, symbol_aliases))


local symbols = {}


---@param symbol_name string
---@return boolean
symbols.has_codepoint = function(symbol_name)
  return symbol_map:has(symbol_name)
end


---@param symbol_name string
---@return integer
symbols.get_codepoint = function(symbol_name)
  params.assert.string(symbol_name)

  if not symbol_map:has(symbol_name) then
    error(('No symbol for %s'):format('symbol_name'))
  end

  return symbol_map:get(symbol_name)
end


---@deprecated
symbols.has = symbols.has_codepoint

---@deprecated
symbols.get = symbols.get_codepoint


--
-- Gets the text representation of a symbol from a codepoint number or symbol name
--
---@param code string|integer codepoint number or symbol name
---@return string
function symbols.toText(code)
  if (types.isNum(code)) then
    ---@cast code integer
    return utf8.char(code) 
  end

  if types.isString(code) then
    ---@cast code string
    if symbol_map:has(code) then
      return utf8.char(symbol_map:get(code))
    end
  end

  return ''
end

-- console.log(symbols)


return symbols