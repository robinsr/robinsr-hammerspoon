---@meta

---@alias ks.keys.modcombo 'hyper'|'meh'|'btms'|'peace'|'claw'|'lil'|'shift'|'alt'|'ctrl'|'cmd'

---@alias ks.keys.modkey 'shift'|'alt'|'ctrl'|'cmd'

---@alias ks.keys.modifiers ks.keys.modcombo|ks.keys.modkey[]

---@alias ks.keys.keyevent 'pressed'|'released'|'repeat'

---@alias ks.keys.callback fun(): any


---@alias ks.keys.alphas
---|'a'
---|'b'
---|'c'
---|'d'
---|'e'
---|'f'
---|'g'
---|'h'
---|'i'
---|'j'
---|'k'
---|'l'
---|'m'
---|'n'
---|'o'
---|'p'
---|'q'
---|'r'
---|'s'
---|'t'
---|'u'
---|'b'
---|'w'
---|'x'
---|'y'
---|'z'
---|'A'
---|'B'
---|'C'
---|'D'
---|'E'
---|'F'
---|'G'
---|'H'
---|'I'
---|'J'
---|'K'
---|'L'
---|'M'
---|'N'
---|'O'
---|'P'
---|'Q'
---|'R'
---|'S'
---|'T'
---|'U'
---|'B'
---|'W'
---|'X'
---|'Y'
---|'Z'


---@alias ks.keys.keycode
---| ks.keys.alphas
---| 'f1'
---| 'f2'
---| 'f3'
---| 'f4'
---| 'f5'
---| 'f6'
---| 'f7'
---| 'f8'
---| 'f9'
---| 'f10'
---| 'f11'
---| 'f12'
---| 'f13'
---| 'f14'
---| 'f15'
---| 'f16'
---| 'f17'
---| 'f18'
---| 'f19'
---| 'f20'
---| 'pad.'
---| 'pad*'
---| 'pad+'
---| 'pad/'
---| 'pad-'
---| 'pad='
---| 'pad0'
---| 'pad1'
---| 'pad2'
---| 'pad3'
---| 'pad4'
---| 'pad5'
---| 'pad6'
---| 'pad7'
---| 'pad8'
---| 'pad9'
---| 'padclear'
---| 'padenter'
---| 'return'
---| 'tab'
---| 'space'
---| 'delete'
---| 'escape'
---| 'help'
---| 'home'
---| 'pageup'
---| 'forwarddelete'
---| 'end'
---| 'pagedown'
---| 'left'
---| 'right'
---| 'down'
---| 'up'
---| 'shift'
---| 'rightshift'
---| 'cmd'
---| 'rightcmd'
---| 'alt'
---| 'rightalt'
---| 'ctrl'
---| 'rightctrl'
---| 'capslock'
---| 'fn'
