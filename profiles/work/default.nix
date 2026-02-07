#profiles/work/default.nix
{ inputs, username }:
{ config, pkgs, ... }: {
  imports = [
    ./productivity.nix
    ./certification.nix
  ];

  # Work-related packages
  environment.systemPackages = with pkgs; [
    libreoffice
    drawio
    remmina
    qtcreator
  ];

  # Work-specific settings
  networking.firewall.allowedTCPPorts = [ 3389 ];

  # Printing support
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint pkgs.hplip ];

  # Scanner support
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
}
