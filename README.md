# VSCodium to VSCode (Linux & Wayland Desktop Integration)

This repository transforms **VSCodium** on Linux into a clean, seamless **VS Code** desktop experience.

It can be installed either directly as an **Arch Linux / Pacman replacement package** (`makepkg -si`) or via the standalone **`install.sh`** script.

---

## 🌟 Key Features

1. **Pacman Drop-in Replacement (`vscodium-code-bin`)**:
   - `provides=('vscode' 'codium' 'vscodium' 'vscodium-bin' 'visual-studio-code-bin')`
   - `conflicts=('vscodium' 'vscodium-bin' 'codium')`
   - `replaces=('vscodium')`
   - Replaces stock `vscodium` packages cleanly without breaking dependencies (such as `vscodium-marketplace`).
   - Managed 100% by pacman: no manual `/usr/local` files or orphaned entries.

2. **Custom Flags Wrapper (`/usr/bin/codium`, `/usr/bin/code`)**:
   - Properly loads Electron/Chromium flags from `~/.config/code-flags.conf` and `~/.config/codium-flags.conf`.
   - Supports Wayland (`--ozone-platform=wayland`), VAAPI hardware acceleration, and custom Electron parameters.

3. **No Clutter in Menus or "Open With..."**:
   - Only a single **Code** desktop entry is registered for file associations.
   - Eliminates duplicate entries ("VSCodium - Wayland", multiple "Code" listings) in Dolphin and file managers.

4. **Complete VS Code Icon Theming**:
   - Patches internal Electron window icon (`resources/linux/code.png`).
   - Installs high-resolution SVG and PNG icons across `hicolor` and pixmaps.
   - Sets Wayland `desktopName` and `StartupWMClass` to ensure docks, taskbars, and Alt+Tab switchers display the VS Code logo.

---

## 🚀 Installation

### Option 1: Arch Linux Pacman Package (Recommended)

Build and install directly with pacman / makepkg:

```bash
git clone https://github.com/<your-username>/vscodium-to-vscode.git
cd vscodium-to-vscode
makepkg -si
```

Pacman will prompt to replace `vscodium` and install `vscodium-code-bin`.

### Option 2: Standalone Script (All Distributions)

If you already have VSCodium installed and just want to apply the customizations on top:

```bash
git clone https://github.com/<your-username>/vscodium-to-vscode.git
cd vscodium-to-vscode
sudo ./install.sh
```

To revert:

```bash
sudo ./uninstall.sh
```

---

## 📂 Project Structure

```
├── PKGBUILD                    # Arch Linux package recipe (replaces vscodium)
├── .SRCINFO                    # Generated package metadata for AUR
├── vscodium-code-bin.install   # Post-install icon & desktop cache triggers
├── codium                      # Custom flags-aware wrapper
├── code.desktop                # Main desktop entry
├── code-url-handler.desktop    # URI handler desktop entry
├── vscode.svg                  # Official VS Code vector logo
├── vscode_1024.png             # High-res 1024x1024 icon
├── install.sh                  # Standalone installer
├── uninstall.sh                # Standalone uninstaller
└── README.md
```

---

## 📝 License

MIT
