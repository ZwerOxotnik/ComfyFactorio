require 'modules.custom_death_messages'
require 'modules.flashlight_toggle_button'
require 'modules.global_chat_toggle'
require 'modules.scrap_towny_ffa.worms_create_oil_patches'
require 'modules.biters_yield_coins'
require 'modules.scrap_towny_ffa.mining'
require 'modules.scrap_towny_ffa.on_tick_schedule'
require 'modules.scrap_towny_ffa.building'
require 'modules.scrap_towny_ffa.spaceship'
require 'modules.scrap_towny_ffa.town_center'
require 'modules.scrap_towny_ffa.market'
require 'modules.scrap_towny_ffa.slots'
require 'modules.scrap_towny_ffa.wreckage_yields_scrap'
require 'modules.scrap_towny_ffa.rocks_yield_ore_veins'
require 'modules.scrap_towny_ffa.spawners_contain_biters'
require 'modules.scrap_towny_ffa.explosives_are_explosive'
require 'modules.scrap_towny_ffa.fluids_are_explosive'
require 'modules.scrap_towny_ffa.trap'
require 'modules.scrap_towny_ffa.turrets_drop_ammo'
require 'modules.scrap_towny_ffa.combat_balance'

local Autostash = require 'modules.autostash'
local BottomFrame = require 'utils.gui.bottom_frame'
local Table = require 'modules.scrap_towny_ffa.table'
local Nauvis = require 'modules.scrap_towny_ffa.nauvis'
local Biters = require 'modules.scrap_towny_ffa.biters'
local Pollution = require 'modules.scrap_towny_ffa.pollution'
local Fish = require 'modules.scrap_towny_ffa.fish_reproduction'
local Info = require 'modules.scrap_towny_ffa.info'
local Team = require 'modules.scrap_towny_ffa.team'
local Spawn = require 'modules.scrap_towny_ffa.spawn'
local Radar = require 'modules.scrap_towny_ffa.limited_radar'
local Evolution = require 'modules.scrap_towny_ffa.evolution'
local mod_gui = require('mod-gui')
local Gui = require 'utils.gui'
local Color = require 'utils.color_presets'
local Where = require 'utils.commands.where'
local Inventory = require 'modules.show_inventory'

-- for testing purposes only!!!
local testing_mode = false

-- how long in ticks between spawn and death will be considered spawn kill (10 seconds)
local max_ticks_between_spawns = 60 * 10
-- how many players must login before teams are teams_enabled
local min_players_for_enabling_towns = 0

local function load_buffs(player)
    if player.force.name ~= 'player' and player.force.name ~= 'rogue' then
        return
    end
    local ffatable = Table.get_table()
    local player_index = player.index
    if player.character == nil then
        return
    end
    if ffatable.buffs[player_index] == nil then
        ffatable.buffs[player_index] = {}
    end
    if ffatable.buffs[player_index].character_inventory_slots_bonus ~= nil then
        player.character.character_inventory_slots_bonus = ffatable.buffs[player_index].character_inventory_slots_bonus
    end
    if ffatable.buffs[player_index].character_mining_speed_modifier ~= nil then
        player.character.character_mining_speed_modifier = ffatable.buffs[player_index].character_mining_speed_modifier
    end
    if ffatable.buffs[player_index].character_crafting_speed_modifier ~= nil then
        player.character.character_crafting_speed_modifier = ffatable.buffs[player_index].character_crafting_speed_modifier
    end
end

