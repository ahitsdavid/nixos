# Scripts Reference

Interactive scripts for managing users, hosts, secrets, deployment, and installation in this NixOS configuration.

All scripts share the same helper infrastructure (colors, prompt functions, validation) and follow the same interactive patterns.

---

## `scripts/add-user.sh`

**Purpose:** Set up users for the NixOS configuration.
**Modes:** `--init` (replace primary user) | `--add` (add extra user to a host)
**Full docs:** [docs/USER_SETUP.md](USER_SETUP.md)

### Structure (380 lines)

```
Line    Section
─────   ──────────────────────────────────────────
1-8     Shebang, header, set -euo pipefail
10-50   Helpers: repo root, colors, prompt functions
52-84   generate_variables_nix()  — template for variables.nix
86-135  setup_sops_age_key()      — age key generation + .sops.yaml update
137-235 do_init()                 — --init mode: replace primary user
237-357 do_add()                  — --add mode: add extra user to host
359-380 usage() + case dispatch
```

### Functions

| Function | Purpose |
|----------|---------|
| `info()` / `ok()` / `warn()` / `err()` | Colored output helpers |
| `check_tool()` | Verify a CLI tool exists |
| `prompt_default()` | Prompt with a default value |
| `prompt_required()` | Prompt that loops until non-empty |
| `generate_variables_nix()` | Generate `home/users/<name>/variables.nix` from params |
| `setup_sops_age_key()` | Generate age key, optionally update `.sops.yaml` |
| `do_init()` | Full init flow: create user dir, update flake.nix username, SOPS setup |
| `do_add()` | Add flow: create user dir, add `extraUsers` to host's `meta.nix` |

### Files Created/Modified

| Mode | Creates | Modifies |
|------|---------|----------|
| `--init` | `home/users/<name>/variables.nix`, `face.png` | `flake.nix` (username), `.sops.yaml` (optional) |
| `--add` | `home/users/<name>/variables.nix`, `face.png` | `hosts/<host>/meta.nix` (extraUsers) |

---

## `scripts/add-host.sh`

**Purpose:** Scaffold a new NixOS host configuration interactively.
**Modes:** No flags needed — single interactive flow with copy-from-existing or configure-from-scratch options.

### Structure (881 lines)

```
Line    Section
─────   ──────────────────────────────────────────
1-8     Shebang, header, set -euo pipefail
10-83   Helpers: repo root, colors, prompt functions
          - prompt_default(), prompt_required()  (same as add-user.sh)
          - prompt_yn()      — yes/no with default, stores true/false
          - prompt_choice()  — numbered menu, validates input
85-143  Validation functions
145-230 read_host_config()   — parse existing host for copy mode
232-477 Generator functions
479-500 add_to_flake()       — sed-based flake.nix modification
502-713 main()               — interactive flow
715-738 usage() + case dispatch
```

### Functions

#### Helpers (shared pattern with add-user.sh)

| Function | Purpose |
|----------|---------|
| `prompt_yn(prompt, default, var)` | Yes/no prompt, stores `true`/`false` |
| `prompt_choice(prompt, var, ...options)` | Numbered menu, validates choice |

#### Validation

| Function | Purpose |
|----------|---------|
| `get_existing_hosts()` | List directories under `hosts/` |
| `get_existing_ssh_aliases()` | Scan all `hosts/*/meta.nix` for `sshAlias` values |
| `validate_hostname(name)` | Regex check + uniqueness (no existing dir or flake entry) |
| `validate_ssh_alias(alias)` | Non-empty + not already used by another host |

#### Copy From Existing Host

| Function | Purpose |
|----------|---------|
| `read_host_config(host)` | Parse `meta.nix` + `default.nix` to extract all settings |

`read_host_config()` detects:
- **GPU driver** from `default.nix` imports: `hybrid-gpu.nix` / `nvidia.nix` / `intel.nix`
- **GNOME** from `default.nix` (`gnome.enable = true`) — not just `meta.nix` usesGnome flag
- **Profiles** from `default.nix`: `profiles/development`, `profiles/work`
- **Kernel** from `default.nix`: `linuxPackages_latest` / `linuxPackages_zen` / `linuxPackages`
- **Hybrid bus IDs** from `default.nix`: `intelBusId`, `nvidiaBusId`, `mode`
- **Meta flags** from `meta.nix`: `isGaming`, `isHeadless`, `isLaptop`

