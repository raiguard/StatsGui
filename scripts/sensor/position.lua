local math = require("__flib__.math")

return function(player)
  if not storage.players[player.index].settings.show_position then
    return
  end

  local position = player.position

  return { "", { "statsgui.position" }, " = ", math.round(position.x), ", ", math.round(position.y) }
end
