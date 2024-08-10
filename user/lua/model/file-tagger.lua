local inspect  = require 'hs.inspect'
local fs       = require 'user.lua.lib.fs'
local lists    = require 'user.lua.lib.list'
local paths    = require 'user.lua.lib.path'
local params   = require 'user.lua.lib.params'
local regex    = require 'user.lua.lib.regex'
local strings  = require 'user.lua.lib.string'
local tables   = require 'user.lua.lib.table'
local types    = require 'user.lua.lib.typecheck'
local logr     = require 'user.lua.util.logger'

local utils = require 'pl.utils'

local log = logr.new('mod-filetags', 'verbose')

local front_tag_pattern = '^%/'

local DEFAULT_GROUPS = { '[credit]', '(date)', '{tags}', 'name' }
local DEFAULT_COMBINATOR = '{credit+}{date+}{tags+}{name}{ext}'


---@param gr string
---@return string, string, string
local function open_group(gr)
  local open, name, close =  gr:sub(1,1), gr:sub(2, #gr-1), gr:sub(#gr)

  if open:match('%w') and close:match('%w') then
    return gr, '', ''
  else
    return name, open, close
  end
end


---@param groups string[]
---@return       ks.matcher.pcre
local function group_pattern(groups)
  local pattern = strings.linewriter():write('^')
    
  for _,gr in ipairs(groups) do
    if gr == 'name' then
      pattern:write('(?<name>[^\\.]+\\.*)')
    else
      local name, open, close = open_group(gr)
      
      pattern:write(('(?:\\%s(?<%s>[^\\%s]+)\\%s)?\\s?'):format(open, name, close, close))
    end
  end
  
  pattern:write('\\.(?<ext>[a-z]{3,4})$')

  log.inspect(pattern:value())

  return regex.pcre(pattern:value(), 'gm')
end


---@param groups string[]
---@return       string
local function combinator(groups)
  local tmpl = ''
  local ex = lists({ 'tags','name','ext' })

  for _,gr in ipairs(groups) do
    local name = open_group(gr)

    if not ex:includes(name) then
      tmpl = tmpl .. '{' .. name ..'+}'
    end
  end

  return tmpl .. '{tags+}{name}.{ext}'
end


--
-- Replaces spaces with _, removes non-word characters 
--
---@param text string
---@return String
local function sanitizeInput(text)
  local sanitized = text:gsub('%s', '_'):gsub('[^%w%_]', '')
  return strings.new(sanitized):trim()
end



---@class user.filetagger
---@field original     string
---@field groups       string[]
---@field path         string
---@field name         string
---@field ext          string
---@field tags         user.filetagger.tag[]
---@field fields       { [string]: string }
---@field combinator   string

---@class user.filetagger.tag
---@field value     string
---@field selected  boolean

---@class user.filetagger
local FTagger = {}


--
-- New Filename Tagger
--
---@param filepath string
---@param groups?  string[]
---@return user.filetagger
function FTagger:new(filepath, groups)
  params.assert.string(filepath, 1)
  
  if not paths.exists(filepath) then
    log.wf('Filepath [%s] not found', filepath)
  end

  local this = self == FTagger and {} or self
  
  this.original = filepath
  this.tags = {}
  this.fields = {}
  this.path = paths.dirname(filepath)
  this.ext  = paths.extname(filepath)
  this.groups = groups or DEFAULT_GROUPS
  this.combinator = combinator(this.groups)

  local basename = paths.basename(filepath)
  local matcher = group_pattern(this.groups)
  local first, last, matches = matcher(basename) --[[@as int, int, table]]

  if first == -1 then
    error('Error parsing filename: ' .. basename)
  end

  if first ~= 1 or last ~= #basename then
    error('Could not fully parse filename: ' .. basename)
  end

  for field, val in utils.kpairs(matches) do
    if field == 'tags' and val then
      this.tags = lists(strings.split(val, ','))
        :map(function(tag) 
          return { value = tag, selected = true }
        end):values()  

    elseif field == 'name' then
      this.name = val

    elseif field == 'ext' then
      this.ext = val

    else
      this.fields[field] = val
    end
  end

  log.inspect(this)

  return setmetatable(this, { __index = FTagger })
end



---@param index  number
---@param value  string
---@return string, number
function FTagger:onUpdateTag(index, value)
  local inputs = strings.new(value):trim()
  local sanitized = sanitizeInput(inputs)
  
  local nextIndex = index

  local tags = lists(self.tags)

  -- Selected a tag but gave bad input (text after sanitizing is empty) --> do nothing
  if sanitized:empty() and not inputs:empty() then
    return inputs, index
  end

  -- Selected a tag with no text input --> Toggle the tag
  if inputs:empty() then
    tags:at(index-1).selected = not tags:at(index-1).selected
  end

  -- Selected a tag with text input --> Change tag value
  if not sanitized:empty() then
    tags:at(index-1).value = sanitized
    -- Also assuming you want that tag re-enabled if unselected
    tags:at(index-1).selected = true
  end

  return '', nextIndex
end


---@param index  number
---@param value  string
---@return string, number
function FTagger:onNewTag(index, value)
  local inputs = strings.new(value):trim()
  local sanitized = sanitizeInput(inputs)
  local nextIndex = index

  local tags = lists(self.tags)

  -- Selected "Add new tag" with null input --> Highlight the "Done" item
  if inputs:empty() then
    nextIndex = tags:len() + 2
  end

  -- Selected "Add new tag" with input --> Add new tag, reset text input
  if not sanitized:empty() then
    local newTag = { value = sanitized, selected = true }
    
    if inputs:match(front_tag_pattern) then
      tags:shift(newTag)
    else
      tags:push(newTag)
    end
  end

  self.tags = tags:values()

  return '', nextIndex
end


---@return string
function FTagger:getFilename()

  local tags = lists(self.tags)
    :filter(function(t) return t.selected end)
    :mapProp('value')

  local tmpl_vars = lists(self.groups):reduce({}, function(vars, gr)
    local name, open, close = open_group(gr)
    vars[name] = self.fields[name] and open.. self.fields[name] ..close
    return vars
  end)

  tmpl_vars.tags = tags:len() > 0 and '{'.. tags:join(',') ..'}'
  tmpl_vars.name = self.name
  tmpl_vars.ext = self.ext

  local filename = strings.tmpl(self.combinator)(tmpl_vars)

  return paths.join(self.path, filename)
end


--
--
--
function FTagger:renameFile()
  local filepath = self:getFilename()

  log.d(strings.linewriter():add('Renaming file...')
    :addf('  from [%s]', self.original)
    :addf('    to [%s]', filepath):value())

  fs.moveFile(self.original, filepath)
end


return setmetatable({}, { __index = FTagger })


--[[
'^(?:\\[(?<artist>[\\w_]+)\\])?\\s?(?:\\((?<date>[\\d\\-]+)\\))?\\s?(?:\\{(?<tags>[\\w-_,]+)\\})?\\s?(?<title>[^\\.]+)\\.[\\w]{3,4}$'

]]