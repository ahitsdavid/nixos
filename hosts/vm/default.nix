# Headless build server with Harmonia binary cache
{ config, pkgs, inputs, username, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # VM guest support (Unraid/QEMU)
  services.qemuGuest.enable = true;

  # Networking
  networking.hostName = "vm";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 5000 ];  # SSH + Harmonia
  };

  # User account
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # Add SSH public keys from your other machines here
      # Example: "ssh-ed25519 AAAAC3Nza... user@desktop"
    ];
  };

  # SSH server
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Tailscale for easy access from other machines
  services.tailscale.enable = true;

  # SOPS secrets
  sops.defaultSopsFile = ../../secrets/system.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets."harmonia/signing-key" = {};

  # Nix configuration for remote building
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" username ];
      # Allow building for other architectures if needed
      extra-platforms = [ "i686-linux" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Harmonia binary cache server
  services.harmonia = {
    enable = true;
    signKeyPath = config.sops.secrets."harmonia/signing-key".path;
    settings = {
      bind = "[::]:5000";
      priority = 50;  # Lower priority than cache.nixos.org
    };
  };

  # Basic packages for administration
  environment.systemPackages = with pkgs; [
    git
    htop
    curl
    vim
  ];

  # stateVersion: Set at initial install - do not change
  system.stateVersion = "25.05";
}
