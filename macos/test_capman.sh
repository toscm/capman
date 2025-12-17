#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="${SCRIPT_DIR}/karabiner.json"
CONFIG_DIR="${HOME}/.config/karabiner"
CONFIG_FILE="${CONFIG_DIR}/karabiner.json"
TEST_PROFILE_NAMES=("Capman Test Profile A" "Capman Test Profile B")

write_mini_config() {
    cat >"${CONFIG_FILE}" <<'EOF'
{
    "profiles": [
        {
            "name": "Capman Test Profile A",
            "selected": true,
            "complex_modifications": { "rules": [] },
            "virtual_hid_keyboard": { "keyboard_type_v2": "ansi" }
        },
        {
            "name": "Capman Test Profile B",
            "selected": false,
            "complex_modifications": { "rules": [] },
            "virtual_hid_keyboard": { "keyboard_type_v2": "ansi" }
        }
    ]
}
EOF
}

ensure_profiles_listed() {
    local output="$1"
    shift
    for expected in "$@"; do
        if ! printf '%s\n' "${output}" | grep -Fq -- "${expected}"; then
            echo "karabiner_cli output did not contain expected profile '${expected}'." >&2
            printf 'Command output was:\n%s\n' "${output}" >&2
            exit 1
        fi
    done
}

CLI_AVAILABLE=false
ORIGINAL_PRESENT=false
BACKUP_FILE=""
RESTORE_COMPLETE=false

cleanup() {
    if [ "${CLI_AVAILABLE}" != "true" ]; then
        return
    fi
    if [ "${RESTORE_COMPLETE}" = "true" ]; then
        return
    fi
    if [ "${ORIGINAL_PRESENT}" = "true" ] && [ -n "${BACKUP_FILE}" ] && [ -f "${BACKUP_FILE}" ]; then
        mv "${BACKUP_FILE}" "${CONFIG_FILE}"
        echo "Restored previous Karabiner configuration from ${BACKUP_FILE}."
    else
        rm -f "${CONFIG_FILE}"
        echo "Removed temporary test configuration at ${CONFIG_FILE}."
    fi
    RESTORE_COMPLETE=true
}

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required to validate JSON but was not found." >&2
    exit 1
fi

echo "Validating repo config with jq: ${SOURCE_FILE}"
jq empty "${SOURCE_FILE}"
echo "JSON syntax looks good."

REPO_PROFILE_NAMES=()
while IFS= read -r profile_name; do
    if [ -n "${profile_name}" ]; then
        REPO_PROFILE_NAMES+=("${profile_name}")
    fi
done < <(jq -r '.profiles[].name // empty' "${SOURCE_FILE}")

if [ ${#REPO_PROFILE_NAMES[@]} -eq 0 ]; then
    echo "No profile names found in ${SOURCE_FILE}; cannot validate reload behavior." >&2
    exit 1
fi

if ! command -v karabiner_cli >/dev/null 2>&1; then
    echo "karabiner_cli not found; skipping runtime validation."
    exit 0
fi

CLI_AVAILABLE=true
trap cleanup EXIT

mkdir -p "${CONFIG_DIR}"

if [ -f "${CONFIG_FILE}" ]; then
    BACKUP_FILE="$(mktemp "${CONFIG_DIR}/karabiner.test.backup.XXXXXX.json")"
    cp "${CONFIG_FILE}" "${BACKUP_FILE}"
    ORIGINAL_PRESENT=true
    echo "Backed up existing config to ${BACKUP_FILE}."
else
    echo "No existing config found; test will temporarily install the repo config."
fi

echo "Installing minimal test configuration to verify karabiner_cli output..."
write_mini_config
mini_output=$(karabiner_cli --list-profile-names)
ensure_profiles_listed "${mini_output}" "${TEST_PROFILE_NAMES[@]}"
echo "karabiner_cli listed the expected test profiles."

cp "${SOURCE_FILE}" "${CONFIG_FILE}"
echo "Installed repo config from ${SOURCE_FILE} to ${CONFIG_FILE}."

repo_output=$(karabiner_cli --list-profile-names)
ensure_profiles_listed "${repo_output}" "${REPO_PROFILE_NAMES[@]}"
echo "karabiner_cli successfully reloaded the repo configuration and listed all its profiles."

cleanup
trap - EXIT