#### Generators

| Function | Purpose |
|----------|---------|
| `generate_meta_nix()` | Template for `hosts/<name>/meta.nix` |
| `generate_default_nix()` | Template for GUI `hosts/<name>/default.nix` (dispatches to headless) |
| `generate_default_nix_headless()` | Template for headless `hosts/<name>/default.nix` |
| `generate_hardware_placeholder()` | Placeholder `hardware-configuration.nix` with setup instructions |

#### Flake Modification

| Function | Purpose |
|----------|---------|
| `add_to_flake()` | Insert host into `flake.nix` nixosConfigurations + all-systems list |

Insertion strategy:
- **GUI hosts**: inserted before `# VM is headless` comment; added to `all-systems` array
- **Headless hosts**: inserted after `vm = mkHeadlessConfiguration` line; NOT added to `all-systems`
- `all-systems` sed targets the line containing `"desktop".*"thinkpad".*"macbook"` to avoid false matches

### Interactive Flow

```
main()
  │
  ├─ Prompt: hostname + description
  ├─ Validate hostname (regex, uniqueness)
  │
  ├─ Show existing hosts
  ├─ Choice: "Copy from existing host" or "Configure from scratch"
  │
  ├─ [If copy] ──────────────────────────────────────
  │    ├─ Prompt: which host to copy from
  │    ├─ read_host_config() → pre-fills all settings
  │    └─ [If hybrid GPU] re-prompt for bus IDs
  │
  ├─ [If scratch] ───────────────────────────────────
  │    ├─ Headless? (gates all GUI questions)
  │    │   └─ [If yes] set safe defaults, skip to SSH alias
  │    ├─ DE: Hyprland or GNOME
  │    ├─ GPU: None / Intel / NVIDIA / Hybrid
  │    │   └─ [If hybrid] mode (sync/offload) + bus IDs
  │    ├─ Gaming? Laptop?
  │    └─ Profiles: development? work?
  │
  ├─ SSH alias (show existing, validate uniqueness)
  ├─ Kernel: latest / zen / lts (skipped if copied)
  ├─ State version
  │
  ├─ Confirmation summary table
  ├─ Proceed? [Y/n]
  │
  ├─ Generate files:
  │    ├─ hosts/<name>/meta.nix
  │    ├─ hosts/<name>/default.nix
  │    └─ hosts/<name>/hardware-configuration.nix
  │
  ├─ Modify flake.nix (nixosConfigurations + all-systems)
  │
  └─ Print next steps
```

### Generated Output Patterns

The generators produce configs that match existing hosts:

| Scenario | Matches Host | Key Features |
|----------|-------------|--------------|
| Hyprland + Intel + Laptop | `thinkpad` | Intel driver, laptop profile, dev+work |
| NVIDIA Desktop | `desktop` | NVIDIA driver, `hardware.graphics`, kernel params |
| Hybrid GPU | `legion` | `hybrid-gpu.nix` import with mode + bus IDs |
| GNOME + Intel | `macbook` | GNOME services, power-profiles-daemon, extensions |
| Headless Server | `vm` | SSH profile, userVars, tailscale, basic packages |

### Files Created/Modified

| Creates | Modifies |
|---------|----------|
| `hosts/<name>/default.nix` | `flake.nix` (nixosConfigurations) |
| `hosts/<name>/meta.nix` | `flake.nix` (all-systems list, GUI only) |
| `hosts/<name>/hardware-configuration.nix` | |

---

## `scripts/setup-secrets.sh`

**Purpose:** SOPS secrets bootstrap and management — key generation, .sops.yaml configuration, re-encryption, and verification.
**Subcommands:** `bootstrap` | `keygen` | `system-key` | `reencrypt` | `verify` | `rotate`

### Structure (~310 lines)

