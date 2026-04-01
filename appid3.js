/**
 * LUA Manifest Download/Generate
 * Enter the game's AppID. If a .zip archive containing a README exists, it will be prioritized; otherwise, the raw .lua manifest file is served.
 * Note: Generated links are temporary and expire within minutes.
 * 
 * @author mPhpMaster
 * @link https://github.com/mPhpMaster/steam-lua-manifestor
 */
let H = 'https://generator.ryuu.lol';
if (location.host === 'kernelos.org') {
    let I = prompt("Enter Steam App ID or URL:");
    let appId = String(I).trim().match(/(?:store\.steampowered\.com\/app\/|\/app\/)?(\d+)/)?.[1];
    if (I && appId) {
        window.location.href = `${H}/secure_download?appid=${appId}&auth_code=RYUUMANIFESTfvrlu0`;
    }
} else {
    location.href = H;
}
