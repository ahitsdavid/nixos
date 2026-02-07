# NixOS Configuration Refactoring Guide

This document outlines identified improvements and step-by-step refactoring tasks for this NixOS configuration. Prioritized by impact and risk level.

---

## Progress

| Task | Status | Commit |
|------|--------|--------|
| 1.1 Extract Catppuccin colors | **Done** | - |
| 1.2 Centralize NVIDIA env | **Done** | `526fa76` |
| 1.3 Remove dead code | **Done** | `526fa76` |
| 1.4 Standardize state versions | **Done** | `526fa76` |
| 2.1 Create laptop profile | **Done** | - |
| 2.2 Create display manager profile | **Done** | - |
| 2.3 Standardize import syntax | **Done** | - |
| 2.4 Extract package sets | **Done** | - |
| 3.1 Add Nix linting | **Done** | - |
| 3.2 Extract flake helper functions | **Done** | - |
| 3.4 Fix QML path duplication | **Done** | - |

---

## Executive Summary

| Category | Issues Found | Priority |
|----------|--------------|----------|
| Code Duplication | 6 major instances | High |
| Inconsistent Patterns | 5 patterns | Medium |
| Missing Abstractions | 4 areas | Medium |
| Organization Issues | 3 areas | Low |
| Dead Code | ~~8+ files~~ Fixed | Low |

---

## Phase 1: High Impact, Low Risk

These changes eliminate duplication without altering behavior.

### 1.1 Extract Shared Catppuccin Color Scheme

**Problem**: The Catppuccin Mocha base16 palette is duplicated identically in two files.

**Files affected**:
- `home/modules/stylix.nix` (lines 9-27)
- `core/modules/stylix.nix` (lines 7-27)

**Steps**:

1. Create the shared color scheme file:
   ```bash
   mkdir -p lib/colors
   ```

2. Create `lib/colors/catppuccin-mocha.nix`:
   ```nix
   # Catppuccin Mocha - Base16 color scheme
   # Single source of truth for both system and home-manager
   {
     base00 = "1e1e2e"; # base
     base01 = "181825"; # mantle
     base02 = "313244"; # surface0
     base03 = "45475a"; # surface1
     base04 = "585b70"; # surface2
     base05 = "cdd6f4"; # text
     base06 = "f5e0dc"; # rosewater
     base07 = "b4befe"; # lavender
     base08 = "f38ba8"; # red
     base09 = "fab387"; # peach
     base0A = "f9e2af"; # yellow
     base0B = "a6e3a1"; # green
     base0C = "94e2d5"; # teal
     base0D = "89b4fa"; # blue
     base0E = "cba6f7"; # mauve
     base0F = "f2cdcd"; # flamingo
   }
   ```

3. Update `home/modules/stylix.nix`:
   ```nix
   { config, lib, pkgs, ... }:
   let
     catppuccin = import ../../lib/colors/catppuccin-mocha.nix;
   in
   {
     stylix = {
       enable = true;
       polarity = "dark";
       base16Scheme = catppuccin;
       # ... rest of config
     };
   }
   ```

4. Update `core/modules/stylix.nix` similarly

5. Test:
   ```bash
   nixos-rebuild build --flake .#desktop
   ```

---

### 1.2 Centralize NVIDIA Environment Variables ✓

**Status**: Complete - Created `lib/nvidia-env.nix` with multiple output formats.

**Problem**: Same NVIDIA Wayland environment variables defined in 3 locations.

**Files affected**:
- `core/drivers/nvidia.nix` (lines 50-57)
- `home/modules/hyprland/env-nvidia.nix`
- `home/modules/quickshell.nix` (lines 39-42)

**Steps**:

