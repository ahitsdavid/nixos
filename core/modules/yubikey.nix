{ pkgs, lib, config, ... }:
{
  # YubiKey packages
  environment.systemPackages = with pkgs; [
    yubikey-personalization  # Tools for personalization of YubiKey
    yubikey-manager          # CLI and GUI for YubiKey management
    yubico-pam               # PAM module for YubiKey authentication
    pam_u2f                  # Alternative FIDO2/U2F support
  ];

  # Enable pcscd for smart card functionality
  services.pcscd.enable = true;

  # udev rules for YubiKey
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # PAM configuration for Challenge-Response authentication
  security.pam.services = {
    # Login (SDDM)
    login.yubicoAuth = true;

    # Sudo
    sudo.yubicoAuth = true;

    # Screen unlock
    hyprlock.yubicoAuth = true;
  };

  # YubiKey Challenge-Response configuration
  security.pam.yubico = {
    enable = true;
    mode = "challenge-response";

    # Debug mode - set to false after enrollment works
    debug = false;

    # Control mode: sufficient means YubiKey OR password works
    # If YubiKey succeeds, skip password. If it fails, try password.
    control = "sufficient";
  };
}
