return function(player)
  if not storage.players[player.index].settings.show_research then
    return
  end

  local string = storage.research_progress_strings[player.force.index]
  if string then
    return { "", { "statsgui.research-finished" }, " = ", string }
  end
end