1. Create `lib/nvidia-env.nix`:
   ```nix
   # NVIDIA Wayland environment variables
   # Required for proper Wayland compositor support with NVIDIA GPUs
   {
     # Hardware acceleration
     LIBVA_DRIVER_NAME = "nvidia";
     GBM_BACKEND = "nvidia-drm";
     __GLX_VENDOR_LIBRARY_NAME = "nvidia";

     # Cursor rendering fix
     WLR_NO_HARDWARE_CURSORS = "1";

     # EGL platform
     __NV_PRIME_RENDER_OFFLOAD = "1";
     __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
     __VK_LAYER_NV_optimus = "NVIDIA_only";

     # Qt/GTK Wayland
     QT_QPA_PLATFORM = "wayland";
     GDK_BACKEND = "wayland";

     # XDG session
     XDG_SESSION_TYPE = "wayland";
   }
   ```

2. Update `core/drivers/nvidia.nix`:
   ```nix
   { config, lib, pkgs, ... }:
   let
     nvidiaEnv = import ../../lib/nvidia-env.nix;
   in
   {
     environment.sessionVariables = nvidiaEnv;
     # ... rest of config
   }
   ```

3. Update `home/modules/hyprland/env-nvidia.nix`:
   ```nix
   { config, lib, ... }:
   let
     nvidiaEnv = import ../../../lib/nvidia-env.nix;
   in
   {
     wayland.windowManager.hyprland.settings.env =
       lib.mapAttrsToList (k: v: "${k},${v}") nvidiaEnv;
   }
   ```

4. Update `home/modules/quickshell.nix` to import and use

5. Test on NVIDIA host:
   ```bash
   nixos-rebuild switch --flake .#desktop
   ```

---

### 1.3 Remove Dead Code and Commented Imports ✓

**Status**: Complete - Removed ~60 lines of dead code from 6 files.

**Problem**: 8+ files contain commented-out imports creating confusion about what's active.

**Files to clean**:
- `home/base.nix`
- `home/modules/default.nix`
- `core/modules/default.nix`
- `hosts/*/default.nix`

**Steps**:

1. Audit each file for commented imports:
   ```bash
   grep -r "^#.*import\|^#.*\.nix" --include="*.nix" .
   ```

2. For each commented import, decide:
   - **Delete** if obsolete/replaced
   - **Move** to `docs/disabled-modules.md` if may be needed later
   - **Uncomment** if should be active

3. Create `docs/disabled-modules.md` for reference:
   ```markdown
   # Disabled Modules Reference

   ## home/modules/dolphin.nix
   - Reason: Switched to Yazi file manager
   - Disabled: 2024-10

   ## core/modules/greetd.nix
   - Reason: Using SDDM instead
   - Disabled: 2024-09
   ```

4. Remove commented lines from source files

5. Commit with descriptive message

---

### 1.4 Standardize State Versions ✓

**Status**: Complete - Added clarifying comments to all 8 host/home files.

**Problem**: Mixed `stateVersion` values across hosts.

**Current state**:
| Host | Version |
|------|---------|
| sb1 | 24.11 |
| desktop, thinkpad, legion, work-intel | 25.05 |
| macbook | 25.11 |
| home.stateVersion | 25.11 |

**Steps**:

1. Document current versions in `docs/state-versions.md`:
   ```markdown
   # State Version Policy

   ## Rules
   - State version is set at install time
   - Only update when performing major upgrades
   - Never change retroactively on existing systems

   ## Current Versions
   | Host | System | Home | Install Date |
   |------|--------|------|--------------|
   | sb1 | 24.11 | 25.11 | 2024-11 |
   ...
   ```

2. Add comment in each host's `default.nix`:
   ```nix
   # stateVersion set at initial install - do not change
   system.stateVersion = "25.05";
   ```

3. Consider adding assertion to catch mismatches:
   ```nix
   # In profiles/base/default.nix
   assertions = [{
     assertion = config.system.stateVersion != "";
     message = "stateVersion must be explicitly set per-host";
   }];
   ```

---

## Phase 2: Medium Impact

These require more changes but significantly improve maintainability.

### 2.1 Create Laptop Profile

**Problem**: Power management, trackpad, lid handling duplicated across 4 laptop hosts.

