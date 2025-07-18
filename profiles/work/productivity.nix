# profiles/work/productivity.nix
{ pkgs, ... }: {
  # Productivity tools
  environment.systemPackages = with pkgs; [
    pandoc
    obsidian
    zotero
  ];
}
