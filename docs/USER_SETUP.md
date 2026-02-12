# User Setup System

This NixOS configuration supports a single-source-of-truth user identity system. All user-specific values (name, email, shell, groups, etc.) flow from one place: `home/users/<username>/variables.nix`.

---

## Architecture Overview

```
flake.nix:81
  username = "davidthach"        ← Single source of truth
        │
        ├─► specialArgs ─► all NixOS modules get `username`
        │
        ├─► lib/user-vars.nix    ← Safe import helper with defaults
        │     └─► home/users/<username>/variables.nix
        │
        ├─► profiles/base/users.nix     (system account: shell, groups, description)
        ├─► profiles/base/nix-config.nix (sshUser for remote builds)
        ├─► core/modules/sops.nix       (secret ownership, key paths)
        ├─► home/base.nix              (git name/email)
        ├─► home/minimal.nix           (git name/email)
        └─► hosts/vm/default.nix       (git name/email for headless VM)
```

### How `username` flows through the system

1. **`flake.nix:81`** defines `username = "davidthach"`
2. **`lib/host-builders.nix`** passes it via `specialArgs` to all NixOS modules
3. **NixOS modules** (like `sops.nix`) receive it automatically as a function argument
4. **Parameterized imports** (like `users.nix`, `nix-config.nix`) receive it via `{ inputs, username }:`
5. **`lib/user-vars.nix`** imports `home/users/${username}/variables.nix` with fallback defaults

### `lib/user-vars.nix` — Safe Import Helper

This helper ensures builds never break even with a minimal `variables.nix`. Every field has a sensible default:

```nix
# Usage in any module:
let userVars = import ../lib/user-vars.nix username;
in {
  programs.git.settings.user.name = userVars.gitUsername;
  programs.git.settings.user.email = userVars.gitEmail;
}
```

Fields and their fallback chain:

| Field | Falls back to |
|-------|---------------|
| `fullName` | `gitUsername` → `username` |
| `description` | `fullName` → `gitUsername` → `username` |
| `gitUsername` | `fullName` → `username` |
| `gitEmail` | `"${username}@localhost"` |
| `shell` | `"fish"` |
| `extraGroups` | `[ "networkmanager" "wheel" "docker" "libvirtd" "keys" ]` |
| `browser` | `"firefox"` |
| `terminal` | `"kitty"` |
| `file-manager` | `"yazi"` |
| `keyboardLayout` | `"us"` |
| `consoleKeyMap` | `"us"` |
| `wallpaper` | `"Pictures/Wallpapers/yosemite.png"` |
| `extraMonitorSettings` | `""` |

### `home/users/<username>/variables.nix` — User Identity File

Each user has a directory under `home/users/` containing:

```
home/users/davidthach/
├── variables.nix    ← All identity and preference settings
└── face.png         ← User avatar (used by SDDM, AccountsService)
```

Example `variables.nix`:

```nix
{
  fullName = "David Thach";
  description = "David Thach";
  gitUsername = "David Thach";
  gitEmail = "davidthach@live.com";

  shell = "fish";
  extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "keys" ];

  extraMonitorSettings = "";

  browser = "firefox";
  terminal = "kitty";
  file-manager = "yazi";
  keyboardLayout = "us";
  consoleKeyMap = "us";

  wallpaper = "Pictures/Wallpapers/yosemite.png";
}
```

---

## Setup Script: `scripts/add-user.sh`

Interactive script for setting up users. Two modes:

### `--init` — Fork / Fresh Install

Use this when you've cloned or forked the repo and want to make it your own.

```bash
scripts/add-user.sh --init
```

What it does:

1. Prompts for: username, full name, email, shell, browser, terminal
2. Creates `home/users/<username>/variables.nix` with your settings
3. Copies a default `face.png`
4. Updates `flake.nix` username to your new username
5. Optionally generates an age key for SOPS secrets (`age-keygen`)
6. Optionally updates `.sops.yaml` `&daily` anchor with your new public key
7. Optionally generates a login password hash (`mkpasswd`)

