#!/usr/bin/env bash
set -euo pipefail
module_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 "$module_root/Scripts/check_structure.py"
swift package --package-path "$module_root" dump-package >/dev/null
