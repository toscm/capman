#include lib.ahk

DoNothing(Hotkey) {
    ; Do nothing
}

Backspace(Hotkey) {
    SendInput("{BackSpace}")
}

Delete(Hotkey) {
    SendInput("{Delete}")
}

Cut(Hotkey) {
    SendInput("^{x}")
}

Copy(Hotkey) {
    SendInput("^{c}")
}

Paste(Hotkey) {
    SendInput("^{v}")
}

Undo(Hotkey) {
    SendInput("^{z}")
}

Redo(Hotkey) {
    SendInput("^{y}")
}

InsertNewLine(Hotkey) {
    SendInput("{End}")
    SendInput("{Enter}")
    SwitchToModeInsert("")
}

PipeSelectionThroughCommand() {
    ; Copy current selection
    ClipSaved := Clipboard
    Clipboard := ""
    SendInput("^c")
    Selection := Clipboard
    ClipWait()

    ; Pipe selection through `command` and into clipboard
    Command := InputBox("Run:")
    Clipboard := ""
    MsgBox(A_ComSpec "/c echo " Selection " | " Command " | clip")
    RunWait(A_ComSpec "/c echo " Selection " | " Command " | clip")
    ClipWait()

    ; Paste current clipboard content and restore old content
    SendInput("^v")
    Clipboard := ClipSaved ; Restore clipboard
    ClipSaved := "" ; Free memory
}

GoogleSelection() {
    oldClipboard := ClipboardAll
    Clipboard := "" ; Clear the clipboard
    SendInput("^c")
    if ClipWait(1)
    {
        Run("http://www.google.com/search?q=" . Clipboard)
    } else {
        MsgBox("Command 'GoogleSelection()' failed. Reason: no text selected.")
    }
    Clipboard := oldClipboard
    return
}

OpenSelectionInDefaultApp() {
    clipboardOld := ClipboardAll
    Clipboard := ""
    SendInput("^c")
    ClipWait(0.5)
    if (Clipboard != "") {
        try {
            Run(Clipboard)
        } catch {
            MsgBox("Error running: " Clipboard)
        }
    }
    Clipboard := clipboardOld
    return
}
