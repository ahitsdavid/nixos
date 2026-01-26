# Personal NixOS Configuration

My personal NixOS configuration with Hyprland and QuickShell, managing multiple machines from a single Nix flake. This repository contains a complete, reproducible system configuration for daily driving NixOS across different hardware profiles.

## Disclaimer

**This is a personal configuration repository.** It is tailored specifically for my hardware and workflow. If you choose to use or reference any part of this configuration, you do so entirely at your own risk. I am not responsible for any issues, data loss, or system problems that may arise from using this configuration.

## Credits

This configuration heavily utilizes and builds upon:

- **[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)** - The QuickShell/AGS configuration that powers the desktop widgets, bar, and UI components. Huge thanks to end-4 for the incredible work on this project.
- **[QuickShell](https://git.outfoxxed.me/quickshell/quickshell)** - The Qt6/QML shell framework

---

## Overview

This is a flake-based NixOS configuration supporting multiple hosts with shared modules and profiles. The configuration emphasizes:

- **Reproducibility** - Entire system declared in Nix, version controlled
- **Multi-host support** - Same codebase for laptops, desktops, and VMs
- **Modularity** - Composable profiles and modules for different use cases
- **Modern desktop** - Hyprland Wayland compositor with polished UI

### Supported Hosts

| Host         | Hardware       | GPU                | Purpose                                  |
|--------------|----------------|--------------------|------------------------------------------|
| `desktop`    | AMD 7800X3D    | NVIDIA 3070Ti      | Primary workstation, dual ultrawide      |
| `thinkpad`   | ThinkPad T480  | Intel integrated   | Portable development                     |
| `legion`     | Intel + NVIDIA | Hybrid (Prime)     | Gaming laptop                            |
| `work-intel` | Intel          | Intel integrated   | Work system (no gaming)                  |
| `vm`         | Virtual        | —                  | Testing and sandbox                      |

---

## Features

### Desktop Environment

- **Hyprland** - Wayland compositor with animations, workspaces, and tiling
- **QuickShell** - Qt6/QML-based panel and widgets (end-4 dots-hyprland)
- **Rofi** - Application launcher with custom theming
- **Hyprlock/Hypridle** - Lock screen and idle management
- **NVIDIA optimization** - Wayland-compatible NVIDIA driver configuration

### Custom Cheatsheet System

A key customization built on top of end-4's QuickShell configuration. The cheatsheet provides an in-app overlay displaying keyboard shortcuts from multiple sources:

| Tab        | Source               | Description                                        |
|------------|----------------------|----------------------------------------------------|
| Keybinds   | `keybinds.nix`       | Hyprland window manager shortcuts                  |
| Neovim     | `nvf.nix`            | Neovim keybinds by mode (Normal, Insert, etc.)     |
| Terminal   | `kitty.nix`, `zsh/`  | Kitty terminal shortcuts and shell aliases         |
| Elements   | end-4                | Periodic table (from upstream)                     |

Custom Python parsers extract keybinds directly from Nix configuration files, so the cheatsheet always reflects the actual configured shortcuts.

### Development Environment

- **Editors** - Neovim (nvf), VS Code, Zed, Claude Code
- **Languages** - Python, C/C++, JavaScript/TypeScript, Go, Nix
- **Containers** - Docker and Docker Compose
- **Tools** - Git, LSP servers, build systems

### System Features

- **SOPS-nix** - Encrypted secrets management (SSH keys, API tokens, credentials)
- **Home Manager** - Declarative user environment and dotfiles
- **PipeWire** - Modern audio with ALSA, PulseAudio, and JACK compatibility
- **Tailscale** - Mesh VPN for connecting machines
- **Gaming** - Steam with Proton, NVIDIA acceleration (optional per-host)

### Applications

- **Browsers** - Firefox (with extensions), Zen Browser, Chromium
- **Media** - Spotify (Spicetify themed), VLC, OBS Studio
- **Productivity** - LibreOffice, Obsidian, Bitwarden
- **Terminals** - Kitty, Zsh with plugins and completions

---

## Project Structure

```
.
├── flake.nix                 # Main flake: inputs, outputs, host definitions
├── flake.lock                # Locked dependency versions
│
├── core/                     # System-level configuration
│   ├── drivers/              # Hardware drivers
│   │   ├── nvidia.nix        # NVIDIA with Wayland optimization
│   │   └── intel.nix         # Intel integrated graphics
│   └── modules/              # Core system services
│       ├── bootloader.nix    # systemd-boot, EFI
│       ├── networking.nix    # NetworkManager, DNS
│       ├── pipewire.nix      # Audio stack
│       ├── sops.nix          # Secrets management
│       └── ...
│
├── home/                     # Home Manager configuration
│   ├── base.nix              # Main home config entry point
│   ├── gaming.nix            # Gaming-specific config
│   └── modules/              # User application configs
│       ├── hyprland/         # Hyprland compositor
│       │   ├── keybinds.nix  # All keyboard shortcuts
│       │   ├── rules.nix     # Window rules
│       │   ├── scripts/      # Keybind parser scripts
│       │   └── quickshell-overrides/
│       ├── quickshell.nix    # QuickShell + end-4 integration
│       ├── nvf.nix           # Neovim configuration
│       ├── firefox/          # Firefox with extensions
│       ├── zsh/              # Zsh shell config
│       ├── kitty.nix         # Terminal emulator
│       └── ...
│
├── hosts/                    # Host-specific configurations
│   ├── desktop/              # AMD + NVIDIA workstation
│   ├── thinkpad/             # ThinkPad T480
│   ├── legion/               # Gaming laptop (hybrid GPU)
│   ├── work-intel/           # Work machine
│   └── vm/                   # Virtual machine
│
├── profiles/                 # Reusable configuration profiles
│   ├── base/                 # Essential system config (all hosts)
│   ├── development/          # Development tools and languages
│   └── work/                 # Work environment (office, printing)
│
├── secrets/                  # SOPS-encrypted secrets
│   ├── system.yaml           # System credentials
│   ├── personal.yaml         # Personal API keys
│   └── work.yaml             # Work credentials
│
└── docs/                     # Documentation
    └── PASSWORD_MANAGEMENT.md
```

For comprehensive documentation, see [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md).

---

## End-4 QuickShell Integration

This configuration uses [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) as the base for the desktop shell, with local customizations layered on top.

### How It Works

1. **Base configuration** is pulled from `dots-hyprland` flake input
2. **Local overrides** in `quickshell-overrides/` are merged at build time
3. **Custom services** provide data from Nix configs to QML components

### My Customizations

| Component                   | Description                                          |
|-----------------------------|------------------------------------------------------|
| `Cheatsheet.qml`            | Extended with Neovim and Terminal tabs               |
| `CheatsheetNvim.qml`        | New component displaying Neovim keybinds by mode     |
| `CheatsheetTerminal.qml`    | New component for Kitty shortcuts and shell aliases  |
| `NvimKeybinds.qml`          | QML service that runs Python parser for nvf.nix      |
| `TerminalKeybinds.qml`      | QML service that runs Python parser for terminals    |
| `get_keybinds.py`           | Enhanced parser supporting all Hyprland bind types   |
| `get_nvim_keybinds.py`      | Parser extracting keybinds from nvf.nix              |
| `get_terminal_keybinds.py`  | Parser for Kitty and shell alias definitions         |

---

## Usage

### Rebuild System

```bash
# Rebuild and switch to new configuration
nixos-rebuild switch --flake .#<hostname>

# Example
nixos-rebuild switch --flake .#desktop
nixos-rebuild switch --flake .#thinkpad
```

### Update Dependencies

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
```

### Build Without Switching

```bash
# Test build
nixos-rebuild build --flake .#desktop

# Build and show diff
nixos-rebuild build --flake .#desktop && nvd diff /run/current-system result
```

---

## Key Dependencies

| Input          | Purpose                       |
|----------------|-------------------------------|
| `nixpkgs`      | nixos-unstable packages       |
| `home-manager` | User environment management   |
| `hyprland`     | Wayland compositor            |
| `quickshell`   | Qt6/QML shell framework       |
| `dots-hyprland`| end-4's shell configuration   |
| `nvf`          | Neovim framework              |
| `sops-nix`     | Secrets management            |
| `catppuccin`   | Color scheme                  |

---

## License

This configuration is provided as-is for reference purposes. The end-4 dots-hyprland components retain their original licensing. Use at your own discretion.
