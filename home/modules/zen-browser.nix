{ inputs, pkgs, config, ... }: 
{

  imports = [inputs.zen-browser.homeModules.beta];

  stylix.targets.zen-browser.profileNames = [ "default" ];

  programs.zen-browser = {
    enable = true;
    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
    };
    profiles = {
      default = {
        id = 0;
        isDefault = true;
        extensions = {
          force = true;
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            bitwarden
            buster-captcha-solver
            translate-web-pages
            return-youtube-dislikes
            sponsorblock
            catppuccin-web-file-icons  # Keep icons only
            firefox-color              # For custom theming
            windscribe
          ];
        };
        settings = {
          "browser.startup.homepage" = "https://www.google.com";
          "browser.startup.page" = 1;
          "browser.shell.checkDefaultBrowser" = false;
          # Enable userChrome.css
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          
          # Dark mode settings - only for browser UI, not web content
          "layout.css.prefers-color-scheme.content-override" = 2;  # Don't override website color schemes
          "ui.systemUsesDarkTheme" = 1;  # Keep dark browser UI
          "browser.theme.dark-private-windows" = true;
          "devtools.theme" = "dark";
          
          # Don't force colors on web content
          "browser.display.document_color_use" = 0;  # Use website colors
          "browser.display.permit_backplate" = false;  # Don't override backgrounds
          
          # Use dark theme as base and enhance with userChrome.css
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          
          # Firefox Color theme configuration using Stylix colors
          "lightweightThemes.selectedThemeID" = "custom-stylix@mozilla.org";
          "lightweightThemes.usedThemes" = builtins.toJSON [{
            "id" = "custom-stylix@mozilla.org";
            "name" = "Stylix Dark Theme";
            "version" = "1.0";
            
            # Main colors
            "colors" = {
              "tab_background_text" = "#${config.stylix.base16Scheme.base05}";
              "icons" = "#${config.stylix.base16Scheme.base05}";
              "frame" = "#${config.stylix.base16Scheme.base00}";
              "popup" = "#${config.stylix.base16Scheme.base01}";
              "popup_text" = "#${config.stylix.base16Scheme.base05}";
              "popup_border" = "#${config.stylix.base16Scheme.base03}";
              "toolbar" = "#${config.stylix.base16Scheme.base01}";
              "toolbar_text" = "#${config.stylix.base16Scheme.base05}";
              "toolbar_field" = "#${config.stylix.base16Scheme.base02}";
              "toolbar_field_text" = "#${config.stylix.base16Scheme.base05}";
              "toolbar_field_border" = "#${config.stylix.base16Scheme.base03}";
              "toolbar_field_focus" = "#${config.stylix.base16Scheme.base02}";
              "toolbar_field_text_focus" = "#${config.stylix.base16Scheme.base05}";
              "toolbar_field_border_focus" = "#${config.stylix.base16Scheme.base0D}";
              "toolbar_top_separator" = "#${config.stylix.base16Scheme.base03}";
              "toolbar_bottom_separator" = "#${config.stylix.base16Scheme.base03}";
              "toolbar_vertical_separator" = "#${config.stylix.base16Scheme.base03}";
              "ntp_background" = "#${config.stylix.base16Scheme.base00}";
              "ntp_text" = "#${config.stylix.base16Scheme.base05}";
              "sidebar" = "#${config.stylix.base16Scheme.base01}";
              "sidebar_text" = "#${config.stylix.base16Scheme.base05}";
              "sidebar_border" = "#${config.stylix.base16Scheme.base03}";
              "tab_line" = "#${config.stylix.base16Scheme.base0D}";
              "tab_loading" = "#${config.stylix.base16Scheme.base0D}";
              "icons_attention" = "#${config.stylix.base16Scheme.base08}";
              "button_background_hover" = "#${config.stylix.base16Scheme.base02}";
              "button_background_active" = "#${config.stylix.base16Scheme.base03}";
            };
            
            # Theme properties
            "properties" = {
              "color_scheme" = "dark";
              "content_color_scheme" = "dark";
            };
          }];
        };
        
        # Custom userChrome.css using Stylix colors (same as Firefox)
        userChrome = ''
          /* Firefox theme using Stylix colors - matches system theme */
          
          :root {
            /* Stylix base16 color scheme */
            --base00: #${config.stylix.base16Scheme.base00}; /* base */
            --base01: #${config.stylix.base16Scheme.base01}; /* mantle */
            --base02: #${config.stylix.base16Scheme.base02}; /* surface0 */
            --base03: #${config.stylix.base16Scheme.base03}; /* surface1 */
            --base04: #${config.stylix.base16Scheme.base04}; /* surface2 */
            --base05: #${config.stylix.base16Scheme.base05}; /* text */
            --base06: #${config.stylix.base16Scheme.base06}; /* rosewater */
            --base07: #${config.stylix.base16Scheme.base07}; /* lavender */
            --base08: #${config.stylix.base16Scheme.base08}; /* red */
            --base09: #${config.stylix.base16Scheme.base09}; /* peach */
            --base0A: #${config.stylix.base16Scheme.base0A}; /* yellow */
            --base0B: #${config.stylix.base16Scheme.base0B}; /* green */
            --base0C: #${config.stylix.base16Scheme.base0C}; /* teal */
            --base0D: #${config.stylix.base16Scheme.base0D}; /* blue */
            --base0E: #${config.stylix.base16Scheme.base0E}; /* mauve */
            --base0F: #${config.stylix.base16Scheme.base0F}; /* flamingo */
          }
          
          /* Override all themes and force dark styling */
          #main-window, #navigator-toolbox, #tabbrowser-tabs, #TabsToolbar {
            background-color: var(--base00) !important;
            color: var(--base05) !important;
          }
          
          /* Tab styling - comprehensive selectors for Zen Browser */
          .tabbrowser-tab,
          .tabbrowser-tab .tab-stack,
          .tabbrowser-tab .tab-background {
            background-color: var(--base02) !important;
            border: none !important;
            color: var(--base04) !important;
          }
          
          /* Active/selected tab with rounded corners */
          .tabbrowser-tab[selected="true"],
          .tabbrowser-tab[selected="true"] .tab-stack,
          .tabbrowser-tab[selected="true"] .tab-background,
          .tabbrowser-tab[visuallyselected="true"],
          .tabbrowser-tab[visuallyselected="true"] .tab-stack,
          .tabbrowser-tab[visuallyselected="true"] .tab-background {
            background-color: var(--base01) !important;
            border-radius: 20px 20px 0 0 !important;
            color: var(--base05) !important;
          }
          
          /* Tab text and labels */
          .tabbrowser-tab .tab-label-container,
          .tabbrowser-tab .tab-label {
            color: var(--base04) !important;
          }
          
          .tabbrowser-tab[selected="true"] .tab-label-container,
          .tabbrowser-tab[selected="true"] .tab-label,
          .tabbrowser-tab[visuallyselected="true"] .tab-label-container,
          .tabbrowser-tab[visuallyselected="true"] .tab-label {
            color: var(--base05) !important;
          }
          
          /* Tab close buttons */
          .tabbrowser-tab .tab-close-button {
            color: var(--base04) !important;
          }
          
          .tabbrowser-tab[selected="true"] .tab-close-button,
          .tabbrowser-tab[visuallyselected="true"] .tab-close-button {
            color: var(--base05) !important;
          }
          
          /* Toolbar and navigation */
          #nav-bar, 
          #PersonalToolbar,
          #toolbar-menubar {
            background-color: var(--base01) !important;
            color: var(--base05) !important;
          }
          
          /* URL bar comprehensive styling */
          #urlbar,
          #urlbar-background,
          #urlbar-input-container {
            background-color: var(--base02) !important;
            color: var(--base05) !important;
            border: 1px solid var(--base03) !important;
            border-radius: 10px !important;
          }
          
          #urlbar input {
            color: var(--base05) !important;
          }
          
          /* All toolbar buttons */
          .toolbarbutton-1,
          .toolbarbutton-combined,
          toolbarbutton {
            color: var(--base05) !important;
            fill: var(--base05) !important;
          }
          
          /* Bookmarks */
          .bookmark-item,
          .subviewbutton {
            color: var(--base05) !important;
          }
          
          /* Context menus and panels */
          menupopup,
          panel,
          .panel-arrowcontainer {
            background-color: var(--base01) !important;
            color: var(--base05) !important;
            border: 1px solid var(--base03) !important;
            border-radius: 10px !important;
          }
          
          menuitem,
          .subviewbutton,
          .panelUI-subView {
            color: var(--base05) !important;
            background-color: transparent !important;
          }
          
          menuitem[_moz-menuactive="true"],
          .subviewbutton:hover {
            background-color: var(--base0D) !important;
            color: var(--base00) !important;
          }
          
          /* Sidebar styling */
          #sidebar-box,
          #sidebar-header {
            background-color: var(--base01) !important;
            color: var(--base05) !important;
          }
        '';
        
        # userContent.css - minimal styling, no web content modification
        userContent = ''
          /* No web content styling - let sites handle their own themes */
        '';
      };
    };
  };
}