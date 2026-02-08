local mod_gui = require("mod-gui")

-- Thanks to https://github.com/jonas205/respawn-button for inspiring this code.

local GUI_FLOW = "respawn-to-any-planet:flow"
local BUTTON_PREFIX = "respawn-to:"

local function get_re_flow(player)
    local button_flow = mod_gui.get_button_flow(player)
    local flow = button_flow.re_flow
    if not flow then
        flow = button_flow.add {
            type = "flow",
            name = "re_flow",
            direction = "horizontal"
        }
    end
    return flow
end

local function add_top_button(player)
    if player.gui.top.re_flow then player.gui.top.re_flow.destroy() end
    local flow = get_re_flow(player)

    local button_name = BUTTON_PREFIX .. "nauvis"
    if flow[button_name] then flow[button_name].destroy() end
    flow.add {
        type = "sprite-button",
        name = button_name,
        sprite = "space-location/nauvis",
        style = mod_gui.button_style,
    }
end


script.on_init(function()
    for _, player in pairs(game.players) do
        add_top_button(player)
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    add_top_button(player)
end)

local function respawn_to(player, planet_name)
    local character = player.character
    if character == nil then
        player.print("No character found. already dead??")
        return
    end

    character.die()
    player.teleport({0, 0}, planet_name)
    if player.mod_settings["respawn-to-any-planet_skip-countdown"].value then
        player.ticks_to_respawn = nil
    end
end

script.on_event(defines.events.on_gui_click, function(event)
    local button_name = BUTTON_PREFIX .. "nauvis"
    if event.element.name == button_name then
        local player = game.players[event.player_index]
        respawn_to(player, "nauvis")
    end
end)
