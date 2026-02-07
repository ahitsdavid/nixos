# Host metadata for SSH aliases and other tooling
{
  sshAlias = "sw";
  description = "Work Intel laptop";

  # Capabilities
  hasNvidia = false;
  isGaming = false;
  isHeadless = false;
  isLaptop = true;

  # Monitor configuration
  monitors = [
    "eDP-1,3840x2160@60,0x0,1.5"      # Laptop screen - HiDPI
    "DP-6,3440x1440@60,2560x0,1"       # Dell U3419W ultrawide
  ];
}
