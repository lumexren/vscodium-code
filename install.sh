#!/usr/bin/env bash
# ==============================================================================
# vscodium-to-vscode installer
# Replaces VSCodium branding & desktop files with VS Code branding & wrapper.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure script is run with root/sudo privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires root privileges to update system icons and wrappers."
    echo "Please run: sudo $0"
    exit 1
fi

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

echo "==> Installing vscodium-to-vscode for user: $TARGET_USER ($TARGET_HOME)"

# ------------------------------------------------------------------------------
# 1. Install wrapper script and symlink
# ------------------------------------------------------------------------------
echo "==> Installing /usr/local/bin/codium wrapper..."
install -m 755 "$SCRIPT_DIR/bin/codium" /usr/local/bin/codium
ln -sf /usr/local/bin/codium /usr/local/bin/code

# ------------------------------------------------------------------------------
# 2. Update Electron internal window icon
# ------------------------------------------------------------------------------
VSC_LINUX_RES="/usr/share/vscodium/resources/app/resources/linux"
if [ -d "$VSC_LINUX_RES" ]; then
    echo "==> Updating Electron internal window icon..."
    if [ ! -f "$VSC_LINUX_RES/code.png.bak" ] && [ -f "$VSC_LINUX_RES/code.png" ]; then
        cp -a "$VSC_LINUX_RES/code.png" "$VSC_LINUX_RES/code.png.bak"
    fi
    cp "$SCRIPT_DIR/icons/vscode_1024.png" "$VSC_LINUX_RES/code.png"
fi

# ------------------------------------------------------------------------------
# 3. Update /usr/share/pixmaps
# ------------------------------------------------------------------------------
echo "==> Updating /usr/share/pixmaps icons..."
mkdir -p /usr/share/pixmaps
if [ ! -f /usr/share/pixmaps/vscodium.png.bak ] && [ -f /usr/share/pixmaps/vscodium.png ]; then
    cp -a /usr/share/pixmaps/vscodium.png /usr/share/pixmaps/vscodium.png.bak
fi
cp "$SCRIPT_DIR/icons/vscode_1024.png" /usr/share/pixmaps/vscodium.png
cp "$SCRIPT_DIR/icons/vscode_1024.png" /usr/share/pixmaps/code.png
cp "$SCRIPT_DIR/icons/vscode_1024.png" /usr/share/pixmaps/vscode.png

# ------------------------------------------------------------------------------
# 4. Update hicolor icon theme
# ------------------------------------------------------------------------------
echo "==> Updating hicolor scalable icons..."
HICOLOR_DIR="/usr/share/icons/hicolor/scalable/apps"
mkdir -p "$HICOLOR_DIR"
if [ ! -f "$HICOLOR_DIR/vscodium.svg.bak" ] && [ -f "$HICOLOR_DIR/vscodium.svg" ]; then
    cp -a "$HICOLOR_DIR/vscodium.svg" "$HICOLOR_DIR/vscodium.svg.bak"
fi
cp "$SCRIPT_DIR/icons/vscode.svg" "$HICOLOR_DIR/vscode.svg"
cp "$SCRIPT_DIR/icons/vscode.svg" "$HICOLOR_DIR/vscodium.svg"
cp "$SCRIPT_DIR/icons/vscode.svg" "$HICOLOR_DIR/codium.svg"

