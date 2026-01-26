# NixOS Configuration - Project Structure

This document provides a comprehensive overview of the NixOS configuration repository structure, organization patterns, and key components.

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Core Modules](#core-modules)
- [Home Manager Configuration](#home-manager-configuration)
- [Host Configurations](#host-configurations)
- [Profiles](#profiles)
- [QuickShell & End-4 Integration](#quickshell--end-4-integration)
- [Secrets Management](#secrets-management)
- [Flake Architecture](#flake-architecture)
- [Build Commands](#build-commands)

---

## Overview

This is a multi-host NixOS configuration using Nix Flakes. The repository supports:

- **6 hosts**: desktop, thinkpad, legion, work-intel, sb1, vm
- **91 Nix files** organized into logical modules
- **Hyprland** as the primary Wayland compositor
- **SOPS-nix** for secrets management
- **QuickShell** with customized end-4 dots-hyprland integration

---

## Directory Structure

```
/home/davidthach/nixos/
├── flake.nix              # Main flake: inputs, outputs, host definitions
├── flake.lock             # Locked dependency versions
├── default.nix            # Legacy NixOS entry point
├── iso.nix                # Custom installation ISO configuration
├── .sops.yaml             # SOPS encryption configuration
│
├── core/                  # System-level modules
│   ├── drivers/           # Hardware drivers
│   │   ├── intel.nix      # Intel integrated graphics
│   │   └── nvidia.nix     # NVIDIA drivers + Wayland optimization
│   └── modules/           # Core system services
│       ├── default.nix    # Module orchestrator
│       ├── bootloader.nix # systemd-boot + EFI
│       ├── fonts.nix      # Font configuration
│       ├── networking.nix # NetworkManager + DNS
│       ├── packages.nix   # Common system packages
│       ├── pipewire.nix   # Audio (PipeWire/ALSA/PulseAudio)
│       ├── sddm.nix       # Display manager
│       ├── sops.nix       # Secrets management
│       ├── steam.nix      # Steam gaming
│       ├── tailscale.nix  # VPN mesh network
│       └── yubikey.nix    # Hardware authentication
│
├── home/                  # Home Manager configurations
│   ├── base.nix           # Main home config entry point
│   ├── gaming.nix         # Gaming-specific user config
│   ├── modules/           # User application modules (31+)
│   │   ├── hyprland/      # Hyprland compositor config
│   │   ├── quickshell.nix # QuickShell + end-4 integration
│   │   ├── nvf.nix        # Neovim (nvf framework)
│   │   ├── firefox/       # Firefox browser
│   │   ├── zsh/           # Zsh shell
│   │   ├── kitty.nix      # Kitty terminal
│   │   ├── rofi/          # Application launcher
│   │   └── ...            # See Home Modules section
│   └── users/davidthach/  # User-specific overrides
│       ├── home.nix
│       ├── variables.nix
│       └── face.png
│
├── hosts/                 # Host-specific configurations
│   ├── desktop/           # AMD 7800X3D + NVIDIA 3070Ti
│   ├── thinkpad/          # ThinkPad T480 (Intel)
│   ├── legion/            # Lenovo Legion (hybrid graphics)
│   ├── work-intel/        # Work system (Intel only)
│   ├── sb1/               # Secondary system
│   └── vm/                # Virtual machine
│
├── profiles/              # Reusable configuration profiles
│   ├── base/              # Essential system config
│   │   ├── default.nix    # Base setup
│   │   ├── users.nix      # User account management
│   │   └── nix-config.nix # Nix settings
│   ├── development/       # Dev tools & languages
│   │   ├── default.nix
│   │   ├── languages/     # Python, C/C++, JS/TS, Go
│   │   ├── tools.nix
│   │   └── containers.nix # Docker
│   └── work/              # Work environment
│       ├── default.nix    # Office, printing, scanning
│       └── productivity.nix
│
├── secrets/               # SOPS-encrypted secrets
│   ├── system.yaml        # System secrets (SSH keys)
│   ├── personal.yaml      # Personal secrets (API keys)
│   └── work.yaml          # Work credentials
│
├── docs/                  # Documentation
│   └── PASSWORD_MANAGEMENT.md
│
├── certs/                 # Custom certificates
├── wallpapers/            # Desktop wallpapers
└── examples/              # Configuration examples
    └── sops-usage.nix
```

---

## Core Modules

**Location:** `core/`

### Drivers (`core/drivers/`)

| File | Purpose |
|------|---------|
| `nvidia.nix` | NVIDIA driver config with Wayland optimization, modesetting, environment variables |
| `intel.nix` | Intel integrated graphics, VAAPI/VDPAU hardware acceleration |

### System Modules (`core/modules/`)

| File | Purpose |
|------|---------|
| `default.nix` | Imports all core modules |
| `bootloader.nix` | systemd-boot, EFI configuration |
| `fonts.nix` | Font packages and rendering |
| `networking.nix` | NetworkManager, DNS, firewall |
| `packages.nix` | Common system packages |
| `pipewire.nix` | Audio: PipeWire + ALSA + PulseAudio + JACK |
| `sddm.nix` | SDDM display manager |
| `sops.nix` | SOPS-nix secrets integration |
| `steam.nix` | Steam gaming platform |
| `tailscale.nix` | Tailscale VPN |
| `yubikey.nix` | YubiKey hardware auth |

---

## Home Manager Configuration

**Location:** `home/`

### Entry Points

| File | Purpose |
|------|---------|
| `base.nix` | Main home-manager config, imports all modules, user packages |
| `gaming.nix` | Gaming-specific config (Pokerogue, MangoHud) |

### Home Modules (`home/modules/`)

#### Desktop Environment & UI

| File | Purpose |
|------|---------|
| `hyprland/default.nix` | Hyprland orchestrator (conditionally loads NVIDIA settings) |
| `hyprland/keybinds.nix` | All keyboard shortcuts |
| `hyprland/hyprland.nix` | Core Hyprland settings |
| `hyprland/env.nix` | Environment variables |
| `hyprland/env-nvidia.nix` | NVIDIA-specific env vars |
| `hyprland/hypridle.nix` | Idle timeout behavior |
| `hyprland/hyprlock.nix` | Lock screen config |
| `hyprland/rules.nix` | Window rules |
| `quickshell.nix` | QuickShell panel/widgets (end-4 integration) |
| `rofi/` | Application launcher |
| `gdm/` | GDM display manager customization |

#### Terminals & Shells

| File | Purpose |
|------|---------|
| `zsh/default.nix` | Zsh with plugins, aliases, completions |
| `kitty.nix` | Kitty terminal emulator |
| `bash.nix` | Bash configuration |

#### Editors & Development

| File | Purpose |
|------|---------|
| `nvf.nix` | Neovim (nvf framework) with LSP, Treesitter |
| `vscode.nix` | VS Code with extensions |
| `zed.nix` | Zed editor (Rust-based) |
| `claude.nix` | Claude Code CLI |
| `git.nix` | Git configuration |

#### Browsers

| File | Purpose |
|------|---------|
| `firefox/default.nix` | Firefox with extensions, certificates |
| `zen-browser.nix` | Zen browser |
| `chromium.nix` | Chromium configuration |
| `shared-bookmarks.nix` | Cross-browser bookmarks |

#### System Tools

| File | Purpose |
|------|---------|
| `ssh.nix` | SSH client config |
| `yazi.nix` | Yazi file manager |
| `eza.nix` | Modern ls replacement |
| `btop.nix` | System monitor |
| `fastfetch/` | System info display |

#### Media & Entertainment

| File | Purpose |
|------|---------|
| `spicetify.nix` | Spotify theming |
| `obs.nix` | OBS Studio |

#### Theming

| File | Purpose |
|------|---------|
| `catppuccin.nix` | Catppuccin color scheme |
| `stylix.nix` | Stylix theme management |

---

## Host Configurations

**Location:** `hosts/`

| Host | Hardware | GPU | Features |
|------|----------|-----|----------|
| `desktop` | AMD 7800X3D | NVIDIA 3070Ti | Gaming, dual ultrawide monitors |
| `thinkpad` | Intel (T480) | Intel integrated | TLP power mgmt, fingerprint |
| `legion` | Intel + NVIDIA | Hybrid (Prime Sync) | Gaming laptop |
| `work-intel` | Intel | Intel integrated | No gaming |
| `sb1` | Generic | - | Secondary system |
| `vm` | Virtual | - | Testing/sandbox |

### Host Configuration Pattern

Each host directory contains:
- `default.nix` - Main host configuration (imports profiles, sets options)
- `hardware-configuration.nix` - Generated hardware config

---

## Profiles

**Location:** `profiles/`

### Base Profile (`profiles/base/`)

Applied to all hosts:
- Bluetooth, Flatpak, networking
- Hyprland, XDG portals
- Locale, timezone, keyboard
- User account creation

### Development Profile (`profiles/development/`)

Development environment:
- Docker, Docker Compose
- Languages: Python, C/C++, JS/TS, Go
- LSP servers, build tools
- Git LFS, Insomnia

### Work Profile (`profiles/work/`)

Work environment:
- LibreOffice, Draw.io
- Remmina (RDP client)
- Printing (CUPS, Gutenprint, HPLIP)
- Scanning (SANE, Airscan)

---

## QuickShell & End-4 Integration

**Location:** `home/modules/quickshell.nix`, `home/modules/hyprland/`

### Overview

QuickShell provides the panel/widget system using end-4's dots-hyprland as a base with extensive local customizations.

### Flake Inputs

```nix
# flake.nix
quickshell.url = "git+https://git.outfoxxed.me/quickshell/quickshell";
dots-hyprland.url = "github:end-4/dots-hyprland";
```

### Configuration Merge Strategy

The quickshell.nix module merges:
1. **Base**: `${inputs.dots-hyprland}/dots/.config/quickshell/ii`
2. **Overrides**: Local `quickshell-overrides/` directory

### Custom Modifications

#### Cheatsheet System

Custom tabbed help overlay displaying keyboard shortcuts:

**Location:** `home/modules/hyprland/quickshell-overrides/modules/ii/cheatsheet/`

| File | Purpose |
|------|---------|
| `Cheatsheet.qml` | Main UI with 4 tabs: Keybinds, Neovim, Terminal, Elements |
| `CheatsheetNvim.qml` | Neovim keybinds by mode (Normal, Insert, Terminal, Visual) |
| `CheatsheetTerminal.qml` | Kitty keybinds + shell aliases |

**Controls:**
- `Ctrl+PageDown/PageUp` - Tab navigation
- `Ctrl+Tab/Shift+Tab` - Cycle tabs
- `Esc` - Close cheatsheet

#### QML Services

**Location:** `home/modules/hyprland/quickshell-overrides/services/`

| File | Purpose |
|------|---------|
| `NvimKeybinds.qml` | Service providing Neovim keybinds via Python parser |
| `TerminalKeybinds.qml` | Service providing terminal keybinds via Python parser |

#### Python Keybind Parsers

**Location:** `home/modules/hyprland/scripts/`

| Script | Purpose | Parses |
|--------|---------|--------|
| `get_keybinds.py` | Hyprland keybind parser | `keybinds.nix` |
| `get_nvim_keybinds.py` | Neovim keybind parser | `nvf.nix` |
| `get_terminal_keybinds.py` | Terminal keybind parser | `kitty.nix`, `zsh/`, `eza.nix`, `claude.nix` |

**Features:**
- Extracts keybinds from Nix `extraConfig` blocks
- Supports all Hyprland bind types (bind, bindl, binde, bindd, etc.)
- Auto-generates human-readable descriptions
- Outputs JSON for QML consumption

### QuickShell Dependencies

The module installs 68 packages including:
- System: gammastep, playerctl, brightnessctl, upower
- CLI: jq, ripgrep, wl-clipboard, cliphist, imagemagick
- Theming: matugen, adw-gtk3, material-symbols
- Hyprland: hyprsunset, hypridle, hyprpicker, hyprlock, hyprshot
- KDE/Qt: 18 kdePackages for Qt6 compatibility

---

## Secrets Management

**Location:** `secrets/`, `.sops.yaml`

### SOPS Configuration

```yaml
# .sops.yaml
keys:
  - &daily age1g2lrl7380khsxt988e5x59yjfnf9q4tmhq29gx2tg86j4vl8mgvsj6pcx3
  - &master age1ufxwrvqk9fnusw5fl508ycmn392zqzsexh6mvlzggfx3h2xya4xqekgmsl
```

### Secret Files

| File | Contents |
|------|----------|
| `system.yaml` | SSH keys, system credentials |
| `personal.yaml` | API keys, tokens |
| `work.yaml` | Work credentials |

### Usage

See `examples/sops-usage.nix` and `docs/PASSWORD_MANAGEMENT.md` for details.

---

## Flake Architecture

### Key Inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` | nixos-unstable |
| `home-manager` | User environment management |
| `hyprland` | Wayland compositor (v0.53.1) |
| `quickshell` | Panel/widget framework |
| `dots-hyprland` | End-4 configuration base |
| `nvf` | Neovim framework |
| `sops-nix` | Secrets management |
| `catppuccin` | Color scheme |
| `spicetify-nix` | Spotify customization |
| `zen-browser` | Privacy browser |

### Host Generation Pattern

```nix
# flake.nix
mkNixosConfiguration = { hostname, extraModules ? [], includeGaming ? true }:
  nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs username; };
    modules = [
      ./hosts/${hostname}
      home-manager.nixosModules.home-manager
      # ... conditional gaming module
    ];
  };
```

### Special Args

All modules receive:
- `inputs` - All flake inputs
- `username` - Primary user ("davidthach")

---

## Build Commands

### Rebuild System

```bash
# Build specific host
nixos-rebuild switch --flake .#desktop
nixos-rebuild switch --flake .#thinkpad
nixos-rebuild switch --flake .#legion

# Test build without switching
nixos-rebuild build --flake .#desktop
```

### Build Installation ISO

```bash
NIXPKGS_ALLOW_UNFREE=1 nix build --impure \
  .#packages.x86_64-linux.desktop-iso.config.system.build.isoImage
```

### Update Flake

```bash
nix flake update
```

### Check Flake

```bash
nix flake check
```

---

## Key Conventions

### Git Workflow

**Always commit before rebuilding:**
```bash
git add . && git commit -m "description"
nixos-rebuild switch --flake .#<host>
```

### Module Organization

- **Profiles** = Reusable feature sets (base, development, work)
- **Modules** = Individual feature configs
- **Hosts** = Device-specific composition

### Conditional Features

- NVIDIA optimization: Only on `desktop` and `legion` hosts
- Gaming: Disabled on `work-intel`
- Hybrid graphics: Only on `legion` (Prime Sync)

### State Versions

- NixOS: 25.05
- Home Manager: 25.11
