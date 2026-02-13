# Scripts Reference

Interactive scaffolding scripts for managing users and hosts in this NixOS configuration.

Both scripts share the same helper infrastructure (colors, prompt functions, validation) and follow the same interactive patterns.

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

## Shared Patterns

Both scripts follow these conventions:

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
Both scripts use `sed -i` to modify Nix files (flake.nix, meta.nix). Patterns are anchored to specific comment markers or unique line patterns to avoid false matches.

### Adding a New Script

When creating a new script in `scripts/`:

1. Copy the shebang + `set -euo pipefail` + repo root detection block
2. Copy the color constants and `info`/`ok`/`warn`/`err` helpers
3. Reuse `prompt_default`, `prompt_required`, `prompt_yn`, `prompt_choice` as needed
4. Add `usage()` function and `case` dispatch at the bottom
5. Make executable: `chmod +x scripts/<name>.sh`
6. Document in this file
