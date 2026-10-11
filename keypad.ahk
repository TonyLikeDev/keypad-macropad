#Requires AutoHotkey v2.0
#SingleInstance Force   ; run start_keypad.cmd again to reload after edits

; Each keypad key sends Ctrl+Alt+Shift+<letter>: S1=a, S2=b ... S16=p. ^ = Ctrl, ! = Alt, + = Shift.
; Rows run across, columns run down, as the keypad is held:
;   S13(m) S9(i)  S5(e) S1(a)     row 1: windows
;   S14(n) S10(j) S6(f) S2(b)     row 2: apps
;   S15(o) S11(k) S7(g) S3(c)     row 3: editing
;   S16(p) S12(l) S8(h) S4(d)     row 4: media

; The pad releases the combo a few ms after pressing it. Wait for that before
; sending anything, or the held Ctrl+Alt+Shift leaks into the keys we send.
Release() {
    KeyWait "Control"
    KeyWait "Alt"
    KeyWait "Shift"
}

Tap(keys) {
    Release()
    Send keys
}

Type(text) {
    Release()
    SendText text
}

; Row 1: windows
^!+m::DllCall("LockWorkStation")        ; S13 lock PC
^!+i::Tap "#d"                          ; S9  show desktop
^!+e::Tap "#{Tab}"                      ; S5  task view
^!+a::Run "taskmgr.exe"                 ; S1  task manager

; Row 2: apps
^!+n::Run "https://www.google.com"      ; S14 browser (default browser)
^!+j::Run "explorer.exe"                ; S10 file explorer
^!+f::Run(EnvGet("LOCALAPPDATA") "\Programs\Microsoft VS Code\Code.exe")   ; S6 VS Code
^!+b::Run "calc.exe"                    ; S2  calculator

; Row 3: editing
^!+o::Tap "^c"                          ; S15 copy
^!+k::Tap "^v"                          ; S11 paste
^!+g::Tap "^z"                          ; S7  undo
^!+c::Run(Format('powershell.exe -NoProfile -Sta -ExecutionPolicy Bypass -File "{}\screenshot.ps1"', A_ScriptDir), , "Hide")   ; S3 screenshot of the monitor under the mouse -> clipboard + Pictures\Screenshots

; Row 4: media
^!+p::Tap "{Media_Play_Pause}"          ; S16 play / pause
^!+l::Tap "{Volume_Down 3}"             ; S12 volume down
^!+h::Tap "{Volume_Up 3}"               ; S8  volume up
^!+d::Tap "{Volume_Mute}"               ; S4  mute
