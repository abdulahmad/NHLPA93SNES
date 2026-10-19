#!/bin/sh
# Full check, as 93G tools/verify_all.sh: extract the assets (tools/prebuild.py), assemble, compare with the retail image, check comments.
cd "$(dirname "$0")/.."
./build.sh || exit 1
python3 tools/extract.py lst/nhlpa93snes.bin --check || exit 1
python3 tools/check_comments.py || exit 1