local function spairs(t, order)
    local keys = {}
    for k in pairs(t) do
        keys[#keys + 1] = k
    end
    if order then
        table.sort(
            keys,
            function(a, b)
                return order(t, a, b)
            end
        )
    else
        table.sort(keys)
    end
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

local function init_score_board(player)
    local ffatable = Table.get_table()
    local saved_frame = ffatable.score_gui_frame[player.index]
    if saved_frame and saved_frame.valid then
        return
    end

    local flow = mod_gui.get_frame_flow(player)
    local frame = flow.add {type = 'frame', style = mod_gui.frame_style, caption = 'Town survival', direction = 'vertical'}
    frame.style.vertically_stretchable = false
    ffatable.score_gui_frame[player.index] = frame
end

local function update_score()
    local ffatable = Table.get_table()

    for _, player in pairs(game.connected_players) do
        local frame = ffatable.score_gui_frame[player.index]
        if not (frame and frame.valid) then
            init_score_board(player)
        end
        if frame and frame.valid then
            frame.clear()

            local inner_frame = frame.add {type = 'frame', style = 'inside_shallow_frame', direction = 'vertical'}

            local subheader = inner_frame.add {type = 'frame', style = 'subheader_frame'}
            subheader.style.horizontally_stretchable = true
            subheader.style.vertical_align = 'center'

            subheader.add {type = 'label', style = 'subheader_label', caption = {'', 'Survive 3 days (72h) to win!'}}

            if not next(subheader.children) then
                subheader.destroy()
            end

            local information_table = inner_frame.add {type = 'table', column_count = 3, style = 'bordered_table'}
            information_table.style.margin = 4
            information_table.style.column_alignments[3] = 'right'

            for _, caption in pairs({'Rank', 'Town (players online/total)', 'Survival time'}) do
                local label = information_table.add {type = 'label', caption = caption}
                label.style.font = 'default-bold'
            end

            local town_ages = {}
            for _, town_center in pairs(ffatable.town_centers) do
                if town_center ~= nil then
                    local age = game.tick - town_center.creation_tick
                    town_ages[town_center] = age
                end
            end

            local rank = 1

            for town_center, age in spairs(
                town_ages,
                function(t, a, b)
                    return t[b] < t[a]
                end
            ) do
                local position = information_table.add {type = 'label', caption = '#' .. rank}
                if town_center == ffatable.town_centers[player.force.name] then
                    position.style.font = 'default-semibold'
                    position.style.font_color = {r = 1, g = 1}
                end
                local label = information_table.add {type = 'label', caption = town_center.town_name ..
                        " (" .. #town_center.market.force.connected_players ..
                        "/" .. #town_center.market.force.players..")"}
                label.style.font = 'default-semibold'
                label.style.font_color = town_center.color
                local age_hours = age / 60 / 3600
                information_table.add {type = 'label', caption = string.format('%.1f', age_hours) .. 'h'}

                rank = rank + 1
            end

            -- Outlander section
            information_table.add {type = 'label', caption = '-'}
            local outlander_on = #game.forces["player"].connected_players + #game.forces["rogue"].connected_players
            local outlander_total = #game.forces["player"].players + #game.forces["rogue"].players

            local label = information_table.add {type = 'label', caption = 'Outlanders' .. " (" .. outlander_on ..
                    "/" .. outlander_total ..")"}
            label.style.font_color = {170, 170, 170}
            information_table.add {type = 'label', caption = '-'}

        end
    end
end

local function on_player_joined_game(event)
    local ffatable = Table.get_table()
    local player = game.players[event.player_index]
    local surface = game.surfaces['nauvis']

    player.game_view_settings.show_entity_info = true
    player.map_view_settings = {
        ['show-logistic-network'] = false,
        ['show-electric-network'] = false,
        ['show-turret-range'] = false,
        ['show-pollution'] = false,
        ['show-train-station-names'] = false,
        ['show-player-names'] = false,
        ['show-networkless-logistic-members'] = false,
        ['show-non-standard-map-info'] = false
    }
    --player.game_view_settings.show_side_menu = false

    init_score_board(player)

    Info.toggle_button(player)
    Team.set_player_color(player)
    if player.force ~= game.forces.player then
        return
    end

    if player.online_time == 0 then
        Info.show(player)
        if testing_mode then
            ffatable.towns_enabled = true
        else
            ffatable.players = ffatable.players + 1
            if ffatable.players >= min_players_for_enabling_towns then
                ffatable.towns_enabled = true
            end
        end

        player.teleport({0, 0}, game.surfaces['limbo'])
        Team.set_player_to_outlander(player)
        Team.give_player_items(player)
        Team.give_key(player.index)
        if (testing_mode == true) then
            player.cheat_mode = true
            player.force.research_all_technologies()
            player.insert {name = 'coin', count = 9900}
        end

        -- first time spawn point
        local spawn_point = Spawn.get_new_spawn_point(player, surface)
        ffatable.strikes[player.name] = 0
        Spawn.clear_spawn_point(spawn_point, surface)
        -- reset cooldown
        ffatable.cooldowns_town_placement[player.index] = 0
        ffatable.last_respawn[player.name] = 0
        player.teleport(spawn_point, surface)
        return
    end
    load_buffs(player)

    if not ffatable.requests[player.index] or ffatable.requests[player.index] ~= 'kill-character' then
        return
    end
    if player.character then
        if player.character.valid then
            local inventories = {
                player.get_inventory(defines.inventory.character_main),
                player.get_inventory(defines.inventory.character_guns),
                player.get_inventory(defines.inventory.character_ammo),
                player.get_inventory(defines.inventory.character_armor),
                player.get_inventory(defines.inventory.character_vehicle),
                player.get_inventory(defines.inventory.character_trash)
            }

            for _, i in pairs(inventories) do
                i.clear()
            end

            player.character.die()
        end
    end
    ffatable.requests[player.index] = nil
end

local function on_player_respawned(event)
    local ffatable = Table.get_table()
    local player = game.players[event.player_index]
    local surface = player.surface
    Team.give_player_items(player)
    if player.force == game.forces['rogue'] then
        Team.set_player_to_outlander(player)
    end
    if player.force == game.forces['player'] then
        Team.give_key(player.index)
    end

    -- get_spawn_point will always return a valid spawn
    local spawn_point = Spawn.get_spawn_point(player, surface)

    -- reset cooldown
    ffatable.last_respawn[player.name] = game.tick
    player.teleport(spawn_point, surface)
    load_buffs(player)
end

local function on_player_died(event)
    local ffatable = Table.get_table()
    local player = game.players[event.player_index]
    if ffatable.strikes[player.name] == nil then
        ffatable.strikes[player.name] = 0
    end

    local ticks_elapsed = game.tick - ffatable.last_respawn[player.name]
    if ticks_elapsed < max_ticks_between_spawns then
        ffatable.strikes[player.name] = ffatable.strikes[player.name] + 1
    else
        ffatable.strikes[player.name] = 0
    end
end

local function on_init()
    Autostash.insert_into_furnace(true)
    Autostash.insert_into_wagon(true)
    Autostash.bottom_button(true)
    BottomFrame.reset()
    BottomFrame.activate_custom_buttons(true)
    Where.module_disabled(true)
    Inventory.module_disabled(true)

    --log("on_init")
    game.enemy_has_vision_on_land_mines = false
    game.draw_resource_selection = true
    game.disable_tutorial_triggers()

    local ffatable = Table.get_table()
    ffatable.last_respawn = {}
    ffatable.last_death = {}
    ffatable.strikes = {}
    ffatable.score_gui_frame = {}
    ffatable.testing_mode = testing_mode
    ffatable.spawn_point = {}
    ffatable.buffs = {}
    ffatable.players = 0
    ffatable.towns_enabled = true

    Nauvis.initialize()
    Team.initialize()
end

local tick_actions = {
    [60 * 0] = Radar.reset, -- each minute, at 00 seconds
    [60 * 5] = Team.update_town_chart_tags, -- each minute, at 05 seconds
    [60 * 10] = Team.set_all_player_colors, -- each minute, at 10 seconds
    [60 * 15] = Fish.reproduce, -- each minute, at 15 seconds
    [60 * 25] = Biters.unit_groups_start_moving, -- each minute, at 25 seconds
    [60 * 30] = Radar.reset, -- each minute, at 30 seconds
    [60 * 45] = Biters.validate_swarms, -- each minute, at 45 seconds
    [60 * 50] = Biters.swarm, -- each minute, at 50 seconds
    [60 * 55] = Pollution.market_scent -- each minute, at 55 seconds
}

local function on_nth_tick(event)
    -- run each second
    local tick = event.tick
    local seconds = tick % 3600 -- tick will recycle minute
    if not tick_actions[seconds] then
        return
    end
    --game.surfaces['nauvis'].play_sound({path = 'utility/alert_destroyed', volume_modifier = 1})
    --log('seconds = ' .. seconds)
    tick_actions[seconds]()
end

local function ui_smell_evolution()
    for _, player in pairs(game.connected_players) do
        -- Only for non-townies
        if player.force.index == game.forces.player.index or player.force.index == game.forces['rogue'].index then
            local e = Evolution.get_evolution(player.position)
            local extra
            if e < 0.1 then
                extra = 'A good place to found a town. Build a furnace to get started.'
            else
                extra = 'Not good to start a new town. Maybe somewhere else?'
            end
            player.create_local_flying_text(
                {
                    position = {x = player.position.x, y = player.position.y},
                    text = 'You smell the evolution around here: ' .. string.format('%.0f', e * 100) .. '%. ' .. extra,
                    color = {r = 1, g = 1, b = 1}
                }
            )
        end
    end
end

local Event = require 'utils.event'

Event.on_init(on_init)
Event.on_nth_tick(60, on_nth_tick) -- once every second
Event.add(defines.events.on_player_joined_game, on_player_joined_game)
Event.add(defines.events.on_player_respawned, on_player_respawned)
Event.add(defines.events.on_player_died, on_player_died)
Event.on_nth_tick(60 * 30, ui_smell_evolution)
Event.on_nth_tick(60, update_score)

--Disable the comfy main gui since we good too many goodies there.
Event.add(
    defines.events.on_gui_click,
    function(event)
        local element = event.element
        if not element or not element.valid then
            return
        end
        local fish_button = Gui.top_main_gui_button
        local main_frame_name = Gui.main_frame_name
        local player = game.get_player(event.player_index)
        if not player or not player.valid then
            return
        end
        if element.name == fish_button then
            if not player.admin then
                if player.gui.left[main_frame_name] and player.gui.left[main_frame_name].valid then
                    player.gui.left[main_frame_name].destroy()
                end
                return player.print('Comfy panel is disabled in this scenario.', Color.fail)
            end
        end
    end
)