**Hosts affected**: thinkpad, work-intel, legion, macbook

**Steps**:

1. Create profile directory:
   ```bash
   mkdir -p profiles/laptop
   ```

2. Create `profiles/laptop/default.nix`:
   ```nix
   { config, lib, pkgs, ... }:
   {
     imports = [
       ./power-management.nix
       ./input-devices.nix
       ./firmware.nix
     ];

     # Common laptop settings
     services.logind = {
       lidSwitch = "suspend";
       lidSwitchExternalPower = "lock";
     };

     # Enable laptop-mode-tools alternative
     services.thermald.enable = true;
   }
   ```

3. Create `profiles/laptop/power-management.nix`:
   ```nix
   { config, lib, pkgs, ... }:
   {
     # TLP for battery optimization
     services.tlp = {
       enable = true;
       settings = {
         CPU_SCALING_GOVERNOR_ON_AC = "performance";
         CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
         # ... common settings
       };
     };

     # Power profiles daemon (alternative)
     services.power-profiles-daemon.enable = lib.mkDefault false;
   }
   ```

4. Create `profiles/laptop/input-devices.nix`:
   ```nix
   { config, lib, pkgs, ... }:
   {
     services.libinput = {
       enable = true;
       touchpad = {
         tapping = true;
         naturalScrolling = true;
         clickMethod = "clickfinger";
       };
     };

     hardware.trackpoint = {
       enable = lib.mkDefault true;
       emulateWheel = true;
     };
   }
   ```

5. Create `profiles/laptop/firmware.nix`:
   ```nix
   { config, lib, pkgs, ... }:
   {
     services.fwupd.enable = true;
     hardware.enableRedistributableFirmware = true;
   }
   ```

6. Update laptop hosts to use profile:
   ```nix
   # hosts/thinkpad/default.nix
   imports = [
     ../../profiles/laptop
     # ... other imports
   ];

   # Override only what's different
   hardware.trackpoint.sensitivity = 200;
   ```

7. Test each laptop host:
   ```bash
   nixos-rebuild build --flake .#thinkpad
   nixos-rebuild build --flake .#legion
   nixos-rebuild build --flake .#work-intel
   ```

---

### 2.2 Create Display Manager Profile ✓

**Status**: Complete - Created `profiles/display-manager/` with sddm-wayland.nix (default) and sddm-x11.nix variants.

**Problem**: SDDM, GDM, X11/Wayland configuration scattered across 5+ files.

**Steps**:

1. Create `profiles/display-manager/` directory

2. Create `profiles/display-manager/sddm-wayland.nix`:
   ```nix
   { config, lib, pkgs, ... }:
   {
     services.displayManager.sddm = {
       enable = true;
       wayland.enable = true;
       theme = "catppuccin-mocha";
       # ... theme configuration
     };

     # Disable conflicting DMs
     services.xserver.displayManager.gdm.enable = false;
   }
   ```

3. Create `profiles/display-manager/sddm-x11.nix` for work-intel

4. Create `profiles/display-manager/gnome.nix` for macbook

5. Update `hosts/*/meta.nix` to specify display manager:
   ```nix
   {
     displayManager = "sddm-wayland"; # or "sddm-x11", "gnome"
   }
   ```

6. Update host configs to use appropriate profile

---

### 2.3 Standardize Import Syntax ✓

**Status**: Complete - Standardized imports in 5 files to use direct paths for non-parameterized imports.

**Problem**: 4 different import patterns used across 27 files.

**Target pattern**:
```nix
# For modules (no parameters needed)
imports = [
  ./hardware-configuration.nix
  ./networking.nix
];

# For parameterized imports
imports = [
  (import ../../profiles/base { inherit inputs username; })
];
```

**Steps**:

1. Find all imports:
   ```bash
   grep -r "import\s" --include="*.nix" . | head -50
   ```

