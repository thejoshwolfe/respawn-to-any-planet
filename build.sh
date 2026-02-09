#!/usr/bin/env bash
set -e

# https://lua-api.factorio.com/latest/auxiliary/mod-structure.html

name=respawn-to-any-planet
version=$(jq -r .version "$name"/info.json)
rm -f "$name"_*.zip
zip -rq "$name"_"$version".zip "$name"/
echo "$name"_"$version".zip

## For Development
#
#Replace `~/.factorio/mods/` with the path to your factorio mods dir if you're not using the Linux default.
#Then run the following command:
#    mod=$(./build.sh) && rm -rf ~/.factorio/mods/respawn-to-any-planet_* && mv "$mod" ~/.factorio/mods/"$mod"
#Or for a plain folder:
#    version=$(jq -r .version respawn-to-any-planet/info.json) && rm -rf ~/.factorio/mods/respawn-to-any-planet_* && cp -Tr respawn-to-any-planet/ ~/.factorio/mods/respawn-to-any-planet_"$version"/
