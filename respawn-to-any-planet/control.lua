----------------------
-- REMOTE INTERFACE --
----------------------

local function clear_event_listeners()
    storage.event_listeners = {
        pre_die = {},
        post_die = {},
    }
end
remote.add_interface("respawn-to-any-planet", {
    -- Call the functions in this interface to register your callback at these times:
    --  * on_init in your mod
    --  * on_configuration_changed in your mod
    -- The registration data is persisted in the save file (and thereby downloaded by multiplayer joins),
    -- so do not call these functions in on_load.
    -- The registration data is wiped on_configuration_changed, so you need to re-register during that mod-wide event.
    -- Your info.json must declare a (potentially optional) dependency on this mod to ensure your mod's on_configuration_changed is called after this one.
    on_pre_die = function(interface_name, function_name) -- function will be called with a single argument: player_index
        table.insert(storage.event_listeners.pre_die, {interface_name, function_name})
    end,
    on_post_die = function(interface_name, function_name) -- function will be called with a single argument: player_index
        table.insert(storage.event_listeners.post_die, {interface_name, function_name})
    end,
})
local function call_hook(hook_name, player_index)
    for _, info in pairs(storage.event_listeners[hook_name]) do
        local interface_name, function_name = unpack(info)
        remote.call(interface_name, function_name, player_index)
    end
end

---------------
-- LIFECYCLE --
---------------

script.on_init(function()
    -- Listeners start empty.
    clear_event_listeners()
end)
script.on_load(function()
    -- Listeners are restored. Don't change anything.
end)
script.on_configuration_changed(function()
    -- Listeners must be re-registered.
    -- This is to allow a mod to be uninstalled and its registered listeners go away.
    clear_event_listeners()
end)

---------------------------
-- PRIMARY FUNCTIONALITY --
---------------------------

local function respawn_to(player, planet_name)
    local character = player.character
    if character ~= nil then
        -- The character is alive.
        call_hook("pre_die", player.index)
        character.die()
        call_hook("post_die", player.index)
    end

    local respawn_position = player.force.get_spawn_position(planet_name)
    player.teleport(respawn_position, planet_name)
    if player.mod_settings["respawn-to-any-planet_skip-countdown"].value then
        player.ticks_to_respawn = nil
        character = player.character
        -- For balance/annoyance reasons, spamming the respawn button should not fill your inventory with pistols (and ammo).
        for i = 1, character.get_max_inventory_index() do
            local inventory = character.get_inventory(i)
            if inventory ~= nil then
                inventory.clear()
            end
        end
    end
end

local function get_unlocked_planet_names(player)
    local planet_names = {}
    for _, surface in pairs(game.surfaces) do
        if
            -- Only actual planets, not space platforms (or surfaces created in editor without an associated planet)
            surface.planet ~= nil and
            -- You have to have landed on it so that it shows up in the remote view sidebar.
            -- Dropping a cargo pod to the planet creates the surface, but doesn't unlock it until you put your boots on the ground.
            player.force.is_space_location_unlocked(surface.name) and
            -- Hiding surfaces is not used in vanilla, but could be used by mods perhaps.
            -- This is a button for humans, so hiding a surface should hide it from the buttons too.
            not player.force.get_surface_hidden(surface.name)
        then
            table.insert(planet_names, surface.name)
        end
    end
    return planet_names
end

---------
-- GUI --
---------

local BUTTON_PREFIX = "respawn-to:"

local function update_buttons_for_player(player)
    -- Thanks to https://github.com/jonas205/respawn-button for inspiring this code.

    local planet_names = get_unlocked_planet_names(player)
    local should_show = player.mod_settings["respawn-to-any-planet_show-buttons"].value and (
        #planet_names > 1 or
        player.mod_settings["respawn-to-any-planet_show-just-one"].value
    )

    local ROOT_GUI_NAME = "respawn-to-any-planet:flow"
    local parent = player.gui.top
    local root_gui = parent[ROOT_GUI_NAME]
    local button_tray = nil

    if should_show and root_gui == nil then
        root_gui = parent.add {
            type = "frame",
            name = ROOT_GUI_NAME,
            direction = "horizontal",
            style = "slot_window_frame",
        }
        local deep_frame = root_gui.add {
            type = "frame",
            name = "the-deep-frame",
            style = "mod_gui_inside_deep_frame", -- no idea what this means.
        }
        button_tray = deep_frame.add {
            type = "flow",
            name = "the-button-tray",
            direction = "vertical",
        }
        button_tray.add {
            type = "label",
            caption = "[virtual-signal=signal-skull][virtual-signal=right-arrow]",
            tooltip = {"respawn-to-heading"},
        }
    elseif should_show and root_gui ~= nil then
        button_tray = root_gui["the-deep-frame"]["the-button-tray"]
    elseif not should_show and root_gui ~= nil then
        -- Probably caused by toggling a setting.
        root_gui.destroy()
        return
    else
        -- Already not showing
        return
    end

    for _, planet_name in pairs(planet_names) do
        local button_name = BUTTON_PREFIX .. planet_name
        if button_tray[button_name] then button_tray[button_name].destroy() end
        button_tray.add {
            type = "sprite-button",
            name = button_name,
            sprite = "space-location/" .. planet_name,
            --caption = "[planet=" .. planet_name .. "]",
            tooltip = {"respawn-to", "[planet=" .. planet_name .. "]", {"space-location-name." .. planet_name}},
            style = "mod_gui_button", -- no idea what this means.
        }
    end
end
local function update_buttons()
    if game == nil then return end
    for _, player in pairs(game.players) do
        update_buttons_for_player(player)
    end
end

script.on_event(defines.events.on_gui_click, function(event)
    -- example "respawn-to:nauvis"
    if string.sub(event.element.name, 1, string.len(BUTTON_PREFIX)) == BUTTON_PREFIX then
        local planet_name = string.sub(event.element.name, 1 + string.len(BUTTON_PREFIX))
        local player = game.players[event.player_index]
        respawn_to(player, planet_name)
    end
end)

-- A player starts a new game, joins a server, loads a save, etc. (I think)
script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    update_buttons_for_player(player)
end)

-- There's no event for is_space_location_unlocked changing,
-- but this is an ok proxy (untested):
script.on_event(defines.events.on_player_changed_surface,  update_buttons)

-- These are needed when someone is fiddling with surfaces in editor mode:
script.on_event(defines.events.on_surface_created,  update_buttons)
script.on_event(defines.events.on_surface_deleted,  update_buttons)
script.on_event(defines.events.on_surface_imported, update_buttons)
script.on_event(defines.events.on_surface_renamed,  update_buttons)

-- Toggling settings triggers this:
script.on_event(defines.events.on_runtime_mod_setting_changed, update_buttons)
