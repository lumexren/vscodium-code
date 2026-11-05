#!/usr/bin/env bash
# ==============================================================================
# vscodium-to-vscode uninstaller
# Restores stock VSCodium files, icons, and desktop entries.
# ==============================================================================

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires root privileges to restore system files."
    echo "Please run: sudo $0"
    exit 1
fi

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

echo "==> Uninstalling vscodium-to-vscode for user: $TARGET_USER..."

# 1. Remove wrappers
rm -f /usr/local/bin/code
rm -f /usr/local/bin/codium

# 2. Restore Electron internal window icon
VSC_LINUX_RES="/usr/share/vscodium/resources/app/resources/linux"
if [ -f "$VSC_LINUX_RES/code.png.bak" ]; then
    mv -f "$VSC_LINUX_RES/code.png.bak" "$VSC_LINUX_RES/code.png"
fi

# 3. Restore /usr/share/pixmaps
if [ -f /usr/share/pixmaps/vscodium.png.bak ]; then
    mv -f /usr/share/pixmaps/vscodium.png.bak /usr/share/pixmaps/vscodium.png
fi
rm -f /usr/share/pixmaps/code.png /usr/share/pixmaps/vscode.png

# 4. Restore hicolor
HICOLOR_DIR="/usr/share/icons/hicolor/scalable/apps"
if [ -f "$HICOLOR_DIR/vscodium.svg.bak" ]; then
    mv -f "$HICOLOR_DIR/vscodium.svg.bak" "$HICOLOR_DIR/vscodium.svg"
fi
rm -f "$HICOLOR_DIR/codium.svg" "$HICOLOR_DIR/vscode.svg"

# 5. Restore Papirus icons
if [ -d "/usr/share/icons/Papirus" ]; then
    for dir in /usr/share/icons/Papirus/*/apps; do
        if [ ! -L "$dir" ] && [ -d "$dir" ] && [ -f "$dir/vscodium.svg.bak" ]; then
            (
                cd "$dir"
                mv -f "vscodium.svg.bak" "vscodium.svg"
                ln -sf "vscodium.svg" "com.vscodium.codium.svg"
            )
        fi
    done
fi

# 6. Restore package.json
PKG_JSON="/usr/share/vscodium/resources/app/package.json"
if [ -f "$PKG_JSON.bak" ]; then
    mv -f "$PKG_JSON.bak" "$PKG_JSON"
fi

# 7. Restore system desktop files
for f in /usr/share/applications/vscodium.desktop /usr/share/applications/vscodium-wayland.desktop; do
    if [ -f "$f.bak" ]; then
        mv -f "$f.bak" "$f"
    fi
done

# 8. Remove user desktop files
USER_APPS_DIR="$TARGET_HOME/.local/share/applications"
rm -f "$USER_APPS_DIR/code.desktop"
rm -f "$USER_APPS_DIR/codium.desktop"
rm -f "$USER_APPS_DIR/vscodium.desktop"
rm -f "$USER_APPS_DIR/vscodium-wayland.desktop"
rm -f "$USER_APPS_DIR/vscodium-uri-handler.desktop"

# 9. Clean up mimeapps.list
MIMEAPPS="$TARGET_HOME/.config/mimeapps.list"
if [ -f "$MIMEAPPS" ]; then
    sed -i '/vscodium\.desktop/d' "$MIMEAPPS"
    sed -i '/vscodium-wayland\.desktop/d' "$MIMEAPPS"
fi

# 10. Refresh caches
gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
gtk-update-icon-cache -q /usr/share/icons/Papirus 2>/dev/null || true

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$USER_APPS_DIR" 2>/dev/null || true
    update-desktop-database /usr/share/applications 2>/dev/null || true
fi

if [ -n "$TARGET_USER" ] && command -v kbuildsycoca6 >/dev/null 2>&1; then
    su - "$TARGET_USER" -c "kbuildsycoca6 2>/dev/null" || true
fi

echo "===================================================================="
echo " Uninstallation completed! Stock VSCodium settings restored."
echo "===================================================================="
