# Home-manager configuration for Claude Code
# Add this to your home.nix or home-manager config

{ config, pkgs, ... }:

{
  # Install claude-code via home-manager
  home.packages = with pkgs; [
    claude-code
    
    # Optional: helpful development tools
    git
    curl
  ];

  # Set up SSL certificates for proper auth
  home.sessionVariables = {
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  # Optional: Add shell aliases for convenience
  programs.bash.shellAliases = {
    claude-debug = "claude --verbose";
  };
  
  # Or if you use zsh:
  programs.zsh.shellAliases = {
    claude-debug = "claude --verbose";
  };
}

# After updating your home-manager config:
# 1. home-manager switch
# 2. claude auth login
# 3. Test with: claude --help