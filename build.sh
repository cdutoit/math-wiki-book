#!/usr/bin/env bash
# Build the book and/or the website. A thin wrapper around the Makefile that
# also sorts out PATH and the npm cache, so it works from any terminal.
#
#   ./build.sh                 PDF + website (same as CI)    -> build/web/
#   ./build.sh pdf             PDF only                      -> build/pdf/main.pdf
#   ./build.sh web             website only                  -> build/web/index.html
#   ./build.sh chapter <path>  one chapter as a PDF          -> build/pdf/chapter.pdf
#                              e.g. chapters/physics/time-dilation
#   ./build.sh serve           build everything, then preview at http://localhost:8000
#   ./build.sh clean           delete build/
set -euo pipefail
cd "$(dirname "$0")"

# BasicTeX on macOS installs here; terminals opened before setup.sh lack it.
[ -d /Library/TeX/texbin ] && export PATH="/Library/TeX/texbin:$PATH"

# npx fails if ~/.npm has root-owned files (an old npm bug); use a private cache.
if [ -d "$HOME/.npm" ] && [ -n "$(find "$HOME/.npm" -user 0 -print -quit 2>/dev/null)" ]; then
  export npm_config_cache="${TMPDIR:-/tmp}/math-wiki-book-npm-cache"
fi

for tool in latexmk latexmlc npx; do
  command -v "$tool" >/dev/null || { echo "Missing $tool: run ./setup.sh first." >&2; exit 1; }
done

target="${1:-site}"
case "$target" in
  site|pdf|web|clean) make "$target" ;;
  chapter)
    [ -n "${2:-}" ] || { echo "usage: ./build.sh chapter chapters/<part>/<chapter>" >&2; exit 1; }
    make chapter CH="${2%.tex}" ;;
  serve) make site && make serve ;;
  *) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
