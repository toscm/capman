// Capman for macOS: CapsLock as a Vim-style modifier key, modes, and Windows-like window snapping.
//
// How it works: at startup hidutil maps the CapsLock key to F18, which has no other use.
// A keyboard event tap then sees F18 going down and up, and rewrites the keys pressed meanwhile.
// The bindings live in one table in `buildBindings` below; README.md documents them.
import AppKit
import Carbon.HIToolbox
import IOKit
import IOKit.hid

let capmanVersion = "0.4.0"
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
enum Snapper {
    static var restoreFrames: [CFHashCode: CGRect] = [:]
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

    static func span(_ lo: CGFloat, _ len: CGFloat, in aLo: CGFloat, _ aLen: CGFloat) -> Span {
        func near(_ a: CGFloat, _ b: CGFloat) -> Bool { abs(a - b) < tol }
        if near(lo, aLo) && near(len, aLen) { return .full }
        if near(lo, aLo) && near(len, aLen / 2) { return .low }
        if near(lo, aLo + aLen / 2) && near(len, aLen / 2) { return .high }
        return .free
    }

    static func place(_ s: Span, _ aLo: CGFloat, _ aLen: CGFloat, keep: (CGFloat, CGFloat)) -> (CGFloat, CGFloat) {
        switch s {
        case .low: return (aLo, aLen / 2)
        case .high: return (aLo + aLen / 2, aLen / 2)
        case .full: return (aLo, aLen)
        case .free: return keep
        }
    }

    static func apply(_ w: AXUIElement, from f: CGRect, to r: CGRect) {
        let id = CFHash(w)
        if restoreFrames[id] == nil { restoreFrames[id] = f }
        setFrame(w, r)
    }

    static func restore(_ w: AXUIElement) {
        if let r = restoreFrames.removeValue(forKey: CFHash(w)) { setFrame(w, r) }
    }

    static func snap(_ d: Direction) {
        guard let w = focusedWindow(), let f = frame(w), let a = area(of: f) else { return }
        let h = span(f.minX, f.width, in: a.minX, a.width), v = span(f.minY, f.height, in: a.minY, a.height)
        // Vertical placement used by Left/Right: keep a top/bottom snap, otherwise use the full height.
        let (y, height) = place(v == .low || v == .high ? v : .full, a.minY, a.height, keep: (f.minY, f.height))
        switch d {
        case .left, .right:
            let side: Span = d == .left ? .low : .high
            if h == side { // already on that side: continue on the neighbouring display
                let others = areas().filter { d == .left ? $0.maxX <= a.minX + tol : $0.minX >= a.maxX - tol }
                guard let n = others.min(by: { abs($0.midX - a.midX) < abs($1.midX - a.midX) }) else { return }
                let vy = place(v == .low || v == .high ? v : .full, n.minY, n.height, keep: (n.minY, n.height))
                let (x, width) = place(d == .left ? .high : .low, n.minX, n.width, keep: (0, 0))
                apply(w, from: f, to: CGRect(x: x, y: vy.0, width: width, height: vy.1))
            } else {
                let (x, width) = place(side, a.minX, a.width, keep: (0, 0))
                apply(w, from: f, to: CGRect(x: x, y: y, width: width, height: height))
            }
        case .up, .down:
            let side: Span = d == .up ? .low : .high
            if h == .full && v == .full { restore(w) }            // maximized: restore
            else if v == side {                                     // already at that side
                if d == .up { apply(w, from: f, to: a) } else { restore(w) }
            } else {                                                // top/bottom half, keeping x and width
                let (ny, nh) = place(side, a.minY, a.height, keep: (0, 0))
                apply(w, from: f, to: CGRect(x: f.minX, y: ny, width: f.width, height: nh))
            }
        }
    }

    static func toggleMaximize() {
        guard let w = focusedWindow(), let f = frame(w), let a = area(of: f) else { return }
        if span(f.minX, f.width, in: a.minX, a.width) == .full && span(f.minY, f.height, in: a.minY, a.height) == .full {
            restore(w)
        } else {
            apply(w, from: f, to: a)
        }
    }

    static func minimize() {
        if let w = focusedWindow() { AXUIElementSetAttributeValue(w, kAXMinimizedAttribute as CFString, kCFBooleanTrue) }
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

/// Small label at the bottom right of the main display showing the current mode (hidden in Insert Mode).
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
        let colors: [Mode: NSColor] = [.normal: .systemBlue, .visual: .systemOrange, .window: .systemPurple]
        panel.contentView?.layer?.backgroundColor = colors[mode]?.withAlphaComponent(0.9).cgColor
        label.stringValue = mode.rawValue
        label.sizeToFit()
        label.setFrameOrigin(NSPoint(x: 12, y: 6))
        let size = NSSize(width: label.frame.width + 24, height: label.frame.height + 12)
        let v = screen.visibleFrame
        panel.setFrame(NSRect(x: v.maxX - size.width - 12, y: v.minY + 12, width: size.width, height: size.height), display: true)
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

    func applicationDidFinishLaunching(_: Notification) {
        let menu = NSMenu()
        menu.delegate = self
        item.menu = menu
        engine.onModeChange = { [weak self] m in self?.showMode(m) }
        reloadConfig()
        showMode(.insert)

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

    func reloadConfig() {
        engine.umlauts = loadConfig()["umlauts"] == "true"
        buildBindings(umlauts: engine.umlauts)
    }

    func showMode(_ m: Mode) {
        item.button?.title = m == .insert ? "⇪" : "⇪ " + m.rawValue
        indicator.show(m)
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        menu.addItem(withTitle: "Capman \(capmanVersion)", action: nil, keyEquivalent: "")
        menu.addItem(withTitle: "Mode: \(engine.mode.rawValue.capitalized)", action: nil, keyEquivalent: "")
        menu.addItem(withTitle: "Umlauts: \(engine.umlauts ? "on" : "off")", action: nil, keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Edit Config…", action: #selector(editConfig), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Reload Config", action: #selector(reload), keyEquivalent: "r").target = self
        menu.addItem(withTitle: "Help", action: #selector(help), keyEquivalent: "").target = self
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

    @objc func reload() { reloadConfig() }
    @objc func help() { NSWorkspace.shared.open(URL(string: helpURL)!) }
}

let app = NSApplication.shared
let delegate = App()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
