{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.eberman.enableDesktop = lib.mkEnableOption "Enable graphical programs";

  config = lib.mkIf config.eberman.enableDesktop {
    home.packages = with pkgs; [
      chromium
      diffoscope
      gdmap
      gnome-tweaks
      gnomeExtensions.system-monitor
      krita
      meld
    ];

    programs = {
      vscode.enable = true;

      ghostty = {
        enable = true;
        enableZshIntegration = true;
        settings.theme = "Catppuccin Latte";
      };

      gnome-shell = {
        enable = true;
        extensions = with pkgs.gnomeExtensions; [
          { package = appindicator; }
          { package = launch-new-instance; }
          { package = native-window-placement; }
          { package = night-theme-switcher; }
          { package = removable-drive-menu; }
          { package = status-icons; }
          { package = system-monitor; }
          { package = tactile; }
        ];
      };
    };

    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        favorite-apps = [
          "chromium-browser.desktop"
          "com.mitchellh.ghostty.desktop"
          "code.desktop"
        ];
      };

      "org/gnome/desktop/wm/keybindings" = {
        switch-applications = [ ];
        switch-applications-backward = [ ];
        "switch-to-workspace-left" = [ "<Control><Super>Left" ];
        "switch-to-workspace-right" = [ "<Control><Super>Right" ];
        "switch-windows" = [ "<Alt>Tab" ];
        "switch-windows-backward" = [ "<Shift><Alt>Tab" ];
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        "logout" = [ ];
      };

      "org/gnome/shell/extensions/system-monitor" = {
        "show-swap" = false;
      };

      "org/gnome/mutter" = {
        edge-tiling = false;
        "workspace-on-on-primary" = false;
        workspaces-only-on-primary = false;
      };

      "org/gnome/shell/apps-switcher" = {
        "current-workspace-only" = true;
      };

      "org/gnome/settings-daemon/plugins/color" = {
        "night-light-enabled" = true;
      };

      "org/gnome/desktop/interface" = {
        "clock-format" = "12h";
        "clock-show-weekday" = true;
        show-battery-percentage = true;
      };

      "org/gtk/settings/file-chooser" = {
        "clock-format" = "12h";
      };

      "org/gnome/desktop/datetime" = {
        "automatic-timezone" = true;
      };

      "org/gnome/shell/extensions/tactile" = {
        col-0 = 30;
        col-1 = 15;
        col-2 = 15;
        col-3 = 30;
        layout-2-col-2 = 0;
        layout-2-col-3 = 0;
        layout-2-row-1 = 0;
        layout-2-row-2 = 0;
        layout-3-col-3 = 0;
        layout-3-row-2 = 0;
        monitor-1-layout = 1;
        row-1 = 1;
        row-2 = 1;
      };

      "org/gnome/shell/extensions/worksets" = {
        cli-switch = "";
        debug-mode = true;
        disable-wallpaper-management = false;
        hide-app-list = false;
        isolate-workspaces = true;
        reverse-menu = false;
        show-helpers = true;
        show-notifications = false;
        show-overlay-thumbnail-labels = true;
        show-panel-indicator = true;
        show-workspace-overlay = true;
      };

      "org/gnome/system/location" = {
        enabled = true;
      };
    };

    fonts.fontconfig = {
      defaultFonts.monospace = [ "CaskaydiaCove NF" ];
      enable = true;
    };
  };
}
