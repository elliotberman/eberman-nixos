{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  users.mutableUsers = lib.mkForce true;

  services.xserver.enable = true;
  home-manager.users.eberman.eberman.enableDesktop = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.05";
}
