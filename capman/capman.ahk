#SingleInstance Force

#Requires AutoHotkey >=2.0

; Provided commands
#include keyboard.ahk
#include mouse.ahk
#include commands.ahk

; Default config and default key mappings
#include config.ahk
#include keymaps.ahk

; User config
; #include %A_AppData%/capman/config.ahk

; App state
LastMode := "Insert"
WinMode := "" ; set to "#" after {Win down}, cleared after {Win up}
CtrlMode := "" ; set to "^" after {Ctrl down}, cleared after {Ctrl up}
ShiftMode := "" ; set to "+" after {Shift down}, cleared after {Shift up}
AltMode := "" ; set to "!" after {Alt down}, cleared after {Alt up}
Tmp := InfoBarInit("Capman v" Version)
InfoBar := Tmp.InfoBar
InfoBarText := Tmp.InfoBarText
InfoBarIsVisible := false
Tmp := ModeBarInit(Mode)
ModeBar := Tmp.ModeBar
ModeBarText := Tmp.ModeBarText

; Main
SetCapsLockState("AlwaysOff")
EnableKeyMap(Keymaps["Caps"])
SwitchToMode(Mode)
UpdateModeBar()
