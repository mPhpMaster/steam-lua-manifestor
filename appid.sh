#!/bin/bash

# LUA Manifest Download/Generate
# Enter the game's AppID. If a .zip archive containing a README exists, it will be prioritized; otherwise, the raw .lua manifest file is served.
# Note: Generated links are temporary and expire within minutes.
#
# Author: mPhpMaster
# Repo: https://github.com/mPhpMaster/steam-lua-manifestor

# Requires: curl, jq, xdg-open (Linux) or open (macOS)

HOST="https://generator.ryuu.lol"

read -p "Enter Steam App ID or URL: " INPUT

if [[ $INPUT =~ ([0-9]+) ]]; then
  APPID="${BASH_REMATCH[1]}"
else
  echo "Error: Invalid Steam App ID or URL"
  exit 1
fi

URL="$HOST/secure_download?appid=$APPID&auth_code=RYUUMANIFESTfvrlu0"

xdg-open "$URL" 2>/dev/null || open "$URL"
