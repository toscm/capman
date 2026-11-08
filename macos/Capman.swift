// Capman for macOS: CapsLock as a Vim-style modifier key, modes, Windows-like window snapping,
// and display switching (Displays.swift).
//
// How it works: at startup hidutil maps the CapsLock key to F18, which has no other use.
// A keyboard event tap then sees F18 going down and up, and rewrites the keys pressed meanwhile.
// The bindings live in one table in `buildBindings` below; README.md documents them.
import AppKit
import Carbon.HIToolbox
import IOKit
import IOKit.hid

let capmanVersion = "0.5.4"
let helpURL = "https://github.com/toscm/capman#readme"
let configURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".config/capman/capman.conf")

let shift = CGEventFlags.maskShift, ctrl = CGEventFlags.maskControl
let opt = CGEventFlags.maskAlternate, cmd = CGEventFlags.maskCommand
let modifierMask: CGEventFlags = [shift, ctrl, opt, cmd]

// MARK: - Bindings

enum Mode: String {
    case insert = "INSERT", normal = "NORMAL", visual = "VISUAL", window = "WINDOW"
}

enum Direction { case left, right, up, down }

enum Action {
    case key(Int, CGEventFlags)
    case text(String)
    case mode(Mode)
    case toggleWindowMode
    case toggleCapsLock
    case open(String)
    case snap(Direction)
    case toggleMaximize
    case minimize
    case displayPicker
    case enableAllDisplays
}

/// A binding runs its actions in order. With `pass`, modifiers the user holds in addition
/// (Shift, Option, Control) are added to the keys it sends, so e.g. CapsLock+Shift+h selects.
struct Binding {
    var actions: [Action]
    var pass: Bool
}

struct Trigger: Hashable {
    let key: Int
    let mods: UInt64
}

enum Layer: Hashable {
    case caps            // while CapsLock is held
    case mode(Mode)      // in Control, Visual or Window Mode
    case global          // always
}

var bindings: [Layer: [Trigger: Binding]] = [:]

func bind(_ layers: [Layer], _ key: Int, _ mods: CGEventFlags, pass: Bool = false, _ actions: Action...) {
    for l in layers { bindings[l, default: [:]][Trigger(key: key, mods: mods.rawValue)] = Binding(actions: actions, pass: pass) }
}

func bind(_ layers: [Layer], _ key: Int, pass: Bool = false, _ actions: Action...) {
    for l in layers { bindings[l, default: [:]][Trigger(key: key, mods: 0)] = Binding(actions: actions, pass: pass) }
}

func key(_ k: Int, _ f: CGEventFlags = []) -> Action { .key(k, f) }

let left = kVK_LeftArrow, right = kVK_RightArrow, up = kVK_UpArrow, down = kVK_DownArrow

