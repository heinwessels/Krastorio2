local compatibility = require("scripts.compatibility")
local tesla_coil = require("scripts.tesla-coil")
local util = require("scripts.util")

local migrations = {}

function migrations.generic()
  util.ensure_turret_force()

  tesla_coil.get_absorber_buffer_capacity()

  compatibility.aai_industry()
  compatibility.disco_science()
  compatibility.nuclear_fuel()
  compatibility.schall_uranium()
end

migrations.versions = {
  ["1.3.0"] = function()
    if game.finished or game.finished_but_continuing then
      for _, force in pairs(game.forces) do
        force.technologies["kr-logo"].enabled = true
      end
    end
  end,
  ["1.3.4"] = function()
    -- Unlock new recipes
    for _, force in pairs(game.forces) do
      force.reset_technology_effects()
    end
  end,
  ["1.3.8"] = function()
    -- Clean up any invalid roboport GUIs
    local new = {}
    for player_index, player_gui in pairs(storage.roboport_guis) do
      if player_gui.valid then
        new[player_index] = player_gui
      end
    end
    storage.roboport_guis = new
  end,
  ["1.3.10"] = function()
    -- Clean up any orphaned internal entities
    local valid_unit_numbers = {}
    for _, data in pairs(storage.tesla_coil.towers) do
      for _, entity in pairs(data.entities) do
        if entity.valid then
          valid_unit_numbers[entity.unit_number or 0] = true
        end
      end
    end
    for _, data in pairs(storage.planetary_teleporter.data) do
      for _, entity in pairs(data.entities) do
        if entity.valid then
          valid_unit_numbers[entity.unit_number or 0] = true
        end
      end
    end
    for _, surface in pairs(game.surfaces) do
      for _, entity in
        pairs(surface.find_entities_filtered({
          name = {
            "kr-planetary-teleporter-turret",
            "kr-planetary-teleporter-front-layer",
            "kr-planetary-teleporter-collision-1",
            "kr-planetary-teleporter-collision-2",
            "kr-planetary-teleporter-collision-3",
            "kr-tesla-coil-turret",
            "kr-tesla-coil-collision",
          },
        }))
      do
        if entity.valid and not valid_unit_numbers[entity.unit_number] then
          entity.destroy()
        end
      end
    end
  end,
}

return migrations
