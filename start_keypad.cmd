@echo off
rem (Re)starts the hotkey script (what each key does) and the serial bridge (Uno -> hotkeys).
call "%~dp0stop_keypad.cmd"

rem AutoHotkey v2: the portable copy in tools\autohotkey, else the normal installer's location.
set "AHK=%~dp0tools\autohotkey\AutoHotkey64.exe"
if not exist "%AHK%" set "AHK=%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe"

rem Python without a console window: the Microsoft Store one if present, else whatever pythonw is on PATH.
set "PYW=pythonw"
if exist "%LOCALAPPDATA%\Microsoft\WindowsApps\pythonw3.11.exe" set "PYW=%LOCALAPPDATA%\Microsoft\WindowsApps\pythonw3.11.exe"

start "" "%AHK%" "%~dp0keypad.ahk"
start "" "%PYW%" "%~dp0bridge.py"
