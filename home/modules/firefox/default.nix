# home/modules/firefox/default.nix
# Firefox config - browser-specific settings only, shared config in ../shared-browser-config.nix
{ config, pkgs, lib, ... }:
let
  shared = import ../shared-browser-config.nix { inherit pkgs config; };
in {

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    policies = shared.policies;

    profiles = {
      default = {
        id = 0;
        isDefault = true;
        extensions = {
          force = true;
          packages = shared.extensions;
        };

        search = shared.search;
        inherit (shared.containers) containersForce containers;

        settings = shared.settings // {
          # Firefox-specific: vertical (side) tabs
          "sidebar.verticalTabs" = true;
          "sidebar.revamp" = true;

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
        };

        userChrome = ''
          ${lib.optionalString config.wayland.windowManager.hyprland.enable ''
          /* Hide window controls (minimize/maximize/close) - Hyprland handles this */
          .titlebar-buttonbox-container {
            display: none !important;
          }
          ''}
          ${shared.userChromeBase}

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

        userContent = ''
          /* No web content styling - let sites handle their own themes */
        '';

        bookmarks = shared.bookmarks;
      };
    };
  };

  # Patch extensions.json on each rebuild to enable private browsing
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
