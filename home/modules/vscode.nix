#home/modules/vscode.nix
{ pkgs, ... } :
{
  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          # === Python ===
          ms-python.python
          ms-python.vscode-pylance      # Better Python intellisense
          charliermarsh.ruff            # Fast linter (matches system ruff)

          # === C/C++ ===
          ms-vscode.cpptools            # C/C++ IntelliSense & debugging
          llvm-vs-code-extensions.vscode-clangd  # clangd LSP
          ms-vscode.cmake-tools
          twxs.cmake                    # CMake language support

          # === Web (TS/JS/HTML) ===
          esbenp.prettier-vscode
          bradlc.vscode-tailwindcss     # Tailwind CSS support

          # === Docker ===
          ms-azuretools.vscode-docker

          # === Nix ===
          jnoortheen.nix-ide

          # === Git ===
          eamodio.gitlens               # Git supercharged
          mhutchie.git-graph            # Visualize branches

          # === Remote ===
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-containers  # Dev containers

          # === Productivity ===
          usernamehw.errorlens          # Inline error display
          christian-kohler.path-intellisense  # Path autocomplete
          gruntfuggly.todo-tree         # Track TODOs/FIXMEs
          streetsidesoftware.code-spell-checker

          # === Theme (icons only - Stylix handles colors) ===
          catppuccin.catppuccin-vsc-icons
        ];

        userSettings = {
          # === Editor ===
          "editor.fontLigatures" = true;
          "editor.formatOnSave" = true;
          "editor.bracketPairColorization.enabled" = true;
          "editor.guides.bracketPairs" = "active";
          "editor.minimap.enabled" = false;  # More screen space
          "editor.rulers" = [ 80 120 ];
          "editor.wordWrap" = "off";
          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;
          "editor.linkedEditing" = true;  # Auto-rename HTML tags
          "editor.stickyScroll.enabled" = true;  # Sticky function headers

          # === Files ===
          "files.autoSave" = "afterDelay";
          "files.autoSaveDelay" = 1000;
          "files.trimTrailingWhitespace" = true;
          "files.insertFinalNewline" = true;
          "files.watcherExclude" = {
            "**/.git/objects/**" = true;
            "**/node_modules/**" = true;
          };

          # === Auto-reload (for when Claude Code edits files) ===
          "files.autoSaveWhenNoErrors" = true;
          "workbench.editor.enablePreview" = false;  # Don't replace tabs

          # === Terminal ===
          "terminal.integrated.defaultProfile.linux" = "zsh";

          # === Explorer ===
          "explorer.confirmDelete" = false;
          "explorer.confirmDragAndDrop" = false;

          # === Git ===
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "gitlens.hovers.currentLine.over" = "line";

          # === Error Lens ===
          "errorLens.gutterIconsEnabled" = true;
          "errorLens.messageMaxChars" = 100;

          # === Disable telemetry ===
          "telemetry.telemetryLevel" = "off";
          "update.mode" = "none";

          # === Language-specific ===
          "[nix]" = {
            "editor.tabSize" = 2;
            "editor.defaultFormatter" = "jnoortheen.nix-ide";
          };
          "[python]" = {
            "editor.tabSize" = 4;
            "editor.defaultFormatter" = "charliermarsh.ruff";
            "editor.formatOnSave" = true;
            "editor.codeActionsOnSave" = {
              "source.fixAll" = "explicit";
              "source.organizeImports" = "explicit";
            };
          };
          "[cpp]" = {
            "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
          };
          "[c]" = {
            "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
          };
          "[typescript]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[javascript]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[html]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[json]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[yaml]" = {
            "editor.tabSize" = 2;
          };
          "[dockerfile]" = {
            "editor.defaultFormatter" = "ms-azuretools.vscode-docker";
          };

          # === Clangd (disable conflicting cpptools intellisense) ===
          "C_Cpp.intelliSenseEngine" = "disabled";

          # === Python ===
          "python.analysis.typeCheckingMode" = "basic";
          "python.analysis.autoImportCompletions" = true;

          # === Nix IDE ===
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";
        };
      };
    };
  };
}