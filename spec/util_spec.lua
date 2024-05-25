local assert = require 'luassert'
local pretty = require 'pl.pretty'
local testutil = require 'spec.util'

local eq = assert.equals

local msg = testutil.msg
local hl = testutil.hl

describe("testutil #meta", function()
  it('prints messages', function()

    local msg1 = msg("msg1 -", hl('test'), hl("brack", "[]"), hl("brace", "{}"), hl("paren", "()"))
    local msg2 = msg("msg2 -", hl(nil), hl(0), hl(false))
    local msg3 = msg("msg3 -", hl(nil, '++'), hl(0, '++'), hl(false, '++'))
    local msg4 = msg("msg4 -", hl('oops', ''))
    
    eq('msg1 - "test" [brack] {brace} (paren)', msg1)
    eq('msg2 - <nil> <0> <false>', msg2)
    eq('msg3 - <nil> +0+ +false+', msg3)
    eq('msg4 - oops', msg4)
  end)
end)