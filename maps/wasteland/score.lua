local Public = {}

local ScenarioTable = require 'maps.wasteland.table'
local Event = require 'utils.event'
local Utils = require 'maps.wasteland.utils'

local age_score_factors = { 10.0, 2.4, 1.2 }
local age_score_factor = age_score_factors[global.game_mode]
local research_evo_score_factors = { 150, 65, 65 }
local research_evo_score_factor = research_evo_score_factors[global.game_mode]
local score_to_win = 100
Public.score_to_win = score_to_win

function Public.score_increment_for_research(evo_increase)
    return evo_increase * research_evo_score_factor
end

function Public.research_score(town_center)
    return math.min(town_center.evolution.worms * research_evo_score_factor, 70)
end

function Public.survival_score(town_center)
    return Public.survival_time_h(town_center) * age_score_factor
end

function Public.survival_time_h(town_center)
    return town_center.survival_time_ticks / 60 / 3600
end

function Public.total_score(town_center)
    return Public.research_score(town_center) + Public.survival_score(town_center)
end

function Public.survival_score(town_center)
    return math.min(Public.survival_time_h(town_center) * age_score_factor, 70)
end

local function format_score(score)
    return string.format('%.1f', math.floor(score * 10) / 10)
end
Public.format_score = format_score

local function format_town_with_player_names(town_center)
    local player_names = ""
    local player_in_town_name = false
    for _, player in pairs(town_center.market.force.players) do
        if not string.find(town_center.town_name, player.name) then
            if player_names ~= "" then
                player_names = player_names .. ", "
            end
            player_names = player_names .. player.name
        else
            player_in_town_name = true
        end
    end
    if player_names ~= "" then
        if player_in_town_name then
            player_names = "+" .. player_names
        end
        player_names = " (" .. player_names .. ")"
    end
    return town_center.town_name .. player_names
end

local score_update_loop_interval = 60
local function update_score()
    local this = ScenarioTable.get_table()

    local town_highest_score = 0
    local town_total_scores = {}
    for _, town_center in pairs(this.town_centers) do
        local market = town_center.market
        local force = market.force
        local shield = this.pvp_shields[force.name]
        if not shield then
            town_center.survival_time_ticks = town_center.survival_time_ticks + score_update_loop_interval
        end

        town_total_scores[town_center] = Public.total_score(town_center)
        if town_total_scores[town_center] > town_highest_score then
            town_highest_score = town_total_scores[town_center]
        end

        if town_total_scores[town_center] >= score_to_win and this.winner == nil then
            this.winner = town_center.town_name
            local town_with_player_names = format_town_with_player_names(town_center)

            game.print(town_with_player_names .. " has won the game!", Utils.scenario_color)

            global.last_winner_name = town_with_player_names
            log("WINNER_STORE=\"" .. town_with_player_names .. "\"")
            global.game_end_sequence_start = game.tick + 600
        end
    end

    -- Announce high score towns
    if this.next_high_score_announcement == 0 then  -- init
        this.next_high_score_announcement = 70
    end
    if town_highest_score >= this.next_high_score_announcement then
        game.print("A town has reached " .. format_score(town_highest_score) .. " score." ..
                " The game ends at 100 score", Utils.scenario_color)
        if town_highest_score >= 70 then
            this.next_high_score_announcement = 80
        end
        if town_highest_score >= 80 then
            this.next_high_score_announcement = 90
        end
        if town_highest_score >= 90 then
            this.next_high_score_announcement = 95
        end
        if town_highest_score >= 95 then
            this.next_high_score_announcement = 9999 -- turning it off
        end
    end
end

Event.on_nth_tick(score_update_loop_interval, update_score)

return Public
