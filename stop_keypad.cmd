@echo off
rem Stops the hotkey script and the bridge (run this before uploading a new sketch: the bridge holds the COM port).
powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'bridge\.p[y]|keypad\.ah[k]' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"
