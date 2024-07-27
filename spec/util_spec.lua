describe("(meta) TestUtil #meta", function()

  local testutil = require 'spec.util'
  
  describe("testutil.alphalist", function()
    it("test tables are not same object", function()
      -- New table is made on each call to testutil.alphalist()
      assert.are_not.equal(testutil.alphalist(), testutil.alphalist())
      assert.is_true(testutil.alphalist() ~= testutil.alphalist())

      -- The tables have identical contents
      assert.are.same(testutil.alphalist(), testutil.alphalist())
    end)
  end)


  describe('testutil.msg, testutil.hl ("highlight")', function()
    it(' prints messages', function()
      local msg = testutil.msg
      local hl = testutil.hl

      local msg1 = msg("msg1 -", hl('test'), hl("brack", "[]"), hl("brace", "{}"), hl("paren", "()"))
      local msg2 = msg("msg2 -", hl(nil), hl(0), hl(false))
      local msg3 = msg("msg3 -", hl(nil, '++'), hl(0, '++'), hl(false, '++'))
      local msg4 = msg("msg4 -", hl('oops', ''))
      
      assert.are.same('msg1 - "test" [brack] {brace} (paren)', msg1)
      assert.are.same('msg2 - <nil> <0> <false>', msg2)
      assert.are.same('msg3 - <nil> +0+ +false+', msg3)
      assert.are.same('msg4 - oops', msg4)
    end)
  end)
end)