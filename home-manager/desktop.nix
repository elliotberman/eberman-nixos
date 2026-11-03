{
  noctalia,
  ...
}@flakeInputs:
{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    noctalia.homeModules.default
  ];

  options.eberman.enableDesktop = lib.mkEnableOption "Enable graphical programs";

  config = lib.mkIf config.eberman.enableDesktop {
    home.packages = with pkgs; [
      chromium
      diffoscope
      gdmap
      gnome-calculator
      krita
      lua5_4
      meld
    ];

    programs = {
      vscode.enable = true;

      ghostty = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          theme = "noctalia";
          gtk-titlebar-style = "tabs";
        };
      };

      noctalia = {
        enable = true;
        systemd.enable = true;
        settings = builtins.fromTOML (builtins.readFile ./noctalia-config.toml);
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      extraConfig = builtins.readFile ./hyprland.lua;
    };

    xdg.configFile."noctalia/templates/hypr-groupbar.lua".source = ./noctalia-groupbar.lua;

    xdg.portal = {
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };

    home.activation.ensureHyprCustomConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p $HOME/.config/hypr
      if [ ! -e $HOME/.config/hypr/custom.lua ]; then
        $DRY_RUN_CMD touch $HOME/.config/hypr/custom.lua
      fi
    '';

    # Noctalia generates this theme at runtime; ghostty config validation during
    # activation fails on first run without it. Must be a plain file, not an HM
    # symlink, so noctalia can overwrite it.
    home.activation.ensureGhosttyNoctaliaTheme =
      lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
        ''
          if [ ! -e $HOME/.config/ghostty/themes/noctalia ]; then
            $DRY_RUN_CMD mkdir -p $HOME/.config/ghostty/themes
            if [ -z "''${DRY_RUN:-}" ]; then
              echo "background = #1e1e2e" > $HOME/.config/ghostty/themes/noctalia
              echo "foreground = #cdd6f4" >> $HOME/.config/ghostty/themes/noctalia
            fi
          fi
        '';

    home.activation.reloadHyprland = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && command -v hyprctl >/dev/null 2>&1; then
        $DRY_RUN_CMD hyprctl reload || true
      fi
    '';

    fonts.fontconfig = {
      defaultFonts.monospace = [ "CaskaydiaCove NF" ];
      enable = true;
    };

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      hyprcursor.enable = true;
    };
  };
}
