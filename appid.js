/**
 * LUA Manifest Download/Generate
 * Enter the game's AppID. If a .zip archive containing a README exists, it will be prioritized; otherwise, the raw .lua manifest file is served.
 * Note: Generated links are temporary and expire within minutes.
 * 
 * @author mPhpMaster
 * @link https://github.com/mPhpMaster/steam-lua-manifestor
 */


const HOST_BASE = 'https://generator.ryuu.lol';
const DOWNLOAD_GEN_URL = HOST_BASE + '/secure_download?appid={appid}&auth_code=RYUUMANIFESTfvrlu0';

/**
 * Requests a signed download link for the given appid.
 * @param {number|string} appid 
 * @returns {Promise<{success: boolean, url?: string, expires_at?: any, error?: string}>}
 */
async function requestSignedLink(appid) {
    const url = DOWNLOAD_GEN_URL.replace('{appid}', String(appid));

    return {
        success: true,
        url: url
    };
}
