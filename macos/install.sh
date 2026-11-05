#!/bin/sh
# Build Capman.app into ~/Applications and start it at login via a LaunchAgent.
# Usage: macos/install.sh            build, install and start
#        macos/install.sh uninstall  stop and remove everything
set -eu
cd "$(dirname "$0")"
APP="$HOME/Applications/Capman.app"
LABEL=de.tosc.capman
AGENT="$HOME/Library/LaunchAgents/$LABEL.plist"
VERSION="$(sed -n 's/^let capmanVersion = "\(.*\)"/\1/p' Capman.swift)"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
pkill -x Capman 2>/dev/null || true

if [ "${1:-}" = uninstall ]; then
    rm -rf "$APP" "$AGENT"
    hidutil property --set '{"UserKeyMapping":[]}' >/dev/null
    echo "Capman uninstalled"
    exit 0
fi

mkdir -p "$APP/Contents/MacOS" "$HOME/Library/LaunchAgents"
swiftc -O -swift-version 5 -parse-as-library Capman.swift Displays.swift -o "$APP/Contents/MacOS/Capman"
cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
    <key>CFBundleIdentifier</key><string>$LABEL</string>
    <key>CFBundleName</key><string>Capman</string>
    <key>CFBundleExecutable</key><string>Capman</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>$VERSION</string>
    <key>LSUIElement</key><true/>
</dict></plist>
EOF

# Sign with a stable self-signed certificate rather than ad hoc, so that the Accessibility permission
# survives rebuilds (macOS ties it to the signing certificate, not to the exact binary).
CERT="Local Code Signing"
if ! security find-identity -p codesigning | grep -q "\"$CERT\""; then
    T="$(mktemp -d)"
    /usr/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 7300 -subj "/CN=$CERT" \
        -addext "keyUsage=critical,digitalSignature" -addext "extendedKeyUsage=critical,codeSigning" \
        -keyout "$T/key.pem" -out "$T/cert.pem" 2>/dev/null
    /usr/bin/openssl pkcs12 -export -inkey "$T/key.pem" -in "$T/cert.pem" -out "$T/id.p12" -passout pass:tmp
    security import "$T/id.p12" -P tmp -T /usr/bin/codesign >/dev/null
    rm -rf "$T"
    echo "created code signing certificate \"$CERT\" in the login keychain"
fi
codesign --force --sign "$CERT" "$APP"

# KeepAlive restarts Capman after a crash, but not after "Quit Capman" from the menu.
cat > "$AGENT" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
    <key>Label</key><string>$LABEL</string>
    <key>ProgramArguments</key><array><string>$APP/Contents/MacOS/Capman</string></array>
    <key>RunAtLoad</key><true/>
    <key>KeepAlive</key><dict><key>SuccessfulExit</key><false/></dict>
</dict></plist>
EOF
launchctl bootstrap "gui/$(id -u)" "$AGENT"
echo "Capman $VERSION installed to $APP and started (autostarts at login)"
