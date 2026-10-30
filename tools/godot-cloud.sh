#!/usr/bin/env bash
set -euo pipefail
export XDG_DATA_HOME=/workspace/.runtime/godot/data
export XDG_CONFIG_HOME=/workspace/.runtime/godot/config
export XDG_CACHE_HOME=/workspace/.runtime/godot/cache
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
cd /workspace/garagem-brasil
exec godot --path . "$@"
