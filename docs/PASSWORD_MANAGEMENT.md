# Password Hash Management with SOPS

This guide explains how to set up declarative user password management using SOPS-encrypted password hashes in your NixOS configuration.

## Benefits

- 🔄 **Consistent credentials** across all your machines
- 🚀 **Quick deployment** - new machines get the right password automatically
- 💾 **Disaster recovery** - rebuild your system with the same login
- 🔐 **Encrypted storage** - password hashes stored safely in SOPS

## Prerequisites

- SOPS configured with age encryption
- The configuration files from this repo (sops.nix and users.nix already set up)

---

## Option 1: Use Your Existing Password Hash

If you already have a user account with a password set, extract the hash:

### Step 1: Get Your Current Password Hash

```bash
sudo cat /etc/shadow | grep YOUR_USERNAME
```

**Example output:**
```
davidthach:$y$j9T$0H1WWgnbW97dIO.7YP82P1$4g3UhOI9MJlyKASpAvX0kFbqSIJjtLz12GGRdcCm6s2:20231::::::
```

### Step 2: Extract the Hash

The hash is the part between the first and second `:` (colons):

```
$y$j9T$0H1WWgnbW97dIO.7YP82P1$4g3UhOI9MJlyKASpAvX0kFbqSIJjtLz12GGRdcCm6s2
```

This includes:
- `$y$` - Hash algorithm (yescrypt)
- `j9T` - Cost parameter
- The rest - Actual hash data

---

## Option 2: Generate a New Password Hash

If you want to set a new password or create a hash without changing your current password:

### Using `mkpasswd` (Recommended)

```bash
# Install mkpasswd if not available
nix-shell -p mkpasswd

# Generate a yescrypt hash (most secure, default on modern systems)
mkpasswd -m yescrypt
```

You'll be prompted to enter your desired password twice. Copy the resulting hash.

### Using `openssl`

```bash
# Generate a SHA-512 hash (older but widely supported)
openssl passwd -6
```

Enter your password when prompted. Copy the resulting hash.

---

## Adding the Hash to SOPS

### Step 1: Edit Your Secrets File

```bash
sops secrets/personal.yaml
```

### Step 2: Add the Password Hash

Add this structure (adjust username as needed):

```yaml
users:
  davidthach:
    password_hash: "$y$j9T$0H1WWgnbW97dIO.7YP82P1$..."
```

**⚠️ Important Notes:**
- Use **double quotes** around the hash (the `$` symbols need to be literal)
- Copy the **entire hash** including the algorithm prefix (`$y$`, `$6$`, etc.)
- Keep the indentation consistent with your YAML file

### Step 3: Save and Exit

SOPS will automatically encrypt the file when you save and exit.

---

## Deploying the Password

### Step 1: Commit the Encrypted Secret

```bash
git add secrets/personal.yaml
git commit -m "Add user password hash"
```

### Step 2: Rebuild Your System

```bash
sudo nixos-rebuild switch --flake ~/nixos#YOUR_HOSTNAME
```

Replace `YOUR_HOSTNAME` with your actual hostname (e.g., `thinkpad`, `desktop`, etc.)

---

## Verification

### Check the Secret Was Created

```bash
ls -la /run/secrets/users/YOUR_USERNAME/
```

You should see `password_hash` file.

### Verify the Hash Matches

```bash
# Check the SOPS secret
sudo cat /run/secrets/users/YOUR_USERNAME/password_hash

# Check what's in /etc/shadow
sudo cat /etc/shadow | grep YOUR_USERNAME | cut -d: -f2
```

Both should show the same hash. ✅

### Test Login (Safe Method)

**Don't log out yet!** Test in a new session:

1. Press `Ctrl+Alt+F2` to switch to TTY2
2. Try logging in with your username and password
3. If it works: Success! ✅
4. Press `Ctrl+Alt+F1` to return to your graphical session

---

## Multi-User / Multi-Machine Setup

### Different Users on Different Machines

Store multiple password hashes in SOPS:

```yaml
users:
  davidthach:
    password_hash: "$y$j9T$..."
  alice:
    password_hash: "$y$j9T$..."
  workuser:
    password_hash: "$6$..."
```

The configuration automatically uses the right hash based on the `username` variable set per-host in `flake.nix`.

### Same User, Different Machines

Just use the same configuration! The hash will work on all machines:

```nix
# flake.nix
thinkpad = mkNixosConfiguration { hostname = "thinkpad"; };
desktop = mkNixosConfiguration { hostname = "desktop"; };
```

Both will use the same `username` and password hash.

---

## Security Considerations

### Protect Your Age Key

Your SOPS encryption key is stored at:
```
~/.config/sops/age/keys.txt
```

**This is critical!** Anyone with this key can decrypt all your secrets.

- ✅ Back it up securely
- ✅ Keep it out of version control
- ✅ Don't share it publicly
- ❌ Never commit it to git

### Fork-Friendly Design

This configuration is fork-friendly:
- People without your secrets can still use the config
- The password hash setup is automatically skipped if secrets don't exist
- No build errors for people without SOPS configured

---

## Troubleshooting

### "No such file or directory: /run/secrets/users/..."

**Cause:** Secret wasn't created during rebuild.

**Solutions:**
1. Verify the hash is in SOPS: `sops -d secrets/personal.yaml | grep -A3 users:`
2. Ensure you committed the secrets file: `git status`
3. Rebuild after committing: `sudo nixos-rebuild switch --flake ~/nixos#hostname`

### "Password doesn't work after rebuild"

**Cause:** Hash might not match or wasn't applied.

**Solutions:**
1. Compare hashes (see Verification section above)
2. Ensure `/run/secrets/users/USERNAME/password_hash` exists
3. Check for typos in the YAML file (quotes, indentation)
4. Verify you're using the right username

### "Secret has wrong permissions"

**Cause:** Owner/mode configuration issue.

**Solution:** The secret should have:
- Owner: `root`
- Mode: `0400` (read-only for owner)

This is configured in `core/modules/sops.nix`.

---

## Related Documentation

- [SOPS-nix Documentation](https://github.com/Mic92/sops-nix)
- [NixOS User Management](https://nixos.org/manual/nixos/stable/#sec-user-management)
- [Password Hashing Schemes](https://en.wikipedia.org/wiki/Crypt_(C))

---

## Quick Reference

```bash
# Extract existing hash
sudo cat /etc/shadow | grep USERNAME | cut -d: -f2

# Generate new hash
mkpasswd -m yescrypt

# Edit secrets
sops secrets/personal.yaml

# Verify secret exists
ls -la /run/secrets/users/USERNAME/

# Compare hashes
sudo cat /run/secrets/users/USERNAME/password_hash
sudo cat /etc/shadow | grep USERNAME | cut -d: -f2
```
