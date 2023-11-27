#SingleInstance Force

#Requires AutoHotkey >=2.0

#include lib.ahk

; Config
Version := "0.0.3"
Mode := "Insert"
WinMode := "" ; will be set to to "#" if we send {Win down} without release
CtrlMode := "" ; will be set to to "^" if we send {Ctrl down} without release
ShiftMode := "" ; will be set to to "+" if we send {Shift down} without release
AltMode := "" ; will be set to to "!" if we send {Alt down} without release
Tmp := ModeBarInit(Mode)
ModeBar := Tmp.ModeBar
ModeBarText := Tmp.ModeBarText
Tmp := InfoBarInit("Capman v" Version)
InfoBar := Tmp.InfoBar
InfoBarText := Tmp.InfoBarText

; Main
SetCapsLockState("AlwaysOff")

; DisableWinL() ; 1)
; OnExit(ExitFunc)
EnableKeyMap(Keymaps["Caps"])
EnableKeyMap(Keymaps["Insert"])
; 1) Disable System Hotkey and instead call DLL ourselves. This is needed so we can use win-l for moving windows to the right in window-mode. System key will be re-enabled on exit.
