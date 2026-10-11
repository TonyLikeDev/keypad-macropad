#Requires AutoHotkey v2.0
#SingleInstance Force
; Test only: logs which Ctrl+Alt+Shift+letter hotkeys fire, instead of running actions.
logFile := A_ScriptDir "\hotkeys.log"
Loop 16
    Hotkey "^!+" Chr(96 + A_Index), (name) => FileAppend(SubStr(name, -1) "`n", logFile)
