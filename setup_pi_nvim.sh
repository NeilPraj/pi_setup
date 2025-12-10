#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== APT update & base package install ==="
sudo apt update
sudo apt install -y \
  neovim golang-go git \
  zathura zathura-pdf-poppler \
  texlive-latex-extra texlive-latex-recommended texlive-fonts-recommended latexmk

echo
echo "=== Installing lemonade ==="
if ! command -v lemonade >/dev/null 2>&1; then
    go install github.com/lemonade-command/lemonade@latest
else
    echo "lemonade already installed."
fi

echo
echo "=== Ensuring ~/go/bin is on PATH ==="
if ! grep -q 'HOME/go/bin' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/go/bin:$PATH"' >> "$HOME/.bashrc"
    echo "Added PATH export to ~/.bashrc"
else
    echo "PATH already configured."
fi

echo
echo "=== Installing Neovim config ==="

NVIM_DIR="$HOME/.config/nvim"
if [ -d "$NVIM_DIR" ]; then
    BACKUP="$HOME/.config/nvim_backup_$(date +%Y%m%d_%H%M%S)"
    mv "$NVIM_DIR" "$BACKUP"
    echo "Backed up old nvim config to: $BACKUP"
fi

mkdir -p "$NVIM_DIR"
cp "$SCRIPT_DIR/init.lua" "$NVIM_DIR/init.lua"
echo "Copied init.lua into $NVIM_DIR"

echo
echo "=== Setup complete ==="
echo "Run:  source ~/.bashrc"
echo "Start Neovim once to install all plugins."
echo
echo "Remember to SSH with:"
echo "    ssh -R 2489:localhost:2489 npi@<pi-ip>"

