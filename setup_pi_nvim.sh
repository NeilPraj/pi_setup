#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== APT update ==="
sudo apt update

echo "=== Base packages (Neovim + build toolchain for Treesitter) ==="
sudo apt install -y \
  git curl ca-certificates unzip xz-utils \
  neovim \
  build-essential gcc g++ make cmake pkg-config \
  golang-go \
  zathura zathura-pdf-poppler \
  texlive-latex-extra texlive-latex-recommended texlive-fonts-recommended latexmk

# Optional but useful: keep this if you ever remote-compile stuff that expects python
# sudo apt install -y python3 python3-pip

echo
echo "=== Ensure ~/.local/bin exists and is on PATH (for lemonade + your tools) ==="
mkdir -p "$HOME/.local/bin"

# Ensure PATH is set for interactive bash sessions
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  echo "Added ~/.local/bin to PATH in ~/.bashrc"
fi

# Ensure PATH is set for *login shells* too (headless SSH commonly uses these)
if [ -f "$HOME/.profile" ] && ! grep -q '\.local/bin' "$HOME/.profile"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
  echo "Added ~/.local/bin to PATH in ~/.profile"
fi

# Make PATH effective for *this* script run too
export PATH="$HOME/.local/bin:$PATH"

echo
echo "=== Installing lemonade into ~/.local/bin ==="
if ! command -v lemonade >/dev/null 2>&1; then
  # Force the install location so PATH issues never bite you again
  GOBIN="$HOME/.local/bin" go install github.com/lemonade-command/lemonade@latest
fi

# Sanity check
if ! command -v lemonade >/dev/null 2>&1; then
  echo "ERROR: lemonade install failed or not on PATH." >&2
  echo "Try: source ~/.bashrc  (or log out/in) then: command -v lemonade" >&2
  exit 1
fi
echo "lemonade -> $(command -v lemonade)"

echo
echo "=== Install Neovim config ==="
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
echo "=== Bootstrap plugins headlessly (lazy + treesitter parsers) ==="
# Clear state/cache so a half-failed previous run doesn't poison next boot
rm -rf "$HOME/.cache/nvim" "$HOME/.local/state/nvim"

# Install/update plugins
nvim --headless "+Lazy! sync" +qa

# Compile/update treesitter parsers in a deterministic way
nvim --headless "+TSUpdateSync" +qa

echo
echo "=== Done ==="
echo "If you're in the same SSH session, run:  source ~/.bashrc"
echo "Then open nvim normally."
echo
echo "Reminder (lemonade over SSH):"
echo "  ssh -R 2489:localhost:2489 npi@<pi-ip>"
