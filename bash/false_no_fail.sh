#!/bin/bash
#set -euo pipefail
set -e

echo toto
false | tee -a
echo toto2
