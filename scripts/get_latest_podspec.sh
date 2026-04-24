#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  SCRIPT_NAME=$(basename "$0")
  echo "Usage: ${SCRIPT_NAME} <pod_name>"
  echo
  echo "Arguments:"
  echo "  pod_name: the name of the pod to get the podspec for"
  echo
  echo "Example:"
  echo "  ${SCRIPT_NAME} IronSourceVoodooAdapter"
  exit 1
fi

POD_NAME=$1

pod repo add-cdn trunk https://cdn.cocoapods.org/ >&2

PODSPEC_PATH=$(pod spec which ${POD_NAME})
cat ${PODSPEC_PATH}