2. Create sed script for common patterns:
   ```bash
   # Fix extra parentheses pattern
   sed -i 's/( import/import/g' **/*.nix
   sed -i 's/\.nix )/\.nix)/g' **/*.nix
   ```

3. Manual review for edge cases

4. Add to `CLAUDE.md` under conventions:
   ```markdown
   ## Import Conventions
   - Direct: `./module.nix`
   - Parameterized: `(import ./module.nix { inherit inputs; })`
   - No extra spaces or parentheses
   ```

---

### 2.4 Extract Package Sets

**Problem**: Related packages scattered across many files without clear organization.

**Steps**:

1. Create `lib/package-sets.nix`:
   ```nix
   { pkgs }:
   {
     # Graphics and display
     graphics = with pkgs; [
       mesa
       mesa-demos
       vulkan-tools
       vulkan-loader
       libva-utils
     ];

     # Audio tools
     audio = with pkgs; [
       pavucontrol
       pamixer
       playerctl
     ];

     # System monitoring
     monitoring = with pkgs; [
       htop
       btop
       lm_sensors
       powertop
       nvtop
     ];

     # Development basics
     devBasics = with pkgs; [
       git
       curl
       wget
       jq
       ripgrep
       fd
     ];

     # Terminal utilities
     terminal = with pkgs; [
       eza
       bat
       fzf
       zoxide
       starship
     ];

     # Networking tools
     networking = with pkgs; [
       nmap
       dig
       traceroute
       netcat
     ];
   }
   ```

2. Update `core/modules/packages.nix`:
   ```nix
   { config, lib, pkgs, ... }:
   let
     sets = import ../../lib/package-sets.nix { inherit pkgs; };
   in
   {
     environment.systemPackages =
       sets.graphics ++
       sets.monitoring ++
       sets.devBasics ++
       [ /* host-specific packages */ ];
   }
   ```

3. Update individual hosts to reference sets

4. Test all hosts build correctly

---

## Phase 3: Code Quality Improvements

### 3.1 Add Nix Linting

**Steps**:

1. Add statix to dev shell in `flake.nix`:
   ```nix
   devShells.x86_64-linux.default = pkgs.mkShell {
     packages = with pkgs; [
       statix
       deadnix
       nixfmt-rfc-style
     ];
   };
   ```

2. Create `.statix.toml`:
   ```toml
   disabled = [
     "empty_pattern"
   ]
   ```

3. Add lint check script `scripts/lint.sh`:
   ```bash
   #!/usr/bin/env bash
   set -e
   echo "Running statix..."
   statix check .
   echo "Running deadnix..."
   deadnix -f .
   echo "All checks passed!"
   ```

4. Add to flake checks:
   ```nix
   checks.x86_64-linux.lint = pkgs.runCommand "lint" {} ''
     cd ${./.}
     ${pkgs.statix}/bin/statix check .
     touch $out
   '';
   ```

---

### 3.2 Extract Flake Helper Functions ✓

**Status**: Complete - Extracted `mkNixosConfiguration` and `mkHeadlessConfiguration` to `lib/host-builders.nix`.

**Problem**: `flake.nix` contains large inline function definitions.

**Steps**:

1. Create `lib/host-builders.nix`:
   ```nix
   { nixpkgs, inputs, ... }:
   {
     mkNixosConfiguration = {
       hostname,
       system ? "x86_64-linux",
       extraModules ? [],
       includeGaming ? true
     }:
       nixpkgs.lib.nixosSystem {
         inherit system;
         specialArgs = { inherit inputs hostname; };
         modules = [
           ./hosts/${hostname}
           ./profiles/base
         ] ++ extraModules
           ++ nixpkgs.lib.optionals includeGaming [ ./home/gaming.nix ];
       };

     mkHomeConfiguration = { username, hostname, ... }:
       inputs.home-manager.lib.homeManagerConfiguration {
         # ...
       };
   }
   ```

