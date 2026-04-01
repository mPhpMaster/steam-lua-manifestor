
:: LUA Manifest Download/Generate
:: Enter the game's AppID. If a .zip archive containing a README exists, it will be prioritized; otherwise, the raw .lua manifest file is served.
:: Note: Generated links are temporary and expire within minutes.
::
:: Author: mPhpMaster
:: Repo: https://github.com/mPhpMaster/steam-lua-manifestor



@echo off
setlocal EnableDelayedExpansion

set HOST=https://generator.ryuu.lol
set /p INPUT=Enter Steam App ID or URL: 

for /f "delims=" %%A in ('
  powershell -NoProfile -Command ^
  "$i='%INPUT%'; if($i -match '(\d+)'){ $matches[1] }"
') do set APPID=%%A

if not defined APPID (
  echo Error: Invalid Steam App ID or URL
  pause
  exit /b
)

for /f "delims=" %%B in ('
  powershell -NoProfile -Command ^
  "(Invoke-RestMethod '%HOST%/secure_download?appid=%APPID%&auth_code=RYUUMANIFESTfvrlu0').url"
') do set URL=%%B

if not defined URL (
  echo Error: Failed to get download link
  pause
  exit /b
)

if "%URL:~0,1%"=="/" set URL=%HOST%%URL%

start "" "%URL%"
