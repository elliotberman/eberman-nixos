{ lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./home.nix
  ];

  boot.loader.systemd-boot.enable = true;
  users.mutableUsers = lib.mkForce true;

  services.xserver.enable = true;
  home-manager.users.eberman.eberman.enableDesktop = true;

  security.pam = {
    u2f.enable = true;
    sshAgentAuth.enable = true;
    services= {
      login.u2f.enable = true;
      sudo = {
        u2f.enable = true;
        sshAgentAuth = true;
      };
    };
  };

  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
  };

  services.udev.extraRules = ''
    ACTION=="remove",ENV{ID_BUS}=="usb",ENV{ID_MODEL_ID}=="0407",ENV{ID_VENDOR_ID}=="1050",ENV{ID_VENDOR}=="Yubico",RUN+="${lib.getExe' pkgs.systemd "loginctl"} lock-sessions"
  '';

  nixpkgs.config.allowUnfree = true;
  eberman.enableDesktop = true;

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.05";
}
