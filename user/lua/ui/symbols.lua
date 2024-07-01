local params = require 'user.lua.lib.params'
local tables = require 'user.lua.lib.table'
local types  = require 'user.lua.lib.typecheck'
local color  = require 'user.lua.ui.color'

local sf_symbol_map = {
  ["filemenu.and.selection"] = 0x100C62,
  ["questionmark.app.dashed"] = 0x100FEA,
  ["doc.on.doc"] = 0x100241,
  ["arrow.counterclockwise"] = 0x100149,
  ["chevron.left.forwardslash.chevron.right"] = 0x10065A, --alias "htmltag"
  ["htmltag"] = 0x10065A,
  ["tag"] = 0x1002E1,
  ["macwindow.on.rectangle"] = 0x10088C,
  ["rectangle.stack"] = 0x1003ED,
  ["rectangle.split.2x2.fill"] = 0x1009CD,
  ["rectangle.split.3x1.fill"] = 0x100578,
  ["command"] = 0x100194,
  ["rectangle.righthalf.inset.filled.arrow.right"] = 0x101065,
  ["rectangle.lefthalf.inset.filled.arrow.left"] = 0x10095f,
  ["terminal"] = 0x100A7C,
  ["terminal.fill"] = 0x100A8F,
  ["externaldrive"] = 0x100902,
  ["externaldrive.connected.to.line.below"] = 0x100A24,
  ["externaldrive.connected.to.line.below.fill"] = 0x100A25,
  ["power"] = 0x1001A8,
  ["power.circle"] = 0x100DC3,
  ["power.circle.fill"] = 0x100DC4,
  ["network"] = 0x100906,
  ["network.slash"] = 0x1018E1,
  ["moon"] = 0x1001B9,
  ["sparkles"] = 0x1001BF,
  ["tornado"] = 0x1001E7,
  ["rainbow"] = 0x100F2D,
  ["swirl.circle.righthalf.filled"] = 0x101E62,
  ["swirl.circle.righthalf.filled.inverse"] = 0x101E6A,
  ["lightspectrum.horizontal"] = 0x101E69,
  ["flag.checkered"] = 0x10164C,
  ["bolt"] = 0x1002E5,
  ["bolt.fill"] = 0x1002E6,
  ["bolt.circle"] = 0x1002E7,
  ["bolt.circle.fill"] = 0x1002E8,
  ["bolt.slash.fill"] = 0x1002EA,
  ["bolt.slash.circle"] = 0x1002EB,
  ["bolt.slash.circle.fill"] = 0x1002EC,
  ["icloud"] = 0x10030B,
  ["icloud.and.arrow.down"] = 0x100315,
  ["icloud.and.arrow.down.fill"] = 0x100316,
  ["icloud.and.arrow.up"] = 0x100317,
  ["icloud.and.arrow.up.fill"] = 0x100318,
  ["scissors"] = 0x100248,
  ["dial.low"] = 0x10037A,
  ["dial.low.fill"] = 0x10037B,
  ["dial.medium"] = 0x1013B4,
  ["dial.medium.fill"] = 0x1013B5,
  ["dial.high"] = 0x100A90,
  ["dial.high.fill"] = 0x100A91,
  ["wrench.adjustable"] = 0x100395,
  ["wrench.adjustable.fill"] = 0x100396,
  ["hammer"] = 0x100644,
  ["hammer.fill"] = 0x100645,
  ["hammer.circle"] = 0x100DD4,
  ["hammer.circle.fill"] = 0x100DD5,
  ["wrench.and.screwdriver"] = 0x10090A,
  ["wrench.and.screwdriver.fill"] = 0x10090B,
  ["light.ribbon"] = 0x10149C,
  ["poweroutlet.strip.fill"] = 0x1014DC,
  ["party.popper.fill"] = 0x1014F6,
  ["fireworks"] = 0x10205E,
  ["frying.pan"] = 0x101405,
  ["tent"] = 0x1012E8,
  ["memorychip"] = 0x100AE6,
  ["memorychip.fill"] = 0x1009D6,
  ["display"] = 0x1008B9,
  ["desktopcomputer"] = 0x100657,
  ["pc"] = 0x10097A,
  ["server.rack"] = 0x100AAC,
  ["xserve"] = 0x1009D8,
  ["xserve.raid"] = 0x101EC7,
  ["macbook"] = 0x1017EC,
  ["cable.coaxial"] = 0x101292,
  ["dot.radiowaves.forward"] = 0x100C2D,
  ["antenna.radiowaves.left.and.right"] = 0x100580,
  ["antenna.radiowaves.left.and.right.circle"] = 0x100DC8,
  ["antenna.radiowaves.left.and.right.circle.fill"] = 0x100DC9,
  ["antenna.radiowaves.left.and.right.slash"] = 0x101152,
  ["heat.waves"] = 0x101C39,
  ["heat.element.windshield"] = 0x1017C9,
  ["flask"] = 0x101C0D,
  ["flask.fill"] = 0x101C0E,
  ["hare"] = 0x1004CE,
  ["tortoise"] = 0x1004D0,
  ["dog"] = 0x102006,
  ["cat"] = 0x10207E,
  ["lizard"] = 0x1015DB,
  ["ladybug"] = 0x100BD4,
  ["fish"] = 0x101590,
  ["pawprint"] = 0x100F9E,
  ["teddybear"] = 0x100CAC,
  ["teddybear.fill"] = 0x100CAD,
  ["camera.macro"] = 0x101082,
  ["tree"] = 0x10176F,
  ["eye.slash"] = 0x1002EF,
  ["eyes"] = 0x1009A7,
  ["mustache.fill"] = 0x100980,
  ["brain.head.profile.fill"] = 0x102086,
  ["brain"] = 0x100BD0,
  ["slider.horizontal.3"] = 0x100306,
  ["slider.horizontal.2.square"] = 0x101D64,
  ["slider.horizontal.2.gobackward"] = 0x10168C,
  ["cube"] = 0x100418,
  ["cube.fill"] = 0x100419,
  ["scope"] = 0x100429,
  ["circle.grid.cross"] = 0x1009F8,
  ["circle.grid.cross.fill"] = 0x1009F9,
  ["circle.grid.cross.left.filled"] = 0x100A44,
  ["circle.grid.cross.up.filled"] = 0x100A45,
  ["circle.grid.cross.right.filled"] = 0x100A46,
  ["circle.grid.cross.down.filled"] = 0x100A47,
  ["dpad"] = 0x100A32,
  ["dpad.fill"] = 0x1009FC,
  ["dpad.left.filled"] = 0x1009FD,
  ["dpad.up.filled"] = 0x1009FE,
  ["dpad.right.filled"] = 0x1009FF,
  ["dpad.down.filled"] = 0x100A00,
  ["arrowkeys"] = 0x101FB0,
  ["arrowkeys.fill"] = 0x101FB1,
  ["arrowkeys.up.filled"] = 0x101FB2,
  ["arrowkeys.down.filled"] = 0x101FB3,
  ["arrowkeys.left.filled"] = 0x101FB4,
  ["arrowkeys.right.filled"] = 0x101FB5,
  ["chart.bar"] = 0x10043E,
  ["chart.bar.fill"] = 0x10043F,
  ["cellularbars"] = 0x100B67,
  ["fossil.shell"] = 0x101554,
  ["fossil.shell.fill"] = 0x101555,
  ["list.bullet.circle"] = 0x100EE7,
  ["list.bullet.circle.fill"] = 0x100EE8,
  ["checkmark.circle"] = 0x100062,
  ["chevron.left"] = 0x100189,
  ["chevron.left.circle"] = 0x100072,
  ["chevron.left.circle.fill"] = 0x100073,
  ["chevron.backward"] = 0x100BF6,
  ["chevron.backward.circle"] = 0x100BF7,
  ["chevron.backward.circle.fill"] = 0x100BF8,
  ["chevron.right"] = 0x10018A,
  ["chevron.right.circle"] = 0x100074,
  ["chevron.right.circle.fill"] = 0x100075,
  ["chevron.forward"] = 0x100BFB,
  ["chevron.forward.circle"] = 0x100BFC,
  ["chevron.forward.circle.fill"] = 0x100BFD,
  ["chevron.up"] = 0x100187,
  ["chevron.up.circle"] = 0x10006E,
  ["chevron.up.circle.fill"] = 0x10006F,
  ["chevron.down"] = 0x100188,
  ["chevron.down.circle"] = 0x100070,
  ["chevron.down.circle.fill"] = 0x100071,
  ["circle.fill"] = 0x100001,
  ["info.circle"] = 0x100174,
  ["questionmark"] = 0x10014D,
}


-- Symbol Aliases
local symbol_aliases = {
  default    = sf_symbol_map["cat"],
  kitty      = sf_symbol_map["cat"],
  info       = sf_symbol_map["info.circle"],
  tag        = sf_symbol_map["tag"],
  reload     = sf_symbol_map["arrow.counterclockwise"],
  term       = sf_symbol_map["terminal"],
  code       = sf_symbol_map["htmltag"],
  command    = sf_symbol_map["command"],
  running    = sf_symbol_map["circle.fill"],
  stopped    = sf_symbol_map["circle.fill"],
  unknown    = sf_symbol_map["circle.fill"],
  float      = sf_symbol_map["macwindow.on.rectangle"],
  spaceLeft  = sf_symbol_map["rectangle.righthalf.inset.filled.arrow.right"],
  spaceRight = sf_symbol_map["rectangle.lefthalf.inset.filled.arrow.left"],
  copy       = sf_symbol_map["doc.on.doc"],
  not_found  = sf_symbol_map["questionmark.app.dashed"],
  arrangement = sf_symbol_map["rectangle.split.2x2.fill"],
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