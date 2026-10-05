#!/usr/bin/env bash
#
# install.sh — Bootstrap dotfiles di mesin baru
# Pemakaian: ./install.sh [package...]
# Contoh:    ./install.sh              (semua package)
#            ./install.sh fish git     (hanya fish & git)
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%F-%H%M)"

# ---- Cek dependency ----
if ! command -v stow >/dev/null 2>&1; then
    echo "⚠️  GNU Stow tidak terinstall."
    if command -v pacman >/dev/null 2>&1; then
        echo "→ Install via pacman..."
        sudo pacman -S --noconfirm stow
    else
        echo "❌ Install stow manual dulu."
        exit 1
    fi
fi

cd "$DOTFILES_DIR"

# ---- Tentukan package ----
if [ $# -eq 0 ]; then
    PACKAGES=()
    for d in */; do
        d="${d%/}"
        [ "$d" = ".git" ] && continue
        [ -d "$d" ] && PACKAGES+=("$d")
    done
else
    PACKAGES=("$@")
fi

echo "📦 Dotfiles dir: $DOTFILES_DIR"
echo "📁 Packages:     ${PACKAGES[*]}"
echo ""

# ---- Backup konflik ----
mkdir -p "$BACKUP_DIR"
CONFLICT=0
for pkg in "${PACKAGES[@]}"; do
    [ -d "$pkg" ] || continue
    while IFS= read -r -d '' target; do
        rel="${target#$pkg/}"
        src="$HOME/$rel"
        if [ -e "$src" ] && [ ! -L "$src" ]; then
            echo "  ↳ konflik: ~/$rel"
            mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
            mv "$src" "$BACKUP_DIR/$rel"
            CONFLICT=$((CONFLICT + 1))
        fi
    done < <(find "$pkg" -type f -print0)
done

if [ $CONFLICT -gt 0 ]; then
    echo ""
    echo "💾 Backup lama → $BACKUP_DIR ($CONFLICT file)"
fi

# ---- Stow ----
echo ""
echo "🔗 Stowing..."
for pkg in "${PACKAGES[@]}"; do
    [ -d "$pkg" ] || continue
    stow -v "$pkg"
done

echo ""
echo "✅ Selesai!"
echo "   Kalau ada masalah, restore dari: $BACKUP_DIR"
