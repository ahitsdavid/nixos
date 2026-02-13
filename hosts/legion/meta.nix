# Host metadata for SSH aliases and other tooling
{
  sshAlias = "sl";
  description = "Legion - Gaming laptop";

  # Capabilities
  hasNvidia = true;
  isGaming = true;
  isHeadless = false;
  isLaptop = true;

  # Hybrid GPU: sync mode for gaming performance
  hybridGpu = {
    mode = "sync";
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
}
