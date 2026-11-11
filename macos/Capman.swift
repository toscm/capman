// Capman for macOS: CapsLock as a Vim-style modifier key, modes, Windows-like window snapping,
// a tile grid for placing windows (also by Shift-dragging them), and display switching (Displays.swift).
//
// How it works: at startup hidutil maps the CapsLock key to F18, which has no other use.
// A keyboard event tap then sees F18 going down and up, and rewrites the keys pressed meanwhile.
// The bindings live in one table in `buildBindings` below; README.md documents them.
import AppKit
import Carbon.HIToolbox
import IOKit
import IOKit.hid

let capmanVersion = "0.7.0"
let helpURL = "https://github.com/toscm/capman#readme"
let configURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".config/capman/capman.conf")

let shift = CGEventFlags.maskShift, ctrl = CGEventFlags.maskControl
let opt = CGEventFlags.maskAlternate, cmd = CGEventFlags.maskCommand
let modifierMask: CGEventFlags = [shift, ctrl, opt, cmd]

// MARK: - Bindings

enum Mode: String {
    case insert = "INSERT", normal = "NORMAL", visual = "VISUAL"
}

enum Direction { case left, right, up, down }

enum Action {
    case key(Int, CGEventFlags)
    case text(String)
    case mode(Mode)
    case toggleCapsLock
    case open(String)
    case snap(Direction)
    case move(Direction)
    case toggleMaximize
    case toggleMinimize
    case toggleHide
    case toggleFullScreen
    case gridPicker
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
    case mode(Mode)      // in Control or Visual Mode
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
    let caps = Layer.caps, normal = Layer.mode(.normal), visual = Layer.mode(.visual)
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
    bind([normal, visual], kVK_ANSI_I, .mode(.insert))
    bind([normal, visual], kVK_ANSI_A, .mode(.insert))
    bind([normal], kVK_ANSI_I, shift, key(left, cmd), .mode(.insert))
    bind([normal], kVK_ANSI_A, shift, key(right, cmd), .mode(.insert))
    bind([normal], kVK_ANSI_O, key(right, cmd), key(kVK_Return), .mode(.insert))
    bind([normal], kVK_ANSI_O, shift, key(left, cmd), key(kVK_Return), key(up), .mode(.insert))
    bind([normal], kVK_ANSI_I, cmd, .mode(.insert), key(kVK_ANSI_I, cmd))

    // Modes and misc.
    bind([caps], kVK_ANSI_N, pass: true, .mode(.normal))
    bind([caps, normal], kVK_ANSI_V, .mode(.visual))
    bind([visual], kVK_ANSI_V, .mode(.normal))
    bind([caps], kVK_Space, .gridPicker)
    bind([caps, normal, visual], kVK_ANSI_Q, key(kVK_Escape))
    bind([caps, normal], kVK_ANSI_C, .toggleCapsLock)
    bind([caps, normal], kVK_ANSI_Slash, key(kVK_ANSI_F, cmd))
    bind([caps, normal], kVK_ANSI_Slash, shift, .open(helpURL))
    bind([caps, normal, visual], kVK_ANSI_Z)                                 // reserved
    bind([caps], kVK_ANSI_M, key(kVK_Tab, opt))                              // AltTab
    bind([normal], kVK_ANSI_M, .mode(.insert), key(kVK_Tab, opt))
    bind([normal, visual], kVK_ANSI_N, key(kVK_Tab, opt))
    bind([caps], kVK_ANSI_F, key(kVK_Space, [shift, cmd]))                   // Homerow hints
    bind([normal], kVK_ANSI_F, .mode(.insert), key(kVK_Space, [shift, cmd]))

    // Always on: Home/End like on Windows and Linux, Cmd+Y redo, window management.
    bind([global], kVK_Home, pass: true, key(left, cmd))
    bind([global], kVK_End, pass: true, key(right, cmd))
    bind([global], kVK_Home, cmd, pass: true, key(up, cmd))
    bind([global], kVK_End, cmd, pass: true, key(down, cmd))
    bind([visual], kVK_Home, key(left, [cmd, shift]))
    bind([visual], kVK_End, key(right, [cmd, shift]))
    bind([global], kVK_ANSI_Y, cmd, key(kVK_ANSI_Z, [cmd, shift]))
    for (k, d) in [(left, Direction.left), (right, .right), (up, .up), (down, .down)] {
        bind([global], k, [ctrl, opt], .snap(d))
        bind([global], k, [ctrl, opt, cmd], .move(d))
    }
    bind([global], kVK_Return, [ctrl, opt], .toggleMaximize)
    bind([global], kVK_Space, [ctrl, opt, cmd], .gridPicker) // Ctrl+Option+Space switches the input source
    // Ctrl+Option+letter is taken in some editors (e.g. Ctrl+Option+H in JetBrains IDEs), so these add Cmd.
    bind([global], kVK_ANSI_M, [ctrl, opt, cmd], .toggleMinimize)
    bind([global], kVK_ANSI_H, [ctrl, opt, cmd], .toggleHide)
    bind([global], kVK_ANSI_F, [ctrl, opt, cmd], .toggleFullScreen)
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
    /// While set (the grid picker is open), it gets every key press instead of the bindings; it returns false to decline.
    var intercept: (Int, String) -> Bool = { _, _ in false }
    /// Gets the mouse events and modifier changes the tap sees (for Shift-dragging windows); they always pass on.
    var onMouse: (CGEventType, CGEvent) -> Void = { _, _ in }
    var post: (CGEvent) -> Void = { $0.post(tap: .cgSessionEventTap) }

