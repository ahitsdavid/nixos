# home/modules/shell-aliases.nix
# Shared aliases for all shells (Zsh, Fish, Bash)
{
  shellAliases = {
    v = "nvim";
    sv = "sudo nvim";
    c = "clear";
    list-generations = "nixos-rebuild list-generations";
    collect-garbage = "sudo nix-collect-garbage -d";

    # Arch container fastfetch
    ff-arch = "distrobox enter arch -- fastfetch --config /etc/fastfetch/config.jsonc";
  };
}
