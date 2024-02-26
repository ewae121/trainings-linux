#!/bin/bash
set -euo pipefail

echo toto
false | tee -a
echo toto2
