#home/modules/vscode.nix 
{ pkgs, ... } :
{
  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          ms-python.python
          jnoortheen.nix-ide
          esbenp.prettier-vscode
          # catppuccin.catppuccin-vsc  # Remove color theme - let Stylix handle
          catppuccin.catppuccin-vsc-icons  # Keep icons - Stylix doesn't handle these
          ms-vscode.cmake-tools
          ms-vscode-remote.remote-ssh
          ];
        userSettings = {
          # Let Stylix handle font and theme settings
          "editor.fontLigatures" = true;
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
  
          # Language-specific settings
          "[nix]" = {
            "editor.tabSize" = 2;
          };
        };
      };
    };
  };
}