func buildBindings(umlauts: Bool) {
    bindings = [:]
    let caps = Layer.caps, normal = Layer.mode(.normal), visual = Layer.mode(.visual), window = Layer.mode(.window)
    let global = Layer.global

    // Movement. Visual Mode sends the same keys with Shift, which extends the selection.
    let moves: [(Int, Int, CGEventFlags)] = [
        (kVK_ANSI_H, left, []), (kVK_ANSI_J, down, []), (kVK_ANSI_K, up, []), (kVK_ANSI_L, right, []),
        (left, left, []), (down, down, []), (up, up, []), (right, right, []),
        (kVK_ANSI_W, right, opt), (kVK_ANSI_E, right, opt), (kVK_ANSI_B, left, opt),
        (kVK_ANSI_0, left, cmd),
    ]
    for (from, to, f) in moves {
        bind([caps, normal], from, pass: true, key(to, f))
        bind([visual], from, pass: true, key(to, f.union(shift)))
    }
    bind([caps], kVK_ANSI_I, pass: true, key(left, cmd))
    bind([caps], kVK_ANSI_O, pass: true, key(right, cmd))
    bind([caps], kVK_ANSI_4, pass: true, key(right, cmd))
    bind([normal], kVK_ANSI_4, shift, key(right, cmd))                        // $
    bind([visual], kVK_ANSI_4, shift, key(right, [cmd, shift]))
    bind([caps, normal], kVK_ANSI_G, key(up, cmd))                            // top of file
    bind([caps, normal], kVK_ANSI_G, shift, key(down, cmd))                   // bottom of file
    bind([visual], kVK_ANSI_G, key(up, [cmd, shift]))
    bind([visual], kVK_ANSI_G, shift, key(down, [cmd, shift]))
    bind([caps, normal, visual], kVK_ANSI_T, key(up, cmd))
    bind([caps, normal], kVK_ANSI_LeftBracket, pass: true, key(kVK_PageUp))
    bind([caps, normal], kVK_ANSI_RightBracket, pass: true, key(kVK_PageDown))
    bind([caps, normal, visual], kVK_ANSI_Comma, key(left, [opt, cmd]))       // previous tab
    bind([caps, normal, visual], kVK_ANSI_Period, key(right, [opt, cmd]))     // next tab

    // Editing. In Visual Mode, editing a selection returns to Control Mode.
    bind([caps, normal], kVK_ANSI_D, key(kVK_ForwardDelete))
    bind([caps, normal], kVK_ANSI_S, key(kVK_Delete))
    bind([caps, normal], kVK_ANSI_X, key(kVK_ANSI_X, cmd))
    bind([caps, normal], kVK_ANSI_Y, key(kVK_ANSI_C, cmd))
    bind([caps, normal], kVK_ANSI_P, key(kVK_ANSI_V, cmd))
    bind([visual], kVK_ANSI_D, key(kVK_ForwardDelete), .mode(.normal))
    bind([visual], kVK_ANSI_S, key(kVK_Delete), .mode(.normal))
    bind([visual], kVK_ANSI_X, key(kVK_ANSI_X, cmd), .mode(.normal))
    bind([visual], kVK_ANSI_Y, key(kVK_ANSI_C, cmd), .mode(.normal))
    bind([visual], kVK_ANSI_P, key(kVK_ANSI_V, cmd), .mode(.normal))
    bind([normal], kVK_ANSI_D, shift, key(left, cmd), key(down, shift), key(kVK_ANSI_X, cmd))           // cut line
    bind([normal], kVK_ANSI_Y, shift, key(left, cmd), key(down, shift), key(kVK_ANSI_C, cmd), key(up))  // copy line
    bind([caps, normal, visual], kVK_ANSI_U, key(kVK_ANSI_Z, cmd))
    bind([caps, normal, visual], kVK_ANSI_R, key(kVK_ANSI_Z, [cmd, shift]))

    // Back to Insert Mode.
    bind([normal, visual, window], kVK_ANSI_I, .mode(.insert))
    bind([normal, visual, window], kVK_ANSI_A, .mode(.insert))
    bind([normal], kVK_ANSI_I, shift, key(left, cmd), .mode(.insert))
    bind([normal], kVK_ANSI_A, shift, key(right, cmd), .mode(.insert))
    bind([normal], kVK_ANSI_O, key(right, cmd), key(kVK_Return), .mode(.insert))
    bind([normal], kVK_ANSI_O, shift, key(left, cmd), key(kVK_Return), key(up), .mode(.insert))
    bind([normal], kVK_ANSI_I, cmd, .mode(.insert), key(kVK_ANSI_I, cmd))

    // Modes and misc.
    bind([caps], kVK_ANSI_N, pass: true, .mode(.normal))
    bind([caps, normal], kVK_ANSI_V, .mode(.visual))
    bind([visual], kVK_ANSI_V, .mode(.normal))
    bind([caps], kVK_Space, .toggleWindowMode)
    bind([caps, normal, visual], kVK_ANSI_Q, key(kVK_Escape))
    bind([caps, normal], kVK_ANSI_C, .toggleCapsLock)
    bind([caps, normal], kVK_ANSI_Slash, key(kVK_ANSI_F, cmd))
    bind([caps, normal], kVK_ANSI_Slash, shift, .open(helpURL))
    bind([caps, normal, visual], kVK_ANSI_Z)                                 // reserved
    bind([caps], kVK_ANSI_M, key(kVK_Tab, opt))                              // AltTab
    bind([normal], kVK_ANSI_M, .mode(.insert), key(kVK_Tab, opt))
    bind([normal, visual, window], kVK_ANSI_N, key(kVK_Tab, opt))
    bind([caps], kVK_ANSI_F, key(kVK_Space, [shift, cmd]))                   // Homerow hints
    bind([normal], kVK_ANSI_F, .mode(.insert), key(kVK_Space, [shift, cmd]))

    // Window Mode.
    for (k, d) in [(kVK_ANSI_H, Direction.left), (kVK_ANSI_J, .down), (kVK_ANSI_K, .up), (kVK_ANSI_L, .right),
                   (left, .left), (down, .down), (up, .up), (right, .right)] {
        bind([window], k, .snap(d))
    }
    bind([window], kVK_ANSI_F, .toggleMaximize)
    bind([window], kVK_ANSI_M, .minimize)
    bind([window], kVK_ANSI_W, key(kVK_ANSI_W, cmd))
    bind([window], kVK_ANSI_Q, key(kVK_ANSI_Q, cmd))
    bind([window], kVK_Space, key(kVK_Space), .mode(.insert))
    bind([window], kVK_Return, key(kVK_Return), .mode(.insert))

    // Always on: Home/End like on Windows and Linux, Cmd+Y redo, Ctrl+Option+Cmd+Arrow snapping.
    bind([global], kVK_Home, pass: true, key(left, cmd))
    bind([global], kVK_End, pass: true, key(right, cmd))
    bind([global], kVK_Home, cmd, pass: true, key(up, cmd))
    bind([global], kVK_End, cmd, pass: true, key(down, cmd))
    bind([visual], kVK_Home, key(left, [cmd, shift]))
    bind([visual], kVK_End, key(right, [cmd, shift]))
    bind([global], kVK_ANSI_Y, cmd, key(kVK_ANSI_Z, [cmd, shift]))
    for (k, d) in [(left, Direction.left), (right, .right), (up, .up), (down, .down)] {
        bind([global], k, [ctrl, opt, cmd], .snap(d))
    }
    bind([global], kVK_ANSI_P, [ctrl, opt, cmd], .displayPicker)            // like Win+P
    bind([global], kVK_ANSI_P, [ctrl, opt, cmd, shift], .enableAllDisplays) // emergency: every display on

    // Optional: Option+a/o/u/s type ä/ö/ü/ß (with Shift: Ä/Ö/Ü), independent of the keyboard layout.
    if umlauts {
        for (k, lower, upper) in [(kVK_ANSI_A, "ä", "Ä"), (kVK_ANSI_O, "ö", "Ö"), (kVK_ANSI_U, "ü", "Ü"), (kVK_ANSI_S, "ß", "ß")] {
            bind([global], k, opt, .text(lower))
            bind([global], k, [opt, shift], .text(upper))
        }
    }
}

