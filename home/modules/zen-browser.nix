# home/modules/zen-browser.nix
# Zen Browser config - browser-specific settings only, shared config in ./shared-browser-config.nix
{ inputs, pkgs, config, lib, ... }:
let
  shared = import ./shared-browser-config.nix { inherit pkgs config; };
in {

  imports = [inputs.zen-browser.homeModules.beta];

  stylix.targets.zen-browser.profileNames = [ "default" ];

  programs.zen-browser = {
    enable = true;
    policies = shared.policies // {
      DisableAppUpdate = true;
    };
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
          # Zen-specific toolbar layout
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
                "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
                "ublock0_raymondhill_net-browser-action"
                "sponsorblocker_ajay_app-browser-action"
                "_windscribeff-browser-action"
                "unified-extensions-button"
              ];
              "toolbar-menubar" = ["menubar-items"];
              "TabsToolbar" = ["tabbrowser-tabs"];
              "vertical-tabs" = [];
              "PersonalToolbar" = ["import-button" "personal-bookmarks"];
              "zen-sidebar-top-buttons" = ["zen-toggle-compact-mode"];
              "zen-sidebar-foot-buttons" = ["downloads-button" "zen-workspaces-button" "zen-create-new-button"];
            };
            seen = [
              "developer-button"
              "screenshot-button"
              "firefoxcolor_mozilla_com-browser-action"
              "_bbb880ce-43c9-47ae-b746-c3e0096c5b76_-browser-action"
              "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"
              "_036a55b4-5e72-4d05-a06c-cba2dfcc134a_-browser-action"
              "_e58d3966-3d76-4cd9-8552-1582fbc800c1_-browser-action"
              "_windscribeff-browser-action"
              "ublock0_raymondhill_net-browser-action"
              "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
              "sponsorblocker_ajay_app-browser-action"
            ];
            dirtyAreaCache = ["nav-bar" "vertical-tabs" "zen-sidebar-foot-buttons" "PersonalToolbar" "toolbar-menubar" "TabsToolbar" "zen-sidebar-top-buttons" "unified-extensions-area"];
            currentVersion = 23;
            newElementCount = 2;
          };
        };

        userChrome = ''
          ${shared.userChromeBase}

          /* Zen-specific tab styling */
          .tabbrowser-tab,
          .tabbrowser-tab .tab-stack,
          .tabbrowser-tab .tab-background {
            background-color: var(--base02) !important;
            border: none !important;
            color: var(--base04) !important;
          }

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

          .tabbrowser-tab .tab-close-button {
            color: var(--base04) !important;
          }

          .tabbrowser-tab[selected="true"] .tab-close-button,
          .tabbrowser-tab[visuallyselected="true"] .tab-close-button {
            color: var(--base05) !important;
          }
        '';

        userContent = ''
          /* No web content styling - let sites handle their own themes */
        '';

        bookmarks = shared.bookmarks;
      };
    };
  };

  # Enable all extensions and allow private browsing on each rebuild.
  # For new extensions: open browser once (so it registers them), then rebuild again.
  home.activation.zenExtPrivateBrowsing = lib.hm.dag.entryAfter ["writeBoundary"] ''
    extJson="$HOME/.zen/default/extensions.json"
    if [ -f "$extJson" ]; then
      ${pkgs.jq}/bin/jq '
        .addons |= map(
          if .type == "extension" then
            .userDisabled = false | .active = true | .privateBrowsingAllowed = true
          else . end
        )
      ' "$extJson" > "$extJson.tmp" && mv "$extJson.tmp" "$extJson"
      rm -f "$HOME/.zen/default/addonStartup.json.lz4"
    fi
  '';
}
