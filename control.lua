local migration = require("__flib__.migration")

local constants = require("constants")

local migrations = require("scripts.migrations")
local player_data = require("scripts.player-data")
local preprocessors = require("scripts.preprocessors")
local sensors = require("scripts.sensors")
local stats_gui = require("scripts.stats-gui")

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- BOOTSTRAP

script.on_init(function()
  global.players = {}
  global.research_progress_samples = {}
  global.research_progress_strings = {}
  for i, player in pairs(game.players) do
    player_data.init(i)
    player_data.refresh(player, global.players[i])
  end
end)

script.on_configuration_changed(function(e)
  if migration.on_config_changed(e, migrations) then
    global.research_progress_samples = {}
    for i, player in pairs(game.players) do
      player_data.refresh(player, global.players[i])
    end
  end
end)

-- PLAYER

script.on_event(defines.events.on_player_created, function(e)
  local player = game.get_player(e.player_index)
  player_data.init(e.player_index)
  player_data.refresh(player, global.players[e.player_index])
end)

script.on_event(defines.events.on_player_removed, function(e)
  global.players[e.player_index] = nil
end)

script.on_event({
  defines.events.on_player_display_resolution_changed,
  defines.events.on_player_display_scale_changed,
}, function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  stats_gui.set_width(player, player_table)
end)

-- SETTINGS

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  if string.sub(e.setting, 1, 8) == "statsgui" then
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    if
      e.setting == "statsgui-single-line"
      or e.setting == "statsgui-adjust-for-fps-ups"
      or e.setting == "statsgui-adjust-for-clock"
    then
      -- recreate the GUI to change the frame direction and/or padding
      player_data.refresh(player, player_table)
    else
      player_data.update_settings(player, player_table)
    end
  end
end)

-- TICK

-- update stats once per second
script.on_nth_tick(60, function()
  -- run preprocessors
  for _, preprocessor in pairs(preprocessors) do
    preprocessor()
  end
  -- update GUIs
  for _, player in pairs(game.connected_players) do
    local player_table = global.players[player.index]
    stats_gui.update(player, player_table)
  end
end)

-- CUTSCENE

script.on_event(
  { defines.events.on_cutscene_started, defines.events.on_cutscene_finished, defines.events.on_cutscene_cancelled },
  function(e)
    local player = game.get_player(e.player_index)
    if not player then
      return
    end
    local player_table = global.players[e.player_index]
    if not player_table then
      return
    end
    player_table.stats_window.visible = player.controller_type ~= defines.controllers.cutscene
  end
)

-- -----------------------------------------------------------------------------
-- REMOTE INTERFACE

remote.add_interface("StatsGui", {
  add_preprocessor = function(interface, func)
    -- create a dummy function that calls the specified remote interface and returns what it returns
    preprocessors[#preprocessors + 1] = function()
      return remote.call(interface, func)
    end
  end,
  add_sensor = function(interface, func)
    -- create a dummy function that calls the specified remote interface and returns what it returns
    sensors[#sensors + 1] = function(player)
      return remote.call(interface, func, player)
    end
  end,
  version = function()
    return constants.interface_version
  end,
})