# ------------------------------------------------------------------------------
# 5. Update Papirus icon theme (if installed)
# ------------------------------------------------------------------------------
if [ -d "/usr/share/icons/Papirus" ]; then
    echo "==> Updating Papirus icons to match VS Code..."
    for dir in /usr/share/icons/Papirus/*/apps; do
        if [ ! -L "$dir" ] && [ -d "$dir" ] && [ -f "$dir/vscode.svg" ]; then
            (
                cd "$dir"
                if [ ! -f "vscodium.svg.bak" ] && [ -f "vscodium.svg" ] && [ ! -L "vscodium.svg" ]; then
                    cp -a "vscodium.svg" "vscodium.svg.bak"
                fi
                ln -sf "vscode.svg" "vscodium.svg"
                ln -sf "vscode.svg" "com.vscodium.codium.svg"
            )
        fi
    done
fi

# ------------------------------------------------------------------------------
# 6. Patch package.json desktopName
# ------------------------------------------------------------------------------
PKG_JSON="/usr/share/vscodium/resources/app/package.json"
if [ -f "$PKG_JSON" ]; then
    echo "==> Patching VSCodium package.json desktopName to code.desktop..."
    if [ ! -f "$PKG_JSON.bak" ]; then
        cp -a "$PKG_JSON" "$PKG_JSON.bak"
    fi
    sed -i 's/"desktopName": "codium.desktop"/"desktopName": "code.desktop"/' "$PKG_JSON"
fi

# ------------------------------------------------------------------------------
# 7. Hide system-level stock VSCodium desktop files from menus & 'Open With'
# ------------------------------------------------------------------------------
echo "==> Hiding stock VSCodium entries from /usr/share/applications..."
for f in /usr/share/applications/vscodium.desktop /usr/share/applications/vscodium-wayland.desktop; do
    if [ -f "$f" ]; then
        if [ ! -f "$f.bak" ]; then
            cp -a "$f" "$f.bak"
        fi
        sed -i '/^MimeType=/d' "$f"
        if ! grep -q "^NoDisplay=" "$f"; then
            sed -i '/^\[Desktop Entry\]/a NoDisplay=true' "$f"
        else
            sed -i 's/^NoDisplay=.*/NoDisplay=true/' "$f"
        fi
    fi
done

# ------------------------------------------------------------------------------
# 8. Install user desktop entries
# ------------------------------------------------------------------------------
USER_APPS_DIR="$TARGET_HOME/.local/share/applications"
echo "==> Installing desktop files to $USER_APPS_DIR..."
mkdir -p "$USER_APPS_DIR"

for desktop_file in "$SCRIPT_DIR/desktop/"*.desktop; do
    fname=$(basename "$desktop_file")
    install -m 644 "$desktop_file" "$USER_APPS_DIR/$fname"
done

# Ensure correct file ownership for the user
chown -R "$TARGET_USER:$TARGET_USER" "$USER_APPS_DIR" 2>/dev/null || true

# ------------------------------------------------------------------------------
# 9. Clean up mimeapps.list to remove unwanted associations
# ------------------------------------------------------------------------------
MIMEAPPS="$TARGET_HOME/.config/mimeapps.list"
if [ -f "$MIMEAPPS" ]; then
    echo "==> Updating [Removed Associations] in mimeapps.list..."
    if ! grep -q "\[Removed Associations\]" "$MIMEAPPS"; then
        printf "\n[Removed Associations]\ninode/directory=vscodium.desktop;vscodium-wayland.desktop;codium.desktop;\ntext/plain=vscodium.desktop;vscodium-wayland.desktop;codium.desktop;\n" >> "$MIMEAPPS"
    else
        if ! grep -q "inode/directory=.*vscodium\.desktop" "$MIMEAPPS"; then
            sed -i '/\[Removed Associations\]/a inode/directory=vscodium.desktop;vscodium-wayland.desktop;codium.desktop;\ntext/plain=vscodium.desktop;vscodium-wayland.desktop;codium.desktop;' "$MIMEAPPS"
        fi
    fi
    chown "$TARGET_USER:$TARGET_USER" "$MIMEAPPS" 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# 10. Refresh desktop and icon databases
# ------------------------------------------------------------------------------
echo "==> Refreshing icon and desktop databases..."
gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
gtk-update-icon-cache -q /usr/share/icons/Papirus 2>/dev/null || true

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$USER_APPS_DIR" 2>/dev/null || true
    update-desktop-database /usr/share/applications 2>/dev/null || true
fi

# If KDE is running, update sycoca
if [ -n "$TARGET_USER" ] && command -v kbuildsycoca6 >/dev/null 2>&1; then
    su - "$TARGET_USER" -c "kbuildsycoca6 2>/dev/null" || true
fi

echo "===================================================================="
echo " Installation completed successfully!"
echo " VSCodium now uses VS Code naming, icons, and custom wrapper."
echo " Duplicate Open-With entries have been eliminated."
echo "===================================================================="
