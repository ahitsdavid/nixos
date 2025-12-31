# UNRAID SSH Key Setup with SOPS

This guide explains how to set up your UNRAID SSH key management using SOPS-Nix, so your SSH access persists across NixOS rebuilds.

## What We've Configured

### 1. Home-Manager SSH Module (`home/modules/ssh.nix`)
- Configures SSH client with a `unraid` host alias
- You can now connect using: `ssh unraid` (instead of `ssh root@192.168.1.29`)
- Points to the SSH key that will be managed by SOPS

### 2. SOPS Secret Configuration (`core/modules/sops.nix`)
- Added `ssh/unraid_private_key` to personal secrets
- Will automatically deploy your private key to `~/.ssh/unraid_ed25519`
- Sets correct permissions (0400 - read-only for you)

## How to Add Your SSH Private Key to SOPS

### Step 1: Check if personal.yaml exists

```bash
ls -la secrets/personal.yaml
```

If it doesn't exist, create it from the template:

```bash
cd ~/nixos
cp secrets/personal.yaml.example secrets/personal.yaml
```

### Step 2: Edit personal.yaml with SOPS

```bash
sops secrets/personal.yaml
```

This will open your encrypted secrets file in your default editor.

### Step 3: Add the SSH key section

Add this section to your `personal.yaml` file:

```yaml
# SSH keys for personal servers
ssh:
  unraid_private_key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    [paste your entire private key here]
    -----END OPENSSH PRIVATE KEY-----
```

### Step 4: Get your private key content

In another terminal, display your current private key:

```bash
cat ~/.ssh/id_rsa
```

Copy the **entire output** (including the BEGIN and END lines) and paste it into the `unraid_private_key` field in the SOPS editor.

**IMPORTANT**: The `|` character after the colon means "literal block scalar" in YAML - it preserves newlines and formatting. Make sure your key content is indented by 2-4 spaces relative to the key name.

Example structure:
```yaml
ssh:
  unraid_private_key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
    [... many more lines ...]
    -----END OPENSSH PRIVATE KEY-----
```

### Step 5: Save and exit

- If using vim: Press `ESC`, then type `:wq` and press Enter
- If using nano: Press `Ctrl+X`, then `Y`, then Enter
- The file will be automatically encrypted when you save

### Step 6: Update the SSH module to use the correct key

Since your current key is RSA (not ED25519), we need to update the SSH module:

```bash
# Edit the SSH module
nano home/modules/ssh.nix
```

Change the `identityFile` line from:
```nix
identityFile = "${config.home.homeDirectory}/.ssh/unraid_ed25519";
```

To:
```nix
identityFile = "${config.home.homeDirectory}/.ssh/unraid_rsa";
```

And update the SOPS path in `core/modules/sops.nix` from:
```nix
path = "/home/davidthach/.ssh/unraid_ed25519";
```

To:
```nix
path = "/home/davidthach/.ssh/unraid_rsa";
```

### Step 7: Commit and rebuild

```bash
# Add all changes to git (required for NixOS rebuild)
git add .

# Commit the changes
git commit -m "Add UNRAID SSH key management with SOPS"

# Rebuild NixOS
sudo nixos-rebuild switch --flake .#thinkpad
```

## How It Works After Rebuild

1. **SOPS decrypts your private key** and places it at `~/.ssh/unraid_rsa` with mode `0400`
2. **Home-manager configures SSH** to use this key for the `unraid` host
3. **You can connect using**: `ssh unraid` (no password needed!)

## Testing Your Connection

After rebuild, test your connection:

```bash
# Using the host alias
ssh unraid

# Or the traditional way (should also work)
ssh root@192.168.1.29
```

Both should work without asking for a password!

## Security Notes

- Your private key is **encrypted at rest** using age encryption
- Only decrypted during NixOS activation
- The decrypted key has restrictive permissions (0400)
- The encrypted secrets file can be safely committed to git
- Only someone with your age key can decrypt the secrets

## Troubleshooting

### Permission denied (publickey)
- Check that your public key is in `/root/.ssh/authorized_keys` on UNRAID
- Verify the key was deployed: `ls -la ~/.ssh/unraid_rsa`
- Check permissions: `ls -la ~/.ssh/unraid_rsa` (should be `-r--------`)

### File not found
- Make sure you committed your changes to git before rebuilding
- Check that `secrets/personal.yaml` exists and has the SSH key

### SOPS editor won't open
- Ensure you have your age key at `~/.config/sops/age/keys.txt`
- Check `~/.sops.yaml` configuration

## Alternative: Generate New SSH Key (Optional)

If you prefer to create a new, modern ED25519 key specifically for UNRAID:

```bash
# Generate new ED25519 key
ssh-keygen -t ed25519 -f ~/.ssh/unraid_temp -C "unraid-access"

# Copy public key to UNRAID
ssh-copy-id -i ~/.ssh/unraid_temp.pub root@192.168.1.29

# Add the new private key to SOPS
cat ~/.ssh/unraid_temp

# Then update the paths in your config to use unraid_ed25519
# And delete the temporary files after adding to SOPS
rm ~/.ssh/unraid_temp ~/.ssh/unraid_temp.pub
```

ED25519 keys are more secure, faster, and have smaller keys than RSA.
