return function(player)
  if not storage.players[player.index].settings.show_evolution then
    return
  end

  local evolution = game.forces.enemy.get_evolution_factor(player.surface) * 100
  return {
    "",
    { "statsgui.evolution" },
    string.format(" = %.2f", evolution),
    "%",
  }
end