```
Line    Section
─────   ──────────────────────────────────────────
1-14    Shebang, header, set -euo pipefail
16-66   Helpers: repo root, colors, prompt functions
68-86   Key helpers: get_age_key_path(), get_public_key(), get_secret_files()
88-120  cmd_keygen()      — generate/overwrite age key
122-148 cmd_system_key()  — copy key to /var/lib/sops-nix/ (sudo)
150-181 cmd_reencrypt()   — re-encrypt all secrets/*.yaml
183-219 cmd_verify()      — verify all secrets are decryptable
221-272 cmd_rotate()      — full key rotation workflow
274-338 cmd_bootstrap()   — interactive setup wizard
340-365 usage() + case dispatch
```

### Subcommands

| Command | Purpose | Destructive? |
|---------|---------|-------------|
| `bootstrap` | Full interactive SOPS setup wizard | Creates files |
| `keygen` | Generate a new age key | Overwrites key (with backup) |
| `system-key` | Copy key to `/var/lib/sops-nix/key.txt` | Requires sudo |
| `reencrypt` | Re-encrypt all secrets with current `.sops.yaml` keys | Modifies secrets |
| `verify` | Verify all secrets can be decrypted | Read-only |
| `rotate` | Generate new key + update `.sops.yaml` + re-encrypt | Full key rotation |

### Functions

| Function | Purpose |
|----------|---------|
| `get_age_key_path()` | Returns `~/.config/sops/age/keys.txt` |
| `get_public_key(keyfile)` | Extract public key from age key file |
| `get_secret_files()` | List `secrets/*.yaml` (excluding `.example`) |
| `cmd_keygen()` | Generate age key with backup if exists |
| `cmd_system_key()` | Copy key to system location (sudo) |
| `cmd_reencrypt()` | Run `sops updatekeys` on all secret files |
| `cmd_verify()` | Test decryption of all secret files |
| `cmd_rotate()` | Backup → keygen → update .sops.yaml → reencrypt |
| `cmd_bootstrap()` | Full wizard: keygen → .sops.yaml → example secrets → verify |

### Interactive Flow (bootstrap)

```
cmd_bootstrap()
  │
  ├─ Check tools: age-keygen, sops
  ├─ Step 1: Generate age key (cmd_keygen)
  ├─ Step 2: Update .sops.yaml &daily anchor
  │    ├─ Show current vs new key
  │    └─ Prompt to update (sed replacement)
  ├─ Step 3: Create secret files from templates
  │    ├─ For each secrets/*.yaml.example
  │    └─ Copy + encrypt with sops
  ├─ Step 4: Verify all secrets (cmd_verify)
  └─ Print next steps
```

### Files Created/Modified

| Command | Creates | Modifies |
|---------|---------|----------|
| `keygen` | `~/.config/sops/age/keys.txt` | — |
| `system-key` | `/var/lib/sops-nix/key.txt` | — |
| `reencrypt` | — | `secrets/*.yaml` |
| `rotate` | `keys.txt` (new), `keys.txt.bak` | `.sops.yaml`, `secrets/*.yaml` |
| `bootstrap` | `keys.txt`, `secrets/*.yaml` (from templates) | `.sops.yaml` (optional) |

### Reference Files

- `.sops.yaml` — Key anchors (`&daily` at line 12, `&master` at line 16)
- `core/modules/sops.nix` — Age key path, secret definitions
- `secrets/*.yaml.example` — Template files for secret structure

---

## `scripts/deploy.sh`

**Purpose:** Deploy NixOS configuration to a host (local or remote via Tailscale SSH).
**Modes:** Local (sudo) | Remote (`--target-host`) | Build-only | Dry-run | Boot

### Structure (~220 lines)

```
Line    Section
─────   ──────────────────────────────────────────
1-16    Shebang, header, set -euo pipefail
18-40   Helpers: repo root, colors, get_username()
42-65   Host discovery: get_all_hosts(), read_host_meta()
67-110  pre_deploy_checks()  — validate host, git status, SSH
112-170 do_deploy()          — execute deployment
172-220 Argument parsing, usage(), main()
```

### Options

