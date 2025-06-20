#home/modules/vscode.nix 
{ pkgs, ... } :
{
  vscode = {
    enable = true;
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          ms-python.python
          jnoortheen.nix-ide
          esbenp.prettier-vscode
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
          ms-vscode.cmake-tools
          ms-vscode-remote.remote-ssh
          ];
        userSettings = {
          "editor.fontSize" = 14;
          "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'JetBrains Mono', monospace";
          "editor.fontLigatures" = true;
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          # Workbench settings
          "workbench.colorTheme" = "Catppuccin Mocha";
  
          # Language-specific settings
          "[nix]" = {
            "editor.tabSize" = 2;
          };
        };
      };
    };
  };
}