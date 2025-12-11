{ pkgs, config, ... }:
{
  programs = {
    _1password-gui.enable = config.programs._1password.enable && config.services.xserver.enable;
  };

  services.displayManager.gdm.enable = config.services.xserver.enable;
  services.desktopManager.gnome.enable = config.services.xserver.enable;

  environment.gnome.excludePackages = with pkgs; [
    gnome-maps
    gnome-music
    gnome-terminal
    epiphany
    simple-scan
  ];

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        chromium
      '';
      mode = "0755";
    };
  };

  fonts.packages = with pkgs; [ nerd-fonts.caskaydia-cove ];
}
