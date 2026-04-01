#Requires -Version 5.1
# Steam 32-bit Downgrader with Christmas Theme
# Gets Steam path from registry and runs with specified parameters

# Clear screen
Clear-Host

# Christmas-themed header
Write-Host ""
Write-Host "===============================================================" -ForegroundColor DarkYellow
Write-Host "Steam 32-bit Downgrader - by discord.gg/luatools (join for fun)" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor DarkYellow
Write-Host ""

# Ensure temp directory exists (fix for systems where $env:TEMP points to non-existent directory)
if (-not $env:TEMP -or -not (Test-Path $env:TEMP)) {
    # Fallback to user's AppData\Local\Temp
    if ($env:LOCALAPPDATA -and (Test-Path $env:LOCALAPPDATA)) {
        $env:TEMP = Join-Path $env:LOCALAPPDATA "Temp"
    }
    # If still not valid, try last resort
    if (-not $env:TEMP -or -not (Test-Path $env:TEMP)) {
        # Last resort: create a temp directory in the script's location or current directory
        if ($PSScriptRoot) {
            $env:TEMP = Join-Path $PSScriptRoot "temp"
        } else {
            $env:TEMP = Join-Path (Get-Location).Path "temp"
        }
    }
}
# Ensure the temp directory exists
if (-not (Test-Path $env:TEMP)) {
    New-Item -ItemType Directory -Path $env:TEMP -Force | Out-Null
}

