@echo off
rem (Re)starts the hotkey script (what each key does) and the serial bridge (Uno -> hotkeys).
call "%~dp0stop_keypad.cmd"
start "" "%~dp0tools\autohotkey\AutoHotkey64.exe" "%~dp0keypad.ahk"
start "" "%LOCALAPPDATA%\Microsoft\WindowsApps\pythonw3.11.exe" "%~dp0bridge.py"
