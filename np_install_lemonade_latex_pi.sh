#!/usr/bin/env bash
set -euo pipefail

echo "=== Updating system ==="
sudo apt update

echo "=== Installing Go (required for lemonade) ==="
sudo apt install -y golang-go

echo "=== Installing LaTeX toolchain ==="
# Minimal but practical LaTeX setup for labs / reports
sudo apt install -y \
  latexmk \
  texlive-latex-base \
  texlive-latex-recommended \
  texlive-latex-extra \
  texlive-fonts-recommended

echo "=== Installing lemonade ==="
export PATH="$HOME/go/bin:$PATH"

go install github.com/lemonade-command/lemonade@latest

echo "=== Ensuring Go bin is on PATH ==="
if ! grep -q 'export PATH="$HOME/go/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/go/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo
echo "=== Verification ==="

if command -v lemonade >/dev/null 2>&1; then
  echo "lemonade OK: $(lemonade --version || echo installed)"
else
  echo "ERROR: lemonade not found on PATH"
  exit 1
fi

if command -v latexmk >/dev/null 2>&1; then
  echo "latexmk OK"
else
  echo "ERROR: latexmk not found"
  exit 1
fi

echo
echo "Install complete."
echo "Remember to run: source ~/.bashrc"
