#!/usr/bin/env bash
set -euo pipefail

DEFAULT_IRONSOURCE_SDK_VERSION="9.3.0.0"

if [[ $# -lt 2 ]]; then
  SCRIPT_NAME=$(basename "$0")
  echo "Usage: ${SCRIPT_NAME} <path_to_podspec_source> <pod_name> <ironsource_sdk_version=${DEFAULT_IRONSOURCE_SDK_VERSION}>"
  echo
  echo "Arguments:"
  echo "  path_to_podspec_source: the original json podspec source file"
  echo "  pod_name: the name of the pod to generate the podspec for"
  echo "  ironsource_sdk_version: the version of the IronSourceSDK to use (optional)"
  echo
  echo "Example:"
  echo "  ${SCRIPT_NAME} IronSourceVoodooAdapter.podspec VoodooIronSourceAdapter"
  exit 1
fi

ORIGINAL_PODSPEC_FILE_PATH=$1
POD_NAME=$2
IRONSOURCE_SDK_VERSION="${3:-$DEFAULT_IRONSOURCE_SDK_VERSION}"

# jq is required to parse the original podspec file
if ! command -v jq >/dev/null 2>&1; then
  echo "❌ Error: jq is required" >&2
  exit 1
fi

# check if the original podspec file exists
if [[ ! -f "${ORIGINAL_PODSPEC_FILE_PATH}" ]]; then
  echo "❌ Error: not a file: ${ORIGINAL_PODSPEC_FILE_PATH}" >&2
  exit 1
fi

# get the VoodooAdn dependency from the original podspec file
VOODOOADN_DEPENDENCY=$(jq -r '((.dependencies // {}).VoodooAdn // []) | if length > 0 then .[0] else empty end' "${ORIGINAL_PODSPEC_FILE_PATH}")
if [[ -z "${VOODOOADN_DEPENDENCY}" ]]; then
  echo "❌ Error: VoodooAdn dependency missing in JSON podspec file: ${ORIGINAL_PODSPEC_FILE_PATH}" >&2
  exit 1
fi
ADN_SDK_VERSION=$(printf '%s' "${VOODOOADN_DEPENDENCY}" | sed -E 's/^[~=><]+[[:space:]]*//')
if [[ -z "${ADN_SDK_VERSION}" ]]; then
  echo "❌ Error: could not determine ADN SDK min version" >&2
  exit 1
fi

ver=$(jq -r '.version | @json' "${ORIGINAL_PODSPEC_FILE_PATH}")
summary=$(jq -r '.summary | @json' "${ORIGINAL_PODSPEC_FILE_PATH}")
description=$(jq -r '.description | @json' "${ORIGINAL_PODSPEC_FILE_PATH}")
homepage=$(jq -r '(.homepage // "http://www.is.com/") | @json' "${ORIGINAL_PODSPEC_FILE_PATH}")
lic_type=$(jq -r '(.license.type // "Commercial") | @json' "${ORIGINAL_PODSPEC_FILE_PATH}")
lic_text=$(jq -r '(.license.text // "") | @json' "${ORIGINAL_PODSPEC_FILE_PATH}")
platform_ios=$(jq -r '((.platforms.ios) // "14.0") | @json' "${ORIGINAL_PODSPEC_FILE_PATH}")
source_files=$(jq -r '.source_files | @json' "${ORIGINAL_PODSPEC_FILE_PATH}")
swift_versions=$(jq -r '(.swift_versions // .swift_version // "5.0") | @json' "${ORIGINAL_PODSPEC_FILE_PATH}")

authors_block=$(
  jq -r '
    ((.authors // {"IronSource": "http://www.is.com/contact/"})
    | to_entries
    | map("    " + (.key | @json) + " => " + (.value | @json))
    | join(",\n"))
  ' "${ORIGINAL_PODSPEC_FILE_PATH}"
)

source_block=$(
  jq -r '.source | to_entries | map("    :\(.key) => \(.value | @json)") | join(",\n")' "${ORIGINAL_PODSPEC_FILE_PATH}"
)

echo "Pod::Spec.new do |s|"
echo "  s.name = \"${POD_NAME}\""
echo "  s.version = ${ver}"
echo "  s.summary = ${summary}"
echo "  s.description = ${description}"
echo "  s.homepage = ${homepage}"
echo "  s.license = { :type => ${lic_type}, :text => ${lic_text} }"
echo "  s.author = {"
echo "${authors_block}"
echo "  }"
echo "  s.source = {"
echo "${source_block}"
echo "  }"
echo "  s.platform = [:ios, ${platform_ios}]"
echo "  s.swift_versions = ${swift_versions}"
echo
echo "  s.source_files = ${source_files}"

if jq -e 'has("public_header_files") and (.public_header_files | type) != "null"' "${ORIGINAL_PODSPEC_FILE_PATH}" >/dev/null 2>&1; then
  phf=$(jq -r '.public_header_files | @json' "${ORIGINAL_PODSPEC_FILE_PATH}")
  echo "  s.public_header_files = ${phf}"
fi
if jq -e 'has("preserve_paths") and (.preserve_paths | type) != "null"' "${ORIGINAL_PODSPEC_FILE_PATH}" >/dev/null 2>&1; then
  pp=$(jq -r '.preserve_paths | @json' "${ORIGINAL_PODSPEC_FILE_PATH}")
  echo "  s.preserve_paths = ${pp}"
fi
if jq -e 'has("vendored_frameworks") and (.vendored_frameworks | type) != "null"' "${ORIGINAL_PODSPEC_FILE_PATH}" >/dev/null 2>&1; then
  vf=$(jq -r '.vendored_frameworks | @json' "${ORIGINAL_PODSPEC_FILE_PATH}")
  echo "  s.vendored_frameworks = ${vf}"
fi

if jq -e '(.pod_target_xcconfig // {}) | length > 0' "${ORIGINAL_PODSPEC_FILE_PATH}" >/dev/null 2>&1; then
  echo
  echo "  s.pod_target_xcconfig = {"
  jq -r '.pod_target_xcconfig | to_entries | map("    \(.key | @json) => \(.value | @json)") | join(",\n")' "${ORIGINAL_PODSPEC_FILE_PATH}"
  echo "  }"
fi

echo
echo "  s.dependency 'IronSourceSDK', '= ${IRONSOURCE_SDK_VERSION}'"
echo "  s.dependency 'VoodooAdn', '>= ${ADN_SDK_VERSION}'"
echo "end"
