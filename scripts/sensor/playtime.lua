local flib_format = require("__flib__.format")

--- Number of ticks in a day
local day = 60 * 60 * 60 * 24

--- @param player LuaPlayer
return function(player)
  local settings = player.mod_settings
  if not settings["statsgui-show-sensor-playtime"].value then
    return
  end

  local ticks_played = game.ticks_played
  local days = math.floor(ticks_played / day)
  if days == 0 or not settings["statsgui-show-playtime-in-days"].value then
    return { "", { "statsgui.playtime" }, " = ", flib_format.time(ticks_played) }
  end

  local remainder = ticks_played % day
  return { "", { "statsgui.playtime" }, " = ", { "statsgui.playtime-days", days, flib_format.time(remainder) } }
end
