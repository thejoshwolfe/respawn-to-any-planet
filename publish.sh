#!/usr/bin/env bash
set -e

# https://wiki.factorio.com/Mod_publish_API

name=respawn-to-any-planet
APIKey=$(<.api_key)
zip_file=$(./build.sh)

# init_publish
response=$(curl -H "Authorization: Bearer $APIKey" -F "mod=$name" https://mods.factorio.com/api/v2/mods/releases/init_upload)
echo "$response"
upload_url=$(echo "$response" | jq -r .upload_url)

# finish_upload
curl -H "Authorization: Bearer $APIKey" -F "file=@$zip_file" "$upload_url"
