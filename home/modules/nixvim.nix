{ inputs, config, lib, pkgs, ... }:
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Colorscheme
    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };

    # Global options
    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      mouse = "a";
      signcolumn = "yes";
      cursorline = true;
      wrap = false;
      undofile = true;
      clipboard = "unnamedplus";
      termguicolors = true;
      autoread = true;
    };

    # Extra plugins not built into nixvim
    extraPlugins = with pkgs.vimPlugins; [
      kitty-scrollback-nvim
    ];

    extraConfigLua = ''
      -- Kitty scrollback
      require('kitty-scrollback').setup()

      -- Auto-reload files when changed externally
      vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
        command = "checktime",
      })

      -- Neo-tree auto-open when opening a file
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() > 0 then
            require("neo-tree.command").execute({ action = "show" })
          end
        end,
      })

      -- Auto insert mode when entering terminal
      vim.api.nvim_create_autocmd("TermOpen", {
        callback = function()
          vim.cmd("startinsert")
        end,
      })

      -- Inlay hints (Neovim 0.10+)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end,
      })

      -- QML filetype and LSP
      vim.filetype.add({
        extension = {
          qml = "qml",
          qmljs = "qml",
        },
      })
    '';

    # LSP configuration
    plugins.lsp = {
      enable = true;
      servers = {
        # Languages
        nixd.enable = true;
        clangd.enable = true;
        zls.enable = true;
        pyright.enable = true;
        ts_ls.enable = true;
        html.enable = true;
        cssls.enable = true;
        bashls.enable = true;
        yamlls.enable = true;
        lua_ls.enable = true;
        gopls.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };
        sqls.enable = true;
        marksman.enable = true;
        # QML
        qmlls = {
          enable = true;
          package = null;  # Use system qmlls
          cmd = [ "${pkgs.kdePackages.qtdeclarative}/bin/qmlls" ];
        };
      };
    };

    # Treesitter
    plugins.treesitter = {
      enable = true;
      settings.highlight.enable = true;
      settings.indent.enable = true;
    };

    # Completion
    plugins.cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.close()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        };
      };
    };

    # Snippets
    plugins.luasnip = {
      enable = true;
      fromVscode = [{}];  # Load friendly-snippets
    };
    plugins.friendly-snippets.enable = true;

    # File tree
    plugins.neo-tree = {
      enable = true;
      closeIfLastWindow = true;
      enableGitStatus = true;
      enableDiagnostics = true;
      filesystem.followCurrentFile.enabled = true;
    };

    # Fuzzy finder
    plugins.telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
    };

    # Status line
    plugins.lualine = {
      enable = true;
      settings.options.theme = "catppuccin";
    };

    # Buffer line
    plugins.bufferline = {
      enable = true;
      settings.options.diagnostics = "nvim_lsp";
    };

    # Git
    plugins.gitsigns.enable = true;
    plugins.fugitive.enable = true;
    plugins.diffview.enable = true;
    plugins.lazygit.enable = true;

    # Diagnostics
    plugins.trouble.enable = true;

    # Comments
    plugins.todo-comments.enable = true;
    plugins.comment.enable = true;

    # UI enhancements
    plugins.noice.enable = true;
    plugins.notify.enable = true;
    plugins.web-devicons.enable = true;
    plugins.indent-blankline.enable = true;
    plugins.rainbow-delimiters.enable = true;
    plugins.fidget.enable = true;

    # Motion and editing
    plugins.leap.enable = true;
    plugins.flash.enable = true;
    plugins.nvim-surround.enable = true;
    plugins.nvim-autopairs.enable = true;

    # Utilities
    plugins.undotree.enable = true;
    plugins.which-key.enable = true;
    plugins.project-nvim.enable = true;
    plugins.toggleterm.enable = true;
    plugins.persistence.enable = true;  # Session management

    # Dashboard
    plugins.dashboard.enable = true;

    # Debugger
    plugins.dap = {
      enable = true;
      extensions.dap-ui.enable = true;
    };

    # AI assistant
    plugins.copilot-lua = {
      enable = true;
      suggestion.enabled = true;
      panel.enabled = true;
    };

    # Formatting (more control than LSP formatting)
    plugins.conform-nvim = {
      enable = true;
      settings.formatters_by_ft = {
        nix = [ "nixfmt" ];
        python = [ "black" ];
        javascript = [ "prettier" ];
        typescript = [ "prettier" ];
        json = [ "prettier" ];
        yaml = [ "prettier" ];
        markdown = [ "prettier" ];
        html = [ "prettier" ];
        css = [ "prettier" ];
        lua = [ "stylua" ];
        go = [ "gofmt" ];
        rust = [ "rustfmt" ];
      };
      settings.format_on_save = {
        timeout_ms = 500;
        lsp_fallback = true;
      };
    };

    # Highlight other uses of word under cursor
    plugins.illuminate = {
      enable = true;
      delay = 200;
    };

    # Better text objects (e.g., via/vaa for arguments)
    plugins.mini = {
      enable = true;
      modules = {
        ai = {};        # Better text objects
        icons = {};     # Icons
      };
    };

    # Code outline/symbols sidebar
    plugins.outline.enable = true;

    # Highlight TODO/FIX/HACK in comments (better config)
    plugins.todo-comments.settings = {
      signs = true;
      highlight = {
        before = "";
        keyword = "wide";
        after = "fg";
      };
    };

    # LSP signature help while typing
    plugins.lsp-signature.enable = true;

    # Markdown preview
    plugins.markdown-preview.enable = true;

    # Better search & replace across project
    plugins.spectre.enable = true;

    # Quick file navigation (bookmark files)
    plugins.harpoon = {
      enable = true;
      enableTelescope = true;
    };

    # Auto-save
    plugins.auto-save.enable = true;

    # Highlight color codes (#ff0000 shows as red)
    plugins.nvim-colorizer.enable = true;

    # Keymaps
    keymaps = [
      # === Claude Code ===
      { mode = "n"; key = "<leader>cc"; action = "<cmd>vsplit | terminal claude<CR>"; options.desc = "Claude Code (vertical)"; }
      { mode = "n"; key = "<leader>ch"; action = "<cmd>split | terminal claude<CR>"; options.desc = "Claude Code (horizontal)"; }

      # === Terminal ===
      { mode = "n"; key = "<leader>tv"; action = "<cmd>vsplit | terminal<CR>"; options.desc = "Terminal (vertical)"; }
      { mode = "n"; key = "<leader>th"; action = "<cmd>split | terminal<CR>"; options.desc = "Terminal (horizontal)"; }
      { mode = "n"; key = "<leader>tt"; action = "<cmd>ToggleTerm<CR>"; options.desc = "Toggle terminal"; }

      # === File operations ===
      { mode = "n"; key = "<C-s>"; action = "<cmd>w<CR>"; options.desc = "Save file"; }
      { mode = "i"; key = "<C-s>"; action = "<Esc><cmd>w<CR>"; options.desc = "Save file"; }
      { mode = "n"; key = "<C-q>"; action = "<cmd>q<CR>"; options.desc = "Close window"; }

      # === File/Project navigation ===
      { mode = "n"; key = "<C-p>"; action = "<cmd>Telescope find_files<CR>"; options.desc = "Find files"; }
      { mode = "n"; key = "<C-f>"; action = "<cmd>Telescope live_grep<CR>"; options.desc = "Search in project"; }
      { mode = "n"; key = "<leader>e"; action = "<cmd>Neotree toggle<CR>"; options.desc = "Toggle file tree"; }
      { mode = "n"; key = "<leader>o"; action = "<cmd>Neotree focus<CR>"; options.desc = "Focus file tree"; }

      # === Buffer navigation ===
      { mode = "n"; key = "<Tab>"; action = "<cmd>bnext<CR>"; options.desc = "Next buffer"; }
      { mode = "n"; key = "<S-Tab>"; action = "<cmd>bprevious<CR>"; options.desc = "Previous buffer"; }
      { mode = "n"; key = "<leader>x"; action = "<cmd>bdelete<CR>"; options.desc = "Close buffer"; }
      { mode = "n"; key = "<leader>b"; action = "<cmd>Telescope buffers<CR>"; options.desc = "List buffers"; }

      # === Window navigation ===
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Move to left window"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Move to bottom window"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Move to top window"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Move to right window"; }

      # === LSP shortcuts ===
      { mode = "n"; key = "gd"; action = "<cmd>lua vim.lsp.buf.definition()<CR>"; options.desc = "Go to definition"; }
      { mode = "n"; key = "gr"; action = "<cmd>Telescope lsp_references<CR>"; options.desc = "Find references"; }
      { mode = "n"; key = "K"; action = "<cmd>lua vim.lsp.buf.hover()<CR>"; options.desc = "Show hover info"; }
      { mode = "n"; key = "<leader>rn"; action = "<cmd>lua vim.lsp.buf.rename()<CR>"; options.desc = "Rename symbol"; }
      { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; options.desc = "Code actions"; }
      { mode = "n"; key = "<leader>d"; action = "<cmd>lua vim.diagnostic.open_float()<CR>"; options.desc = "Show diagnostics"; }
      { mode = "n"; key = "gy"; action = "<cmd>lua vim.lsp.buf.type_definition()<CR>"; options.desc = "Type definition"; }
      { mode = "n"; key = "gi"; action = "<cmd>lua vim.lsp.buf.implementation()<CR>"; options.desc = "Go to implementation"; }
      { mode = "n"; key = "<leader>lf"; action = "<cmd>lua vim.lsp.buf.format({ async = true })<CR>"; options.desc = "Format buffer"; }

      # === Diagnostics ===
      { mode = "n"; key = "[d"; action = "<cmd>lua vim.diagnostic.goto_prev()<CR>"; options.desc = "Previous diagnostic"; }
      { mode = "n"; key = "]d"; action = "<cmd>lua vim.diagnostic.goto_next()<CR>"; options.desc = "Next diagnostic"; }
      { mode = "n"; key = "<leader>xx"; action = "<cmd>Trouble diagnostics toggle<CR>"; options.desc = "Trouble diagnostics"; }
      { mode = "n"; key = "<leader>xq"; action = "<cmd>Trouble quickfix toggle<CR>"; options.desc = "Trouble quickfix"; }

      # === Git ===
      { mode = "n"; key = "<leader>gg"; action = "<cmd>LazyGit<CR>"; options.desc = "LazyGit"; }
      { mode = "n"; key = "<leader>gf"; action = "<cmd>Git<CR>"; options.desc = "Git status (fugitive)"; }
      { mode = "n"; key = "<leader>gb"; action = "<cmd>Git blame<CR>"; options.desc = "Git blame"; }
      { mode = "n"; key = "<leader>gd"; action = "<cmd>DiffviewOpen<CR>"; options.desc = "Git diff (diffview)"; }
      { mode = "n"; key = "<leader>gh"; action = "<cmd>DiffviewFileHistory %<CR>"; options.desc = "File history"; }
      { mode = "n"; key = "<leader>gl"; action = "<cmd>Git log --oneline<CR>"; options.desc = "Git log"; }

      # === More Telescope ===
      { mode = "n"; key = "<leader>fr"; action = "<cmd>Telescope oldfiles<CR>"; options.desc = "Recent files"; }
      { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<CR>"; options.desc = "Help tags"; }
      { mode = "n"; key = "<leader>fc"; action = "<cmd>Telescope commands<CR>"; options.desc = "Commands"; }
      { mode = "n"; key = "<leader>fs"; action = "<cmd>Telescope lsp_document_symbols<CR>"; options.desc = "Document symbols"; }
      { mode = "n"; key = "<leader>fw"; action = "<cmd>Telescope lsp_workspace_symbols<CR>"; options.desc = "Workspace symbols"; }
      { mode = "n"; key = "<leader>ft"; action = "<cmd>TodoTelescope<CR>"; options.desc = "Find TODOs"; }

      # === Utilities ===
      { mode = "n"; key = "<leader>u"; action = "<cmd>UndotreeToggle<CR>"; options.desc = "Undo tree"; }
      { mode = "n"; key = "<leader>S"; action = "<cmd>lua require('persistence').load()<CR>"; options.desc = "Load session"; }
      { mode = "n"; key = "<leader>sr"; action = "<cmd>lua require('spectre').open()<CR>"; options.desc = "Search & replace"; }
      { mode = "n"; key = "<leader>sw"; action = "<cmd>lua require('spectre').open_visual({select_word=true})<CR>"; options.desc = "Search word"; }
      { mode = "n"; key = "<leader>lo"; action = "<cmd>Outline<CR>"; options.desc = "Toggle outline"; }
      { mode = "n"; key = "<leader>mp"; action = "<cmd>MarkdownPreviewToggle<CR>"; options.desc = "Markdown preview"; }

      # === Harpoon (quick file marks) ===
      { mode = "n"; key = "<leader>ha"; action = "<cmd>lua require('harpoon.mark').add_file()<CR>"; options.desc = "Harpoon add"; }
      { mode = "n"; key = "<leader>hh"; action = "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>"; options.desc = "Harpoon menu"; }
      { mode = "n"; key = "<leader>1"; action = "<cmd>lua require('harpoon.ui').nav_file(1)<CR>"; options.desc = "Harpoon file 1"; }
      { mode = "n"; key = "<leader>2"; action = "<cmd>lua require('harpoon.ui').nav_file(2)<CR>"; options.desc = "Harpoon file 2"; }
      { mode = "n"; key = "<leader>3"; action = "<cmd>lua require('harpoon.ui').nav_file(3)<CR>"; options.desc = "Harpoon file 3"; }
      { mode = "n"; key = "<leader>4"; action = "<cmd>lua require('harpoon.ui').nav_file(4)<CR>"; options.desc = "Harpoon file 4"; }

      # === Terminal mode ===
      { mode = "t"; key = "<Esc>"; action = "<C-\\><C-n>"; options.desc = "Exit terminal mode"; }
      { mode = "t"; key = "<C-h>"; action = "<C-\\><C-n><C-w>h"; options.desc = "Move to left window"; }
      { mode = "t"; key = "<C-j>"; action = "<C-\\><C-n><C-w>j"; options.desc = "Move to bottom window"; }
      { mode = "t"; key = "<C-k>"; action = "<C-\\><C-n><C-w>k"; options.desc = "Move to top window"; }
      { mode = "t"; key = "<C-l>"; action = "<C-\\><C-n><C-w>l"; options.desc = "Move to right window"; }
    ];
  };
}