**After running:**

```bash
# If you updated .sops.yaml, re-encrypt existing secrets:
sops updatekeys secrets/*.yaml

# Commit and rebuild:
git add -A
git commit -m "Setup user <yourname>"
nixos-rebuild switch --flake .#<hostname>
```

### `--add` — Additional User on a Host

Use this to add a second (or third, etc.) user to a specific host.

```bash
scripts/add-user.sh --add
```

What it does:

1. Prompts for: username, full name, email, shell, browser, terminal
2. Creates `home/users/<username>/` directory with `variables.nix` and `face.png`
3. Lists available hosts and asks which one to add the user to
4. Adds `extraUsers = [ "<username>" ]` to the host's `meta.nix`
5. Optionally generates a login password hash

**After running:**

```bash
git add -A
git commit -m "Add user <name> to <host>"
nixos-rebuild switch --flake .#<hostname>
```

### Required Tools

The script checks for these and will error if missing:

- `age-keygen` — for generating SOPS age keys (only `--init`)
- `sops` — for re-encrypting secrets (optional)
- `mkpasswd` — for generating password hashes (optional)

All are available in the NixOS dev shell: `nix develop`

---

## Multi-User Support (`extraUsers`)

Hosts can declare additional users in their `meta.nix`:

```nix
# hosts/desktop/meta.nix
{
  isGaming = true;
  hasNvidia = true;
  extraUsers = [ "alice" "bob" ];
}
```

Each extra user gets:
- A system account (`users.users.<name>`) with settings from their `variables.nix`
- A home-manager configuration (`home-manager.users.<name>`) with the same module set as the primary user

The primary user is always set in `flake.nix:81`. Extra users are per-host.

### Adding an extra user manually (without the script)

1. Create `home/users/<username>/variables.nix` (see example above)
2. Add a `face.png` to `home/users/<username>/`
3. Add `extraUsers = [ "<username>" ]` to the host's `meta.nix`
4. Optionally add a password hash to `secrets/personal.yaml`

---

## Files Reference

### Files that consume `username` / `userVars`

| File | How it gets `username` | What it uses |
|------|----------------------|--------------|
| `core/modules/sops.nix` | NixOS module args (specialArgs) | Secret ownership, age key path |
| `profiles/base/users.nix` | Explicit import param | System account (description, shell, groups) |
| `profiles/base/nix-config.nix` | Explicit import param | `sshUser` for remote builds |
| `profiles/base/default.nix` | Explicit import param | Passes to sub-imports, `/etc/nixos` symlink |
| `profiles/development/containers.nix` | Explicit import param | (available for container user setup) |
| `home/base.nix` | home-manager specialArgs | Git name/email |
| `home/minimal.nix` | home-manager specialArgs | Git name/email |
| `hosts/vm/default.nix` | NixOS module args (specialArgs) | Git name/email, SSH key path |
| `home/modules/bitwarden.nix` | home-manager specialArgs | (username available, no longer gated) |
| `lib/host-builders.nix` | Direct param from flake.nix | Primary + extra user creation |
| `examples/sops-usage.nix` | NixOS module args | Example references |

### Import patterns used

```nix
# Pattern 1: NixOS module system (username from specialArgs)
# Used by: sops.nix, bitwarden.nix, vm/default.nix
{ config, lib, pkgs, username, ... }:

# Pattern 2: Explicit import parameters
# Used by: users.nix, nix-config.nix, containers.nix
{ inputs, username }:
{ config, pkgs, lib, ... }:

# Pattern 3: userVars helper in let block
# Used by: users.nix, base.nix, minimal.nix, vm/default.nix
let
  userVars = import ../lib/user-vars.nix username;
in { ... }
```

### Shell mapping in `users.nix`

The user's shell preference (a string like `"fish"`) is mapped to a package:

```nix
shellPkg = {
  fish = pkgs.fish;
  zsh = pkgs.zsh;
  bash = pkgs.bash;
}.${userVars.shell} or pkgs.fish;
```
