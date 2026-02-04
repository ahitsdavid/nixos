{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    claude-code
  ];

  # SSL certificates for proper auth
  home.sessionVariables = {
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  programs.zsh.shellAliases = {
    claude-debug = "claude --verbose";
  };
}