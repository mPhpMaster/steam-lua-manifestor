/**
 * LUA Manifest Download/Generate
 * Enter the game's AppID. If a .zip archive containing a README exists, it will be prioritized; otherwise, the raw .lua manifest file is served.
 * Note: Generated links are temporary and expire within minutes.
 * 
 * @author mPhpMaster
 * @link https://github.com/mPhpMaster/steam-lua-manifestor
 */


const HOST_BASE = 'https://kernelos.org';
const DOWNLOAD_GEN_URL = HOST_BASE + '/games/download.php?gen=1&id={appid}';

/**
 * Requests a signed download link for the given appid.
 * @param {number|string} appid 
 * @returns {Promise<{success: boolean, url?: string, expires_at?: any, error?: string}>}
 */
async function requestSignedLink(appid) {
    try {
        // Construct the URL by replacing the placeholder
        const url = DOWNLOAD_GEN_URL.replace('{appid}', String(appid));

        // Perform the request
        const response = await fetch(url);

        // Check for HTTP errors (equivalent to checking success in the python client wrapper)
        if (!response.ok) {
            return { success: false, error: 'request failed' };
        }

        // Get the response body as text first to handle potential parsing errors gracefully
        const textData = await response.text();
        let data;

        try {
            data = JSON.parse(textData);
        } catch (e) {
            return { success: false, error: 'Invalid JSON from generator' };
        }

        // Validate the response structure
        if (!data || typeof data !== 'object' || !('url' in data)) {
            return { success: false, error: 'Malformed response (no url)' };
        }

        let dl = data.url;

        // Handle relative URLs by prepending the host base
        if (typeof dl === 'string' && dl.startsWith('/')) {
            dl = HOST_BASE + dl;
        }

        return {
            success: true,
            url: dl,
            expires_at: data.expires_at
        };

    } catch (e) {
        console.error(`APIManager: requestSignedLink error for ${appid}:`, e);
        return { success: false, error: String(e) };
    }
}
