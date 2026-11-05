#!/usr/bin/env bash
# ==============================================================================
# vscodium-code-bin updater
# Checks for the latest VSCodium release, updates PKGBUILD & .SRCINFO,
# and builds/installs the new package with makepkg.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> Checking latest VSCodium release..."
LATEST_VER=$(curl -s https://api.github.com/repos/VSCodium/vscodium/releases/latest | grep '"tag_name":' | head -n1 | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_VER" ]; then
    echo "Error: Could not retrieve latest version from GitHub API."
    exit 1
fi

CURRENT_VER=$(grep '^pkgver=' PKGBUILD | head -n1 | cut -d= -f2)

echo "    Current version : $CURRENT_VER"
echo "    Latest version  : $LATEST_VER"

if [ "$CURRENT_VER" = "$LATEST_VER" ]; then
    echo "==> Package is already up to date ($CURRENT_VER)."
    read -p "Do you want to force rebuild/reinstall anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
else
    echo "==> Updating version to $LATEST_VER..."
    sed -i "s/^pkgver=.*/pkgver=$LATEST_VER/" PKGBUILD
    sed -i "s/^pkgrel=.*/pkgrel=1/" PKGBUILD

    echo "==> Fetching new release SHA256 checksum..."
    SHA_URL="https://github.com/VSCodium/vscodium/releases/download/${LATEST_VER}/VSCodium-linux-x64-${LATEST_VER}.tar.gz.sha256"
    NEW_SHA=$(curl -sL "$SHA_URL" | head -n1 | awk '{print $1}')

    if [ -n "$NEW_SHA" ] && [ "${#NEW_SHA}" -eq 64 ]; then
        echo "    New SHA256: $NEW_SHA"
        python3 -c "
import re
with open('PKGBUILD') as f:
    c = f.read()
c = re.sub(r\"sha256sums=\(\s*'[a-f0-9]{64}'\", f\"sha256sums=(\n    '$NEW_SHA'\", c, count=1)
with open('PKGBUILD', 'w') as f:
    f.write(c)
"
    else
        echo "    Falling back to updpkgsums..."
        updpkgsums
    fi

    echo "==> Updating .SRCINFO..."
    makepkg --printsrcinfo > .SRCINFO
fi

echo "==> Building and installing updated package..."
makepkg -sif
