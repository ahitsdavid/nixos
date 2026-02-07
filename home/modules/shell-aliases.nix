# home/modules/shell-aliases.nix
# Shared aliases for all shells (Zsh, Fish, Bash)
{ username }:

let
  # Import central Tailscale hosts definition
  tailscaleHosts = import ./tailscale-hosts.nix;

  # Generate SSH aliases from hosts: { sd = "ssh user@desktop"; sl = "ssh user@legion"; ... }
  sshAliases = builtins.listToAttrs (
    builtins.map (name: {
      name = tailscaleHosts.${name}.alias;
      value = "ssh ${username}@${name}";
    }) (builtins.attrNames tailscaleHosts)
  );
in
{
  shellAliases = {
    v = "nvim";
    sv = "sudo nvim";
    c = "clear";
    list-generations = "nixos-rebuild list-generations";
    collect-garbage = "sudo nix-collect-garbage -d";

    # Arch container fastfetch
    ff-arch = "distrobox enter arch -- fastfetch --config /etc/fastfetch/config.jsonc";
  } // sshAliases;  # Merge in dynamically generated SSH aliases
}
