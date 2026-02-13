# Host metadata for SSH aliases and other tooling
{
  sshAlias = "sm";
  description = "MacBook Pro 2014";

  # Capabilities
  hasNvidia = false;
  isGaming = false;
  isHeadless = false;
  isLaptop = true;
  usesGnome = true;
  isWork = true;

  # Monitor configuration
  monitors = [
    "eDP-1,2880x1800@60,0x0,1.5"  # MacBook Pro Retina display
  ];
}
