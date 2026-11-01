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
          theme = "dark:Catppuccin Frappe,light:Catppuccin Latte";
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
      plugins = with pkgs.hyprlandPlugins; [
        hy3
        hyprfocus
      ];
    };

    home.activation.ensureHyprCustomConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p $HOME/.config/hypr
      if [ ! -e $HOME/.config/hypr/custom.lua ]; then
        $DRY_RUN_CMD touch $HOME/.config/hypr/custom.lua
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
  };
}