/// Apps where the umlaut bindings are skipped, because they use Option for something else (iTerm2: Meta).
let umlautExceptions: Set<String> = ["com.googlecode.iterm2"]

// MARK: - Keyboard engine

let marker: Int64 = 0x6361_706D // "capm": marks events Capman sent itself
let letters: Set<Int> = [kVK_ANSI_A, kVK_ANSI_B, kVK_ANSI_C, kVK_ANSI_D, kVK_ANSI_E, kVK_ANSI_F, kVK_ANSI_G, kVK_ANSI_H,
                         kVK_ANSI_I, kVK_ANSI_J, kVK_ANSI_K, kVK_ANSI_L, kVK_ANSI_M, kVK_ANSI_N, kVK_ANSI_O, kVK_ANSI_P,
                         kVK_ANSI_Q, kVK_ANSI_R, kVK_ANSI_S, kVK_ANSI_T, kVK_ANSI_U, kVK_ANSI_V, kVK_ANSI_W, kVK_ANSI_X,
                         kVK_ANSI_Y, kVK_ANSI_Z]
let fnKeys: Set<Int> = [left, right, up, down, kVK_Home, kVK_End, kVK_PageUp, kVK_PageDown, kVK_ForwardDelete]

final class Engine {
    var mode = Mode.insert { didSet { if mode != oldValue { onModeChange(mode) } } }
    var onModeChange: (Mode) -> Void = { _ in }
    var umlauts = false
    private var capsDown = false
    private var capsUsed = false
    private var capsPressedAt = Date.distantPast
    private var swallowed = Set<Int>() // keys whose key-up must be dropped because we handled their key-down
    private let source = CGEventSource(stateID: .privateState)
    var tap: CFMachPort?
    var post: (CGEvent) -> Void = { $0.post(tap: .cgSessionEventTap) }

