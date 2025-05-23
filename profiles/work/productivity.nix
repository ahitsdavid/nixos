# profiles/work/productivity.nix
{ pkgs, ... }: {
  # Productivity tools
  environment.systemPackages = with pkgs; [
    pandoc
    texlive.combined.scheme-full
    obsidian
    zotero
  ];
}
