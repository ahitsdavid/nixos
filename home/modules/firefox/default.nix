# home/modules/firefox/default.nix
# Firefox config
{ config, pkgs, lib, ... }:
let
  sharedBookmarks = import ../shared-bookmarks.nix { };
  ffAddons = pkgs.nur.repos.rycee.firefox-addons;

  browserExtensions = with ffAddons; [
    ublock-origin
    bitwarden
    buster-captcha-solver
    translate-web-pages
    return-youtube-dislikes
    sponsorblock
    catppuccin-web-file-icons
    firefox-color
    windscribe
    multi-account-containers
    clearurls
  ];

  # Policy: allow each extension in private browsing
  mkExtensionSettings = builtins.listToAttrs (map (pkg: {
    name = pkg.addonId;
    value = { private_browsing = "allowed"; };
  }) browserExtensions);
in {

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    # Install custom certificates (Vaultwarden self-signed cert)
    policies = {
      Certificates = {
        Install = [
          "${config.home.homeDirectory}/nixos/certs/vaultwarden.crt"
        ];
      };

      # Privacy & telemetry
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      ExtensionSettings = mkExtensionSettings;
    };

    profiles = {
      default = {
        id = 0;
        isDefault = true;
        extensions = {
          force = true;
          packages = browserExtensions;
        };

        # Custom search engines with keyword aliases
        search = {
          force = true;
          default = "google";
          engines = {
            "Nix Packages" = {
              urls = [{ template = "https://search.nixos.org/packages?query={searchTerms}"; }];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Options" = {
              urls = [{ template = "https://search.nixos.org/options?query={searchTerms}"; }];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
            };
            "Home Manager Options" = {
              urls = [{ template = "https://home-manager-options.extranix.com/?query={searchTerms}"; }];
              definedAliases = [ "@hm" ];
            };
            "GitHub" = {
              urls = [{ template = "https://github.com/search?q={searchTerms}&type=code"; }];
              definedAliases = [ "@gh" ];
            };
            "bing".metaData.hidden = true;
            "ebay".metaData.hidden = true;
            "amazondotcom-us".metaData.hidden = true;
          };
        };

        # Declarative container tabs
        containersForce = true;
        containers = {
          Personal = { id = 1; color = "blue"; icon = "fingerprint"; };
          Work     = { id = 2; color = "orange"; icon = "briefcase"; };
          Banking  = { id = 3; color = "green"; icon = "dollar"; };
          Shopping = { id = 4; color = "pink"; icon = "cart"; };
        };

        settings = {
          "browser.startup.homepage" = "https://www.google.com";
          "browser.startup.page" = 1;
          "browser.shell.checkDefaultBrowser" = false;

          # Auto-enable extensions in private browsing on fresh install
          "extensions.allowPrivateBrowsingByDefault" = true;

          # Disable sponsored content and bloat on new tab
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.topsites.contile.enabled" = false;
          "extensions.pocket.enabled" = false;

          # Performance tuning (safe across all hardware)
          "nglayout.initialpaint.delay" = 0;
          "nglayout.initialpaint.delay_in_oopif" = 0;
          "content.notify.interval" = 100000;
          "browser.sessionstore.interval" = 60000;
          "network.http.max-persistent-connections-per-server" = 10;
          "network.http.max-connections" = 1800;

          # Pin Bitwarden, uBlock, SponsorBlock, Windscribe to toolbar
          "browser.uiCustomization.state" = builtins.toJSON {
            placements = {
              "widget-overflow-fixed-list" = [];
              "unified-extensions-area" = [
                "firefoxcolor_mozilla_com-browser-action"
                "_bbb880ce-43c9-47ae-b746-c3e0096c5b76_-browser-action"
                "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"
                "_036a55b4-5e72-4d05-a06c-cba2dfcc134a_-browser-action"
                "_e58d3966-3d76-4cd9-8552-1582fbc800c1_-browser-action"
              ];
              "nav-bar" = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "customizableui-special-spring1"
                "vertical-spacer"
                "urlbar-container"
                "customizableui-special-spring2"
                "downloads-button"
                "fxa-toolbar-menu-button"
                "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
                "ublock0_raymondhill_net-browser-action"
                "sponsorblocker_ajay_app-browser-action"
                "_windscribeff-browser-action"
                "unified-extensions-button"
              ];
              "toolbar-menubar" = ["menubar-items"];
              "TabsToolbar" = ["firefox-view-button" "tabbrowser-tabs" "new-tab-button" "alltabs-button"];
              "vertical-tabs" = [];
              "PersonalToolbar" = ["import-button" "personal-bookmarks"];
            };
            seen = [
              "developer-button"
              "screenshot-button"
              "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
              "firefoxcolor_mozilla_com-browser-action"
              "_bbb880ce-43c9-47ae-b746-c3e0096c5b76_-browser-action"
              "_windscribeff-browser-action"
              "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"
              "_036a55b4-5e72-4d05-a06c-cba2dfcc134a_-browser-action"
              "ublock0_raymondhill_net-browser-action"
              "_e58d3966-3d76-4cd9-8552-1582fbc800c1_-browser-action"
              "sponsorblocker_ajay_app-browser-action"
            ];
            dirtyAreaCache = ["nav-bar" "vertical-tabs" "unified-extensions-area" "toolbar-menubar" "TabsToolbar" "PersonalToolbar"];
            currentVersion = 23;
            newElementCount = 2;
          };

          # Vertical (side) tabs
          "sidebar.verticalTabs" = true;
          "sidebar.revamp" = true;

          # Disable DNS over HTTPS to use system DNS (needed for Tailscale)
          "network.trr.mode" = 5;  # 5 = off, use system DNS only
          "network.dns.disablePrefetch" = false;  # Allow DNS prefetch
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
        
        # Custom userChrome.css using Stylix colors
        userChrome = ''
          ${lib.optionalString config.wayland.windowManager.hyprland.enable ''
          /* Hide window controls (minimize/maximize/close) - Hyprland handles this */
          .titlebar-buttonbox-container {
            display: none !important;
          }
          ''}
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

          /* Auto-hide sidebar - collapses to icons, expands on hover */
          #sidebar-box {
            max-width: 40px !important;
            min-width: 40px !important;
            overflow: hidden !important;
            transition: all 0.2s ease !important;
          }
          #sidebar-box:hover {
            max-width: 300px !important;
            min-width: 300px !important;
          }
        '';
        
        # userContent.css - minimal styling, no web content modification
        userContent = ''
          /* No web content styling - let sites handle their own themes */
        '';
        
        # Use shared bookmarks configuration
        bookmarks = sharedBookmarks.bookmarks;
      };
    };
  };

  # Patch extensions.json on each rebuild to enable private browsing
  # and remove the startup cache so Firefox picks up the changes
  home.activation.firefoxExtPrivateBrowsing = lib.hm.dag.entryAfter ["writeBoundary"] ''
    extJson="$HOME/.mozilla/firefox/default/extensions.json"
    if [ -f "$extJson" ]; then
      ${pkgs.jq}/bin/jq '
        .addons |= map(
          if .type == "extension" then
            .userDisabled = false | .active = true | .privateBrowsingAllowed = true
          else . end
        )
      ' "$extJson" > "$extJson.tmp" && mv "$extJson.tmp" "$extJson"
      rm -f "$HOME/.mozilla/firefox/default/addonStartup.json.lz4"
    fi
  '';
}