#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

usage() {
  echo "Usage: ${SCRIPT_NAME} <pod_name>" >&2
  echo "  pod_name: the name of the pod to get the podspec for" >&2
  echo "Example:"
  echo "  ${SCRIPT_NAME} IronSourceVoodooAdapter"
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

POD_NAME=$1

pod repo update >&2
cat "$(pod spec which ${POD_NAME})"
