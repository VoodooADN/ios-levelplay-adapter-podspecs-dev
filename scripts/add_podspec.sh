#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  SCRIPT_NAME=$(basename "$0")
  echo "Usage: ${SCRIPT_NAME} <path_to_podspec>"
  echo
  echo "Arguments:"
  echo "  path_to_podspec: the path to the podspec to add"
  echo
  echo "Example:"
  echo "  ${SCRIPT_NAME} VoodooIronSourceAdapter.podspec"
  exit 1
fi

PODSPEC_FILE_PATH=$1

# check if the podspec file exists
if [[ ! -f "${PODSPEC_FILE_PATH}" ]]; then
  echo "❌ Error: not a file: ${PODSPEC_FILE_PATH}"
  exit 1
fi

# get the podspec name from the podspec file
PODSPEC_NAME=$(sed -nE "s/^[[:space:]]*s\.name[[:space:]]*=[[:space:]]*['\"]([^'\"]+)['\"].*/\1/p" "${PODSPEC_FILE_PATH}")
if [[ -z "${PODSPEC_NAME}" ]]; then
  echo "❌ Error: could not determine podspec name"
  exit 1
fi

# get the podspec version from the podspec file
PODSPEC_VERSION=$(sed -nE "s/^[[:space:]]*s\.version[[:space:]]*=[[:space:]]*['\"]([^'\"]+)['\"].*/\1/p" "${PODSPEC_FILE_PATH}")
if [[ -z "${PODSPEC_VERSION}" ]]; then
  echo "❌ Error: could not determine podspec version"
  exit 1
fi

# check if the podspec is already in this repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PODSPEC_DIRECTORY_FINAL_PATH="${SCRIPT_DIR}/../${PODSPEC_NAME}/${PODSPEC_VERSION}"
PODSPEC_FINAL_PATH="${PODSPEC_DIRECTORY_FINAL_PATH}/${PODSPEC_NAME}.podspec"
if [[ -f "${PODSPEC_FINAL_PATH}" ]]; then
  echo "⚠️ Warning: podspec already exists at ${PODSPEC_FINAL_PATH}"
  exit 0 # do not fail at this step!
else
  # add the podspec to the podspec repo
  mkdir -p "${PODSPEC_DIRECTORY_FINAL_PATH}"
  mv "${PODSPEC_FILE_PATH}" "${PODSPEC_DIRECTORY_FINAL_PATH}"
fi
