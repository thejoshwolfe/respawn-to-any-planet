#!/usr/bin/env bash
set -e

# https://wiki.factorio.com/Mod_publish_API

name=respawn-to-any-planet
category=tweaks
tags=transportation
license=default_mit
source_url=$(jq -r .homepage "$name"/info.json)
description=$(<README.md)
