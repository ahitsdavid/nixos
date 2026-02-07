# Host metadata for SSH aliases and other tooling
{
  sshAlias = "sd";
  description = "Desktop - AMD 7800X3D + NVIDIA 3070Ti";

  # Capabilities
  hasNvidia = true;
  isGaming = true;
  isHeadless = false;
  isLaptop = false;

  # VNC
  vncServer = true;  # This host runs wayvnc for remote access

  # Monitor configuration
  monitors = [
    "DP-5,3440x1440@100,0x0,1"           # Samsung CF791 ultrawide on left
    "DP-4,1920x1080@180,3440x0,1,transform,3"  # Samsung LS27DG30X vertical on right
  ];

  # Syncthing - run `syncthing --device-id` to get this
  syncthingId = "DYEG3ZG-UAONKD7-KA6MOZF-LROKHIX-CRST5P2-37F2JH2-VENS72R-QEEC7QO";
  syncFolders = [ "Documents" ];
}
