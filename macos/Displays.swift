// Display management: turn displays on/off and switch display modes, similar to Win+P on Windows.
// Formerly the separate app toscdm. Used by the menu and by Ctrl+Option+Cmd+P (see Capman.swift).
import AppKit
import Carbon.HIToolbox

// Private CoreGraphics call that logically disconnects a display (same one BetterDisplay uses).
@_silgen_name("CGSConfigureDisplayEnabled")
func CGSConfigureDisplayEnabled(_ config: CGDisplayConfigRef, _ display: CGDirectDisplayID, _ enabled: Bool) -> CGError

struct Display {
    let id: CGDirectDisplayID
    let name: String
    let builtin: Bool
    let enabled: Bool
}

enum DisplayMode: String, CaseIterable {
    case internalOnly = "Internal display only"
    case externalOnly = "External displays only"
    case mirror = "Mirror displays"
    case extend = "Extend displays"
}

final class DisplayManager {
    // Disabled displays vanish from all system lists, so we remember them (id -> name, persisted).
    private var disabled: [CGDirectDisplayID: String] = [:] {
        didSet { UserDefaults.standard.set(Dictionary(uniqueKeysWithValues: disabled.map { (String($0), $1) }), forKey: "disabled") }
    }
    private var builtinID: CGDirectDisplayID? {
        didSet { if let builtinID { UserDefaults.standard.set(Int(builtinID), forKey: "builtin") } }
    }

    init() {
        let saved = UserDefaults.standard.dictionary(forKey: "disabled") as? [String: String] ?? [:]
        disabled = Dictionary(uniqueKeysWithValues: saved.compactMap { k, v in UInt32(k).map { ($0, v) } })
        let b = UserDefaults.standard.integer(forKey: "builtin")
        builtinID = b > 0 ? CGDirectDisplayID(b) : nil
    }

    private func list(active: Bool = false) -> [CGDirectDisplayID] {
        var ids = [CGDirectDisplayID](repeating: 0, count: 16)
        var n: UInt32 = 0
        if active { CGGetActiveDisplayList(16, &ids, &n) } else { CGGetOnlineDisplayList(16, &ids, &n) }
        return Array(ids.prefix(Int(n)))
    }

    private func name(_ id: CGDirectDisplayID) -> String {
        if let s = NSScreen.screens.first(where: { $0.deviceDescription[.init("NSScreenNumber")] as? CGDirectDisplayID == id }) {
            return s.localizedName
        }
        return CGDisplayIsBuiltin(id) != 0 ? "Built-in Display" : "Display \(id)"
    }

    func displays() -> [Display] {
        var result = list().map { id -> Display in
            if CGDisplayIsBuiltin(id) != 0 { builtinID = id }
            return Display(id: id, name: name(id), builtin: CGDisplayIsBuiltin(id) != 0, enabled: disabled[id] == nil)
        }
        for (id, n) in disabled where !result.contains(where: { $0.id == id }) {
            result.append(Display(id: id, name: n, builtin: id == builtinID, enabled: false))
        }
        return result.sorted { ($0.builtin ? 0 : 1, $0.id) < ($1.builtin ? 0 : 1, $1.id) }
    }

    @discardableResult
    private func configure(_ body: (CGDisplayConfigRef) -> Void) -> Bool {
        var cfg: CGDisplayConfigRef?
        guard CGBeginDisplayConfiguration(&cfg) == .success, let cfg else { return false }
        body(cfg)
        return CGCompleteDisplayConfiguration(cfg, .permanently) == .success
    }

    func setEnabled(_ d: Display, _ on: Bool) {
        if !on && displays().filter(\.enabled).count <= 1 { NSSound.beep(); return } // never turn off the last screen
        let ok = configure { _ = CGSConfigureDisplayEnabled($0, d.id, on) }
        if on || !ok { disabled[d.id] = nil } else { disabled[d.id] = d.name }
    }

    func enableAll() {
        guard !disabled.isEmpty else { return }
        configure { cfg in for id in disabled.keys { _ = CGSConfigureDisplayEnabled(cfg, id, true) } }
        disabled = [:]
    }

    /// Safety net: if no real display is left (e.g. HDMI unplugged while the built-in was off), turn everything back on.
    /// Displays without a vendor id are placeholders macOS may create when nothing is attached, so they don't count.
    func watchdog() {
        guard !disabled.isEmpty else { return }
        let usable = list(active: true).filter { disabled[$0] == nil && CGDisplayVendorNumber($0) != 0 }
        if usable.isEmpty {
            NSLog("capman: no usable display left, re-enabling %@", disabled.values.joined(separator: ", "))
            enableAll()
        }
    }

    func logState() {
        let d = list().map { "\($0)[builtin=\(CGDisplayIsBuiltin($0)) active=\(CGDisplayIsActive($0)) vendor=\(CGDisplayVendorNumber($0))]" }
        NSLog("capman: online %@, disabled %@", d.joined(separator: " "), disabled.keys.map(String.init).joined(separator: " "))
    }

    func currentMode() -> DisplayMode {
        let ds = displays()
        guard let b = ds.first(where: \.builtin) else { return .extend }
        if !b.enabled { return .externalOnly }
        if ds.filter({ !$0.builtin }).allSatisfy({ !$0.enabled }) { return .internalOnly }
        return CGDisplayIsInMirrorSet(b.id) != 0 ? .mirror : .extend
    }