    func handle(_ type: CGEventType, _ e: CGEvent) -> CGEvent? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            return e
        }
        if e.getIntegerValueField(.eventSourceUserData) == marker { return e }
        if type != .keyDown && type != .keyUp { onMouse(type, e); return e }
        let k = Int(e.getIntegerValueField(.keyboardEventKeycode))

        if k == kVK_F18 { // the remapped CapsLock key
            if type == .keyDown, !capsDown {
                capsDown = true
                capsUsed = false
                capsPressedAt = Date()
            } else if type == .keyUp {
                capsDown = false
                if !capsUsed && Date().timeIntervalSince(capsPressedAt) < 1 && !intercept(kVK_Escape, "") { send(kVK_Escape) }
            }
            return nil
        }
        if type == .keyUp { return swallowed.remove(k) != nil ? nil : e }
        guard type == .keyDown else { return e }
        if capsDown { capsUsed = true }

        if intercept(k, typed(e)) {
            swallowed.insert(k)
            return nil
        }
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

    /// The character the key types in the current keyboard layout, lowercased.
    private func typed(_ e: CGEvent) -> String {
        var len = 0
        var buf = [UniChar](repeating: 0, count: 4)
        e.keyboardGetUnicodeString(maxStringLength: 4, actualStringLength: &len, unicodeString: &buf)
        return String(utf16CodeUnits: buf, count: len).lowercased()
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
            case .toggleCapsLock: toggleCapsLock()
            case let .open(url): DispatchQueue.main.async { NSWorkspace.shared.open(URL(string: url)!) }
            // Accessibility calls can be slow, so they run after the event tap has returned.
            case let .snap(d): DispatchQueue.main.async { Snapper.snap(d) }
            case let .move(d): DispatchQueue.main.async { Snapper.move(d) }
            case .toggleMaximize: DispatchQueue.main.async { Snapper.toggleMaximize() }
            case .toggleMinimize: DispatchQueue.main.async { Snapper.toggleMinimize() }
            case .toggleHide: DispatchQueue.main.async { Snapper.toggleHide() }
            case .toggleFullScreen: DispatchQueue.main.async { Snapper.toggleFullScreen() }
            case .gridPicker: DispatchQueue.main.async { (NSApp.delegate as? App)?.gridPicker.toggle() }
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

/// A display's tile grid: `cols` columns and `rows` rows, written `4x2` in the config.
struct Grid: Equatable {
    let cols: Int, rows: Int
    var text: String { "\(cols)x\(rows)" }
    static let maxTiles = 35 // tiles are named 1-9, then a-z
}

func parseGrid(_ s: String?) -> Grid? {
    guard let p = s?.lowercased().split(separator: "x"), p.count == 2,
          let c = Int(p[0].trimmingCharacters(in: .whitespaces)), let r = Int(p[1].trimmingCharacters(in: .whitespaces)),
          c >= 1, r >= 1, c * r <= Grid.maxTiles else { return nil }
    return Grid(cols: c, rows: r)
}

/// Ultrawide displays (wider than 2:1) default to 4x2, all others to 2x2.
func defaultGrid(_ s: NSScreen) -> Grid {
    s.frame.width > 2 * s.frame.height ? Grid(cols: 4, rows: 2) : Grid(cols: 2, rows: 2)
}

func screenGrid(_ s: NSScreen) -> Grid { parseGrid(capmanConfig["grid.\(s.localizedName)"]) ?? defaultGrid(s) }

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

    /// Usable area of a display (without menu bar, notch and Dock), in Accessibility coordinates (origin top left).
    /// With `reserve_menubar`, it also leaves room for a menu bar that hides automatically.
    static func usable(_ s: NSScreen) -> CGRect {
        let h = NSScreen.screens.first?.frame.height ?? 0
        var v = s.visibleFrame
        var top = s.frame.maxY - s.safeAreaInsets.top
        if capmanConfig["reserve_menubar"] == "true" { top = min(top, s.frame.maxY - NSStatusBar.system.thickness) }
        if v.maxY > top { v.size.height -= v.maxY - top }
        return CGRect(x: v.minX, y: h - v.maxY, width: v.width, height: v.height)
    }

    static func areas() -> [CGRect] { NSScreen.screens.map(usable) }

    static func grid(_ a: CGRect) -> Grid {
        NSScreen.screens.first { usable($0) == a }.map(screenGrid) ?? Grid(cols: 2, rows: 2)
    }

    /// The nearest display in direction `d`.
    static func neighbour(of a: CGRect, _ d: Direction) -> CGRect? {
        let others = areas().filter {
            switch d {
            case .left: return $0.maxX <= a.minX + tol
            case .right: return $0.minX >= a.maxX - tol
            case .up: return $0.midY < a.minY
            case .down: return $0.midY > a.maxY
            }
        }
        return others.min { hypot($0.midX - a.midX, $0.midY - a.midY) < hypot($1.midX - a.midX, $1.midY - a.midY) }
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

    /// `k` of the `n` columns at the left or right side of the area.
    static func sideRect(_ d: Direction, _ k: Int, of n: Int, _ v: Span, in a: CGRect, keeping f: CGRect) -> CGRect {
        let w = a.width * CGFloat(k) / CGFloat(n)
        let (y, h) = place(v, a.minY, a.height, keep: (f.minY, f.height))
        return CGRect(x: d == .left ? a.minX : a.maxX - w, y: y, width: w, height: h)
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

    /// Applies one snapping step to `window` (default: the focused window). `origin` is the frame to restore
    /// if Capman doesn't know the window yet (default: its current frame).
    static func act(on window: AXUIElement? = nil, origin: CGRect? = nil, _ decide: (CGRect, CGRect, Span, Span, inout Memory) -> Outcome) {
        minimized = nil
        guard let w = window ?? focusedWindow(), let f = frame(w), let a = area(of: f) else { return }
        let id = CFHash(w)
        let o = origin ?? f
        let fresh = Memory(restore: o, restoreArea: area(of: o) ?? a, corner: nil, lastSet: f, intended: f)
        var m = memory[id] ?? fresh
        if !near(f, m.lastSet) { m = fresh } // moved by the user
        // Decide from the frame Capman asked for, not the one the window got: a window with a minimum size
        // larger than half the display (like Battle.net) would otherwise never count as a top half and get stuck.
        let g = m.intended
        let outcome = decide(g, a, span(g.minX, g.width, in: a.minX, a.width), span(g.minY, g.height, in: a.minY, a.height), &m)
        switch outcome {
        case let .frame(r):
            setFrame(w, r)
            let t = area(of: r) ?? a // the display the window goes to
            if var got = frame(w), got.maxX > t.maxX + 1 || got.maxY > t.maxY + 1 {
                // The app kept a larger minimum size: keep the window on the display, anchored to the snapped edge.
                got.origin = CGPoint(x: max(t.minX, min(got.minX, t.maxX - got.width)), y: max(t.minY, min(got.minY, t.maxY - got.height)))
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

    /// Makes an app the frontmost one. Via Accessibility, because macOS may ignore `activate()` from a background app.
    static func bringToFront(_ pid: pid_t) {
        AXUIElementSetAttributeValue(AXUIElementCreateApplication(pid), kAXFrontmostAttribute as CFString, kCFBooleanTrue)
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
        if AXUIElementGetPid(w, &pid) == .success { bringToFront(pid) }
        return true
    }

    static func snap(_ d: Direction) {
        if d == .up && unminimize() { return }
        act { f, a, h, v, m in
            let maximized = h == .full && v == .full
            switch d {
            case .left, .right:
                // A side is half the columns (rounded up: 2 of 3); with more than two columns, pressing the same
                // side again cycles through one column less
                // and its complement (on 4x2: half, quarter, three quarters, half, ...), so a neighbour can fill the rest.
                let n = grid(a).cols, big = (n + 1) / 2, small = big - 1
                var steps = [big]
                for k in [small, n - small] where k > 0 && k < n && !steps.contains(k) { steps.append(k) }
                let atSide = steps.first { k in
                    k > 0 && near(f.width, a.width * CGFloat(k) / CGFloat(n)) && (d == .left ? near(f.minX, a.minX) : near(f.maxX, a.maxX))
                }
                if let k = atSide, v == .low || v == .high {          // quarter: stretch to the full height
                    m.corner = v
                    return .frame(sideRect(d, k, of: n, .full, in: a, keeping: f))
                }
                if let k = atSide, v == .full, let corner = m.corner { // stretched: back to the quarter
                    m.corner = nil
                    return .frame(sideRect(d, k, of: n, corner, in: a, keeping: f))
                }
                m.corner = nil
                if let k = atSide {
                    let v2: Span = v == .free ? .full : v
                    if steps.count > 1 { return .frame(sideRect(d, steps[(steps.firstIndex(of: k)! + 1) % steps.count], of: n, v2, in: a, keeping: f)) }
                    // Continue on the opposite side of the neighbouring display.
                    guard let nb = neighbour(of: a, d) else { return .none }
                    let nn = grid(nb).cols
                    return .frame(sideRect(d == .left ? .right : .left, (nn + 1) / 2, of: nn, v2, in: nb, keeping: f))
                }
                let keepV = !maximized && (v == .low || v == .high)
                return .frame(sideRect(d, big, of: n, keepV ? v : .full, in: a, keeping: f))
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

    /// Minimizes the focused window, or brings back the window minimized last if the focus hasn't moved on since.
    static func toggleMinimize() {
        if !unminimize() { minimize() }
    }

    /// Moves the focused window to the next grid line in direction `d` without resizing it.
    /// At the edge of the display, it continues on the neighbouring display.
    static func move(_ d: Direction) {
        act { f, a, _, _, m in
            m.corner = nil
            let g = grid(a), horizontal = d == .left || d == .right
            let n = horizontal ? g.cols : g.rows
            let lo = horizontal ? a.minX : a.minY, len = horizontal ? a.width : a.height
            let lines = (0...n).map { lo + len * CGFloat($0) / CGFloat(n) }
            var r = f
            switch d {
            case .left: if let x = lines.last(where: { $0 < f.minX - 2 }) { r.origin.x = x; return .frame(r) }
            case .up: if let y = lines.last(where: { $0 < f.minY - 2 }) { r.origin.y = y; return .frame(r) }
            case .right: if let x = lines.first(where: { $0 > f.maxX + 2 }) { r.origin.x = x - f.width; return .frame(r) }
            case .down: if let y = lines.first(where: { $0 > f.maxY + 2 }) { r.origin.y = y - f.height; return .frame(r) }
            }
            guard let nb = neighbour(of: a, d) else { return .none }
            let w = min(f.width, nb.width), h = min(f.height, nb.height)
            if horizontal {
                let y = nb.minY + min(max(f.minY - a.minY, 0), nb.height - h)
                return .frame(CGRect(x: d == .left ? nb.maxX - w : nb.minX, y: y, width: w, height: h))
            }
            let x = nb.minX + min(max(f.minX - a.minX, 0), nb.width - w)
            return .frame(CGRect(x: x, y: d == .up ? nb.maxY - h : nb.minY, width: w, height: h))
        }
    }

    /// Gives a window (default: the focused one) the frame `r` (from the grid picker or a Shift-drag).
    static func place(_ r: CGRect, on window: AXUIElement? = nil, origin: CGRect? = nil) {
        act(on: window, origin: origin) { _, _, _, _, m in
            m.corner = nil
            return .frame(r)
        }
    }

    // The app hidden last, and the app in front right afterwards: like minimizing, hiding again brings it back
    // as long as no other app came to the front in between.
    static var hidden: NSRunningApplication?
    static var frontAfterHide: pid_t?

    static func toggleHide() {
        let front = NSWorkspace.shared.frontmostApplication
        if let app = hidden, app.isHidden, frontAfterHide == nil || frontAfterHide == front?.processIdentifier {
            hidden = nil
            app.unhide()
            let pid = app.processIdentifier
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { bringToFront(pid) } // unhiding takes a moment
            return
        }
        guard let app = front else { return }
        hidden = app
        frontAfterHide = nil
        app.hide()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if hidden === app { frontAfterHide = NSWorkspace.shared.frontmostApplication?.processIdentifier }
        }
    }

    /// Switches the focused window into or out of the macOS full-screen mode.
    static func toggleFullScreen() {
        guard let w = focusedWindow() else { return }
        var v: CFTypeRef?
        let on = AXUIElementCopyAttributeValue(w, "AXFullScreen" as CFString, &v) == .success && (v as? Bool) == true
        AXUIElementSetAttributeValue(w, "AXFullScreen" as CFString, (on ? kCFBooleanFalse : kCFBooleanTrue)!)
    }
}

// MARK: - Grid picker

/// CapsLock+Space: shows the tile grid of the display under the mouse. Typing two tiles (1-9, then a-z) moves the
/// focused window to the smallest rectangle covering them; with `grid_confirm`, only after Enter. Esc cancels.
final class GridPicker {
    private var panel: NSPanel?
    private var view: GridView?
    private var screen: NSScreen?
    private var tiles: [Int] = []
    var isOpen: Bool { panel != nil }

    func toggle() { if isOpen { close() } else { open() } }

    func open() {
        let mouse = NSEvent.mouseLocation
        guard let s = NSScreen.screens.first(where: { NSMouseInRect(mouse, $0.frame, false) }) ?? NSScreen.main else { return }
        (panel, view) = GridView.show(on: s)
        screen = s
        tiles = []
        view?.hint = hint()
    }

    private func hint() -> String {
        let typed = tiles.map(GridPicker.name).joined(separator: ", ")
        let how = capmanConfig["grid_confirm"] == "true" ? "Type one or two tiles · Enter applies" : "Type two tiles (Enter after one)"
        return (typed.isEmpty ? "" : typed + "   ") + how + " · Esc cancels"
    }

    func close() {
        panel?.orderOut(nil)
        panel = nil
        view = nil
    }

    static func name(_ i: Int) -> String {
        i < 9 ? String(i + 1) : String(UnicodeScalar(UInt8(97 + i - 9)))
    }

    static func index(_ ch: String) -> Int? {
        guard ch.count == 1, let c = ch.unicodeScalars.first?.value else { return nil }
        if (49...57).contains(c) { return Int(c) - 49 }   // 1-9
        if (97...122).contains(c) { return Int(c) - 97 + 9 } // a-z
        return nil
    }

    /// Gets every key press while open (see Engine.intercept).
    func key(_ k: Int, _ ch: String) -> Bool {
        guard isOpen, let s = screen, let v = view else { return false }
        let g = screenGrid(s)
        switch k {
        case kVK_Escape, kVK_Space: close()
        case kVK_Return, kVK_ANSI_KeypadEnter: apply(g, Snapper.usable(s))
        case kVK_Delete: if !tiles.isEmpty { tiles.removeLast() }
        default:
            guard let t = Self.index(ch), t < g.cols * g.rows else { break }
            if tiles.count == 2 { tiles = [] }
            tiles.append(t)
            // Without `grid_confirm`, the second tile applies right away (a single tile: type it twice, or Enter).
            if tiles.count == 2 && capmanConfig["grid_confirm"] != "true" { apply(g, Snapper.usable(s)); return true }
        }
        v.tiles = tiles
        v.hint = hint()
        return true
    }

    private func apply(_ g: Grid, _ a: CGRect) {
        let t = tiles
        close()
        guard let first = t.first, let last = t.last else { return }
        let c0 = min(first % g.cols, last % g.cols), c1 = max(first % g.cols, last % g.cols)
        let r0 = min(first / g.cols, last / g.cols), r1 = max(first / g.cols, last / g.cols)
        let r = GridView.rect(c0, r0, c1, r1, of: g, in: a)
        DispatchQueue.main.async { Snapper.place(r) }
    }
}

// MARK: - Shift-drag

/// Dragging a window with Shift held shows the grid of the display under the mouse. The pointer near a tile's centre
/// picks that tile, near the edge between two tiles both, near a point where four tiles meet all four.
/// Space fixes the current tiles, so further dragging stretches from them (Space again lets go).
/// Releasing the mouse with Shift held places the window on the highlighted tiles; releasing Shift first, or Esc, cancels.
final class DragSnap {
    typealias Cells = (c0: Int, r0: Int, c1: Int, r1: Int)
    private let queue = DispatchQueue(label: "capman.drag") // Accessibility calls, which can be slow, run here
    private var down = false
    private var generation = 0 // counts mouse presses, so late answers from the queue are dropped
    private var window: AXUIElement?
    private var start: CGRect?   // the window's frame when the mouse went down
    private var moved = false    // the window follows the mouse, so this is a window drag
    private var checking = false
    private var cancelled = false
    private var panel: NSPanel?
    private var view: GridView?
    private var screen: NSScreen?
    private var cells: Cells?
    private var anchor: Cells?
    static let edge: CGFloat = 0.15 // share of a tile at each side that counts as the edge to the neighbour

    func mouse(_ type: CGEventType, _ e: CGEvent) {
        let shift = e.flags.contains(.maskShift)
        switch type {
        case .leftMouseDown:
            generation += 1
            down = true
            moved = false
            cancelled = false
            window = nil
            start = nil
            anchor = nil
            hide()
            let gen = generation, p = e.location
            queue.async {
                let w = Self.window(at: p), f = w.flatMap(Snapper.frame)
                DispatchQueue.main.async { if gen == self.generation { self.window = w; self.start = f } }
            }
        case .leftMouseDragged, .flagsChanged:
            guard down, !cancelled else { return }
            if !moved { if shift { check() }; return }
            if shift { update(e.location) } else { hide() }
        case .leftMouseUp:
            generation += 1
            down = false
            if panel != nil, let c = cells, let s = screen, let w = window {
                let r = GridView.rect(c.c0, c.r0, c.c1, c.r1, of: screenGrid(s), in: Snapper.usable(s))
                let origin = start
                // Let the app finish its own drag first.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { Snapper.place(r, on: w, origin: origin) }
            }
            hide()
        default:
            break
        }
    }

    /// Space (stretch) and Esc (cancel) while the grid is shown.
    func key(_ k: Int) -> Bool {
        guard panel != nil else { return false }
        switch k {
        case kVK_Space: anchor = anchor == nil ? cells : nil
        case kVK_Escape: cancelled = true; hide(); return true
        default: return false
        }
        if let p = CGEvent(source: nil)?.location { update(p) }
        return true
    }

    /// The window under the point, in Accessibility coordinates.
    static func window(at p: CGPoint) -> AXUIElement? {
        var el: AXUIElement?
        let system = AXUIElementCreateSystemWide()
        AXUIElementSetMessagingTimeout(system, 0.3)
        guard AXUIElementCopyElementAtPosition(system, Float(p.x), Float(p.y), &el) == .success, let el else { return nil }
        var role: CFTypeRef?
        AXUIElementCopyAttributeValue(el, kAXRoleAttribute as CFString, &role)
        if role as? String == kAXWindowRole { return el }
        var w: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, kAXWindowAttribute as CFString, &w) == .success, let w else { return nil }
        return (w as! AXUIElement)
    }

    /// Whether the window has moved (same size, other position) since the mouse went down.
    private func check() {
        guard !checking, let w = window, let f0 = start else { return }
        checking = true
        let gen = generation
        queue.async {
            let f = Snapper.frame(w)
            DispatchQueue.main.async {
                self.checking = false
                guard gen == self.generation, let f else { return }
                let sameSize = abs(f.width - f0.width) < 2 && abs(f.height - f0.height) < 2
                if sameSize && (abs(f.minX - f0.minX) > 2 || abs(f.minY - f0.minY) > 2) {
                    self.moved = true
                    if let e = CGEvent(source: nil), e.flags.contains(.maskShift) { self.update(e.location) }
                }
            }
        }
    }

    private func update(_ p: CGPoint) {
        let h = NSScreen.screens.first?.frame.height ?? 0
        let cocoa = NSPoint(x: p.x, y: h - p.y)
        guard let s = NSScreen.screens.first(where: { NSMouseInRect(cocoa, $0.frame, false) }) else { return }
        if s != screen || panel == nil {
            hide()
            (panel, view) = GridView.show(on: s)
            screen = s
            anchor = nil
        }
        let g = screenGrid(s), a = Snapper.usable(s)
        let fx = (p.x - a.minX) / a.width * CGFloat(g.cols), fy = (p.y - a.minY) / a.height * CGFloat(g.rows)
        func span(_ f: CGFloat, _ n: Int) -> (Int, Int) {
            let i = min(max(Int(f.rounded(.down)), 0), n - 1), u = f - CGFloat(i)
            if u < Self.edge && i > 0 { return (i - 1, i) }
            if u > 1 - Self.edge && i < n - 1 { return (i, i + 1) }
            return (i, i)
        }
        let (c0, c1) = span(fx, g.cols), (r0, r1) = span(fy, g.rows)
        var c: Cells = (c0, r0, c1, r1)
        if let a = anchor { c = (min(a.c0, c0), min(a.r0, r0), max(a.c1, c1), max(a.r1, r1)) }
        cells = c
        view?.tiles = [c.r0 * g.cols + c.c0, c.r1 * g.cols + c.c1]
        view?.hint = (anchor == nil ? "Space: stretch from here" : "Space: stop stretching") + " · release Shift or Esc to cancel"
    }

    private func hide() {
        panel?.orderOut(nil)
        panel = nil
        view = nil
        screen = nil
        cells = nil
    }
}

final class GridView: NSView {
    let grid: Grid
    var tiles: [Int] = [] { didSet { needsDisplay = true } }
    var hint = "" { didSet { needsDisplay = true } }

    /// Shows a grid overlay over the usable area of a display.
    static func show(on s: NSScreen) -> (NSPanel, GridView) {
        let a = Snapper.usable(s), h = NSScreen.screens.first?.frame.height ?? 0
        let rect = NSRect(x: a.minX, y: h - a.maxY, width: a.width, height: a.height)
        let p = NSPanel(contentRect: rect, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        p.level = .popUpMenu
        p.backgroundColor = .clear
        p.isOpaque = false
        p.hasShadow = false
        p.ignoresMouseEvents = true
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        let v = GridView(grid: screenGrid(s))
        p.contentView = v
        p.setFrame(rect, display: false)
        p.orderFrontRegardless()
        return (p, v)
    }

    /// The frame of the tiles from column c0, row r0 to column c1, row r1, in Accessibility coordinates.
    static func rect(_ c0: Int, _ r0: Int, _ c1: Int, _ r1: Int, of g: Grid, in a: CGRect) -> CGRect {
        let cw = a.width / CGFloat(g.cols), rh = a.height / CGFloat(g.rows)
        return CGRect(x: a.minX + CGFloat(c0) * cw, y: a.minY + CGFloat(r0) * rh,
                      width: CGFloat(c1 - c0 + 1) * cw, height: CGFloat(r1 - r0 + 1) * rh)
    }

    init(grid: Grid) {
        self.grid = grid
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError() }

    override var isFlipped: Bool { true } // row 0 at the top

    override func draw(_: NSRect) {
        let cw = bounds.width / CGFloat(grid.cols), rh = bounds.height / CGFloat(grid.rows), pad: CGFloat = 8
        func cell(_ c0: Int, _ r0: Int, _ c1: Int, _ r1: Int) -> NSRect {
            NSRect(x: CGFloat(c0) * cw, y: CGFloat(r0) * rh, width: CGFloat(c1 - c0 + 1) * cw, height: CGFloat(r1 - r0 + 1) * rh)
                .insetBy(dx: pad, dy: pad)
        }
        NSColor.black.withAlphaComponent(0.25).setFill()
        bounds.fill()
        if let first = tiles.first, let last = tiles.last {
            let path = NSBezierPath(roundedRect: cell(min(first % grid.cols, last % grid.cols), min(first / grid.cols, last / grid.cols),
                                                      max(first % grid.cols, last % grid.cols), max(first / grid.cols, last / grid.cols)),
                                    xRadius: 14, yRadius: 14)
            NSColor.systemBlue.withAlphaComponent(0.45).setFill()
            path.fill()
            NSColor.systemBlue.setStroke()
            path.lineWidth = 4
            path.stroke()
        }
        let shadow = NSShadow()
        shadow.shadowColor = .black
        shadow.shadowBlurRadius = 4
        let font = NSFont.systemFont(ofSize: min(96, min(cw, rh) * 0.3), weight: .semibold)
        for i in 0..<grid.cols * grid.rows {
            let r = cell(i % grid.cols, i / grid.cols, i % grid.cols, i / grid.cols)
            let path = NSBezierPath(roundedRect: r, xRadius: 14, yRadius: 14)
            NSColor.white.withAlphaComponent(0.5).setStroke()
            path.lineWidth = 2
            path.stroke()
            let label = NSAttributedString(string: GridPicker.name(i), attributes: [.font: font, .foregroundColor: NSColor.white, .shadow: shadow])
            let size = label.size()
            label.draw(at: NSPoint(x: r.midX - size.width / 2, y: r.midY - size.height / 2))
        }
        let hint = NSAttributedString(string: hint,
                                      attributes: [.font: NSFont.systemFont(ofSize: 18, weight: .medium), .foregroundColor: NSColor.white, .shadow: shadow])
        let size = hint.size()
        let origin = NSPoint(x: bounds.midX - size.width / 2, y: bounds.maxY - size.height - 32)
        NSColor.black.withAlphaComponent(0.75).setFill()
        NSBezierPath(roundedRect: NSRect(origin: origin, size: size).insetBy(dx: -16, dy: -8), xRadius: 10, yRadius: 10).fill()
        hint.draw(at: origin)
    }
}

// MARK: - Config

/// The current configuration (see `loadConfig`), read again by "Reload Config".
var capmanConfig: [String: String] = [:]

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
let modeColors: [Mode: NSColor] = [.normal: .systemBlue, .visual: .systemOrange]

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
    let gridPicker = GridPicker()
    let dragSnap = DragSnap()
    var displayBusy = false
    // Keeps App Nap from throttling the display watchdog while Capman sits idle in the menu bar.
    let activity = ProcessInfo.processInfo.beginActivity(options: .userInitiatedAllowingIdleSystemSleep, reason: "display watchdog")

    func applicationDidFinishLaunching(_: Notification) {
        let menu = NSMenu()
        menu.delegate = self
        item.menu = menu
        engine.onModeChange = { [weak self] m in self?.showMode(m) }
        engine.intercept = { [weak self] k, ch in
            guard let self else { return false }
            return gridPicker.key(k, ch) || dragSnap.key(k)
        }
        engine.onMouse = { [weak self] type, e in self?.dragSnap.mouse(type, e) }
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
        let mask = [CGEventType.keyDown, .keyUp, .flagsChanged, .leftMouseDown, .leftMouseDragged, .leftMouseUp]
            .reduce(0) { $0 | (1 << $1.rawValue) }
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

    /// Sets `key` in the config file, or removes it if `value` is nil, and reloads the config.
    /// Writes in place, so a symlinked config (e.g. from a dotfiles repo) stays a symlink.
    func setConfig(_ key: String, _ value: String?) {
        let target = configURL.resolvingSymlinksInPath()
        var lines = ((try? String(contentsOf: target, encoding: .utf8)) ?? "# Capman configuration, see \(helpURL)\n")
            .components(separatedBy: "\n")
        let i = lines.firstIndex { line in
            let content = line.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false).first ?? ""
            return content.split(separator: "=", maxSplits: 1).first?.trimmingCharacters(in: .whitespaces) == key
        }
        if let value {
            if let i { lines[i] = "\(key) = \(value)" } else {
                if lines.last == "" { lines.removeLast() }
                lines += ["\(key) = \(value)", ""]
            }
        } else if let i {
            lines.remove(at: i)
        }
        try? FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? lines.joined(separator: "\n").write(to: target, atomically: false, encoding: .utf8)
        reloadConfig()
    }

    @objc func toggleUmlauts() { setConfig("umlauts", "\(!engine.umlauts)") }

    @objc func toggleGridConfirm() {
        setConfig("grid_confirm", capmanConfig["grid_confirm"] == "true" ? nil : "true")
    }

    @objc func toggleReserveMenuBar() {
        setConfig("reserve_menubar", capmanConfig["reserve_menubar"] == "true" ? nil : "true")
    }

    @objc func pickGrid(_ sender: NSMenuItem) {
        guard let (name, grid) = sender.representedObject as? (String, String?) else { return }
        setConfig("grid.\(name)", grid)
    }

    func reloadConfig() {
        capmanConfig = loadConfig()
        engine.umlauts = capmanConfig["umlauts"] == "true"
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
        let reserve = NSMenuItem(title: "Leave Room for Hidden Menu Bar", action: #selector(toggleReserveMenuBar), keyEquivalent: "")
        reserve.state = capmanConfig["reserve_menubar"] == "true" ? .on : .off
        reserve.target = self
        menu.addItem(reserve)
        let confirm = NSMenuItem(title: "Confirm Window Grid with Enter", action: #selector(toggleGridConfirm), keyEquivalent: "")
        confirm.state = capmanConfig["grid_confirm"] == "true" ? .on : .off
        confirm.target = self
        menu.addItem(confirm)
        menu.addItem(withTitle: "Edit Config…", action: #selector(editConfig), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Reload Config", action: #selector(reload), keyEquivalent: "r").target = self
        menu.addItem(withTitle: "Help", action: #selector(help), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(.sectionHeader(title: "Window Grid (columns × rows, ⇪Space)"))
        for s in NSScreen.screens {
            let current = screenGrid(s), auto = defaultGrid(s), name = s.localizedName
            let item = NSMenuItem(title: "\(name): \(current.cols) × \(current.rows)", action: nil, keyEquivalent: "")
            let sub = NSMenu()
            let explicit = parseGrid(capmanConfig["grid.\(name)"])
            let a = NSMenuItem(title: "Automatic (\(auto.cols) × \(auto.rows))", action: #selector(pickGrid(_:)), keyEquivalent: "")
            a.representedObject = (name, String?.none)
            a.state = explicit == nil ? .on : .off
            a.target = self
            sub.addItem(a)
            sub.addItem(.separator())
            for (c, r) in [(2, 2), (3, 2), (4, 2), (6, 2), (2, 3), (3, 3), (4, 3), (1, 2), (1, 3)] {
                let g = Grid(cols: c, rows: r)
                let i = NSMenuItem(title: "\(c) × \(r)", action: #selector(pickGrid(_:)), keyEquivalent: "")
                i.representedObject = (name, Optional(g.text))
                i.state = explicit == g ? .on : .off
                i.target = self
                sub.addItem(i)
            }
            item.submenu = sub
            menu.addItem(item)
        }
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
