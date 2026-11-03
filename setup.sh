#!/usr/bin/env bash
# Install everything needed to build the book (PDF) and the website locally.
#
#   ./setup.sh
#
# macOS: uses Homebrew (BasicTeX, LaTeXML, Node). Asks for your password once,
#        because the BasicTeX installer and tlmgr write to /usr/local/texlive.
# Ubuntu/Debian: uses apt, with the same packages as the CI build.
#
# Safe to run again: anything already installed is skipped.
set -euo pipefail

# Must match PAGEFIND in the Makefile.
PAGEFIND_VERSION=1.3.0

# TeX packages the book uses that BasicTeX may not include.
TEX_PACKAGES=(latexmk pgf geometry listings amscls amsfonts hyperref xcolor etoolbox
              changepage appendix emptypage titlesec biblatex biber enumitem
              mdframed zref needspace avantgar rsfs)  # last two lines: LegrandOrangeBook.cls

APT_PACKAGES=(make latexmk texlive-latex-base texlive-latex-recommended
              texlive-latex-extra texlive-pictures texlive-fonts-recommended
              texlive-bibtex-extra biber latexml nodejs npm)

step() { printf '\n==> %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

setup_macos() {
  if ! have brew; then
    echo "Homebrew is required: https://brew.sh" >&2
    exit 1
  fi

  step "TeX (BasicTeX)"
  if have pdflatex || [ -x /Library/TeX/texbin/pdflatex ]; then
    echo "already installed"
  else
    brew install --cask basictex
  fi
  # BasicTeX puts its binaries here; new terminals pick this up automatically.
  export PATH="/Library/TeX/texbin:$PATH"

  step "TeX packages (${TEX_PACKAGES[*]})"
  local missing=()
  for p in "${TEX_PACKAGES[@]}"; do
    tlmgr info --only-installed --data name "$p" 2>/dev/null | grep -qx "$p" || missing+=("$p")
  done
  if [ ${#missing[@]} -eq 0 ]; then
    echo "already installed"
  else
    sudo tlmgr update --self
    sudo tlmgr install "${missing[@]}"
  fi

  step "LaTeXML and Node"
  # formula:command pairs
  for pair in latexml:latexmlc node:node; do
    if have "${pair#*:}"; then
      echo "${pair%%:*}: already installed"
    else
      brew install "${pair%%:*}"
    fi
  done
}

setup_linux() {
  if ! have apt-get; then
    echo "Only macOS (Homebrew) and Ubuntu/Debian (apt) are supported." >&2
    echo "Install by hand: ${APT_PACKAGES[*]}" >&2
    exit 1
  fi
  step "TeX Live, LaTeXML and Node (apt)"
  local sudo=""; [ "$(id -u)" -ne 0 ] && sudo="sudo"
  $sudo apt-get update
  DEBIAN_FRONTEND=noninteractive $sudo apt-get install -y --no-install-recommends "${APT_PACKAGES[@]}"
}

case "$(uname -s)" in
  Darwin) setup_macos ;;
  Linux)  setup_linux ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

step "Pagefind (search index), fetched by npx"
if [ -d "$HOME/.npm" ] && [ -n "$(find "$HOME/.npm" -user 0 -print -quit 2>/dev/null)" ]; then
  echo "Note: ~/.npm contains root-owned files, so npx cannot use it."
  echo "      build.sh works around this; to fix it for good run:"
  echo "      sudo chown -R $(id -u):$(id -g) \"$HOME/.npm\""
  export npm_config_cache="${TMPDIR:-/tmp}/math-wiki-book-npm-cache"
fi
npx -y "pagefind@$PAGEFIND_VERSION" --version

step "Installed"
pdflatex --version | head -1
latexmk -v 2>/dev/null | grep -m1 Version
latexmlc --VERSION 2>&1 | head -1
echo "node $(node --version)"
printf '\nDone. Build with ./build.sh (or make pdf / make web).\n'
