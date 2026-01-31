# LUA Manifest Downloader

![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-blue)
![Status](https://img.shields.io/badge/status-stable-brightgreen)

A lightweight tool to **download existing Lua manifest files** for Steam applications using an **AppID**.

The tool **does not generate files**.  
It fetches already-available manifest files from a remote source.

If a `.zip` archive exists, it is downloaded first.  
Otherwise, the raw `.lua` file is downloaded directly.

> ⚠️ Download links are **temporary** and expire within minutes.

![How to use the tool](how_to.gif)

---

## 📦 Downloaded File Format

### `ID.zip`

Contains:

- `ID.lua`
- `README.txt`

### `ID.lua`

- Downloaded directly when a ZIP archive is not available.

---

## 🚀 Using This Tool (with SteamTools)

**SteamTools** is a third-party Steam client that supports:

- Cloud saves
- Achievements
- Remote Play
- Multiplayer
- Steam Workshop access

### Steps

1. Install **SteamTools** from its [official website](https://steamtools.net/download).
2. Find a game on [**SteamDB**](https://steamdb.info/) or [**Steam**](https://store.steampowered.com/) and copy its **AppID** or **The store page URL**.
3. Paste the AppID/URL into this tool.
4. Download the provided file.
5. If a ZIP was downloaded, extract it.
6. Drag the `.lua` file onto the **SteamTools floating window**.
7. Restart Steam.

---

## 🛠 How to Run the Tool

### Windows

> You can run any of the following scripts:

- `appid.bat`
- `appid.ps1` (PowerShell)
- `appid.vbs`

### Linux / macOS

- `appid.sh`

### Alternative Runtimes

**Node.js**

- `appid.js`

**Python**

- `appid.py`

### Python Setup

```bash
pip install -r requirements.txt
python appid.py
```

---

## 🧩 Troubleshooting

### File Downloads but Nothing Happens

- Make sure the file finishes downloading completely
- Extract the ZIP if applicable
- Only drag the **`.lua` file** into SteamTools
- Restart Steam after adding the manifest

### Download Errors

- Change Steam download region
  `Settings → Downloads → Download Region`
- Retry after a few minutes
- Ensure:

  - Enough free disk space
  - Write permissions for the Steam library folder

---

## 🔗 Additional Tools

- **DLC Unlocker**: [Download](https://drive.google.com/file/d/1purTft-YuowEvqhLfpi9n9tH-jBU3NEo/view?usp=sharing)
> password: `mPhpMaster`

---

## ❤️ Support

If this tool helped you:

[Donate via PayPal](https://www.paypal.com/paypalme/mfsafadi)

---

## ⚖️ Disclaimer

This project **only downloads existing files** and does not modify or generate Steam content.

Use responsibly and ensure compliance with all platform terms and local laws.

---

## 📄 License

Licensed under the **MIT License**.
See the [LICENSE](LICENSE) file for details.
