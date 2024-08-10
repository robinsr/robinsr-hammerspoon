---@diagnostic disable: redundant-parameter
local inspect = require 'inspect'
local tutil  = require 'spec.util'
local dkjson = require 'dkjson'
local plfile = require 'pl.file'
local plpath = require 'pl.path'

--[[
local inspect  = require 'hs.inspect'
local fs       = require 'user.lua.lib.fs'
local lists    = require 'user.lua.lib.list'
local paths    = require 'user.lua.lib.path'
local params   = require 'user.lua.lib.params'
local strings  = require 'user.lua.lib.string'
local types    = require 'user.lua.lib.typecheck'
local logr     = require 'user.lua.util.logger'
]]



local bug_one = '/some/path/[den3ver] (2024-07-31) {tile_wall,wall_(structure)} Tiles in closer detail....png'


insulate("user.lua.model.filetagger", function()

  local noop = spy.new(function() end)

  package.loaded['user.lua.interface.console'] = {
    print = inspect
  }

  package.loaded['user.lua.util.logger'] = tutil.mock_logger(spy, 'off')
  
  package.loaded['hs.inspect'] = noop

  package.loaded['user.lua.lib.path'] = require('user.lua.lib.path')
  package.loaded['user.lua.lib.path'].exists = spy.new(function() return true end)

  package.loaded['user.lua.lib.fs'] = {
    moveFile = spy.new(function() end)
  }


  local FileTagger = require('user.lua.model.file-tagger')
  local strings  = require('user.lua.lib.string')

  describe("setup", function()
    it("should load module", function()
      local ft = FileTagger:new('Hello World.txt', { '(poop)', '{dick}', 'name' })

      -- tutil.dump(ft)

      assert.is.True(true, "this should be true")
    end)
  end)

  describe("parsing the filename", function()

    local file_full = '[spec] (2024-08-08) {tag1,tag2} file with all.txt'
    local file_tags = '{tag1,tag2} file with tags only.txt'
    local file_basic = 'simple file name.txt'

    local expected_tags = {
      { value = 'tag1', selected = true },
      { value = 'tag2', selected = true },
    }

    it('should match simple filename', function()
      local ft = FileTagger:new(file_basic)

      assert.is.False(ft.fields.credit)
      assert.is.False(ft.fields.date)
      assert.are.same({}, ft.tags)

      assert.is_not.Nil(ft.name)
      assert.are.same('simple file name', ft.name)
    end)


    it("should recognize filenames with pre-existing tags", function()
      local ft = FileTagger:new(file_tags)

      assert.is_not.Nil(ft.tags)
      assert.are.same(expected_tags, ft.tags)

      assert.is.False(ft.fields.credit)
      assert.is.False(ft.fields.date)

      assert.is_not.Nil(ft.name)
      assert.are.same('file with tags only', ft.name)
    end)

    
    it('should match complex filename', function()
      local ft = FileTagger:new(file_full)

      assert.is_not.Nil(ft.tags)
      assert.are.same(expected_tags, ft.tags)

      assert.is_not.Nil(ft.fields.credit)
      assert.are.same('spec', ft.fields.credit)

      assert.is_not.Nil(ft.fields.date)
      assert.are.same('2024-08-08', ft.fields.date)

      assert.is_not.Nil(ft.name)
      assert.are.same('file with all', ft.name)
    end)

    it('should match complex filename', function()
      
      
      local ft = FileTagger:new(bug_one)

      assert.is_not.Nil(ft.tags)
      assert.are.same({
        { value = 'tile_wall', selected = true },
        { value = 'wall_(structure)', selected = true },
      }, ft.tags)

      assert.is_not.Nil(ft.fields.credit)
      assert.are.same('den3ver', ft.fields.credit)

      assert.is_not.Nil(ft.fields.date)
      assert.are.same('2024-07-31', ft.fields.date)

      assert.is_not.Nil(ft.ext)
      assert.are.same('png', ft.ext)

      assert.is_not.Nil(ft.name)
      assert.are.same('Tiles in closer detail...', ft.name)
    end)


    it("should be somewhat configurable", function()

      local groups = { '[credit]', '(date)', '{tags}', 'name' }

      local ft = FileTagger:new(bug_one, groups)
      
    end)
  end)

  describe("recombining the filename", function()
    it("should work", function()
      

      assert.are.same(bug_one, FileTagger:new(bug_one):getFilename())

    end)

    it("should work", function()
      
      local original = '/some/path/[spec] (2024-08-08) {tag1,tag2} file with all.txt'
      local expected = '/some/path/[spec] (2024-08-08) {tag1,tag2,tag3} file with all.txt'

      local ft = FileTagger:new(original)

      table.insert(ft.tags, { value = 'tag3', selected = true })

      assert.are.same(expected, ft:getFilename())
    end)

    it("should also work", function()
      
      local original = '/some/path/plain file.txt'
      local expected = '/some/path/{tag1,tag2,tag3} plain file.txt'

      local ft = FileTagger:new(original)

      table.insert(ft.tags, { value = 'tag1', selected = true })
      table.insert(ft.tags, { value = 'tag2', selected = true })
      table.insert(ft.tags, { value = 'tag3', selected = true })

      assert.are.same(expected, ft:getFilename())
    end)

    it("should leave file alone if nothing changed", function()
      
      local original = '/some/path/plain file.txt'
      local expected = '/some/path/plain file.txt'

      local ft = FileTagger:new(original)

      assert.are.same(expected, ft:getFilename())
    end)

    it("should handle duplicate-file-style filenames, eg '(1)', '(2)', etc... ", function()
      
      local original = '/some/path/plain file (1).txt'
      local expected = '/some/path/plain file (1).txt'

      local ft = FileTagger:new(original)

      assert.are.same(expected, ft:getFilename())
    end)
  end)

end)