2. Update `flake.nix` to import:
   ```nix
   let
     builders = import ./lib/host-builders.nix { inherit nixpkgs inputs; };
   in
   {
     nixosConfigurations = {
       desktop = builders.mkNixosConfiguration { hostname = "desktop"; };
       # ...
     };
   }
   ```

---

### 3.3 Document Module Structure Rules

**Steps**:

1. Add to `CLAUDE.md`:
   ```markdown
   ## Module Structure Rules

   ### When to use a directory
   - Module has 100+ lines
   - Module has sub-components (e.g., hyprland has keybinds, rules, etc.)
   - Module requires local assets (scripts, configs, themes)

   ### When to use a single file
   - Module is < 100 lines
   - Module is self-contained
   - No local assets needed

   ### Naming
   - Directories: `modules/<name>/default.nix`
   - Single files: `modules/<name>.nix`
   - Never mix both patterns for same logical module
   ```

2. Refactor inconsistent modules to match rules

---

### 3.4 Fix QML Path Duplication in QuickShell ✓

**Status**: Complete - Extracted `qmlImportPaths` to let binding, reduced 4 duplications to 1.

**File**: `home/modules/quickshell.nix`

**Problem**: `QML2_IMPORT_PATH` concatenation appears twice.

**Steps**:

1. Extract to let binding:
   ```nix
   let
     qmlImportPath = lib.concatStringsSep ":" [
       "${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml"
       "${pkgs.kdePackages.qtwayland}/lib/qt-6/qml"
       # ... all paths
     ];
   in
   {
     systemd.user.services.quickshell.Service.Environment = [
       "QML2_IMPORT_PATH=${qmlImportPath}"
     ];

     home.sessionVariables.QML2_IMPORT_PATH = qmlImportPath;
   }
   ```

---

## Phase 4: Future Considerations

### 4.1 Hybrid GPU Abstraction

Create `core/drivers/hybrid-gpu.nix` for Legion and work-intel:
```nix
{ mode ? "offload" # "offload" or "sync"
, intelBusId
, nvidiaBusId
}:
{ config, lib, pkgs, ... }:
{
  hardware.nvidia = {
    modesetting.enable = true;
    prime = {
      ${mode}.enable = true;
      intelBusId = intelBusId;
      nvidiaBusId = nvidiaBusId;
    };
  };
}
```

### 4.2 SSH Configuration Consolidation

Move from scattered configs to `profiles/ssh/`:
- Client config
- Server config (optional)
- Firewall rules
- Host aliases from meta.nix

### 4.3 Secrets Management Audit

Review `secrets/*.yaml` for:
- Unused secrets
- Secrets that could be removed
- Documentation of what each secret is for

---

## Testing Checklist

After each phase, verify:

- [ ] All hosts build: `nix flake check`
- [ ] Desktop builds: `nixos-rebuild build --flake .#desktop`
- [ ] Laptop builds: `nixos-rebuild build --flake .#thinkpad`
- [ ] No regressions in functionality
- [ ] Commit each logical change separately

---

## Recommended Order

1. ~~**Phase 1.3** - Remove dead code (quick win, reduces noise)~~ ✓
2. ~~**Phase 1.1** - Extract color scheme (high duplication impact)~~ ✓
3. ~~**Phase 1.2** - Centralize NVIDIA env (high duplication impact)~~ ✓
4. ~~**Phase 2.1** - Create laptop profile (biggest structural improvement)~~ ✓
5. ~~**Phase 2.4** - Extract package sets (improves organization)~~ ✓
6. ~~**Phase 3.1** - Add linting (prevents future issues)~~ ✓
7. ~~**Phase 2.3** - Standardize import syntax~~ ✓
8. ~~**Phase 3.2** - Extract flake helper functions~~ ✓
9. ~~**Phase 3.4** - Fix QML path duplication~~ ✓

**Remaining tasks:**
- Phase 3.3 - Document module structure rules
- Phase 4.x - Future considerations (Hybrid GPU, SSH consolidation, Secrets audit)

Each step should be a separate commit for easy rollback.
