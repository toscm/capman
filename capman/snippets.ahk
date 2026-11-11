; Snippets: a few strings kept in memory, pasted with CapsLock + F1 ... F12.
;
;   CapsLock + F1          paste snippet F1
;   CapsLock + Shift + F1  save the clipboard's text as snippet F1
;   CapsLock + Ctrl + F1   type snippet F1 into a masked input box (empty clears it)
;
; Snippets live only in this process's memory, never on disk, so they may
; hold sensitive strings. They are lost when Capman exits or reloads.
;
; Pasting goes through the clipboard (instant, and not mangled by editor
; auto-indent or auto-closing brackets like typing would be). The previous
; clipboard is restored afterwards, and both clipboard writes are flagged so
; they don't show up in the Win+V clipboard history.

Snippets := Map()

Snippet(Hotkey) {
    slot := RegExReplace(Hotkey, ".*&\s*") ; "CapsLock & F1" -> "F1"
    if GetKeyState("Ctrl") {
        EnterSnippet(slot)
    } else if GetKeyState("Shift") {
        SaveSnippet(slot, A_Clipboard)
    } else {
        PasteSnippet(slot)
    }
}

PasteSnippet(slot) {
    text := Snippets.Get(slot, "")
    if (text = "") {
        SnippetTip("Snippet " slot " is empty. CapsLock+Shift+" slot " saves the clipboard there.")
        return
    }
    saved := ClipboardAll()
    SetClipboardNoHistory([[13, TextToUtf16Buffer(text)]]) ; 13 = CF_UNICODETEXT
    SendInput("^v")
    Sleep(300) ; the target app reads the clipboard asynchronously
    SetClipboardNoHistory(ClipboardAllToFormats(saved))
}

SaveSnippet(slot, text) {
    if (text = "") {
        SnippetTip("The clipboard contains no text.")
        return
    }
    Snippets[slot] := text
    SnippetTip("Saved snippet " slot " (" StrLen(text) " characters).")
}

EnterSnippet(slot) {
    result := InputBox("Text for snippet " slot " (kept in memory only; leave empty to clear it):", "Capman snippet " slot, "Password w420 h110")
    if (result.Result != "OK") {
        return
    }
    if (result.Value = "") {
        if Snippets.Has(slot) {
            Snippets.Delete(slot)
        }
        SnippetTip("Cleared snippet " slot ".")
    } else {
        SaveSnippet(slot, result.Value)
    }
}

SnippetTip(message) {
    ToolTip(message)
    SetTimer(() => ToolTip(), -2500)
}

TextToUtf16Buffer(text) {
    buf := Buffer(StrPut(text, "UTF-16") * 2)
    StrPut(text, buf, "UTF-16")
    return buf
}

; Splits a ClipboardAll() object into [[format, Buffer], ...].
; Its layout is a sequence of (UInt format, UInt size, data), ended by format 0.
ClipboardAllToFormats(clip) {
    ; GDI handle formats can't be restored from raw bytes; Windows synthesizes
    ; CF_BITMAP etc. from CF_DIB, which is restored.
    skip := Map(2, 1, 3, 1, 9, 1, 14, 1, 0x80, 1, 0x82, 1, 0x83, 1, 0x8E, 1)
    formats := []
    offset := 0
    while (offset + 8 <= clip.Size) {
        format := NumGet(clip, offset, "UInt")
        if (format = 0) {
            break
        }
        size := NumGet(clip, offset + 4, "UInt")
        if !skip.Has(format) {
            data := Buffer(size)
            DllCall("RtlMoveMemory", "Ptr", data, "Ptr", clip.Ptr + offset + 8, "UPtr", size)
            formats.Push([format, data])
        }
        offset += 8 + size
    }
    return formats
}

; Replaces the clipboard with the given [[format, Buffer], ...] and marks it
; as excluded from clipboard history and cloud clipboard sync.
SetClipboardNoHistory(formats) {
    opened := false
    Loop 10 {
        if (opened := DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)) {
            break
        }
        Sleep(20) ; another app holds the clipboard
    }
    if !opened {
        SnippetTip("Could not open the clipboard.")
        return false
    }
    DllCall("EmptyClipboard")
    noHistory := Buffer(4, 0) ; DWORD 0
    for name in ["ExcludeClipboardContentFromMonitorProcessing", "CanIncludeInClipboardHistory", "CanUploadToCloudClipboard"] {
        formats.Push([DllCall("RegisterClipboardFormat", "Str", name, "UInt"), noHistory])
    }
    for item in formats {
        size := Max(item[2].Size, 1)
        hMem := DllCall("GlobalAlloc", "UInt", 0x42, "UPtr", size, "Ptr") ; GMEM_MOVEABLE | GMEM_ZEROINIT
        ptr := DllCall("GlobalLock", "Ptr", hMem, "Ptr")
        DllCall("RtlMoveMemory", "Ptr", ptr, "Ptr", item[2], "UPtr", item[2].Size)
        DllCall("GlobalUnlock", "Ptr", hMem)
        if !DllCall("SetClipboardData", "UInt", item[1], "Ptr", hMem, "Ptr") {
            DllCall("GlobalFree", "Ptr", hMem)
        }
    }
    DllCall("CloseClipboard")
    return true
}
