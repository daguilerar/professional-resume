#!/usr/bin/env bash
# build-resume.sh - generate PDF versions of the resume
# Usage:
#   ./build-resume.sh [en|es] [normal|compact]
#   ./build-resume.sh all [normal|compact]
#
# This script generates PDF using Chrome headless so that CSS styles,
# colors, and tables are handled consistently with the resume-style.css.

set -euo pipefail
cd "$(dirname "$0")"

lang=${1:-all}
mode=${2:-normal}

function render() {
  local in=$1
  local out=$2
  local html="${out%.pdf}.html"

  # Generate HTML from markdown with CSS and disable pandoc defaults
  pandoc "$in" -s -c resume-style.css -o "$html" \
    -A /dev/null

  # Use Chrome headless to print to PDF (respects CSS)
  /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
    --headless --disable-gpu \
    --print-to-pdf="$(pwd)/$out" \
    "file://$(pwd)/$html"

  echo "generated $out (chrome mode)"
}

function build_all() {
  render resume-en.md resume-en.pdf
  render resume-es.md resume-es.pdf
}

function usage() {
  cat <<EOF
Usage: $0 [en|es|all] [normal|compact]

Generates HTML+PDF versions of the resume.  By default both languages
are rendered in "normal" mode (regular font size).  Use "compact"
for slightly smaller text/spacing suitable to fit on one page.
EOF
}

if [[ "$lang" == "all" ]]; then
  build_all
elif [[ "$lang" == "en" ]]; then
  render resume-en.md resume-en.pdf
elif [[ "$lang" == "es" ]]; then
  render resume-es.md resume-es.pdf
else
  usage
  exit 1
fi
