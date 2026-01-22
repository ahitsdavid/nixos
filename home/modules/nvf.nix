{ inputs, config, lib, pkgs, ... }:
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
        bash.enable = true;
        yaml.enable = true;
        lua.enable = true;
      };

      options = {
        tabstop = 2;
        shiftwidth = 2;
        wrap = false;
        mouse = "a";           # Enable mouse support
        number = true;         # Line numbers
        relativenumber = true; # Relative line numbers
        signcolumn = "yes";    # Always show sign column
        cursorline = true;     # Highlight current line
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


      statusline.lualine = {
        enable = true;
        theme = lib.mkForce "catppuccin";
      };
      telescope.enable = true;
      autocomplete.nvim-cmp.enable = true;
      projects.project-nvim.enable = true;
      dashboard.dashboard-nvim.enable = true;
      filetree.neo-tree = {
        enable = true;
        setupOpts = {
          close_if_last_window = true;
          enable_git_status = true;
          enable_diagnostics = true;
          filesystem = {
            follow_current_file = {
              enabled = true;
            };
          };
        };
      };

      luaConfigRC.neo-tree-autoopen = ''
        vim.api.nvim_create_autocmd("VimEnter", {
          callback = function()
            if vim.fn.argc() > 0 then
              require("neo-tree.command").execute({ action = "show" })
            end
          end,
        })
      '';

      # Auto-reload files when changed externally (e.g., by Claude Code)
      luaConfigRC.auto-reload = ''
        vim.o.autoread = true
        vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
          command = "checktime",
        })
      '';

      # QML language server setup
      luaConfigRC.qmlls = ''
        -- Register QML filetype
        vim.filetype.add({
          extension = {
            qml = "qml",
            qmljs = "qml",
          },
        })

        -- Setup qmlls (Qt QML Language Server)
        local lspconfig = require("lspconfig")
        lspconfig.qmlls.setup({
          cmd = { "${pkgs.kdePackages.qtdeclarative}/bin/qmlls" },
          filetypes = { "qml", "qmljs" },
          root_dir = lspconfig.util.root_pattern("CMakeLists.txt", ".git", "*.qmlproject"),
        })
      '';

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
        vim-fugitive.enable = true;
      };

      debugger.nvim-dap = {
        enable = true;
        ui.enable = true;
      };

      utility = {
        surround.enable = true;
        motion.leap.enable = true;
      };

      comments.comment-nvim.enable = true;
      autopairs.nvim-autopairs.enable = true;
      tabline.nvimBufferline.enable = true;
      notify.nvim-notify.enable = true;

      # User-friendly keybinds
      maps = {
        normal = {
          # === Claude Code ===
          "<leader>cc" = {
            action = ":vsplit | terminal claude<CR>";
            desc = "Claude Code (vertical)";
          };
          "<leader>ch" = {
            action = ":split | terminal claude<CR>";
            desc = "Claude Code (horizontal)";
          };

          # === Terminal ===
          "<leader>tv" = {
            action = ":vsplit | terminal<CR>";
            desc = "Terminal (vertical)";
          };
          "<leader>th" = {
            action = ":split | terminal<CR>";
            desc = "Terminal (horizontal)";
          };
          "<leader>tt" = {
            action = ":tabnew | terminal<CR>";
            desc = "Terminal (new tab)";
          };

          # === File operations (familiar shortcuts) ===
          "<C-s>" = {
            action = ":w<CR>";
            desc = "Save file";
          };
          "<C-q>" = {
            action = ":q<CR>";
            desc = "Close window";
          };

          # === File/Project navigation ===
          "<C-p>" = {
            action = ":Telescope find_files<CR>";
            desc = "Find files";
          };
          "<C-f>" = {
            action = ":Telescope live_grep<CR>";
            desc = "Search in project";
          };
          "<leader>e" = {
            action = ":Neotree toggle<CR>";
            desc = "Toggle file tree";
          };
          "<leader>o" = {
            action = ":Neotree focus<CR>";
            desc = "Focus file tree";
          };

          # === Buffer navigation ===
          "<Tab>" = {
            action = ":bnext<CR>";
            desc = "Next buffer";
          };
          "<S-Tab>" = {
            action = ":bprevious<CR>";
            desc = "Previous buffer";
          };
          "<leader>x" = {
            action = ":bdelete<CR>";
            desc = "Close buffer";
          };
          "<leader>b" = {
            action = ":Telescope buffers<CR>";
            desc = "List buffers";
          };

          # === Window navigation ===
          "<C-h>" = {
            action = "<C-w>h";
            desc = "Move to left window";
          };
          "<C-j>" = {
            action = "<C-w>j";
            desc = "Move to bottom window";
          };
          "<C-k>" = {
            action = "<C-w>k";
            desc = "Move to top window";
          };
          "<C-l>" = {
            action = "<C-w>l";
            desc = "Move to right window";
          };

          # === LSP shortcuts ===
          "gd" = {
            action = ":lua vim.lsp.buf.definition()<CR>";
            desc = "Go to definition";
          };
          "gr" = {
            action = ":Telescope lsp_references<CR>";
            desc = "Find references";
          };
          "K" = {
            action = ":lua vim.lsp.buf.hover()<CR>";
            desc = "Show hover info";
          };
          "<leader>rn" = {
            action = ":lua vim.lsp.buf.rename()<CR>";
            desc = "Rename symbol";
          };
          "<leader>ca" = {
            action = ":lua vim.lsp.buf.code_action()<CR>";
            desc = "Code actions";
          };
          "<leader>d" = {
            action = ":lua vim.diagnostic.open_float()<CR>";
            desc = "Show diagnostics";
          };

          # === Git ===
          "<leader>gg" = {
            action = ":Git<CR>";
            desc = "Git status (fugitive)";
          };
          "<leader>gb" = {
            action = ":Git blame<CR>";
            desc = "Git blame";
          };
          "<leader>gd" = {
            action = ":Git diff<CR>";
            desc = "Git diff";
          };
          "<leader>gl" = {
            action = ":Git log --oneline<CR>";
            desc = "Git log";
          };
        };

        # Insert mode
        insert = {
          "<C-s>" = {
            action = "<Esc>:w<CR>";
            desc = "Save file";
          };
        };

        # Terminal mode - easy escape
        terminal = {
          "<Esc>" = {
            action = "<C-\\><C-n>";
            desc = "Exit terminal mode";
          };
          "<C-h>" = {
            action = "<C-\\><C-n><C-w>h";
            desc = "Move to left window";
          };
          "<C-j>" = {
            action = "<C-\\><C-n><C-w>j";
            desc = "Move to bottom window";
          };
          "<C-k>" = {
            action = "<C-\\><C-n><C-w>k";
            desc = "Move to top window";
          };
          "<C-l>" = {
            action = "<C-\\><C-n><C-w>l";
            desc = "Move to right window";
          };
        };
      };

    };
  };
}