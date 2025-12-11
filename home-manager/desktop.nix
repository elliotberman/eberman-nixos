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
        settings.theme = "catppuccin-latte";
      };

      gnome-shell = {
        enable = true;
        extensions = with pkgs.gnomeExtensions; [
          { package = launch-new-instance; }
          { package = native-window-placement; }
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

      "org/gnome/shell/wm/keybindings" = {
        "switch-to-workspace-left" = [ "<Control><Super>Left" ];
        "switch-to-workspace-right" = [ "<Control><Super>Right" ];
        "switch-windows" = [ "<Alt>Tab" ];
        "switch-windows-backward" = [ "<Shift><Alt>Tab" ];
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        "logout" = [];
      };

      "org/gnome/shell/extensions/system-monitor" = {
        "show-swap" = false;
      };

      "org/gnome/mutter" = {
        "workspace-on-on-primary" = false;
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
      };

      "org/gtk/settings/file-chooser" = {
        "clock-format" = "12h";
      };
    };

    fonts.fontconfig = {
      defaultFonts.monospace = [ "CaskaydiaCove NF" ];
      enable = true;
    };
  };
}
