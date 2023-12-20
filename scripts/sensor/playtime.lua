local flib_format = require("__flib__.format")

return function(player)
  if not global.players[player.index].settings.show_playtime then
    return
  end

  return { "", { "statsgui.playtime" }, " = ", flib_format.time(game.ticks_played) }
end
