# home/modules/virtualization.nix
# User-level virt-manager configuration
# System-level libvirtd and packages are in profiles/development/virtualization.nix
{ pkgs, lib, ... }: {
  # Configure virt-manager default connection via dconf
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
