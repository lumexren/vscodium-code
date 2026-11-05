# VSCodium to VSCode (Linux & Wayland Desktop Integration)

This repository transforms **VSCodium** on Linux (especially with KDE Plasma / GNOME on Wayland or X11) into a clean, seamless **VS Code** desktop experience.

It fixes the notorious Linux window manager issue where launching customized `code.desktop` entries still displays the VSCodium logo in docks, taskbars, and window switchers instead of the VS Code icon.

---

## 🌟 What This Does

1. **Custom Wrapper (`/usr/local/bin/codium` & `/usr/local/bin/code`)**:
   - Supports reading custom Electron flags from `~/.config/code-flags.conf` and `~/.config/codium-flags.conf`.
   - Properly forwards Wayland, GPU acceleration, and Ozone flags to the Electron process.
   - Provides `/usr/local/bin/code` command in the terminal.

2. **Accurate Window Matching & Desktop Entries**:
   - Creates `code.desktop` (named **Code**, with VS Code icon).
   - Generates matching `codium.desktop` and `vscodium.desktop` entries with `StartupWMClass=codium` so KWin and GNOME Shell reliably attach running windows to the VS Code icon instead of falling back to VSCodium branding.
   - Hides duplicate stock entries with `NoDisplay=true`.

3. **Complete Icon Theming**:
   - Updates Electron's internal window icon (`resources/linux/code.png`).
   - Updates `/usr/share/pixmaps/`.
   - Links scalable hicolor and Papirus icon themes so any fallback queries for `vscodium` or `codium` always resolve to the VS Code logo.

---

## 🚀 Installation

Clone this repository and run the installer with root privileges:

```bash
git clone https://github.com/<your-username>/vscodium-to-vscode.git
cd vscodium-to-vscode
sudo ./install.sh
```

---

## 🧹 Uninstallation

To revert all changes and restore original stock VSCodium branding and files:

```bash
sudo ./uninstall.sh
```

---

## 📂 Project Structure

```
├── bin/
│   └── codium              # Wrapper script with flag-loading support
├── desktop/
│   ├── code.desktop        # Main user desktop entry
│   ├── codium.desktop      # WM matching desktop entry
│   ├── vscodium.desktop    # Overriding stock desktop entry
│   ├── vscodium-uri-handler.desktop
│   └── vscodium-wayland.desktop
├── icons/
│   ├── vscode.svg          # Official VS Code SVG vector logo
│   └── vscode_1024.png     # 1024x1024 high-res PNG logo
├── install.sh              # One-command installer
├── uninstall.sh            # Safe uninstaller with backup restoration
└── README.md
```

---

## 📝 License

MIT
