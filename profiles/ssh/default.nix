# profiles/ssh/default.nix
# Consolidated SSH server configuration
{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable = true;

    settings = {
      # Security hardening
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
      KbdInteractiveAuthentication = false;

      # Limit authentication attempts
      MaxAuthTries = 3;

      # Disable X11 forwarding by default (enable per-host if needed)
      X11Forwarding = lib.mkDefault false;
    };

    # Use modern key exchange algorithms
    extraConfig = ''
      # Prefer modern algorithms
      KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
    '';
  };

  # Note: Port 22 is opened in core/modules/networking.nix
  # If you need custom ports, override networking.firewall.allowedTCPPorts
}