| Flag | Action | nixos-rebuild command |
|------|--------|---------------------|
| (default) | Build + activate immediately | `sudo nixos-rebuild switch --flake .#host` |
| `--boot` | Build + activate on next reboot | `sudo nixos-rebuild boot --flake .#host` |
| `--build-only` | Build closure, no activation | `nix build .#nixosConfigurations.host...` |
| `--dry-run` | Show what would change | `nixos-rebuild dry-activate --flake .#host` |
| `--target-host` | Deploy to remote via SSH | `nixos-rebuild switch --target-host user@host --use-remote-sudo` |
| `--skip-checks` | Skip pre-deploy validation | — |

### Functions

| Function | Purpose |
|----------|---------|
| `get_username()` | Extract username from `flake.nix` |
| `get_all_hosts()` | List directories under `hosts/` |
| `read_host_meta(hostname)` | Parse `meta.nix` for description, SSH alias, headless flag |
| `pre_deploy_checks(hostname, remote)` | Validate host exists, check git status, test SSH |
| `do_deploy(hostname, action, remote)` | Execute the appropriate nixos-rebuild command |

### Pre-deploy Checks

1. **Host directory exists** — `hosts/$hostname/` must be present
2. **Git status** — Warns if there are uncommitted changes
3. **SSH connectivity** (remote only) — Tests `ssh -o ConnectTimeout=5`

### Interactive Flow

```
main()
  │
  ├─ Parse arguments (flags + hostname)
  ├─ If no hostname: show available hosts, prompt
  ├─ Read host metadata
  ├─ Pre-deploy checks (unless --skip-checks)
  │    ├─ Validate host directory
  │    ├─ Check git status (warn on dirty)
  │    └─ Test SSH (if remote)
  ├─ Show deployment summary
  └─ Execute deploy (switch/boot/build-only/dry-run)
```

---

## `scripts/install.sh`

**Purpose:** Full NixOS installation wizard supporting local (ISO) and remote (SSH) modes.
**Features:** Partition schemes (plain/LUKS/LUKS+LVM), multiple filesystems, btrfs subvolumes.

### Structure (~530 lines)

```
Line    Section
─────   ──────────────────────────────────────────
1-19    Shebang, header, set -euo pipefail
21-100  Helpers: repo root, colors, prompt functions
102-112 run_cmd()                  — local/remote execution wrapper
114-155 detect_disks()             — lsblk-based disk detection + safety prompt
157-166 partition_name()           — NVMe vs SATA naming helper
168-182 do_partition_plain()       — GPT + ESP + root
184-217 do_partition_luks()        — GPT + ESP + LUKS2 root
219-262 do_partition_luks_lvm()    — GPT + ESP + LUKS2 + LVM (root + swap)
264-286 format_filesystem()        — mkfs for ext4/btrfs/xfs/f2fs/bcachefs
288-305 create_btrfs_subvolumes()  — @, @home subvolumes
307-335 mount_filesystems()        — mount root/boot/swap to /mnt
337-359 generate_hardware_config() — nixos-generate-config + copy to repo
361-385 clone_repo_to_target()     — scp repo to /mnt/etc/nixos-config
387-400 run_nixos_install()        — nixos-install --flake
402-445 post_install()             — SOPS key copy + user password
447-480 select_host()              — host selection with scaffold option
482-530 main()                     — full installation wizard
```

### Partition Schemes

| Scheme | Layout | Encryption |
|--------|--------|-----------|
| Plain | ESP (512MiB) + root | None |
| LUKS | ESP (512MiB) + LUKS2 → root | AES-256 (LUKS2) |
| LUKS + LVM | ESP (512MiB) + LUKS2 → LVM VG → root + swap LVs | AES-256 (LUKS2) |

### Supported Filesystems

| Filesystem | Subvolumes | Notes |
|-----------|-----------|-------|
| ext4 | No | Standard, widely supported |
| btrfs | Yes (@, @home) | Compression (zstd), snapshots |
| xfs | No | High performance |
| f2fs | No | Flash/SSD optimized |
| bcachefs | No | Next-gen COW |

### Key Functions

