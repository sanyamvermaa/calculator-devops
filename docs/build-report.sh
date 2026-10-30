#!/usr/bin/env bash
# Regenerate docs/report.pdf from docs/report.html and assert it is exactly 3 pages.
# Run from the repository root:  ./docs/build-report.sh
set -euo pipefail
cd "$(dirname "$0")/.."

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || CHROME="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
[ -x "$CHROME" ] || { echo "No Chrome/Brave found — install one or export CHROME=..."; exit 1; }

echo "Rendering docs/report.html -> docs/report.pdf ..."
"$CHROME" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$PWD/docs/report.pdf" "file://$PWD/docs/report.html" >/dev/null 2>&1
sleep 1

PAGES=$(python3 -c '
import re, sys, zlib
d = open("docs/report.pdf","rb").read()
m = re.findall(rb"/Type\s*/Pages[^>]*?/Count\s+(\d+)", d)
if not m:
    for s in re.findall(rb"stream\r?\n(.*?)endstream", d, re.S):
        try: dec = zlib.decompress(s)
        except Exception: continue
        m += re.findall(rb"/Type\s*/Pages[^>]*?/Count\s+(\d+)", dec)
print(max(int(x) for x in m) if m else 0)
')

if [ "$PAGES" -eq 3 ]; then
  echo "OK — docs/report.pdf is exactly 3 pages."
else
  echo "FAIL — docs/report.pdf is $PAGES pages, must be 3."
  echo "Trim text in docs/report.html (or shrink .shot img height in the CSS) and re-run."
  exit 1
fi