    func handle(_ type: CGEventType, _ e: CGEvent) -> CGEvent? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            return e
        }
        if e.getIntegerValueField(.eventSourceUserData) == marker { return e }
        let k = Int(e.getIntegerValueField(.keyboardEventKeycode))

        if k == kVK_F18 { // the remapped CapsLock key
            if type == .keyDown, !capsDown {
                capsDown = true
                capsUsed = false
                capsPressedAt = Date()
            } else if type == .keyUp {
                capsDown = false
                if !capsUsed && Date().timeIntervalSince(capsPressedAt) < 1 { send(kVK_Escape) }
            }
            return nil
        }
        if type == .keyUp { return swallowed.remove(k) != nil ? nil : e }
        guard type == .keyDown else { return e }
        if capsDown { capsUsed = true }

        let held = e.flags.intersection(modifierMask)
        if let (b, extra) = lookup(k, held) {
            swallowed.insert(k)
            run(b, extra: extra)
            return nil
        }
        // In the CapsLock layer and the modes, unbound letters do nothing instead of typing.
        if (capsDown || mode != .insert) && letters.contains(k) && held.isDisjoint(with: [cmd, ctrl]) {
            swallowed.insert(k)
            return nil
        }
        return e
    }

    private func lookup(_ k: Int, _ held: CGEventFlags) -> (Binding, CGEventFlags)? {
        var layers: [Layer] = capsDown ? [.caps] : mode == .insert ? [] : [.mode(mode)]
        layers.append(.global)
        for layer in layers {
            guard let table = bindings[layer] else { continue }
            if layer == .global && umlauts && held.contains(opt), let app = NSWorkspace.shared.frontmostApplication?.bundleIdentifier,
               umlautExceptions.contains(app), [kVK_ANSI_A, kVK_ANSI_O, kVK_ANSI_U, kVK_ANSI_S].contains(k) { return nil }
            if let b = table[Trigger(key: k, mods: held.rawValue)] { return (b, []) }
            let base = held.intersection(cmd)
            if let b = table[Trigger(key: k, mods: base.rawValue)], b.pass { return (b, held.subtracting(base)) }
        }
        return nil
    }

    private func run(_ b: Binding, extra: CGEventFlags) {
        for a in b.actions {
            switch a {
            case let .key(k, f): send(k, b.pass ? f.union(extra) : f)
            case let .text(s): type(s)
            case let .mode(m): mode = m
            case .toggleWindowMode: mode = mode == .window ? .insert : .window
            case .toggleCapsLock: toggleCapsLock()
            case let .open(url): DispatchQueue.main.async { NSWorkspace.shared.open(URL(string: url)!) }
            // Accessibility calls can be slow, so they run after the event tap has returned.
            case let .snap(d): DispatchQueue.main.async { Snapper.snap(d) }
            case .toggleMaximize: DispatchQueue.main.async { Snapper.toggleMaximize() }
            case .minimize: DispatchQueue.main.async { Snapper.minimize() }
            case .displayPicker: DispatchQueue.main.async { (NSApp.delegate as? App)?.displayHotKey() }
            case .enableAllDisplays: DispatchQueue.main.async { (NSApp.delegate as? App)?.enableAllDisplays() }
            }
        }
    }

    func send(_ k: Int, _ f: CGEventFlags = []) {
        var flags = f
        if fnKeys.contains(k) { flags.insert(.maskSecondaryFn) }
        if [left, right, up, down].contains(k) { flags.insert(.maskNumericPad) }
        for isDown in [true, false] {
            guard let e = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(k), keyDown: isDown) else { continue }
            e.flags = flags
            e.setIntegerValueField(.eventSourceUserData, value: marker)
            post(e)
        }
    }

    func type(_ s: String) {
        let chars = Array(s.utf16)
        for isDown in [true, false] {
            guard let e = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: isDown) else { continue }
            e.flags = []
            e.keyboardSetUnicodeString(stringLength: chars.count, unicodeString: chars)
            e.setIntegerValueField(.eventSourceUserData, value: marker)
            post(e)
        }
    }
}

func toggleCapsLock() {
    let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(kIOHIDSystemClass))
    defer { IOObjectRelease(service) }
    var connect: io_connect_t = 0
    guard IOServiceOpen(service, mach_task_self_, UInt32(kIOHIDParamConnectType), &connect) == KERN_SUCCESS else { return }
    defer { IOServiceClose(connect) }
    var on = false
    IOHIDGetModifierLockState(connect, Int32(kIOHIDCapsLockState), &on)
    IOHIDSetModifierLockState(connect, Int32(kIOHIDCapsLockState), !on)
}

