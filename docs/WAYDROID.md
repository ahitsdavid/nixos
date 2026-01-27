# Waydroid Setup Guide

Waydroid runs Android in a container on Wayland. This config is host-locked to **Legion** because it uses Intel iGPU for proper GPU acceleration (NVIDIA proprietary drivers don't work with Waydroid's Mesa-based graphics stack).

## Prerequisites

- Wayland session (Hyprland works)
- Intel or AMD GPU with Mesa drivers
- Legion host (configured in `hosts/legion/default.nix`)

## Post-Rebuild Setup

After `nixos-rebuild switch` on Legion, run these one-time initialization steps:

### 1. Initialize Waydroid

```bash
# With Google Play Store support
sudo waydroid init -s GAPPS -f

# Or without Google Play (smaller, faster)
sudo waydroid init
```

### 2. Start the Container

```bash
sudo systemctl start waydroid-container
```

### 3. Start a Session

```bash
waydroid session start
```

### 4. Launch Android UI

```bash
waydroid show-full-ui
```

## Common Commands

| Command | Description |
|---------|-------------|
| `waydroid show-full-ui` | Launch full Android UI |
| `waydroid app list` | List installed Android apps |
| `waydroid app launch <app>` | Launch specific app |
| `waydroid app install /path/to.apk` | Install APK file |
| `sudo waydroid shell` | Access Android shell |
| `waydroid session stop` | Stop current session |
| `sudo systemctl stop waydroid-container` | Stop container |

## Configuration

### Set Window Size

```bash
waydroid prop set persist.waydroid.width 1080
waydroid prop set persist.waydroid.height 1920
```

### Google Play Certification

On first launch with GAPPS, you'll see a "Device not certified" warning. Follow the on-screen instructions to self-certify, or:

```bash
sudo waydroid shell
ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"
```

Register the ID at: https://www.google.com/android/uncertified

## Troubleshooting

### Reset Everything

If things break, nuke it and start fresh:

```bash
waydroid session stop
sudo systemctl stop waydroid-container
sudo rm -rf /var/lib/waydroid
rm -rf ~/.local/share/waydroid
rm -rf ~/.local/share/applications/*aydroid*
# Then re-run: sudo waydroid init -s GAPPS -f
```

### Suspend/Hibernate Issues

Waydroid can interfere with suspend. Stop the session before sleeping:

```bash
waydroid session stop
sudo systemctl stop waydroid-container
```

### Check Logs

```bash
# Container logs
journalctl -u waydroid-container

# Session logs
waydroid log
```

## Why Legion Only?

- **NVIDIA GPUs**: Don't work with Waydroid - Android requires Mesa drivers, NVIDIA proprietary drivers aren't part of Mesa
- **Intel/AMD**: Work perfectly with full GPU acceleration via Mesa
- **Legion**: Has Intel iGPU (hybrid graphics) which Waydroid can use
- **Desktop (7800X3D)**: No iGPU, only NVIDIA - would require software rendering (SwiftShader), poor performance for games

## ARM Game Support

Waydroid uses libhoudini or libndk for ARM-to-x86 translation. This is automatic for most ARM apps/games. Performance depends on:

1. Translation overhead (CPU-bound)
2. GPU acceleration (works on Intel/AMD)

## Files

| File | Purpose |
|------|---------|
| `core/modules/waydroid.nix` | NixOS module |
| `hosts/legion/default.nix` | Host that imports waydroid |
| `/var/lib/waydroid/` | Waydroid data (images, props) |
| `~/.local/share/waydroid/` | User session data |

## Resources

- [Official NixOS Wiki](https://wiki.nixos.org/wiki/Waydroid)
- [Waydroid Docs](https://docs.waydro.id/)
- [Waydroid GitHub](https://github.com/waydroid/waydroid)
