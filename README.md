# vscodium-code

VSCodium packaged as a clean drop-in replacement with official VS Code branding, Wayland flags support, and proper desktop integration.

Available on the AUR as [`vscodium-code-bin`](https://aur.archlinux.org/packages/vscodium-code-bin).

---

## Why?

Why not?

---

## Installation

### AUR (Recommended)

```bash
yay -S vscodium-code-bin
# or
paru -S vscodium-code-bin
```

Pacman will prompt to replace `vscodium` with `vscodium-code-bin`.

### From Git

```bash
git clone https://github.com/lumexren/vscodium-code.git
cd vscodium-code
makepkg -si
```

*(Non-Arch distributions can run `./install.sh` as root to apply the wrapper, desktop files, and icons on top of an existing VSCodium install.)*

---

## Custom Flags

Place your flags in `~/.config/code-flags.conf` or `~/.config/codium-flags.conf` (one flag per line).

Example `~/.config/code-flags.conf`:

```ini
--ozone-platform=wayland
--enable-features=WaylandWindowDecorations
--enable-gpu-rasterization
--enable-zero-copy
```
