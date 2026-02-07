{ inputs }:
{ pkgs, ... }:
let
  sets = import ../../lib/package-sets.nix { inherit pkgs; };
in
{
  environment.systemPackages = with pkgs;
    sets.monitoring ++
    sets.graphics ++
    sets.archive ++
    sets.system ++
    sets.network ++
    sets.dev ++
    sets.disk ++
    sets.audio ++
    [
      # Icons and themes
      adwaita-icon-theme
      hicolor-icon-theme

      # Utilities
      bc
      brightnessctl
      cliphist
      ffmpeg
      gnupg
      killall
      mutagen
      ncspot
      nextcloud-client
      nwg-displays
      os-prober
      sbctl

      # Display manager
      tuigreet

      # Cursor
      inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
