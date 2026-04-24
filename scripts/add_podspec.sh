#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

usage() {
  echo "Usage: ${SCRIPT_NAME} <path_to_podspec>" >&2
  echo "  path_to_podspec: the path to the podspec to add" >&2
  echo "Example:"
  echo "  ${SCRIPT_NAME} VoodooIronSourceAdapter.podspec"
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

PODSPEC_FILE_PATH=$1

# check if the podspec file exists
if [[ ! -f "${PODSPEC_FILE_PATH}" ]]; then
  echo "error: not a file: ${PODSPEC_FILE_PATH}" >&2
  exit 1
fi

# get the podspec name from the podspec file
PODSPEC_NAME=$(sed -nE "s/^[[:space:]]*s\.name[[:space:]]*=[[:space:]]*['\"]([^'\"]+)['\"].*/\1/p" "${PODSPEC_FILE_PATH}")
if [[ -z "${PODSPEC_NAME}" ]]; then
  echo "error: could not determine podspec name" >&2
  exit 1
fi

# get the podspec version from the podspec file
PODSPEC_VERSION=$(sed -nE "s/^[[:space:]]*s\.version[[:space:]]*=[[:space:]]*['\"]([^'\"]+)['\"].*/\1/p" "${PODSPEC_FILE_PATH}")
if [[ -z "${PODSPEC_VERSION}" ]]; then
  echo "error: could not determine podspec version" >&2
  exit 1
fi

# check if the podspec is already in this repository
PODSPEC_DIRECTORY_FINAL_PATH="${SCRIPT_DIR}/../${PODSPEC_NAME}/${PODSPEC_VERSION}"
PODSPEC_FINAL_PATH="${PODSPEC_DIRECTORY_FINAL_PATH}/${PODSPEC_NAME}.podspec"
if [[ -f "${PODSPEC_FINAL_PATH}" ]]; then
  echo "error: podspec already exists at ${PODSPEC_FINAL_PATH}" >&2
  exit 1
fi

# add the podspec to the podspec repo
mkdir -p "${PODSPEC_DIRECTORY_FINAL_PATH}"
mv "${PODSPEC_FILE_PATH}" "${PODSPEC_DIRECTORY_FINAL_PATH}"