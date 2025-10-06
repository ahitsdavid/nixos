{ inputs, config, lib, ... }:
{

  imports = [inputs.nvf.homeManagerModules.default];

  programs.nvf = {
    enable = true;
    settings.vim = {
      vimAlias = true;
      viAlias = true;
      withNodeJs = true;
      lsp.enable = true;

      theme = {
        enable = true;
        name = lib.mkForce "catppuccin";
        style = lib.mkForce "mocha";
      };
      
      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        nix.enable = true;
        clang.enable = true;
        zig.enable = true;
        python.enable = true;
        markdown.enable = true;
        ts.enable = true;
        html.enable = true;
      };

      options = {
        tabstop = 2;
        shiftwidth = 2;
        wrap = false;
      };
      
      visuals = {
        nvim-web-devicons.enable = true;
        nvim-cursorline.enable = true;
        cinnamon-nvim.enable = true;
        fidget-nvim.enable = true;
        highlight-undo.enable = true;
        indent-blankline.enable = true;
        rainbow-delimiters.enable = true;
      };


      statusline.lualine.enable = true;
      telescope.enable = true;
      autocomplete.nvim-cmp.enable = true;
      projects.project-nvim.enable = true;
      dashboard.dashboard-nvim.enable = true;
      filetree.neo-tree.enable = true;
      
      spellcheck = {
        enable = false;
      };

      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };

      git = {
        enable = true;
        gitsigns.enable = true;
        gitsigns.codeActions.enable = false; # throws an annoying debug message
      };

    };
  };
}