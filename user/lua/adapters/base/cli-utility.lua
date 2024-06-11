local sh      = require 'user.lua.adapters.shell'
local lists   = require 'user.lua.lib.list'
local strings = require 'user.lua.lib.string'
local proto   = require 'user.lua.lib.proto'

---@class CmdLineProgram
local cli = {}

---@param program string     - Program name; must be in $PATH
---@param init_args? string[] - Arguments included with every command 
function cli:new(program, init_args)

  ---@class CmdLineProgram
  local this = self == cli and {} or self

  this.prog = program
  this.init_args = init_args

  this.queue = lists({})

  proto.setProtoOf(this, cli)

  this:reset()

  return this
end


-- Reset queue (without issuing command)
-- 
function cli:reset()
  self.queue = lists({
    { type = 'cmd', val = self.prog },
  })

  lists(self.init_args):each(function(val)
    self.queue:push({ type = 'arg', val = val })
  end)
end


-- Add a positional argument to queue
--
function cli:arg(name, value, separator)
  -- TODO - logic for "arg=value" types
  self.queue:push({ type = 'argname', val = name })
  self.queue:push({ type = 'argname', val = value })

  return self
end


-- Add a long flag to arg queue
--
function cli:lf(name, value, separator)
  return self
end


-- Add a short flag to arg queue
--
function cli:sf(name, value, separator)
  self.queue:push({ type = 'arg', pre = '-', val = name  })

  return self
end


-- Start sub-command
--
function cli:sub(cmd_name)
  return self
end


-- Add a positional argument to end of queue
--
function cli:pos(value)
  return self
end


-- Returns the command as a string
--
function cli:raw()
  -- TODO execution
  self:reset()

  return ''
end


-- Returns the command as a list of strings
--
function cli:args()
  -- TODO execution
  self:reset()

  return { '', '' }
end


-- Execute command from queue items
--
function cli:exec()
  -- TODO execution
  self:reset()

  return nil
end


--
-- TEST
--

local testcli = cli:new('mycli', { 'always-include', 'these-args' })

testcli:sub('do-thing'):lf('longflag'):pos('ThingA'):pos('ThingB')




return cli