| Function | Purpose |
|----------|---------|
| `run_cmd(cmd)` | Execute locally or via `ssh root@$REMOTE_HOST` |
| `detect_disks()` | List disks via `lsblk`, prompt for selection |
| `partition_name(disk, num)` | Handle NVMe (`p1`) vs SATA (`1`) naming |
| `do_partition_plain(disk)` | GPT + ESP + root (no encryption) |
| `do_partition_luks(disk)` | GPT + ESP + LUKS2 root |
| `do_partition_luks_lvm(disk)` | GPT + ESP + LUKS2 + LVM with swap |
| `format_filesystem(device, fstype)` | Format root + boot partitions |
| `create_btrfs_subvolumes(device)` | Create @, @home subvolumes |
| `mount_filesystems()` | Mount everything to /mnt |
| `generate_hardware_config(hostname)` | Run nixos-generate-config, copy to repo |
| `clone_repo_to_target()` | Copy repo to target /mnt/etc/nixos-config |
| `run_nixos_install(hostname)` | Execute nixos-install --flake |
| `post_install(hostname)` | Copy SOPS key, set user password |
| `select_host()` | Choose existing host or scaffold new one |

### Interactive Flow

```
main()
  │
  ├─ Mode detection (local vs remote SSH)
  │    └─ [If remote] test SSH connectivity
  │
  ├─ Step 1: Host selection
  │    ├─ Show existing hosts
  │    ├─ Use existing or scaffold new (calls add-host.sh)
  │    └─ Validate host directory exists
  │
  ├─ Step 2: Disk selection
  │    ├─ detect_disks() — lsblk + numbered list
  │    └─ DANGER confirmation
  │
  ├─ Step 3: Partition scheme
  │    └─ Plain / LUKS / LUKS + LVM
  │
  ├─ Step 4: Filesystem
  │    └─ ext4 / btrfs / xfs / f2fs / bcachefs
  │
  ├─ Step 5: Swap (non-LVM only)
  │
  ├─ Confirmation summary table
  ├─ Proceed? [y/N]
  │
  ├─ Execute:
  │    ├─ 1. Partition disk
  │    ├─ 2. Format filesystem
  │    ├─ 3. Btrfs subvolumes (if applicable)
  │    ├─ 4. Mount filesystems + swap
  │    ├─ 5. Generate hardware config
  │    ├─ 6. Clone repo to target
  │    └─ 7. Run nixos-install
  │
  ├─ Post-install:
  │    ├─ Copy SOPS age key (user + system)
  │    └─ Set user password
  │
  └─ Success + reboot instructions
```

### Options

| Flag | Purpose |
|------|---------|
| `--remote <host>` | Install to a remote machine via SSH |
| `--hostname <name>` | Pre-set hostname (skip selection prompt) |
| `--disk <device>` | Pre-set target disk (skip detection) |
| `--no-encrypt` | Force plain partitioning (skip encryption prompt) |

### Reference Files

- `iso.nix` — Custom ISO with all filesystem tools, encryption, LVM
- `scripts/add-host.sh` — Host scaffolding (can chain into install)
- `hosts/*/hardware-configuration.nix` — Reference hardware configs

---

## Shared Patterns

All scripts follow these conventions:

### Color Constants
```bash
RED='\033[0;31m'  GREEN='\033[0;32m'
YELLOW='\033[1;33m'  CYAN='\033[0;36m'  NC='\033[0m'
```

### Output Prefixes
```
[info]   — Informational (cyan)
[ok]     — Success (green)
[warn]   — Warning (yellow)
[error]  — Error (red, stderr)
```

### Repo Root Detection
```bash
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
```

### File Modification via sed
Scripts use `sed -i` to modify Nix files (flake.nix, meta.nix, .sops.yaml). Patterns are anchored to specific comment markers or unique line patterns to avoid false matches.

### Adding a New Script

When creating a new script in `scripts/`:

1. Copy the shebang + `set -euo pipefail` + repo root detection block
2. Copy the color constants and `info`/`ok`/`warn`/`err` helpers
3. Reuse `prompt_default`, `prompt_required`, `prompt_yn`, `prompt_choice` as needed
4. Add `usage()` function and `case` dispatch at the bottom
5. Make executable: `chmod +x scripts/<name>.sh`
6. Document in this file
