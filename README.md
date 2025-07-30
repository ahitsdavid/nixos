# NixOS Configuration

This repository contains my personal NixOS configuration with multiple host profiles and a custom ISO for desktop installation.

## Host Profiles

- **thinkpad**: ThinkPad T480 with Intel graphics and power management optimizations
- **desktop**: Intel i7-8700K + Nvidia 3070Ti with Hyprland and gaming support
- **sb1**: Secondary system configuration
- **vm**: Virtual machine configuration

## Desktop Installation ISO

### Building the ISO

```bash
NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#packages.x86_64-linux.desktop-iso.config.system.build.isoImage
```

The ISO will be generated at: `result/iso/nixos-minimal-*.iso` (~4.1GB)

### ISO Features

**Hardware Support:**
- Nvidia 3070Ti drivers pre-loaded with Wayland optimization
- Intel i7-8700K CPU support with microcode updates
- Complete multi-filesystem support (ext4, btrfs, xfs, f2fs, zfs, bcachefs)

**Desktop Environment:**
- Hyprland (Wayland compositor) with Nvidia-specific optimizations
- GNOME (fallback desktop environment)
- GDM display manager

**Installation Tools:**
- **Partitioning**: gparted (GUI), cfdisk, gdisk
- **Filesystems**: Complete toolset for any filesystem choice
- **Network**: NetworkManager for WiFi/ethernet
- **Helper**: `/etc/install-desktop.sh` with step-by-step instructions

### Installation Process

1. **Create Installation Media**
   ```bash
   # Copy ISO to a convenient location
   cp result/iso/nixos-minimal-*.iso ~/Downloads/nixos-desktop.iso
   
   # Flash to USB (replace /dev/sdX with your USB device)
   sudo dd if=~/Downloads/nixos-desktop.iso of=/dev/sdX bs=4M status=progress && sync
   ```

2. **Boot from USB**
   - Login credentials: `nixos` / `nixos` or `root` / `nixos`
   - Choose Hyprland or GNOME desktop environment

3. **Connect to Network**
   - WiFi: Use NetworkManager GUI or `nmtui`
   - Ethernet: Usually auto-configured

4. **Partition Disks**
   - GUI: Launch `gparted`
   - CLI: Use `cfdisk` or `gdisk`
   - Create EFI boot partition (~512MB, FAT32)
   - Create root partition (remaining space, your choice of filesystem)

5. **Format Filesystems**
   ```bash
   # Examples for different filesystems:
   mkfs.ext4 /dev/sdX2      # ext4 (standard)
   mkfs.btrfs /dev/sdX2     # btrfs (snapshots, compression)
   mkfs.xfs /dev/sdX2       # xfs (high performance)
   mkfs.f2fs /dev/sdX2      # f2fs (SSD optimized)
   zpool create rpool /dev/sdX2  # zfs (enterprise features)
   bcachefs format /dev/sdX2     # bcachefs (next-gen)
   
   # Boot partition (always FAT32)
   mkfs.fat -F 32 /dev/sdX1
   ```

6. **Mount Filesystems**
   ```bash
   mount /dev/sdX2 /mnt
   mkdir -p /mnt/boot
   mount /dev/sdX1 /mnt/boot
   ```

7. **Copy Configuration**
   ```bash
   # Copy desktop configuration
   cp -r /etc/nixos/desktop-config/* /mnt/etc/nixos/
   
   # Generate hardware configuration
   nixos-generate-config --root /mnt
   ```

8. **Install System**
   ```bash
   nixos-install --flake /mnt/etc/nixos#desktop
   ```

9. **Reboot**
   ```bash
   reboot
   ```

### Post-Installation

After reboot, your system will have:
- **Hyprland** with Nvidia acceleration
- **Gaming support** (Steam pre-installed)
- **Development tools** from the development profile
- **All your dotfiles** and configurations
- **Automatic Nvidia environment variables** for Wayland/Hyprland

## Configuration Structure

```
.
├── core/               # Core system modules
│   ├── drivers/        # Hardware drivers (intel.nix, nvidia.nix)
│   └── modules/        # System modules (bootloader, networking, etc.)
├── home/               # Home Manager configurations
│   ├── modules/        # User-space modules
│   └── users/          # User-specific configs
├── hosts/              # Host-specific configurations
│   ├── desktop/        # Desktop profile (Intel + Nvidia)
│   ├── thinkpad/       # ThinkPad profile (Intel graphics)
│   └── vm/             # VM profile
├── profiles/           # Reusable configuration profiles
│   ├── base/           # Base system configuration
│   ├── development/    # Development tools and languages
│   └── work/           # Work-specific configurations
└── iso.nix            # Custom installation ISO configuration
```

## Key Features

- **Conditional Hyprland Config**: Automatically uses Nvidia-optimized settings on desktop
- **Multi-host Support**: Same codebase for laptop, desktop, VM, and server
- **Comprehensive Filesystem Support**: Install with any modern filesystem
- **Gaming Ready**: Steam and gaming optimizations included
- **Development Environment**: Full development stack with modern tools
- **Secure**: SOPS-nix for secrets management

## Building Individual Hosts

```bash
# Build specific host configuration
nixos-rebuild switch --flake .#desktop
nixos-rebuild switch --flake .#thinkpad
nixos-rebuild switch --flake .#vm
```

## IMPORTANT: Git Workflow for System Changes

**⚠️ CRITICAL RULE: Always commit configuration changes before rebuilding NixOS ⚠️**

When making changes to this NixOS configuration:

1. **Review changes**: Check what files were modified
   ```bash
   git status
   git diff
   ```

2. **Stage changes**: Add files to git tracking
   ```bash
   git add .
   # OR selectively add specific files
   git add path/to/modified/file.nix
   ```

3. **Get permission before commit**: Always review the commit message and changes
   ```bash
   git commit -m "Description of changes made"
   ```

4. **NEVER rebuild with dirty git tree**: NixOS rebuild should only happen after clean commits
   ```bash
   # ❌ BAD: Will show "warning: Git tree is dirty"
   sudo nixos-rebuild switch --flake .#thinkpad
   
   # ✅ GOOD: Clean git tree
   git add . && git commit -m "Add docker GUI support" 
   sudo nixos-rebuild switch --flake .#thinkpad
   ```

5. **Push changes**: Keep remote in sync
   ```bash
   git push origin main
   ```

**Why this matters:**
- Dirty git trees can cause build failures
- Changes might be lost if not committed
- Other systems won't get the updates
- Rollback becomes impossible without proper git history