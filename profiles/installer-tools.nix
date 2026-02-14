# profiles/installer-tools.nix
# All tools required by scripts/install.sh
# Import this on any host that may run the install script
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Partitioning
    parted
    gptfdisk       # gdisk
    util-linux     # lsblk, cfdisk, mkswap

    # Encryption
    cryptsetup

    # LVM
    lvm2

    # Filesystem tools (all supported by install.sh)
    e2fsprogs      # ext4
    btrfs-progs    # btrfs
    xfsprogs       # xfs
    f2fs-tools     # f2fs
    dosfstools     # FAT32 (boot partition)
    bcachefs-tools # bcachefs
  ];
}
