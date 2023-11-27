#include lib.ahk

GoToLineStart(hotkey) {
    Send "{Home}"
}

GoToLineEnd(hotkey) {
    Send "{Home}"
}

GoToFileStart(hotkey) {
    Send "^{Home}"
}

GoToFileEnd(hotkey) {
    Send "^{Home}"
}

GoToAnything(Hotkey) {
    Hook := InputHook("L1 M")
    Hook.Start()
    Hook.Wait()
    if (Hook.Input = "d") { ; GoToDefinition
        SendInput("{F12}")
    } else if (Hook.Input == "s") { ; GoToSymbolInEditor
        SendInput("^+{o}")
    } else if (Hook.Input == "S") { ; GoToSymbolInWorkspace
        SendInput("^t")
    }
}