/// Maps CapsLock (HID usage 0x39) to F18 (0x6D) on all keyboards, or removes the mapping again.
func remapCapsLock(_ on: Bool) {
    let mapping = on ? #"{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000006D}"# : ""
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/hidutil")
    p.arguments = ["property", "--set", #"{"UserKeyMapping":["# + mapping + "]}"]
    p.standardOutput = FileHandle.nullDevice
    try? p.run()
    p.waitUntilExit()
}

func drain(_ iterator: io_iterator_t) {
    var s = IOIteratorNext(iterator)
    while s != 0 { IOObjectRelease(s); s = IOIteratorNext(iterator) }
}

// MARK: - Window snapping

/// Windows-like snapping of the focused window (see README.md, "Window Snapping").
/// Per window it remembers the frame to restore and the corner a quarter was stretched from.
enum Snapper {
    struct Memory {
        var restore: CGRect      // frame before the first snap
        var restoreArea: CGRect  // usable area of the display the restore frame was on
        var corner: Span?        // vertical span of a quarter that Left/Right stretched to a half
        var lastSet: CGRect      // frame Capman set last; if the window differs, the user moved it
        var intended: CGRect     // frame Capman asked for; differs from lastSet if the app enforces a minimum size
    }

    static var memory: [CFHashCode: Memory] = [:]
    // The window minimized by the last snapping step, and the window that had focus right afterwards.
    // Up restores it as long as the focus has not moved on, like Win+Up after Win+Down on Windows.
    static var minimized: AXUIElement?
    static var focusAfterMinimize: AXUIElement?
    static var focusRecorded = false
    static let tol: CGFloat = 40 // apps like terminals round their size to whole characters

    enum Span { case low, high, full, free } // low = left/top half, high = right/bottom half

    static func focusedWindow() -> AXUIElement? {
        guard let pid = NSWorkspace.shared.frontmostApplication?.processIdentifier else { return nil }
        var w: CFTypeRef?
        guard AXUIElementCopyAttributeValue(AXUIElementCreateApplication(pid), kAXFocusedWindowAttribute as CFString, &w) == .success
        else { return nil }
        return (w as! AXUIElement)
    }

    static func frame(_ w: AXUIElement) -> CGRect? {
        var p: CFTypeRef?, s: CFTypeRef?
        guard AXUIElementCopyAttributeValue(w, kAXPositionAttribute as CFString, &p) == .success,
              AXUIElementCopyAttributeValue(w, kAXSizeAttribute as CFString, &s) == .success else { return nil }
        var origin = CGPoint.zero, size = CGSize.zero
        AXValueGetValue(p as! AXValue, .cgPoint, &origin)
        AXValueGetValue(s as! AXValue, .cgSize, &size)
        return CGRect(origin: origin, size: size)
    }

    static func setFrame(_ w: AXUIElement, _ r: CGRect) {
        var origin = r.origin, size = r.size
        let p = AXValueCreate(.cgPoint, &origin)!, s = AXValueCreate(.cgSize, &size)!
        // Size, position, size again: a window moving to a smaller display may otherwise not fit.
        AXUIElementSetAttributeValue(w, kAXSizeAttribute as CFString, s)
        AXUIElementSetAttributeValue(w, kAXPositionAttribute as CFString, p)
        AXUIElementSetAttributeValue(w, kAXSizeAttribute as CFString, s)
    }

    /// Usable area of every display (without menu bar and Dock), in Accessibility coordinates (origin top left).
    static func areas() -> [CGRect] {
        let h = NSScreen.screens.first?.frame.height ?? 0
        return NSScreen.screens.map { s in
            let v = s.visibleFrame
            return CGRect(x: v.minX, y: h - v.maxY, width: v.width, height: v.height)
        }
    }

    static func area(of r: CGRect) -> CGRect? {
        let all = areas()
        return all.first { $0.contains(CGPoint(x: r.midX, y: r.midY)) } ?? all.first
    }

    static func near(_ a: CGFloat, _ b: CGFloat) -> Bool { abs(a - b) < tol }

    static func near(_ a: CGRect, _ b: CGRect) -> Bool {
        near(a.minX, b.minX) && near(a.minY, b.minY) && near(a.width, b.width) && near(a.height, b.height)
    }

    static func span(_ lo: CGFloat, _ len: CGFloat, in aLo: CGFloat, _ aLen: CGFloat) -> Span {
        if near(lo, aLo) && near(len, aLen) { return .full }
        if near(lo, aLo) && near(len, aLen / 2) { return .low }
        if near(lo, aLo + aLen / 2) && near(len, aLen / 2) { return .high }
        return .free
    }

    /// Start and length of a span within an area; `.free` keeps the given values.
    static func place(_ s: Span, _ aLo: CGFloat, _ aLen: CGFloat, keep: (CGFloat, CGFloat)) -> (CGFloat, CGFloat) {
        switch s {
        case .low: return (aLo, aLen / 2)
        case .high: return (aLo + aLen / 2, aLen / 2)
        case .full: return (aLo, aLen)
        case .free: return keep
        }
    }

    static func rect(_ h: Span, _ v: Span, in a: CGRect, keeping f: CGRect) -> CGRect {
        let (x, w) = place(h, a.minX, a.width, keep: (f.minX, f.width))
        let (y, ht) = place(v, a.minY, a.height, keep: (f.minY, f.height))
        return CGRect(x: x, y: y, width: w, height: ht)
    }

    /// The restore frame, moved to the display the window is on now if it was snapped to another one.
    static func restoreFrame(_ m: Memory, in a: CGRect) -> CGRect {
        if m.restoreArea == a { return m.restore }
        let w = min(m.restore.width, a.width), h = min(m.restore.height, a.height)
        let x = a.minX + min(max(m.restore.minX - m.restoreArea.minX, 0), a.width - w)
        let y = a.minY + min(max(m.restore.minY - m.restoreArea.minY, 0), a.height - h)
        return CGRect(x: x, y: y, width: w, height: h)
    }

    enum Outcome { case frame(CGRect), restore, minimize, none }

    /// Applies one snapping step to the focused window.
    static func act(_ decide: (CGRect, CGRect, Span, Span, inout Memory) -> Outcome) {
        minimized = nil
        guard let w = focusedWindow(), let f = frame(w), let a = area(of: f) else { return }
        let id = CFHash(w)
        let fresh = Memory(restore: f, restoreArea: a, corner: nil, lastSet: f, intended: f)
        var m = memory[id] ?? fresh
        if !near(f, m.lastSet) { m = fresh } // moved by the user
        // Decide from the frame Capman asked for, not the one the window got: a window with a minimum size
        // larger than half the display (like Battle.net) would otherwise never count as a top half and get stuck.
        let g = m.intended
        let outcome = decide(g, a, span(g.minX, g.width, in: a.minX, a.width), span(g.minY, g.height, in: a.minY, a.height), &m)
        switch outcome {
        case let .frame(r):
            setFrame(w, r)
            if var got = frame(w), got.maxX > a.maxX + 1 || got.maxY > a.maxY + 1 {
                // The app kept a larger minimum size: keep the window on the display, anchored to the snapped edge.
                got.origin = CGPoint(x: max(a.minX, min(got.minX, a.maxX - got.width)), y: max(a.minY, min(got.minY, a.maxY - got.height)))
                var o = got.origin
                AXUIElementSetAttributeValue(w, kAXPositionAttribute as CFString, AXValueCreate(.cgPoint, &o)!)
            }
            m.lastSet = frame(w) ?? r
            m.intended = r
            memory[id] = m
        case .restore:
            setFrame(w, restoreFrame(m, in: a))
            memory[id] = nil
        case .minimize:
            memory[id] = m
            AXUIElementSetAttributeValue(w, kAXMinimizedAttribute as CFString, kCFBooleanTrue)
            minimized = w
            focusAfterMinimize = nil
            focusRecorded = false
            // macOS moves the focus asynchronously, so look at it a moment later.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if minimized === w { focusAfterMinimize = focusedWindow(); focusRecorded = true }
            }
        case .none:
            break
        }
    }

    /// Un-minimizes the window minimized last, if the focus is still where minimizing left it.
    static func unminimize() -> Bool {
        guard let w = minimized else { return false }
        let focus = focusedWindow()
        let unchanged = !focusRecorded || (focus == nil ? focusAfterMinimize == nil : focusAfterMinimize.map { CFEqual($0, focus) } ?? false)
        minimized = nil
        guard unchanged else { return false }
        AXUIElementSetAttributeValue(w, kAXMinimizedAttribute as CFString, kCFBooleanFalse)
        AXUIElementPerformAction(w, kAXRaiseAction as CFString)
        var pid: pid_t = 0
        if AXUIElementGetPid(w, &pid) == .success { NSRunningApplication(processIdentifier: pid)?.activate() }
        return true
    }

    static func snap(_ d: Direction) {
        if d == .up && unminimize() { return }
        act { f, a, h, v, m in
            let maximized = h == .full && v == .full
            switch d {
            case .left, .right:
                let side: Span = d == .left ? .low : .high
                if h == side && (v == .low || v == .high) {           // quarter: stretch to the half
                    m.corner = v
                    return .frame(rect(side, .full, in: a, keeping: f))
                }
                if h == side && v == .full, let corner = m.corner {   // stretched half: back to the quarter
                    m.corner = nil
                    return .frame(rect(side, corner, in: a, keeping: f))
                }
                m.corner = nil
                if h == side {                                        // half: continue on the neighbouring display
                    let others = areas().filter { d == .left ? $0.maxX <= a.minX + tol : $0.minX >= a.maxX - tol }
                    guard let n = others.min(by: { abs($0.midX - a.midX) < abs($1.midX - a.midX) }) else { return .none }
                    return .frame(rect(d == .left ? .high : .low, v == .free ? .full : v, in: n, keeping: f))
                }
                let keepV = !maximized && (v == .low || v == .high)
                return .frame(rect(side, keepV ? v : .full, in: a, keeping: f))
            case .up:
                m.corner = nil
                if maximized { return .restore }
                switch v {
                case .low: return .frame(a)                                       // top: maximize
                case .high: return .frame(rect(.free, .full, in: a, keeping: f))  // bottom: full height
                case .full, .free: return .frame(rect(.free, .low, in: a, keeping: f))
                }
            case .down:
                m.corner = nil
                if maximized { return .restore }
                switch v {
                case .high: return .minimize                                      // bottom: minimize
                case .low: return .frame(rect(.free, .full, in: a, keeping: f))   // top: full height
                case .full, .free: return .frame(rect(.free, .high, in: a, keeping: f))
                }
            }
        }
    }

    static func toggleMaximize() {
        act { _, a, h, v, m in
            m.corner = nil
            return h == .full && v == .full ? .restore : .frame(a)
        }
    }

    static func minimize() {
        act { _, _, _, _, _ in .minimize }
    }
}

