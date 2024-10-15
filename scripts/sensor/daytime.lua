local flib_format = require("__flib__.format")

--- @param player LuaPlayer
return function(player)
  if not storage.players[player.index].settings.show_daytime then
    return
  end

  local daytime = player.surface.daytime + 0.5
  local daytime_minutes = math.floor(daytime * 24 * 60)
  local daytime_hours = math.floor(daytime_minutes / 60) % 24
  daytime_minutes = daytime_minutes - (daytime_minutes % 15)

  local ticks_per_day = player.surface.ticks_per_day
  local days = math.floor(1 + ((game.tick + (ticks_per_day / 2)) / ticks_per_day))

  return {
    "",
    { "statsgui.time" },
    " = " .. string.format("%d:%02d", daytime_hours, daytime_minutes % 60),
    ", ",
    { "statsgui.day" },
    " " .. flib_format.number(days),
  }
end
