# Headless build server with Harmonia binary cache
{ config, pkgs, inputs, username, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../profiles/ssh
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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9m9hi0nKZsrlHCFLLyjoFG+jkO6VpB72B7M9UJzvOhQJJq/9vXfdg4xqxMrmP7vTs1fm9RUxrK4RUFBECEmfc56ZuTw1kzGj0ABwGRj0oBDULOeHW2SwYgJv59utf5ClHWQMLsqWgKEnAfZZsQyjpdn9TF1u5XaTGjmfWYW6DiH1zw24cO7m14L/llIKN6Ex+WZT09SQ3nTQNn85fFmxuSuSz9fLDjLurGx+GhRLruF6M0bR+hFugBMTpasUDnXPb0iwe2bxfZoIQIlLnBnkQLCfnOCFAaP3dS/Z9ejDwTlVRSeaBPvXmqjVwYaoaV6+UWNCd7lhhLlBhrLy7vPAwTjuaGkIU3lXSh1IlPZ+0qLKpN+IGumPSOq21eq1Fa/FwYbxciCEBCR4kjElSNNIRlM+Nb0CAYTQ2SfgKQou/j+/LxvCUVFp5WdU9cKBzNrzQJl1orap0uGbf1YJNQ/LU43ikhpyD59R4U3y0Brqnxj5Q4Hue59sJIsf0w0kmklbtLyecQKky8lE1/BfvdMn1++AlVqIXg4ix0IkW7bZW3cpnX0mb1ejxfkK389oSx1lFIWSmfFRGpsXLxTlGBeuxqJWeKJ1as/C/yI1IDrelZsgpnZfDBCGmyYmHDTGc7AZL3SUCSwUb30gUQJvAHuSVeLYG8xQ0cdODsZjA021RAw== davidthach@live.com"
    ];
  };

  # Tailscale for easy access from other machines
  services.tailscale.enable = true;

  # SOPS secrets
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets."harmonia/signing-key" = {
    sopsFile = ../../secrets/system.yaml;
  };
  # GitHub SSH key for git operations
  sops.secrets."ssh/github_private_key" = {
    sopsFile = ../../secrets/personal.yaml;
    owner = username;
    mode = "0400";
    path = "/home/${username}/.ssh/id_rsa";
  };

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
    signKeyPaths = [ config.sops.secrets."harmonia/signing-key".path ];
    settings = {
      bind = "[::]:5000";
      priority = 50;  # Lower priority than cache.nixos.org
    };
  };

  # Git configuration (no home-manager on headless VM)
  programs.git = {
    enable = true;
    config = {
      user.name = "David Thach";
      user.email = "davidthach@live.com";
    };
  };

  # Basic packages for administration
  environment.systemPackages = with pkgs; [
    htop
    curl
    vim
  ];

  # stateVersion: Set at initial install - do not change
  system.stateVersion = "25.05";
}