// MARK: - Config

/// Reads `key = value` lines from ~/.config/capman/capman.conf (`#` starts a comment).
func loadConfig() -> [String: String] {
    guard let text = try? String(contentsOf: configURL, encoding: .utf8) else { return [:] }
    var config: [String: String] = [:]
    for line in text.split(separator: "\n") {
        let kv = (line.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false).first ?? "")
            .split(separator: "=", maxSplits: 1)
        if kv.count == 2 { config[kv[0].trimmingCharacters(in: .whitespaces)] = kv[1].trimmingCharacters(in: .whitespaces) }
    }
    return config
}

// MARK: - App

/// Small label at the bottom left of the main display (where Vim shows it) showing the current mode (hidden in Insert Mode).
/// Colours of the modes, shared by the mode indicator and the menu-bar icon (Insert Mode has none).
let modeColors: [Mode: NSColor] = [.normal: .systemBlue, .visual: .systemOrange, .window: .systemPurple]

final class ModeIndicator {
    private let panel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
    private let label = NSTextField(labelWithString: "")

    init() {
        panel.level = .statusBar
        panel.ignoresMouseEvents = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        label.font = .monospacedSystemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        let bg = NSView()
        bg.wantsLayer = true
        bg.layer?.cornerRadius = 8
        bg.addSubview(label)
        panel.contentView = bg
    }

