#!/bin/bash
# verify_all.sh: fresh asset extraction, then the retail build with tools/build.js, verified against nhlpa93retail.sfc,
# then the extracted assets against the ROM and the comment layout check. Same wrapper as NHLPA93Genesis.
# Usage: tools/verify_all.sh [-q|--quiet]
# -q: print only failures and the final ALL MATCH / VERIFY FAILED line.
cd "$(dirname "$0")/.." || exit 1
quiet=0; case "$1" in -q|--quiet) quiet=1;; esac
fail=0
rm -rf Extracted output
# build.js prints the result of each step on an indented line under it: "   MATCH output/retail/nhlpa93snes.sfc == ...".
r=$(node tools/build.js retail)
last=$(echo "$r" | grep -E '^ +MATCH ')
case "$last" in
  *MATCH*) [ $quiet = 1 ] || echo "retail: ${last#"${last%%[! ]*}"}" ;;
  *) echo "retail: FAILED"; echo "$r"; fail=1 ;;
esac
if [ $fail = 0 ]; then
  node tools/extractAssets93s.js nhlpa93retail.sfc --check >/dev/null || { echo "assets: Extracted/ differs from the ROM"; fail=1; }
  python3 tools/check_comments.py | tail -1 | grep -q "comment layout OK" || { echo "comments: layout check failed"; python3 tools/check_comments.py | tail -5; fail=1; }
fi
if [ "$fail" = 1 ]; then
  echo "VERIFY FAILED"
  exit 1
fi
echo "ALL MATCH"
exit 0
