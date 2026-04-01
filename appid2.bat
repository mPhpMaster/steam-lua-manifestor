:: LUA Manifest Download/Generate
:: Enter the game's AppID. If a .zip archive containing a README exists, it will be prioritized; otherwise, the raw .lua manifest file is served.
:: Note: Generated links are temporary and expire within minutes.
::
:: Author: mPhpMaster
:: Repo: https://github.com/mPhpMaster/steam-lua-manifestor



@echo off
setlocal EnableDelayedExpansion

set "HOST=https://generator.ryuu.lol"

:: Ask user
set /p INPUT=Enter Steam App ID or URL: 

:: Extract App ID using PowerShell regex
for /f "delims=" %%A in ('
  powershell -NoProfile -Command ^
  "$i='%INPUT%'; if($i -match '(?:store\.steampowered\.com/app/|/app/)?(\d+)'){ $matches[1] }"
') do set APPID=%%A

if not defined APPID (
    echo Error: Invalid Steam App ID or URL
    pause
    exit /b
)

echo Found App ID: %APPID%

:: Build download URL
set DOWNLOAD_URL=%HOST%/secure_download?appid=%APPID%&auth_code=RYUUMANIFESTfvrlu0

echo Opening download link...
start "" "%DOWNLOAD_URL%"

exit /b
