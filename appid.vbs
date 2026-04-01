' LUA Manifest Download/Generate
' Enter the game's AppID. If a .zip archive containing a README exists, it will be prioritized; otherwise, the raw .lua manifest file is served.
' Note: Generated links are temporary and expire within minutes.
'
' Author: mPhpMaster
' Repo: https://github.com/mPhpMaster/steam-lua-manifestor


Dim host, input, re, matches, appId, http, json, url, shell
host = "https://generator.ryuu.lol"

input = InputBox("Enter Steam App ID or URL:")

Set re = New RegExp
re.Pattern = "(\d+)"
re.Global = False

If re.Test(input) Then
  Set matches = re.Execute(input)
  appId = matches(0).SubMatches(0)
Else
  MsgBox "Invalid Steam App ID or URL", 16
  WScript.Quit
End If

url = host & "/secure_download?appid=" & appId & "&auth_code=RYUUMANIFESTfvrlu0"

Set shell = CreateObject("WScript.Shell")
shell.Run url
