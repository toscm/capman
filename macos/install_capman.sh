#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${HOME}/.config/karabiner"
TARGET_FILE="${CONFIG_DIR}/karabiner.json"
BACKUP_DIR="${CONFIG_DIR}/backup"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="${SCRIPT_DIR}/karabiner.json"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H-%M-%SZ")"

mkdir -p "${CONFIG_DIR}"

if [ -e "${TARGET_FILE}" ]; then
    mkdir -p "${BACKUP_DIR}"
    BACKUP_FILE="${BACKUP_DIR}/karabiner-${TIMESTAMP}.json"
    mv "${TARGET_FILE}" "${BACKUP_FILE}"
    echo "Existing karabiner.json backed up to ${BACKUP_FILE}"
fi

cp "${SOURCE_FILE}" "${TARGET_FILE}"
echo "Installed ${SOURCE_FILE} to ${TARGET_FILE}"