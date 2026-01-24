<#
.SYNOPSIS
    LUA Manifest Download/Generate
.DESCRIPTION
    Enter the game's AppID. If a .zip archive containing a README exists, it will be prioritized; otherwise, the raw .lua manifest file is served.
    Note: Generated links are temporary and expire within minutes.
.AUTHOR
    mPhpMaster
.LINK
    https://github.com/mPhpMaster/steam-lua-manifestor
#>



$HostUrl = "https://kernelos.org"

# Ask user
$inputValue = Read-Host "Enter Steam App ID or URL"

# Extract App ID
if ($inputValue -match '(?:store\.steampowered\.com/app/|/app/)?(\d+)') {
    $appId = $matches[1]
} else {
    Write-Host "Error: Invalid Steam App ID or URL" -ForegroundColor Red
    exit
}

# Build API URL
$apiUrl = "$HostUrl/games/download.php?gen=1&id=$appId"

try {
    # Fetch JSON
    $response = Invoke-RestMethod -Uri $apiUrl -Method Get

    if ($response.url) {
        $downloadUrl = $response.url

        # Handle relative URLs
        if ($downloadUrl.StartsWith("/")) {
            $downloadUrl = $HostUrl + $downloadUrl
        }

        Write-Host "Opening download link..."
        Start-Process $downloadUrl
    } else {
        Write-Host "Error: Download URL not found in response" -ForegroundColor Red
    }
}
catch {
    Write-Host "Error: Failed to get download link" -ForegroundColor Red
}
