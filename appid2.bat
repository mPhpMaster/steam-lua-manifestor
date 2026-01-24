:: LUA Manifest Download/Generate
:: Enter the game's AppID. If a .zip archive containing a README exists, it will be prioritized; otherwise, the raw .lua manifest file is served.
:: Note: Generated links are temporary and expire within minutes.
::
:: Author: mPhpMaster
:: Repo: https://github.com/mPhpMaster/steam-lua-manifestor



@echo off
setlocal EnableDelayedExpansion

set "HOST=https://kernelos.org"

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

:: Fetch JSON and extract URL
for /f "delims=" %%B in ('
  powershell -NoProfile -Command ^
  "try {
     $r = Invoke-RestMethod '%HOST%/games/download.php?gen=1&id=%APPID%';
     if($r.url){ $r.url }
   } catch { '' }"
') do set DOWNLOAD_URL=%%B

if not defined DOWNLOAD_URL (
    echo Error: Failed to get download link
    pause
    exit /b
)

:: Handle relative URLs
if "%DOWNLOAD_URL:~0,1%"=="/" (
    set DOWNLOAD_URL=%HOST%%DOWNLOAD_URL%
)

echo Opening download link...
start "" "%DOWNLOAD_URL%"

exit /b
