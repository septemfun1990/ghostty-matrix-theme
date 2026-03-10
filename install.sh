#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/Library/Application Support/com.mitchellh.ghostty"
SHADER_DIR="${TARGET_DIR}/shaders"
BACKUP_ROOT="${TARGET_DIR}/backups"
TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
DRY_RUN=0
EXISTING_FILES=()

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

track_existing_file() {
  local source_path="$1"

  if [[ -f "${source_path}" ]]; then
    EXISTING_FILES+=("${source_path}")
  fi
}

backup_file() {
  local source_path="$1"
  local relative_path="$2"

  if [[ ! -f "${source_path}" ]]; then
    return
  fi

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    return
  fi

  mkdir -p "$(dirname "${BACKUP_DIR}/${relative_path}")"
  cp "${source_path}" "${BACKUP_DIR}/${relative_path}"
}

install_file() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "${target_path}")"
  cp "${source_path}" "${target_path}"
}

if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "Dry run only. No files will be changed."
else
  mkdir -p "${SHADER_DIR}"
fi

track_existing_file "${TARGET_DIR}/config"
track_existing_file "${SHADER_DIR}/matrix_display.glsl"
track_existing_file "${SHADER_DIR}/matrix_cursor_halo.glsl"

backup_file "${TARGET_DIR}/config" "config"
backup_file "${SHADER_DIR}/matrix_display.glsl" "shaders/matrix_display.glsl"
backup_file "${SHADER_DIR}/matrix_cursor_halo.glsl" "shaders/matrix_cursor_halo.glsl"

if [[ "${DRY_RUN}" -eq 0 ]]; then
  install_file "${SRC_DIR}/config" "${TARGET_DIR}/config"
  install_file "${SRC_DIR}/shaders/matrix_display.glsl" "${SHADER_DIR}/matrix_display.glsl"
  install_file "${SRC_DIR}/shaders/matrix_cursor_halo.glsl" "${SHADER_DIR}/matrix_cursor_halo.glsl"
fi

if [[ "${DRY_RUN}" -eq 1 && "${#EXISTING_FILES[@]}" -gt 0 ]]; then
  echo "Would back up existing Ghostty files to:"
  echo "  ${BACKUP_DIR}"
elif [[ -d "${BACKUP_DIR}" ]]; then
  echo "Backed up existing Ghostty files to:"
  echo "  ${BACKUP_DIR}"
else
  echo "No existing Ghostty Matrix files needed backup."
fi

if [[ "${DRY_RUN}" -eq 0 ]]; then
  echo "Installed Ghostty config to:"
  echo "  ${TARGET_DIR}/config"
  echo "Installed shaders to:"
  echo "  ${SHADER_DIR}"
else
  echo "Would install Ghostty config to:"
  echo "  ${TARGET_DIR}/config"
  echo "Would install shaders to:"
  echo "  ${SHADER_DIR}"
fi

echo
echo "Required fonts:"
echo "  JetBrains Mono"
echo "  Sarasa Mono TC"
echo
echo "Fully quit and reopen Ghostty to ensure all settings are applied."
echo "Optional validation:"
echo "  '/Applications/Ghostty.app/Contents/MacOS/ghostty' +validate-config"
