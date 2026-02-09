# respawn-to-any-planet

A mod for Factorio: Space Age that transports your character to any previously visited planet via death and respawn.

You bring no inventory through death/respawn, not even your armor and weapons.
There is an option to remove the countdown after dying to respawn instantly when using this mod's buttons.

Possible uses for this mod:
* You rush to Fulgora and realize you're ill prepared. Warp back to Nauvis to build a better ship and try again without reloading any saves.
* Your Gleba factory collapses for mysterious spoilage-related reasons and you want to pop over to manually debug.
* You spell "HELP" with concrete on Aquilo as your ship is pummelled to bits by large asteroids.
* You're playing an Archipelago randomizer, and the unlocks for Gleba, Vulcanus, and Fulgora machines trickle in in random order.

⚠️ THERE IS NO CONFIRMATION WHEN CLICKING A BUTTON TO DIE ⚠️.
If you know how to make a confirmation dialog in a Factorio mod, please open a PR.
The best I could do is add a setting to hide all the buttons until you're ready to click one.
Escape | Settings | Mod settings | Per player | Respawn to any Planet | Show buttons for this mod.

### Remote API

This mod exposes hooks for other mods to install callbacks that fire before and after a character dies due to this mod's buttons.
This may be useful to understand why a character died.
For example, an Archipelago mod might disable Death Link for this case.
