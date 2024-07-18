local lists  = require 'user.lua.lib.list'
local params = require 'user.lua.lib.params'

-- Date format pattern for "Saturday, January 09 2018 at 12:42:19 AM"
local default_pattern = '%A, %B %d %Y at %I:%M:%S %p'


local Time = {}


function Time.date_table_utc()
  return os.date('!*t')
end


function Time.date_table_local()
  return os.date('*t')
end



--
-- Returns a formated date string (defaults to os.time for date,
-- and human-readable date for pattern)
--
---@param date? number
---@param pattern? string
---@return string
function Time.fmt(date, pattern)
  data = date or os.time()
  pattern = pattern or default_pattern
  return os.date(pattern, date) --[[@as string]]
end


--
-- Returns the number of whole "chonks" in `total_time` (seconds), and the seconds
-- remaining with chonks subtracted
--
function Time.chonk_time(total_time, chonk_equiv)
  local chonks = total_time / chonk_equiv

  if chonks > 1 then
    local whole_chonks = math.floor(chonks)
    local remaining = total_time - (whole_chonks * chonk_equiv)

    return remaining, whole_chonks
  else
    return total_time, 0
  end
end


--
-- Returns time since `tick`
--
---@param tick number
---@return number
function Time.ago(tick)
  params.assert.number(tick, 1)

  return os.difftime(os.time(), tick)
end


--
-- Returns human readable "time since" string
--
---@param tick number
---@return string
function Time.fmt_ago(tick)
  params.assert.number(tick, 1)

  return Time.fmt_duration(Time.ago(tick))
end


local function pluralize(count, single, multi)
  local multi = multi or single..'s'
  return count > 1 and multi or single
end


--
-- Formats a duration (seconds) to human-readable string 
-- like "4 days, 1 hour, 13 minutes, 20 seconds"
--
---@param duration number
---@return string
function Time.fmt_duration(duration)
  params.assert.number(duration, 1)

  local outputs = {}

  local days, hours, minutes

  duration, days = Time.chonk_time(duration, 24*60*60)
  duration, hours = Time.chonk_time(duration, 60*60)
  duration, minutes = Time.chonk_time(duration, 60)
  duration, seconds = Time.chonk_time(duration, 1)

  if days > 0 then
    table.insert(outputs, days .. pluralize(days, ' day'))
  end
  
  if hours > 0 then
    table.insert(outputs, hours .. pluralize(hours, ' hour'))
  end

  if minutes > 0 then
    table.insert(outputs, minutes .. pluralize(minutes, ' minute'))
  end

  if seconds > 0 then
    table.insert(outputs, seconds .. pluralize(seconds, ' second'))
  end

  return table.concat(outputs, ", ")
end



return Time