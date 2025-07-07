# SOPS-Nix Setup Guide

This guide will help you set up SOPS-Nix for managing secrets in this NixOS configuration.

## 🚀 Quick Start (For New Users/Forks)

### 1. Generate Your Age Key

```bash
# Create the sops config directory
mkdir -p ~/.config/sops/age

# Generate your private key (KEEP THIS SAFE!)
age-keygen -o ~/.config/sops/age/keys.txt

# Your public key will be displayed, copy it!
# It looks like: age1abc123def456ghi789...
```

### 2. Update SOPS Configuration

Edit `.sops.yaml` and add your public key:

```yaml
keys:
  - &yourusername age1abc123def456ghi789...  # Your public key here

creation_rules:
  - path_regex: secrets/system\.yaml$
    key_groups:
    - age:
      - *yourusername
```

### 3. Create Your Secrets

```bash
# Copy the templates and create your actual secrets
cp secrets/system.yaml.example secrets/system.yaml
cp secrets/personal.yaml.example secrets/personal.yaml

# Edit your secrets (this will encrypt them automatically)
sops secrets/system.yaml
sops secrets/personal.yaml
```

### 4. Test & Rebuild

```bash
# Test that you can decrypt
sops -d secrets/system.yaml

# Rebuild your system
sudo nixos-rebuild switch --flake .#yourhostname
```

## 📚 Detailed Setup

### Understanding the Structure

```
nixos/
├── .sops.yaml                    # SOPS configuration (who can decrypt what)
├── secrets/                      # Encrypted secrets directory
│   ├── system.yaml              # System-wide secrets (WiFi, VPN)
│   ├── personal.yaml            # Your personal API keys
│   ├── work.yaml                # Work-related secrets
│   ├── *.yaml.example           # Templates for new users
├── core/modules/sops.nix        # SOPS-Nix integration
└── examples/sops-usage.nix     # Usage examples
```

### What Gets Committed to Git?

✅ **Safe to commit:**
- `.sops.yaml` (configuration)
- `secrets/*.yaml` (encrypted secrets)
- `secrets/*.yaml.example` (templates)
- All NixOS configuration files

❌ **NEVER commit:**
- `~/.config/sops/age/keys.txt` (your private key!)
- Unencrypted secret files

### Managing Multiple Machines

Add all your machine keys to `.sops.yaml`:

```yaml
keys:
  - &desktop age1abc123...    # Desktop key
  - &laptop age1def456...     # Laptop key  
  - &server age1ghi789...     # Server key

creation_rules:
  - key_groups:
    - age:
      - *desktop
      - *laptop
      - *server
```

## 🛠️ Common Operations

### Creating/Editing Secrets

```bash
# Edit system secrets
sops secrets/system.yaml

# Edit personal secrets  
sops secrets/personal.yaml

# Create new secret file
sops secrets/new-secrets.yaml
```

### Moving to a New Machine

1. **Backup your private key:**
   ```bash
   cp ~/.config/sops/age/keys.txt /backup/location/
   ```

2. **On new machine:**
   ```bash
   mkdir -p ~/.config/sops/age
   cp /backup/location/keys.txt ~/.config/sops/age/
   chmod 600 ~/.config/sops/age/keys.txt
   ```

3. **Clone and rebuild:**
   ```bash
   git clone https://github.com/youruser/nixos-config
   cd nixos-config
   sudo nixos-rebuild switch --flake .#yourhostname
   ```

### Adding Team Members

1. **Get their public key:**
   ```bash
   # They run this and give you the public key
   age-keygen | grep "public key:"
   ```

2. **Add to `.sops.yaml`:**
   ```yaml
   keys:
     - &you age1your_key...
     - &teammate age1their_key...
   ```

3. **Re-encrypt secrets:**
   ```bash
   sops updatekeys secrets/system.yaml
   sops updatekeys secrets/personal.yaml
   ```

## 🔧 Usage Examples

### WiFi Networks

```nix
# In your configuration
networking.wireless.networks = lib.mkIf (config.sops.secrets ? "wifi/home_network") {
  "YourNetworkName" = {
    pskFile = config.sops.secrets."wifi/home_network".path;
  };
};
```

### API Keys for Scripts

```nix
# Create a script that uses secrets
environment.systemPackages = [
  (pkgs.writeShellScriptBin "weather-check" ''
    API_KEY=$(cat ${config.sops.secrets."api_keys/weather".path})
    curl "http://api.openweathermap.org/data/2.5/weather?appid=$API_KEY&q=YourCity"
  '')
];
```

### User Service with Secrets

```nix
systemd.user.services.backup = {
  script = ''
    ${pkgs.rsync}/bin/rsync -e "${pkgs.openssh}/bin/ssh -i ${config.sops.secrets."ssh/backup_key".path}" \
      /home/user/ backup@server:/backups/
  '';
};
```

## 🚨 Security Notes

- **Keep your private key safe!** If you lose it, you can't decrypt your secrets
- **Backup your private key** in a secure location (password manager, encrypted USB)
- **Never commit private keys** to git
- **Use different keys for different purposes** (personal vs work)
- **Regularly rotate secrets** especially if team members change

## 🐛 Troubleshooting

### "Failed to decrypt" errors
- Check that `~/.config/sops/age/keys.txt` exists and has correct permissions (600)
- Verify your public key is in `.sops.yaml`
- Make sure the secret file was encrypted with your key

### "No such file or directory" 
- The configuration tries to use secrets that don't exist
- Either create the secret file or disable that part of the config

### "Permission denied"
- Check file ownership and permissions in `/run/secrets/`
- Secrets are owned by the user/group specified in the config

## 📖 More Information

- [SOPS-Nix Documentation](https://github.com/Mic92/sops-nix)
- [SOPS Documentation](https://github.com/mozilla/sops)
- [Age Encryption](https://github.com/FiloSottile/age)

## 🤝 Contributing Secrets

When contributing to this repository:

1. **Never commit real secrets** - only commit encrypted `.yaml` files
2. **Update templates** when adding new secret types
3. **Document usage** in `examples/sops-usage.nix`
4. **Test fork-friendliness** - ensure config works without secrets