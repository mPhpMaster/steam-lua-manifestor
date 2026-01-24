/**
 * LUA Manifest Download/Generate
 * Enter the game's AppID. If a .zip archive containing a README exists, it will be prioritized; otherwise, the raw .lua manifest file is served.
 * Note: Generated links are temporary and expire within minutes.
 * 
 * @author mPhpMaster
 * @link https://github.com/mPhpMaster/steam-lua-manifestor
 */
let H = 'https://kernelos.org';
if (location.host === 'kernelos.org') {
    let I = prompt("Enter Steam App ID or URL:");
    let appId = String(I).trim().match(/(?:store\.steampowered\.com\/app\/|\/app\/)?(\d+)/)?.[1];
    if (I && appId) {
        fetch(`${H}/games/download.php?gen=1&id=${appId}`)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Error: Failed to get download link');
                }
                return response.json();
            })
            .then(data => {
                if (data.url) {
                    window.location.href = data.url.startsWith('/') ? H + data.url : data.url;
                }
            })
            .catch(error => {
                alert(error.message);
            });
    }
} else {
    location.href = H;
}
