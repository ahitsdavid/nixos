{pkgs, ...}: {
  home.packages = with pkgs; [
     virt-manager
     virt-viewer 
  ];

    home.sessionVariables = {
    LIBVIRT_DEFAULT_URI = "qemu:///system";
  };
}
