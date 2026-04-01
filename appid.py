
"""
LUA Manifest Download/Generate
Enter the game's AppID. If a .zip archive containing a README exists, it will be prioritized; otherwise, the raw .lua manifest file is served.
Note: Generated links are temporary and expire within minutes.

Author: mPhpMaster
Repo: https://github.com/mPhpMaster/steam-lua-manifestor
"""

# pip install requests
import re
import webbrowser

HOST = "https://generator.ryuu.lol"

inp = input("Enter Steam App ID or URL: ").strip()

match = re.search(r'(\d+)', inp)
if not match:
    print("Error: Invalid Steam App ID or URL")
    exit(1)

app_id = match.group(1)

url = f"{HOST}/secure_download?appid={app_id}&auth_code=RYUUMANIFESTfvrlu0"

webbrowser.open(url)
