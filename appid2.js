/**
 * LUA Manifest Download/Generate
 * Enter the game's AppID. If a .zip archive containing a README exists, it will be prioritized; otherwise, the raw .lua manifest file is served.
 * Note: Generated links are temporary and expire within minutes.
 * 
 * @author mPhpMaster
 * @link https://github.com/mPhpMaster/steam-lua-manifestor
 */
let HOST_BASE = 'https://generator.ryuu.lol';
let DOWNLOAD_GEN_URL = HOST_BASE + '/secure_download?appid={appid}&auth_code=RYUUMANIFESTfvrlu0';

async function requestSignedLink(appid) {
    let url = DOWNLOAD_GEN_URL.replace('{appid}', String(appid));
    return { success: true, url: url };
}

// Get user input
let userInput = prompt("Enter Steam App ID or URL:");

if (userInput) {
    // Extract app ID
    let appId = userInput.trim();

    // Extract from URL if needed
    let match = userInput.match(/(?:store\.steampowered\.com\/app\/|\/app\/)(\d+)/);
    if (match && match[1]) {
        appId = match[1];
    }

    // Check if it's a valid number
    if (/^\d+$/.test(appId)) {
        let result = await requestSignedLink(appId);

        if (result.success && result.url) {
            window.location.href = result.url;
        } else {
            alert(`Error: ${result.error || 'Failed to get download link'}`);
        }
    } else {
        alert("Invalid input. Please enter a valid App ID or Steam URL.");
    }
}