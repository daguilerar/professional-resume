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

file_name="David-Aguilera_Cloud-Devops-Engineer"  # base name for output PDF files; language suffix and -compact are added as needed
lang=${1:-all}
mode=${2:-normal}   # normal or compact; compact reduces font/margins to try to fit one page

# engine may be passed as third arg or via PDF_ENGINE environment variable
# if unspecified or set to "auto", try to pick a working engine in order:
# chrome -> wkhtmltopdf -> pandoc (requires TeX)
engine_arg=${3:-${PDF_ENGINE:-auto}}

function detect_engine() {
  if command -v "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" >/dev/null 2>&1 || command -v chromium >/dev/null 2>&1; then
    echo chrome
  elif command -v wkhtmltopdf >/dev/null 2>&1; then
    echo wkhtmltopdf
  elif command -v pandoc >/dev/null 2>&1; then
    echo pandoc
  else
    echo ""  # none found
  fi
}

if [[ "$engine_arg" == "auto" || -z "$engine_arg" ]]; then
  engine=$(detect_engine)
  if [[ -z "$engine" ]]; then
    echo "no PDF engine detected; please install chrome, wkhtmltopdf or pandoc" >&2
    exit 1
  fi
else
  engine="$engine_arg"
fi

function render() {
  local in=$1
  local base=$2
  # append mode suffix if compact
  local suffix=""
  if [[ "$mode" == "compact" ]]; then
    suffix="-compact"
  fi
  local out="${base%.pdf}${suffix}.pdf"
  local html="${out%.pdf}.html"

  # Generate HTML from markdown with CSS and disable pandoc defaults
  pandoc "$in" -s -c resume-style.css -o "$html" \
    -A /dev/null

  # if requested, add a compact stylesheet snippet directly into the HTML
  if [[ "$mode" == "compact" ]]; then
    # these rules mirror the print/compact media rules but apply always
    sed -i '' '/<\/head>/i\
<style>body{font-size:9pt;line-height:1.25;}h1{font-size:18pt;margin-bottom:0.15rem;}h2{margin-top:0.5rem;margin-bottom:0.15rem;font-size:10.5pt;}h3{margin:0.1rem 0;font-size:9.5pt;}p,li{margin:0.2rem 0;}</style>' "$html"
  fi

  case "$engine" in
    chrome)
      # Use Chrome/Chromium headless to print to PDF (default)
      /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
        --headless --disable-gpu \
        --print-to-pdf="$(pwd)/$out" \
        --print-to-pdf-no-header \
        "file://$(pwd)/$html"
      ;;
    pandoc)
      # let pandoc produce PDF directly via LaTeX; requires TeX installation
      pandoc "$html" -o "$out"
      ;;
    wkhtmltopdf)
      # requires wkhtmltopdf in PATH
      wkhtmltopdf \
        --enable-local-file-access \
        "file://$(pwd)/$html" \
        "$out"
      ;;
    *)
      echo "unknown engine '$engine'" >&2
      exit 1
      ;;
  esac

  echo "generated $out (chrome mode)"
}

function build_all() {
  render resume-en.md $file_name-en.pdf
  render resume-es.md $file_name-es.pdf
}

function usage() {
  cat <<EOF
Usage: $0 [en|es|all] [normal|compact] [engine]

Generates HTML+PDF versions of the resume.  By default both languages
are rendered in "normal" mode (regular font size).  Use "compact"
for slightly smaller text/spacing suitable to fit on one page.

The third argument selects the PDF engine; supported values are
"chrome", "pandoc" (requires a TeX distribution), "wkhtmltopdf" or
"auto".  "auto" (the default) will try to find an available engine in
this order: chrome → wkhtmltopdf → pandoc.  You can also set the
PDF_ENGINE environment variable instead of passing the argument.

The output PDF file names will include a "-compact" suffix when the
compact mode is chosen (e.g. resume-en-compact.pdf).  Normal mode leaves
names unchanged.
EOF
}

if [[ "$lang" == "all" ]]; then
  build_all
elif [[ "$lang" == "en" ]]; then
  render resume-en.md $file_name-en.pdf
elif [[ "$lang" == "es" ]]; then
  render resume-es.md $file_name-es.pdf
else
  usage
  exit 1
fi

# note: the "mode" variable is global; pass "compact" to the script to
# activate the smaller-font/margin override that may help everything fit
# on a single page.  There is no automatic detection – if the output still
# spills over, you can further tweak the CSS or shorten the content.