# Function to pause script and explain error
function Stop-OnError {
    param(
        [string]$ErrorMessage,
        [string]$ErrorDetails = "",
        [string]$StepName = ""
    )
    
    Write-Host ""
    Write-Host "===============================================================" -ForegroundColor Red
    Write-Host "ERROR OCCURRED" -ForegroundColor Red
    if ($StepName) {
        Write-Host "Step: $StepName" -ForegroundColor Yellow
    }
    Write-Host "===============================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error Message: $ErrorMessage" -ForegroundColor Red
    if ($ErrorDetails) {
        Write-Host ""
        Write-Host "Details: $ErrorDetails" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "The script cannot continue due to this error." -ForegroundColor Yellow
    Write-Host "Please resolve the issue and try again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "===============================================================" -ForegroundColor Red
    Write-Host "Exiting..." -ForegroundColor Red
    Write-Host "===============================================================" -ForegroundColor Red
    exit 1
}

# Function to get Steam path from registry
function Get-SteamPath {
    $steamPath = $null
    
    Write-Host "Searching for Steam installation..." -ForegroundColor Gray
    
    # Try HKCU first (User registry)
    $regPath = "HKCU:\Software\Valve\Steam"
    if (Test-Path $regPath) {
        $steamPath = (Get-ItemProperty -Path $regPath -Name "SteamPath" -ErrorAction SilentlyContinue).SteamPath
        if ($steamPath -and (Test-Path $steamPath)) {
            return $steamPath
        }
    }
    
    # Try HKLM (System registry)
    $regPath = "HKLM:\Software\Valve\Steam"
    if (Test-Path $regPath) {
        $steamPath = (Get-ItemProperty -Path $regPath -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath
        if ($steamPath -and (Test-Path $steamPath)) {
            return $steamPath
        }
    }
    
    # Try 32-bit registry on 64-bit systems
    $regPath = "HKLM:\Software\WOW6432Node\Valve\Steam"
    if (Test-Path $regPath) {
        $steamPath = (Get-ItemProperty -Path $regPath -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath
        if ($steamPath -and (Test-Path $steamPath)) {
            return $steamPath
        }
    }
    
    return $null
}

# Function to download file with inline progress bar
function Download-FileWithProgress {
    param(
        [string]$Url,
        [string]$OutFile
    )
    
    try {
        # Add cache-busting to prevent PowerShell cache
        $uri = New-Object System.Uri($Url)
        $uriBuilder = New-Object System.UriBuilder($uri)
        $timestamp = (Get-Date -Format 'yyyyMMddHHmmss')
        if ($uriBuilder.Query) {
            $uriBuilder.Query = $uriBuilder.Query.TrimStart('?') + "&t=" + $timestamp
        } else {
            $uriBuilder.Query = "t=" + $timestamp
        }
        $cacheBustUrl = $uriBuilder.ToString()
        
        # First request to get content length and verify response
        $request = [System.Net.HttpWebRequest]::Create($cacheBustUrl)
        $request.CachePolicy = New-Object System.Net.Cache.RequestCachePolicy([System.Net.Cache.RequestCacheLevel]::NoCacheNoStore)
        $request.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate")
        $request.Headers.Add("Pragma", "no-cache")
        $request.Timeout = 30000 # 30 seconds timeout
        $request.ReadWriteTimeout = 30000
        
        try {
            $response = $request.GetResponse()
        } catch {
            Write-Host "  [ERROR] Connection failed: $_" -ForegroundColor Red
            Write-Host "  [ERROR] URL: $cacheBustUrl" -ForegroundColor Red
            throw "Connection timeout or failed to connect to server"
        }
        
        # Check response code
        $statusCode = [int]$response.StatusCode
        if ($statusCode -ne 200) {
            $response.Close()
            Write-Host "  [ERROR] Invalid response code: $statusCode (expected 200)" -ForegroundColor Red
            Write-Host "  [ERROR] URL: $cacheBustUrl" -ForegroundColor Red
            throw "Server returned status code $statusCode instead of 200"
        }
        
        # Check content length (some servers return -1 for unknown length, which is acceptable)
        $totalLength = $response.ContentLength
        if ($totalLength -eq 0) {
            $response.Close()
            Write-Host "  [ERROR] Invalid content length: $totalLength (expected > 0 or -1 for unknown)" -ForegroundColor Red
            Write-Host "  [ERROR] URL: $cacheBustUrl" -ForegroundColor Red
            throw "Server returned zero content length"
        }
        # If ContentLength is -1, we'll handle it in the download loop (unknown size)
        
        $response.Close()
        
        # Second request to download the file (no timeout - allow long downloads)
        $request = [System.Net.HttpWebRequest]::Create($cacheBustUrl)
        $request.CachePolicy = New-Object System.Net.Cache.RequestCachePolicy([System.Net.Cache.RequestCacheLevel]::NoCacheNoStore)
        $request.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate")
        $request.Headers.Add("Pragma", "no-cache")
        $request.Timeout = -1 # No timeout
        $request.ReadWriteTimeout = -1 # No timeout
        
        $response = $null
        try {
            $response = $request.GetResponse()
        } catch {
            Write-Host "  [ERROR] Download connection failed: $_" -ForegroundColor Red
            Write-Host "  [ERROR] URL: $cacheBustUrl" -ForegroundColor Red
            throw "Connection failed during download"
        }
        
        try {
            # Ensure the output directory exists
            $outDir = Split-Path $OutFile -Parent
            if ($outDir -and -not (Test-Path $outDir)) {
                New-Item -ItemType Directory -Path $outDir -Force | Out-Null
            }
            
            $responseStream = $null
            $targetStream = $null
            $responseStream = $response.GetResponseStream()
            $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $OutFile, Create
            
            $buffer = New-Object byte[] (10 * 1024)  # 10KB buffer
            $count = $responseStream.Read($buffer, 0, $buffer.Length)
            $downloadedBytes = $count
            $lastUpdate = Get-Date
            $lastBytesDownloaded = $downloadedBytes
            $lastBytesUpdateTime = Get-Date
            $stuckTimeoutSeconds = 60 # 1 minute timeout for stuck downloads
            
            while ($count -gt 0) {
                $targetStream.Write($buffer, 0, $count)
                $count = $responseStream.Read($buffer, 0, $buffer.Length)
                $downloadedBytes += $count
                
                # Check if download is stuck (no progress for 1 minute)
                $now = Get-Date
                if ($downloadedBytes -gt $lastBytesDownloaded) {
                    # Bytes increased, reset stuck timer
                    $lastBytesDownloaded = $downloadedBytes
                    $lastBytesUpdateTime = $now
                } else {
                    # No bytes downloaded, check if stuck
                    $timeSinceLastBytes = ($now - $lastBytesUpdateTime).TotalSeconds
                    if ($timeSinceLastBytes -ge $stuckTimeoutSeconds) {
                        # Clean up partial file - streams will be closed in finally block
                        if (Test-Path $OutFile) {
                            Remove-Item $OutFile -Force -ErrorAction SilentlyContinue
                        }
                        Write-Host ""
                        Write-Host "  [ERROR] Download appears stuck (0 kbps for $stuckTimeoutSeconds seconds)" -ForegroundColor Red
                        Write-Host "  [ERROR] Downloaded: $downloadedBytes bytes, Expected: $totalLength bytes" -ForegroundColor Red
                        throw "Download stalled - no data received for $stuckTimeoutSeconds seconds"
                    }
                }
                
                # Update progress every 100ms to avoid too frequent updates
                if (($now - $lastUpdate).TotalMilliseconds -ge 100) {
                    if ($totalLength -gt 0) {
                        $percentComplete = [math]::Round(($downloadedBytes / $totalLength) * 100, 2)
                        $downloadedMB = [math]::Round($downloadedBytes / 1MB, 2)
                        $totalMB = [math]::Round($totalLength / 1MB, 2)
                        
                        # Update progress on same line
                        $progressBarLength = [math]::Floor($percentComplete / 2)
                        $progressBar = "=" * $progressBarLength
                        $progressBar = $progressBar.PadRight(50)
                        Write-Host "`r  Progress: [$progressBar] $percentComplete% ($downloadedMB MB / $totalMB MB)" -NoNewline -ForegroundColor Cyan
                    } else {
                        # Show bytes downloaded if total length unknown
                        $downloadedMB = [math]::Round($downloadedBytes / 1MB, 2)
                        Write-Host "`r  Progress: Downloaded $downloadedMB MB..." -NoNewline -ForegroundColor Cyan
                    }
                    $lastUpdate = $now
                }
            }
            
            # Final update to show 100%
            if ($totalLength -gt 0) {
                $downloadedMB = [math]::Round($downloadedBytes / 1MB, 2)
                $totalMB = [math]::Round($totalLength / 1MB, 2)
                $progressBar = "=" * 50
                Write-Host "`r  Progress: [$progressBar] 100.00% ($downloadedMB MB / $totalMB MB)" -NoNewline -ForegroundColor Cyan
            } else {
                $downloadedMB = [math]::Round($downloadedBytes / 1MB, 2)
                Write-Host "`r  Progress: Downloaded $downloadedMB MB... Complete!" -NoNewline -ForegroundColor Cyan
            }
            
            Write-Host "" # New line after progress
            
            return $true
        } finally {
            # Always close streams, even if an error occurs
            if ($targetStream) {
                $targetStream.Close()
            }
            if ($responseStream) {
                $responseStream.Close()
            }
            if ($response) {
                $response.Close()
            }
        }
    } catch {
        Write-Host ""
        Write-Host "  [ERROR] Download failed: $_" -ForegroundColor Red
        Write-Host "  [ERROR] Error details: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.InnerException) {
            Write-Host "  [ERROR] Inner exception: $($_.Exception.InnerException.Message)" -ForegroundColor Red
        }
        Write-Host ""
        # Throw exception instead of exiting - let caller handle it (fallback function or main script)
        throw $_
    }
}

# Function to download and extract with fallback URL support
function Download-AndExtractWithFallback {
    param(
        [string]$PrimaryUrl,
        [string]$FallbackUrl,
        [string]$TempZipPath,
        [string]$DestinationPath,
        [string]$Description
    )
    
    $urls = @($PrimaryUrl, $FallbackUrl)
    $lastError = $null
    
    foreach ($url in $urls) {
        # Determine if this is the fallback URL before try block (so it's available in catch)
        $isFallback = ($url -eq $FallbackUrl)
        
        try {
            # Clean up any existing temp file
            if (Test-Path $TempZipPath) {
                Remove-Item -Path $TempZipPath -Force -ErrorAction SilentlyContinue
            }
            
            if ($isFallback) {
                Write-Host "  [INFO] Primary download failed, trying fallback URL..." -ForegroundColor Yellow
            }
            
            Write-Host "  Downloading from: $url" -ForegroundColor Gray
            Download-FileWithProgress -Url $url -OutFile $TempZipPath
            Write-Host "  [SUCCESS] Download complete" -ForegroundColor Green
            
            # Try to extract - this will validate the ZIP
            Write-Host "  Extracting to: $DestinationPath" -ForegroundColor Gray
            Expand-ArchiveWithProgress -ZipPath $TempZipPath -DestinationPath $DestinationPath
            Write-Host "  [SUCCESS] Extraction complete" -ForegroundColor Green
            
            # Clean up temp file
            Remove-Item -Path $TempZipPath -Force -ErrorAction SilentlyContinue
            
            return $true
        } catch {
            $lastError = $_
            $errorMessage = $_.ToString()
            if ($_.Exception -and $_.Exception.Message) {
                $errorMessage = $_.Exception.Message
            }
            
            if ($isFallback) {
                # Both URLs failed
                Write-Host "  [ERROR] Fallback download also failed: $_" -ForegroundColor Red
                throw "Both primary and fallback downloads failed. Last error: $_"
            } else {
                # Check if it's a ZIP validation error or download error that should trigger fallback
                # Cloudflare blocks: ZIP validation errors (HTML page instead of ZIP)
                # Connection issues: timeouts, connection failures, stuck downloads
                if ($errorMessage -match "Invalid ZIP|corrupted|End of Central Directory|PK signature|ZIP file|Connection.*failed|timeout|stalled|stuck|failed to connect") {
                    Write-Host "  [WARNING] Download failed (possible Cloudflare block or connection issue), will try fallback URL..." -ForegroundColor Yellow
                    continue
                } else {
                    # Other error (like invalid response code, authentication, etc.), rethrow
                    throw $_
                }
            }
        }
    }
    
    # Should never reach here, but just in case
    if ($lastError) {
        throw $lastError
    } else {
        throw "Download failed for unknown reason"
    }
}

# Function to extract archive with inline progress bar
function Expand-ArchiveWithProgress {
    param(
        [string]$ZipPath,
        [string]$DestinationPath
    )
    
    try {
        # Validate ZIP file exists and has content
        if (-not (Test-Path $ZipPath)) {
            Write-Host "  [ERROR] ZIP file not found: $ZipPath" -ForegroundColor Red
            throw "ZIP file does not exist"
        }
        
        $zipFileInfo = Get-Item $ZipPath -ErrorAction Stop
        if ($zipFileInfo.Length -eq 0) {
            Write-Host "  [ERROR] ZIP file is empty (0 bytes)" -ForegroundColor Red
            throw "ZIP file is empty"
        }
        
        # Check if file starts with ZIP signature (PK header)
        $zipStream = $null
        try {
            $zipStream = [System.IO.File]::OpenRead($ZipPath)
            $header = New-Object byte[] 4
            $bytesRead = $zipStream.Read($header, 0, 4)
            
            if ($bytesRead -lt 4 -or $header[0] -ne 0x50 -or $header[1] -ne 0x4B) {
                Write-Host "  [ERROR] File does not appear to be a valid ZIP file (missing PK signature)" -ForegroundColor Red
                Write-Host "  [ERROR] File size: $($zipFileInfo.Length) bytes" -ForegroundColor Red
                throw "Invalid ZIP file format"
            }
        } finally {
            if ($zipStream) {
                $zipStream.Close()
            }
        }
        
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        
        # Try to open the ZIP file - this will fail if corrupted
        $zip = $null
        try {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
        } catch {
            Write-Host "  [ERROR] ZIP file is corrupted or incomplete" -ForegroundColor Red
            Write-Host "  [ERROR] File size: $($zipFileInfo.Length) bytes" -ForegroundColor Red
            Write-Host "  [ERROR] Error: $($_.Exception.Message)" -ForegroundColor Red
            throw "ZIP file is corrupted - download may have been interrupted. Please try again."
        }
        
        try {
            $entries = $zip.Entries
            
            # Count only files (exclude directories)
            $fileEntries = @()
            foreach ($entry in $entries) {
                if (-not ($entry.FullName.EndsWith('\') -or $entry.FullName.EndsWith('/'))) {
                    $fileEntries += $entry
                }
            }
            $totalFiles = $fileEntries.Count
            if ($totalFiles -eq 0) {
                Write-Host "  [WARNING] ZIP file contains no files (only directories)" -ForegroundColor Yellow
                return $true
            }
            $extractedCount = 0
            $lastUpdate = Get-Date
            
            foreach ($entry in $entries) {
                # Sanitize entry path to prevent path traversal attacks
                $sanitizedPath = $entry.FullName
                # Remove leading slashes/backslashes and normalize path separators
                $sanitizedPath = $sanitizedPath.TrimStart('\', '/')
                # Replace any remaining absolute path indicators
                $sanitizedPath = $sanitizedPath -replace '^[A-Z]:\\', '' -replace '^/', ''
                # Normalize path separators to backslashes for Windows
                $sanitizedPath = $sanitizedPath -replace '/', '\'
                
                $entryPath = Join-Path $DestinationPath $sanitizedPath
                
                # Additional safety check: ensure the resolved path is still within destination
                $resolvedEntryPath = [System.IO.Path]::GetFullPath($entryPath)
                $resolvedDestination = [System.IO.Path]::GetFullPath($DestinationPath)
                if (-not $resolvedEntryPath.StartsWith($resolvedDestination, [System.StringComparison]::OrdinalIgnoreCase)) {
                    Write-Host "  [WARNING] Skipping potentially dangerous path: $($entry.FullName)" -ForegroundColor Yellow
                    continue
                }
                
                # Create directory if it doesn't exist
                $entryDir = Split-Path $entryPath -Parent
                if ($entryDir -and -not (Test-Path $entryDir)) {
                    New-Item -ItemType Directory -Path $entryDir -Force | Out-Null
                }
                
                # Skip if entry is a directory
                if ($entry.FullName.EndsWith('\') -or $entry.FullName.EndsWith('/')) {
                    continue
                }
                
                # Extract the file
                try {
                    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $entryPath, $true)
                    $extractedCount++
                } catch {
                    # If file is locked, provide more helpful error message
                    if ($_.Exception.Message -match "being used by another process|locked|access.*denied") {
                        Write-Host ""
                        Write-Host "  [ERROR] Cannot extract $($entry.FullName) - file is locked or in use" -ForegroundColor Red
                        Write-Host "  [ERROR] Please close any programs using this file and try again" -ForegroundColor Red
                        throw "File locked: $($entry.FullName)"
                    } else {
                        throw
                    }
                }
                
                # Update progress every 50ms
                $now = Get-Date
                if (($now - $lastUpdate).TotalMilliseconds -ge 50) {
                    $percentComplete = [math]::Round(($extractedCount / $totalFiles) * 100, 2)
                    $progressBarLength = [math]::Floor($percentComplete / 2)
                    $progressBar = "=" * $progressBarLength
                    $progressBar = $progressBar.PadRight(50)
                    Write-Host "`r  Progress: [$progressBar] $percentComplete% ($extractedCount / $totalFiles files)" -NoNewline -ForegroundColor Cyan
                    $lastUpdate = $now
                }
            }
            
            # Final update to show 100%
            $progressBar = "=" * 50
            Write-Host "`r  Progress: [$progressBar] 100.00% ($totalFiles / $totalFiles files)" -NoNewline -ForegroundColor Cyan
            
            Write-Host "" # New line after progress
            
            return $true
        } finally {
            # Always dispose the ZIP file, even if an error occurs
            if ($zip) {
                $zip.Dispose()
            }
        }
    } catch {
        Write-Host ""
        throw $_
    }
}

# Step 0: Get Steam path from registry
Write-Host "Step 0: Locating Steam installation..." -ForegroundColor Yellow
$steamPath = Get-SteamPath
$steamExePath = $null

if (-not $steamPath) {
    Write-Host "  [ERROR] Steam installation not found in registry." -ForegroundColor Red
    Write-Host "  Please ensure Steam is installed on your system." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "===============================================================" -ForegroundColor DarkYellow
    Write-Host "Exiting..." -ForegroundColor Green
    Write-Host "===============================================================" -ForegroundColor DarkYellow
    exit
}

$steamExePath = Join-Path $steamPath "Steam.exe"

if (-not (Test-Path $steamExePath)) {
    Write-Host "  [ERROR] Steam.exe not found at: $steamExePath" -ForegroundColor Red
    Write-Host "  The Steam directory exists but Steam.exe is missing." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "===============================================================" -ForegroundColor DarkYellow
    Write-Host "Exiting..." -ForegroundColor Green
    Write-Host "===============================================================" -ForegroundColor DarkYellow
    exit
}

Write-Host "  [SUCCESS] Steam found!" -ForegroundColor Green
Write-Host "  Location: $steamPath" -ForegroundColor White
Write-Host ""

# Step 1: Kill all Steam processes
Write-Host "Step 1: Killing all Steam processes..." -ForegroundColor Yellow

# Function to kill Steam processes with retry and verification
function Stop-SteamProcesses {
    $maxAttempts = 3
    $attempt = 0
    
    # First, try to stop SteamService as a Windows service (if it exists)
    $steamServiceNames = @("Steam Client Service", "SteamService", "Steam")
    
    foreach ($serviceName in $steamServiceNames) {
        try {
            $steamService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
            if ($steamService -and $steamService.Status -eq 'Running') {
                Write-Host "  [INFO] Stopping $serviceName..." -ForegroundColor Gray
                try {
                    Stop-Service -Name $serviceName -Force -ErrorAction Stop
                    Write-Host "  [SUCCESS] $serviceName stopped" -ForegroundColor Green
                    Start-Sleep -Seconds 1
                    break
                } catch {
                    Write-Host "  [WARNING] Could not stop $serviceName (may require administrator privileges): $_" -ForegroundColor Yellow
                }
            }
        } catch {
            # Service might not exist or not accessible, try next name
            continue
        }
    }
    
    while ($attempt -lt $maxAttempts) {
        $attempt++
        $steamProcesses = Get-Process -Name "steam*" -ErrorAction SilentlyContinue
        
        if (-not $steamProcesses) {
            if ($attempt -eq 1) {
                Write-Host "  [INFO] No Steam processes found running" -ForegroundColor Cyan
            }
            return $true
        }
        
        if ($attempt -gt 1) {
            Write-Host "  [INFO] Attempt $attempt of $maxAttempts to kill remaining processes..." -ForegroundColor Yellow
        }
        
        foreach ($proc in $steamProcesses) {
            # Check if this is SteamService - try to stop it as a service first
            if ($proc.Name -eq "SteamService") {
                $serviceStoppedInLoop = $false
                foreach ($serviceName in $steamServiceNames) {
                    try {
                        $steamService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
                        if ($steamService -and $steamService.Status -eq 'Running') {
                            Write-Host "  [INFO] Attempting to stop SteamService as a Windows service ($serviceName)..." -ForegroundColor Gray
                            Stop-Service -Name $serviceName -Force -ErrorAction Stop
                            Write-Host "  [SUCCESS] SteamService stopped via service control" -ForegroundColor Green
                            Start-Sleep -Seconds 1
                            $serviceStoppedInLoop = $true
                            break
                        }
                    } catch {
                        # Try next service name
                        continue
                    }
                }
                if ($serviceStoppedInLoop) {
                    continue
                }
            }
            
            try {
                # Try graceful shutdown first
                $proc.Kill()
                Write-Host "  [INFO] Killed process: $($proc.Name) (PID: $($proc.Id))" -ForegroundColor Gray
            } catch {
                try {
                    # Force kill if graceful failed
                    Stop-Process -Id $proc.Id -Force -ErrorAction Stop
                    Write-Host "  [INFO] Force-killed process: $($proc.Name) (PID: $($proc.Id))" -ForegroundColor Gray
                } catch {
                    # If it's SteamService and we couldn't stop it, provide helpful message
                    if ($proc.Name -eq "SteamService") {
                        Write-Host "  [WARNING] Could not kill SteamService (PID: $($proc.Id)) - this is a Windows service" -ForegroundColor Yellow
                        Write-Host "  [INFO] SteamService may require administrator privileges to stop. The script will continue anyway." -ForegroundColor Yellow
                    } else {
                        Write-Host "  [WARNING] Could not kill process: $($proc.Name) (PID: $($proc.Id))" -ForegroundColor Yellow
                    }
                }
            }
        }
        
        # Wait for processes to terminate
        Start-Sleep -Seconds 2
        
        # Clear any previous progress output
        Write-Host ""
        
        # Verify processes are actually gone
        $remainingProcesses = Get-Process -Name "steam*" -ErrorAction SilentlyContinue
        if (-not $remainingProcesses) {
            # Additional wait to ensure DLLs are released
            Write-Host "  Waiting for DLLs to be fully released..." -ForegroundColor Gray
            Start-Sleep -Seconds 3
            
            # Final verification - check if Steam restarted
            $finalCheck = Get-Process -Name "steam*" -ErrorAction SilentlyContinue
            if ($finalCheck) {
                Write-Host "  [WARNING] Steam appears to have restarted, killing again..." -ForegroundColor Yellow
                foreach ($proc in $finalCheck) {
                    try {
                        Stop-Process -Id $proc.Id -Force -ErrorAction Stop
                        Write-Host "  [INFO] Killed restarted process: $($proc.Name) (PID: $($proc.Id))" -ForegroundColor Gray
                    } catch {
                        Write-Host "  [WARNING] Could not kill restarted process: $($proc.Name)" -ForegroundColor Yellow
                    }
                }
                Start-Sleep -Seconds 2
                
                # One more check
                $stillRunning = Get-Process -Name "steam*" -ErrorAction SilentlyContinue
                if ($stillRunning) {
                    Write-Host "  [WARNING] Steam keeps restarting - this may indicate a watchdog process" -ForegroundColor Yellow
                    # Continue the loop to retry instead of returning true
                    continue
                } else {
                    Write-Host "  [SUCCESS] All Steam processes terminated" -ForegroundColor Green
                    return $true
                }
            } else {
                Write-Host "  [SUCCESS] All Steam processes terminated" -ForegroundColor Green
                return $true
            }
        } else {
            Write-Host "  [WARNING] Some processes are still running, retrying..." -ForegroundColor Yellow
        }
    }
    
    # Final check - if processes still exist after all attempts, report error
    $finalCheck = Get-Process -Name "steam*" -ErrorAction SilentlyContinue
    if ($finalCheck) {
        # Filter out SteamService if it's the only remaining process (it's just a service, not blocking)
        $nonServiceProcesses = $finalCheck | Where-Object { $_.Name -ne "SteamService" }
        
        if ($nonServiceProcesses) {
            $processList = ($nonServiceProcesses | ForEach-Object { "$($_.Name) (PID: $($_.Id))" }) -join ", "
            $errorMsg = "The following Steam processes could not be terminated: $processList"
            $errorDetails = "Steam may have a watchdog process that automatically restarts it. Please manually close Steam and any related processes, then try again."
            Stop-OnError -ErrorMessage "Failed to terminate all Steam processes" -ErrorDetails $errorDetails -StepName "Step 1"
        } else {
            # Only SteamService is running, which is okay - it's just a service
            Write-Host "  [INFO] Only SteamService is still running (Windows service - not blocking)" -ForegroundColor Cyan
            Write-Host "  [SUCCESS] All blocking Steam processes terminated" -ForegroundColor Green
        }
    }
    
    return $true
}

Stop-SteamProcesses
Write-Host ""

# Step 2: Download and extract Steam x32 Latest Build
Write-Host "Step 2: Downloading and extracting Steam x32 Latest Build..." -ForegroundColor Yellow
$steamZipUrl = "https://github.com/madoiscool/lt_api_links/releases/download/unsteam/latest32bitsteam.zip"
$steamZipFallbackUrl = "http://files.luatools.work/OneOffFiles/latest32bitsteam.zip"
$tempSteamZip = Join-Path $env:TEMP "latest32bitsteam.zip"

    try {
        Download-AndExtractWithFallback -PrimaryUrl $steamZipUrl -FallbackUrl $steamZipFallbackUrl -TempZipPath $tempSteamZip -DestinationPath $steamPath -Description "Steam x32 Latest Build"
        Write-Host ""
    } catch {
        # Clean up temp file on error
        if (Test-Path $tempSteamZip) {
            Remove-Item -Path $tempSteamZip -Force -ErrorAction SilentlyContinue
        }
        $errorMsg = $_.Exception.Message
        if (-not $errorMsg) {
            $errorMsg = $_.ToString()
        }
        Stop-OnError -ErrorMessage "Failed to download or extract Steam x32 Latest Build" -ErrorDetails $errorMsg -StepName "Step 2"
    }

# Step 3: Download and extract zip file (only if millennium.dll or user32.dll is present - to replace it)
Write-Host "Step 3: Checking for Millennium build..." -ForegroundColor Yellow
# Use case-insensitive search for both millennium.dll and user32.dll
$millenniumDll = Get-ChildItem -Path $steamPath -Filter "millennium.dll" -ErrorAction SilentlyContinue | Select-Object -First 1
$user32Dll = Get-ChildItem -Path $steamPath -Filter "user32.dll" -ErrorAction SilentlyContinue | Select-Object -First 1

# Check if either Millennium DLL is present
$hasMillennium = ($millenniumDll -and (Test-Path $millenniumDll.FullName))
$hasUser32 = ($user32Dll -and (Test-Path $user32Dll.FullName))

if ($hasMillennium -or $hasUser32) {
    $foundDlls = @()
    if ($hasMillennium) {
        $foundDlls += "millennium.dll"
        Write-Host "  [INFO] millennium.dll found" -ForegroundColor Yellow
        Write-Host "    Location: $($millenniumDll.FullName)" -ForegroundColor White
    }
    if ($hasUser32) {
        $foundDlls += "user32.dll"
        Write-Host "  [INFO] user32.dll found" -ForegroundColor Yellow
        Write-Host "    Location: $($user32Dll.FullName)" -ForegroundColor White
    }
    Write-Host "  [INFO] Downloading and extracting Millennium build to replace: $($foundDlls -join ', ')" -ForegroundColor Yellow
    
    # Function to unlock and remove locked DLL
    function Unlock-AndRemoveDll {
        param([string]$DllPath)
        
        $maxRetries = 5
        $retryDelay = 2
        
        for ($i = 0; $i -lt $maxRetries; $i++) {
            try {
                # Try to get file handle to check if locked
                $fileStream = [System.IO.File]::Open($DllPath, 'Open', 'ReadWrite', 'None')
                $fileStream.Close()
                $fileStream.Dispose()
                
                # File is not locked, try to delete
                Remove-Item -Path $DllPath -Force -ErrorAction Stop
                Write-Host "  [INFO] Successfully removed locked DLL (attempt $($i + 1))" -ForegroundColor Gray
                return $true
            } catch {
                if ($i -lt $maxRetries - 1) {
                    Write-Host "  [INFO] DLL is locked, waiting ${retryDelay}s before retry ($($i + 1)/$maxRetries)..." -ForegroundColor Yellow
                    Start-Sleep -Seconds $retryDelay
                } else {
                    Write-Host "  [WARNING] Could not unlock DLL after $maxRetries attempts: $_" -ForegroundColor Yellow
                    return $false
                }
            }
        }
        return $false
    }
    
    # Try to unlock and remove the DLL(s) before extraction
    $dllsToUnlock = @()
    if ($hasMillennium) {
        $dllsToUnlock += @{ Path = $millenniumDll.FullName; Name = "millennium.dll" }
    }
    if ($hasUser32) {
        $dllsToUnlock += @{ Path = $user32Dll.FullName; Name = "user32.dll" }
    }
    
    foreach ($dll in $dllsToUnlock) {
        Write-Host "  Attempting to unlock $($dll.Name)..." -ForegroundColor Gray
        $unlocked = Unlock-AndRemoveDll -DllPath $dll.Path
        
        if (-not $unlocked) {
            $errorMsg = "Could not unlock $($dll.Name) after multiple attempts. The file may be locked by another process (antivirus, Windows Explorer, etc.)."
            Stop-OnError -ErrorMessage "Failed to unlock $($dll.Name)" -ErrorDetails $errorMsg -StepName "Step 3"
        }
    }
    
    $zipUrl = "https://github.com/madoiscool/lt_api_links/releases/download/unsteam/luatoolsmilleniumbuild.zip"
    $zipFallbackUrl = "http://files.luatools.work/OneOffFiles/luatoolsmilleniumbuild.zip"
    $tempZip = Join-Path $env:TEMP "luatoolsmilleniumbuild.zip"

    try {
        Download-AndExtractWithFallback -PrimaryUrl $zipUrl -FallbackUrl $zipFallbackUrl -TempZipPath $tempZip -DestinationPath $steamPath -Description "Millennium build"
        
        # Verify the DLL(s) were actually replaced
        $verificationFailed = $false
        $verifiedDlls = @()
        
        if ($hasMillennium) {
            $newMillenniumDll = Get-ChildItem -Path $steamPath -Filter "millennium.dll" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($newMillenniumDll -and (Test-Path $newMillenniumDll.FullName)) {
                Write-Host "  [SUCCESS] millennium.dll verified after extraction" -ForegroundColor Green
                Write-Host "    Location: $($newMillenniumDll.FullName)" -ForegroundColor Gray
                $verifiedDlls += "millennium.dll"
            } else {
                Write-Host "  [WARNING] millennium.dll was not found after extraction" -ForegroundColor Yellow
                $verificationFailed = $true
            }
        }
        
        if ($hasUser32) {
            $newUser32Dll = Get-ChildItem -Path $steamPath -Filter "user32.dll" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($newUser32Dll -and (Test-Path $newUser32Dll.FullName)) {
                Write-Host "  [SUCCESS] user32.dll verified after extraction" -ForegroundColor Green
                Write-Host "    Location: $($newUser32Dll.FullName)" -ForegroundColor Gray
                $verifiedDlls += "user32.dll"
            } else {
                Write-Host "  [WARNING] user32.dll was not found after extraction" -ForegroundColor Yellow
                $verificationFailed = $true
            }
        }
        
        if ($verificationFailed) {
            $missingDlls = @()
            if ($hasMillennium -and "millennium.dll" -notin $verifiedDlls) {
                $missingDlls += "millennium.dll"
            }
            if ($hasUser32 -and "user32.dll" -notin $verifiedDlls) {
                $missingDlls += "user32.dll"
            }
            $errorMsg = "The following DLL(s) were not found after extraction: $($missingDlls -join ', '). The replacement may have failed."
            Stop-OnError -ErrorMessage "Millennium DLL verification failed" -ErrorDetails $errorMsg -StepName "Step 3"
        }
        Write-Host ""
    } catch {
        # Clean up temp file on error
        if (Test-Path $tempZip) {
            Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue
        }
        $errorMsg = $_.Exception.Message
        if (-not $errorMsg) {
            $errorMsg = $_.ToString()
        }
        Stop-OnError -ErrorMessage "Failed to download or extract Millennium build" -ErrorDetails $errorMsg -StepName "Step 3"
    }
} else {
    Write-Host "  [INFO] Neither millennium.dll nor user32.dll found, skipping download and extraction" -ForegroundColor Cyan
    Write-Host ""
}

# Step 4: Create steam.cfg file
Write-Host "Step 4: Creating steam.cfg file..." -ForegroundColor Yellow
$steamCfgPath = Join-Path $steamPath "steam.cfg"

# Create config file using echo commands as specified
$cfgContent = "BootStrapperInhibitAll=enable`nBootStrapperForceSelfUpdate=disable"
Set-Content -Path $steamCfgPath -Value $cfgContent -Force
Write-Host "  [SUCCESS] steam.cfg created!" -ForegroundColor Green
Write-Host "  Location: $steamCfgPath" -ForegroundColor White
Write-Host ""

# Step 5: Launch Steam
Write-Host "Step 5: Launching Steam..." -ForegroundColor Yellow
$arguments = @("-clearbeta")
Write-Host "  Executable: $steamExePath" -ForegroundColor Gray
Write-Host "  Arguments: $($arguments -join ' ')" -ForegroundColor Gray
Write-Host ""

try {
    $process = Start-Process -FilePath $steamExePath -ArgumentList $arguments -PassThru -WindowStyle Normal
    
    Write-Host "  [SUCCESS] Steam launched successfully!" -ForegroundColor Green
    Write-Host "  Process ID: $($process.Id)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Steam is now running with the config file." -ForegroundColor White
    Write-Host ""
    
} catch {
    $errorMsg = $_.Exception.Message
    if (-not $errorMsg) {
        $errorMsg = $_.ToString()
    }
    Stop-OnError -ErrorMessage "Failed to launch Steam" -ErrorDetails $errorMsg -StepName "Step 5"
}

# ASCII Art
Write-Host ""
Write-Host '                 _...Q._' -ForegroundColor Cyan
Write-Host '               .''       ''.' -ForegroundColor Cyan
Write-Host '              /           \' -ForegroundColor Cyan
Write-Host '             ;.-""--.._ |' -ForegroundColor Cyan
Write-Host '            /''-._____..-''\|' -ForegroundColor Cyan
Write-Host '          .'' ;  o   o    |`;' -ForegroundColor Cyan
Write-Host '         /  /|   ()      ;  \' -ForegroundColor Cyan
Write-Host '    _.-, ''-'' ; ''.__.-''    \  \' -ForegroundColor Cyan
Write-Host '.-"`,  |      \_         / `''`' -ForegroundColor Cyan
Write-Host ' ''._`.; ._    / `''--.,_=-;_' -ForegroundColor Cyan
Write-Host '    \ \|  `\ .\_     /`  \ `._' -ForegroundColor Cyan
Write-Host '     \ \    `/  ``---|    \   (~' -ForegroundColor Cyan
Write-Host '      \ \.  | o   ,   \    (~ (~  ______________' -ForegroundColor Cyan
Write-Host '       \ \`_\ _..-''    \  (\(~   |.------------.|' -ForegroundColor Cyan
Write-Host '        \/  ``        / \(~/     || ALL DONE!! ||' -ForegroundColor Cyan
Write-Host '         \__    __..-'' -   ''.    || """"  """" ||' -ForegroundColor Cyan
Write-Host '          \ \```             \   || discord.gg ||' -ForegroundColor Cyan
Write-Host '          ;\ \o               ;  || /luatools  ||' -ForegroundColor Cyan
Write-Host '          | \ \               |  ||____________||' -ForegroundColor Cyan
Write-Host '          ;  \ \              ;  ''------..------''' -ForegroundColor Cyan
Write-Host '           \  \ \ _.-''\      /          ||' -ForegroundColor Cyan
Write-Host '            ''. \-''     \   .''           ||' -ForegroundColor Cyan
Write-Host '           _.-"  ''      \-''           .-||-.' -ForegroundColor Cyan
Write-Host '           \ ''  '' ''      \           ''..---.- ''' -ForegroundColor Cyan
Write-Host '            \  '' ''      _.'' ' -ForegroundColor Cyan
Write-Host '             \'' ''   _.-''' -ForegroundColor Cyan
Write-Host '              \ _.-''' -ForegroundColor Cyan
Write-Host '               `' -ForegroundColor Cyan
Write-Host ""
