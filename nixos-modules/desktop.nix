{
  noctalia,
  noctalia-greeter,
  ...
}@flakeInputs:
{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    noctalia-greeter.nixosModules.default
    noctalia.nixosModules.default
  ];

  options.eberman.enableDesktop = lib.mkEnableOption "Enable graphical desktop";

  config = lib.mkIf config.eberman.enableDesktop {
    programs = {
      hyprland = {
        enable = true;
        withUWSM = true;
      };

      noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };

      _1password-gui.enable = config.programs._1password.enable;
    };

    services = {
      displayManager.noctalia-greeter = {
        enable = true;
        passwordless-sync-users = [ "eberman" ];
      };

      gnome.gnome-keyring.enable = true;
    };

    security.pam.services.greetd.enableGnomeKeyring = true;

    home-manager.users.eberman.eberman.enableDesktop = true;

    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          chromium
        '';
        mode = "0755";
      };
    };

    fonts.packages = with pkgs; [ nerd-fonts.caskaydia-cove ];
  };
}
