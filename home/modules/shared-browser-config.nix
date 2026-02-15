# home/modules/shared-browser-config.nix
# Shared configuration for Firefox and Zen Browser
{ pkgs, config }:
let
  ffAddons = pkgs.nur.repos.rycee.firefox-addons;

  extensions = with ffAddons; [
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
in {
  inherit extensions;

  policies = {
    # Allow each extension in private browsing
    ExtensionSettings = builtins.listToAttrs (map (pkg: {
      name = pkg.addonId;
      value = { private_browsing = "allowed"; };
    }) extensions);
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    EnableTrackingProtection = {
      Value = true;
      Locked = true;
      Cryptomining = true;
      Fingerprinting = true;
    };
    Certificates = {
      Install = [
        "${config.home.homeDirectory}/nixos/certs/vaultwarden.crt"
      ];
    };
  };

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

  containers = {
    containersForce = true;
    containers = {
      Personal = { id = 1; color = "blue"; icon = "fingerprint"; };
      Work     = { id = 2; color = "orange"; icon = "briefcase"; };
      Banking  = { id = 3; color = "green"; icon = "dollar"; };
      Shopping = { id = 4; color = "pink"; icon = "cart"; };
    };
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

    # Disable DNS over HTTPS to use system DNS (needed for Tailscale)
    "network.trr.mode" = 5;
    "network.dns.disablePrefetch" = false;

    # Enable userChrome.css
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    # Dark mode settings - only for browser UI, not web content
    "layout.css.prefers-color-scheme.content-override" = 2;
    "ui.systemUsesDarkTheme" = 1;
    "browser.theme.dark-private-windows" = true;
    "devtools.theme" = "dark";

    # Don't force colors on web content
    "browser.display.document_color_use" = 0;
    "browser.display.permit_backplate" = false;

    # Use dark theme as base
    "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";

    # Stylix color theme
    "lightweightThemes.selectedThemeID" = "custom-stylix@mozilla.org";
    "lightweightThemes.usedThemes" = builtins.toJSON [{
      "id" = "custom-stylix@mozilla.org";
      "name" = "Stylix Dark Theme";
      "version" = "1.0";
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
      "properties" = {
        "color_scheme" = "dark";
        "content_color_scheme" = "dark";
      };
    }];
  };

  # Shared userChrome.css base (toolbar, urlbar, menus, sidebar)
  userChromeBase = ''
    :root {
      --base00: #${config.stylix.base16Scheme.base00};
      --base01: #${config.stylix.base16Scheme.base01};
      --base02: #${config.stylix.base16Scheme.base02};
      --base03: #${config.stylix.base16Scheme.base03};
      --base04: #${config.stylix.base16Scheme.base04};
      --base05: #${config.stylix.base16Scheme.base05};
      --base06: #${config.stylix.base16Scheme.base06};
      --base07: #${config.stylix.base16Scheme.base07};
      --base08: #${config.stylix.base16Scheme.base08};
      --base09: #${config.stylix.base16Scheme.base09};
      --base0A: #${config.stylix.base16Scheme.base0A};
      --base0B: #${config.stylix.base16Scheme.base0B};
      --base0C: #${config.stylix.base16Scheme.base0C};
      --base0D: #${config.stylix.base16Scheme.base0D};
      --base0E: #${config.stylix.base16Scheme.base0E};
      --base0F: #${config.stylix.base16Scheme.base0F};
    }

    #main-window, #navigator-toolbox, #tabbrowser-tabs, #TabsToolbar {
      background-color: var(--base00) !important;
      color: var(--base05) !important;
    }

    #nav-bar, #PersonalToolbar, #toolbar-menubar {
      background-color: var(--base01) !important;
      color: var(--base05) !important;
    }

    #urlbar, #urlbar-background, #urlbar-input-container {
      background-color: var(--base02) !important;
      color: var(--base05) !important;
      border: 1px solid var(--base03) !important;
      border-radius: 10px !important;
    }

    #urlbar input { color: var(--base05) !important; }

    .toolbarbutton-1, .toolbarbutton-combined, toolbarbutton {
      color: var(--base05) !important;
      fill: var(--base05) !important;
    }

    .bookmark-item, .subviewbutton { color: var(--base05) !important; }

    menupopup, panel, .panel-arrowcontainer {
      background-color: var(--base01) !important;
      color: var(--base05) !important;
      border: 1px solid var(--base03) !important;
      border-radius: 10px !important;
    }

    menuitem, .subviewbutton, .panelUI-subView {
      color: var(--base05) !important;
      background-color: transparent !important;
    }

    menuitem[_moz-menuactive="true"], .subviewbutton:hover {
      background-color: var(--base0D) !important;
      color: var(--base00) !important;
    }

    #sidebar-box, #sidebar-header {
      background-color: var(--base01) !important;
      color: var(--base05) !important;
    }
  '';

  bookmarks = (import ./shared-bookmarks.nix { }).bookmarks;
}
