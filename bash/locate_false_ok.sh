#!/bin/bash
set -euo pipefail
REAL_PATH=$(realpath "$0")
W=$(dirname "${REAL_PATH}")

echo "${W}"

ls "${W}"/false_no_fail.sh
echo $?