    func show(_ mode: Mode) {
        guard mode != .insert, let screen = NSScreen.main else { panel.orderOut(nil); return }
        panel.contentView?.layer?.backgroundColor = modeColors[mode]?.withAlphaComponent(0.9).cgColor
        label.stringValue = mode.rawValue
        label.sizeToFit()
        label.setFrameOrigin(NSPoint(x: 12, y: 6))
        let size = NSSize(width: label.frame.width + 24, height: label.frame.height + 12)
        let v = screen.visibleFrame
        panel.setFrame(NSRect(x: v.minX + 12, y: v.minY + 12, width: size.width, height: size.height), display: true)
        panel.orderFrontRegardless()
    }
}

final class App: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let engine = Engine()
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let indicator = ModeIndicator()
    var permissionTimer: Timer?
    var devicePort: IONotificationPortRef?
    var deviceIterator: io_iterator_t = 0
    var sigterm: DispatchSourceSignal?
    let displays = DisplayManager()
    lazy var picker = DisplayPicker { [weak self] in self?.setDisplayMode($0) }
    var displayBusy = false
    // Keeps App Nap from throttling the display watchdog while Capman sits idle in the menu bar.
    let activity = ProcessInfo.processInfo.beginActivity(options: .userInitiatedAllowingIdleSystemSleep, reason: "display watchdog")

    func applicationDidFinishLaunching(_: Notification) {
        let menu = NSMenu()
        menu.delegate = self
        item.menu = menu
        engine.onModeChange = { [weak self] m in self?.showMode(m) }
        reloadConfig()
        showMode(.insert)

        // Displays are only ever off while Capman runs: a fresh start (login, reboot, crash) turns them all back on.
        displays.enableAll()

        // If no usable display is left (e.g. the monitor was unplugged while the built-in display was off),
        // turn all displays back on: on every display change and, as a fallback, every second.
        RunLoop.main.add(Timer(timeInterval: 1, repeats: true) { [weak self] _ in self?.displays.watchdog() }, forMode: .common)
        CGDisplayRegisterReconfigurationCallback({ _, flags, _ in
            guard !flags.contains(.beginConfigurationFlag) else { return }
            DispatchQueue.main.async { let d = (NSApp.delegate as? App)?.displays; d?.logState(); d?.displaysChanged() }
        }, nil)

        // Undo the CapsLock mapping when launchd stops us (e.g. via install.sh).
        signal(SIGTERM, SIG_IGN)
        sigterm = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)
        sigterm?.setEventHandler { NSApp.terminate(nil) }
        sigterm?.resume()

        if !startTap(prompt: true) {
            item.button?.title = "⇪ needs Accessibility"
            permissionTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] t in
                if self?.startTap(prompt: false) == true { t.invalidate() }
            }
        }
    }

    func applicationWillTerminate(_: Notification) {
        remapCapsLock(false)
        displays.enableAll()
    }

    /// Creates the keyboard event tap once Capman has the Accessibility permission.
    func startTap(prompt: Bool) -> Bool {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt] as CFDictionary
        guard AXIsProcessTrustedWithOptions(opts) else { return false }
        let mask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
        guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
                                          eventsOfInterest: CGEventMask(mask), callback: { _, type, event, _ in
            guard let e = (NSApp.delegate as? App)?.engine.handle(type, event) else { return nil }
            return Unmanaged.passUnretained(e)
        }, userInfo: nil) else { return false }
        engine.tap = tap
        CFRunLoopAddSource(CFRunLoopGetMain(), CFMachPortCreateRunLoopSource(nil, tap, 0), .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        remapCapsLock(true)
        watchKeyboards()
        showMode(engine.mode)
        return true
    }

    /// Re-applies the CapsLock mapping whenever a keyboard is connected, since hidutil only maps present devices.
    func watchKeyboards() {
        devicePort = IONotificationPortCreate(kIOMainPortDefault)
        CFRunLoopAddSource(CFRunLoopGetMain(), IONotificationPortGetRunLoopSource(devicePort).takeUnretainedValue(), .defaultMode)
        IOServiceAddMatchingNotification(devicePort, kIOFirstMatchNotification, IOServiceMatching("IOHIDEventService"), { _, iterator in
            drain(iterator)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { remapCapsLock(true) }
        }, nil, &deviceIterator)
        drain(deviceIterator) // arms the notification
    }

    /// Flips `umlauts` in the config file. Writes in place, so a symlinked config (e.g. from a dotfiles repo) stays a symlink.
    @objc func toggleUmlauts() {
        let target = configURL.resolvingSymlinksInPath()
        var lines = ((try? String(contentsOf: target, encoding: .utf8)) ?? "# Capman configuration, see \(helpURL)\n")
            .components(separatedBy: "\n")
        let line = "umlauts = \(!engine.umlauts)"
        if let i = lines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("umlauts") }) {
            lines[i] = line
        } else {
            if lines.last == "" { lines.removeLast() }
            lines += [line, ""]
        }
        try? FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? lines.joined(separator: "\n").write(to: target, atomically: false, encoding: .utf8)
        reloadConfig()
    }

    func reloadConfig() {
        engine.umlauts = loadConfig()["umlauts"] == "true"
        buildBindings(umlauts: engine.umlauts)
    }

    func showMode(_ m: Mode) {
        // The filled CapsLock symbol: plain in Insert Mode (adapts to light/dark), coloured in the other modes.
        var image = NSImage(systemSymbolName: "capslock.fill", accessibilityDescription: "Capman \(m.rawValue)")
        if let color = modeColors[m] {
            image = image?.withSymbolConfiguration(NSImage.SymbolConfiguration(paletteColors: [color]))
            image?.isTemplate = false
        } else {
            image?.isTemplate = true
        }
        item.button?.image = image
        item.button?.title = ""
        indicator.show(m)
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        menu.addItem(.sectionHeader(title: "Capman \(capmanVersion) · \(engine.mode.rawValue.capitalized) Mode"))
        let umlauts = NSMenuItem(title: "Umlauts (⌥A, ⌥O, ⌥U, ⌥S)", action: #selector(toggleUmlauts), keyEquivalent: "")
        umlauts.state = engine.umlauts ? .on : .off
        umlauts.target = self
        menu.addItem(umlauts)
        menu.addItem(withTitle: "Edit Config…", action: #selector(editConfig), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Reload Config", action: #selector(reload), keyEquivalent: "r").target = self
        menu.addItem(withTitle: "Help", action: #selector(help), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(.sectionHeader(title: "Displays"))
        for d in displays.displays() {
            let i = NSMenuItem(title: d.name, action: #selector(toggleDisplay(_:)), keyEquivalent: "")
            i.state = d.enabled ? .on : .off
            i.representedObject = d
            i.target = self
            menu.addItem(i)
        }
        menu.addItem(.sectionHeader(title: "Display Mode (⌃⌥⌘P)"))
        let current = displays.currentMode()
        for m in DisplayMode.allCases {
            let i = NSMenuItem(title: m.rawValue, action: #selector(pickDisplayMode(_:)), keyEquivalent: "")
            i.state = m == current ? .on : .off
            i.representedObject = m.rawValue
            i.target = self
            menu.addItem(i)
        }
        menu.addItem(withTitle: "Turn All Displays On (⌃⌥⇧⌘P)", action: #selector(enableAllDisplays), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Display Settings…", action: #selector(openDisplaySettings), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Capman", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }

    @objc func editConfig() {
        if !FileManager.default.fileExists(atPath: configURL.path) {
            try? FileManager.default.createDirectory(at: configURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? "# Capman configuration, see \(helpURL)\numlauts = false\n".write(to: configURL, atomically: true, encoding: .utf8)
        }
        NSWorkspace.shared.open([configURL], withApplicationAt: URL(fileURLWithPath: "/System/Applications/TextEdit.app"),
                                configuration: NSWorkspace.OpenConfiguration())
    }

    @objc func toggleDisplay(_ sender: NSMenuItem) {
        guard let d = sender.representedObject as? Display else { return }
        displays.setEnabled(d, !d.enabled)
    }

    @objc func pickDisplayMode(_ sender: NSMenuItem) {
        if let m = DisplayMode(rawValue: sender.representedObject as? String ?? "") { setDisplayMode(m) }
    }

    @objc func openDisplaySettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.Displays-Settings.extension")!)
    }

    func setDisplayMode(_ mode: DisplayMode) {
        guard !displayBusy else { return }
        displayBusy = true
        displays.apply(mode) { [weak self] in
            self?.displayBusy = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { HUD.show(mode.rawValue) }
        }
    }

    /// Ctrl+Option+Cmd+P opens the display picker with the next mode selected; further presses move the selection.
    func displayHotKey() {
        if picker.isVisible { picker.move(1) } else { picker.open(current: displays.currentMode()) }
    }

    /// Ctrl+Option+Shift+Cmd+P and the menu: turn every display on, whatever Capman thinks is off.
    @objc func enableAllDisplays() {
        displays.enableAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { HUD.show("All displays on") }
    }

    @objc func reload() { reloadConfig() }
    @objc func help() { NSWorkspace.shared.open(URL(string: helpURL)!) }
}

@main
enum CapmanMain {
    static func main() {
        // Rescue from a terminal, even if the running Capman is stuck: Capman --enable-displays
        if CommandLine.arguments.contains("--enable-displays") {
            DisplayManager.rescue()
            sleep(2) // let the displays come online before the process (and its display configuration) goes away
            exit(0)
        }
        let app = NSApplication.shared
        let delegate = App()
        app.delegate = delegate
        app.setActivationPolicy(.accessory) // menu bar only, no Dock icon
        withExtendedLifetime(delegate) { app.run() }
    }
}
