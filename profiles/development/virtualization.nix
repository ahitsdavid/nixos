# profiles/development/virtualization.nix
{ inputs }:
{ config, pkgs, lib, ... }:
{
  # Enable libvirtd for QEMU/KVM virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;  # TPM emulation for Windows 11
      # OVMF (UEFI) is now available by default
      vhostUserPackages = [ pkgs.virtiofsd ];  # For shared folders
    };
  };

  # Create and autostart the default NAT network
  systemd.services.libvirt-default-network = {
    description = "Libvirt Default Network Setup";
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Wait for libvirtd socket
      sleep 2

      # Define default network if it doesn't exist
      if ! ${pkgs.libvirt}/bin/virsh net-info default &>/dev/null; then
        ${pkgs.libvirt}/bin/virsh net-define ${pkgs.writeText "default-network.xml" ''
          <network>
            <name>default</name>
            <forward mode="nat"/>
            <bridge name="virbr0" stp="on" delay="0"/>
            <ip address="192.168.122.1" netmask="255.255.255.0">
              <dhcp>
                <range start="192.168.122.2" end="192.168.122.254"/>
              </dhcp>
            </ip>
          </network>
        ''}
      fi

      # Start network if not active
      if ! ${pkgs.libvirt}/bin/virsh net-info default 2>/dev/null | grep -q "Active:.*yes"; then
        ${pkgs.libvirt}/bin/virsh net-start default || true
      fi

      # Enable autostart
      ${pkgs.libvirt}/bin/virsh net-autostart default || true
    '';
  };

  # Install virt-manager and related tools at system level
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice-gtk  # For USB redirection and clipboard sharing
    virtio-win  # VirtIO drivers for Windows guests
  ];

  # Enable dconf for virt-manager settings persistence
  programs.dconf.enable = true;

  # Set default libvirt connection URI
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";
}