    func apply(_ mode: DisplayMode, done: @escaping () -> Void) {
        let needsReset = !disabled.isEmpty
        enableAll()
        // Re-enabled displays come online asynchronously, so wait before arranging them.
        DispatchQueue.main.asyncAfter(deadline: .now() + (needsReset ? 2 : 0)) { [self] in
            let ds = displays()
            guard let b = ds.first(where: \.builtin), let main = ds.first(where: { !$0.builtin }) else { return done() }
            let externals = ds.filter { !$0.builtin }
            configure { cfg in
                for d in ds { CGConfigureDisplayMirrorOfDisplay(cfg, d.id, kCGNullDirectDisplay) }
                // Mirror onto the first external so it keeps its native resolution.
                if mode == .mirror { for d in ds where d.id != main.id { CGConfigureDisplayMirrorOfDisplay(cfg, d.id, main.id) } }
            }
            switch mode {
            case .internalOnly: externals.forEach { setEnabled($0, false) }
            case .externalOnly: setEnabled(b, false)
            case .mirror, .extend: break
            }
            done()
        }
    }
}

/// Win+P-like list of modes in the middle of the screen. Enter applies, Esc or clicking elsewhere closes.
final class DisplayPicker: NSPanel {
    private let onPick: (DisplayMode) -> Void
    private var rows: [NSTextField] = []
    private var current = DisplayMode.extend
    private var selected = 0 { didSet { redraw() } }

    init(onPick: @escaping (DisplayMode) -> Void) {
        self.onPick = onPick
        super.init(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: false)
        level = .modalPanel
        backgroundColor = .clear
        isOpaque = false
        let bg = NSVisualEffectView()
        bg.material = .hudWindow
        bg.state = .active
        bg.wantsLayer = true
        bg.layer?.cornerRadius = 14
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 4
        stack.edgeInsets = NSEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        for _ in DisplayMode.allCases {
            let t = NSTextField(labelWithString: "")
            t.font = .systemFont(ofSize: 18, weight: .medium)
            t.drawsBackground = true
            t.widthAnchor.constraint(equalToConstant: 300).isActive = true
            rows.append(t)
            stack.addArrangedSubview(t)
        }
        bg.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo: bg.leadingAnchor), stack.trailingAnchor.constraint(equalTo: bg.trailingAnchor),
                                     stack.topAnchor.constraint(equalTo: bg.topAnchor), stack.bottomAnchor.constraint(equalTo: bg.bottomAnchor)])
        contentView = bg
    }

    override var canBecomeKey: Bool { true }

    func open(current: DisplayMode) {
        self.current = current
        selected = (DisplayMode.allCases.firstIndex(of: current)! + 1) % DisplayMode.allCases.count
        setContentSize(contentView!.fittingSize)
        let screen = NSScreen.main?.frame ?? .zero
        setFrameOrigin(NSPoint(x: screen.midX - frame.width / 2, y: screen.midY - frame.height / 2))
        NSApp.activate(ignoringOtherApps: true)
        makeKeyAndOrderFront(nil)
    }

    func move(_ by: Int) {
        selected = (selected + by + rows.count) % rows.count
    }

    private func redraw() {
        for (i, (t, m)) in zip(rows, DisplayMode.allCases).enumerated() {
            t.stringValue = (m == current ? " ✓ " : "    ") + m.rawValue
            t.backgroundColor = i == selected ? .selectedContentBackgroundColor : .clear
            t.textColor = i == selected ? .white : .labelColor
        }
    }

    private func dismiss(apply: Bool) {
        orderOut(nil)
        NSApp.hide(nil) // gives the keyboard focus back to the previous app
        if apply { onPick(DisplayMode.allCases[selected]) }
    }

    override func keyDown(with e: NSEvent) {
        switch Int(e.keyCode) {
        case kVK_Return, kVK_ANSI_KeypadEnter: dismiss(apply: true)
        case kVK_Escape: dismiss(apply: false)
        case kVK_DownArrow, kVK_ANSI_P, kVK_Tab: move(1)
        case kVK_UpArrow: move(-1)
        default: break
        }
    }

    override func mouseDown(with e: NSEvent) {
        if let i = rows.firstIndex(where: { $0.convert($0.bounds, to: nil).contains(e.locationInWindow) }) {
            selected = i
            dismiss(apply: true)
        }
    }

    override func resignKey() {
        super.resignKey()
        if isVisible { dismiss(apply: false) }
    }
}

/// Small on-screen label showing the new mode, like the Win+P overlay.
enum HUD {
    static var panel: NSPanel?

    static func show(_ text: String) {
        panel?.close()
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = .white
        label.sizeToFit()
        let size = NSSize(width: label.frame.width + 48, height: label.frame.height + 32)
        let screen = NSScreen.main?.frame ?? .zero
        let p = NSPanel(contentRect: NSRect(x: screen.midX - size.width / 2, y: screen.midY - size.height / 2,
                                            width: size.width, height: size.height),
                        styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        p.level = .statusBar
        p.backgroundColor = .clear
        p.isOpaque = false
        let bg = NSView(frame: NSRect(origin: .zero, size: size))
        bg.wantsLayer = true
        bg.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.75).cgColor
        bg.layer?.cornerRadius = 14
        label.setFrameOrigin(NSPoint(x: 24, y: 16))
        bg.addSubview(label)
        p.contentView = bg
        p.orderFrontRegardless()
        panel = p
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { if panel === p { p.close(); panel = nil } }
    }
}
