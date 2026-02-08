#!/usr/bin/env bash
set -e

# Builds and copies into the specified mods dir.

name=respawn-to-any-planet
version=$(jq -r .version "$name"/info.json)
rm -f "$name"_*.zip
zip -rq "$name"_"$version".zip "$name"/
echo "$name"_"$version".zip
